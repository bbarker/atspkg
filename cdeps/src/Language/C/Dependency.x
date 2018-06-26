{
{-# OPTIONS_GHC -fno-warn-unused-imports #-}
module Language.C.Dependency ( getIncludes
                             , getCDepends
                             , getAll
                             ) where

import Data.Foldable (fold)
import Data.List (groupBy, group, sort)
import Data.Maybe (fromMaybe)
import Control.Monad.IO.Class
import System.Directory (doesFileExist)
import Data.Bool (bool)
import qualified Data.Text.Lazy as TL
import Data.Text.Lazy.Encoding (decodeUtf8)
import qualified Data.ByteString.Lazy as BSL
import System.FilePath (takeDirectory)
import System.Environment (lookupEnv)
import Control.Monad

}

%wrapper "monad-bytestring"

$special_char = [\\ntrba\"]
$inner_char = [^\\]

@esc_char = \\ $special_char
@string = \" (@esc_char | $inner_char)* \"

@include = "#include" | "#include" $white+ \\\n

tokens :-

    $white+                      ;
    "//".*                       ;

    "/*"                         { \_ _ -> nested_comment }

    @include                     { \_ _ -> alex Include }
    @string                      { tok (\_ s -> alex (StringTok (TL.unpack (decodeUtf8 s)))) }

    $printable                   ;

{

data Token = Include
           | StringTok String
           | End

tok f (p,_,s,_) len = f p (BSL.take len s)

alex :: a -> Alex a
alex = pure

alexEOF :: Alex Token
alexEOF = pure End

-- | Given a 'ByteString' containing C, return a list of filepaths it @#include@s.
getIncludes :: BSL.ByteString -> Either String [FilePath]
getIncludes = fmap extractDeps . lexC

-- TODO file name??
nested_comment :: Alex Token
nested_comment = go 1 =<< alexGetInput

    where go :: Int -> AlexInput -> Alex Token
          go 0 input = alexSetInput input *> alexMonadScan
          go n input =
            case alexGetByte input of
                Nothing -> err input
                Just (c, input') ->
                    case c of
                        42 ->
                            case alexGetByte input' of
                                Nothing -> err input'
                                Just (47,input_) -> go (n-1) input_
                                Just (_,input_) -> go n input_
                        47 ->
                            case alexGetByte input' of
                                Nothing -> err input'
                                Just (c',input_) -> go (addLevel c' $ n) input_
                        _ -> go n input'

          addLevel c' = bool id (+1) (c'==42)

          err (pos,_,_,_) =
            let (AlexPn _ line col) = pos in
                alexError ("Error in nested comment at line " ++ show line ++ ", column " ++ show col)

extractDeps :: [Token] -> [FilePath]
extractDeps [] = []
extractDeps (Include:StringTok s:xs) = toInclude s : extractDeps xs
extractDeps (_:xs) = extractDeps xs

toInclude :: String -> FilePath
toInclude = tail . init

lexC :: BSL.ByteString -> Either String [Token]
lexC = flip runAlex loop

loop :: Alex [Token]
loop = do
    tok' <- alexMonadScan
    case tok' of
        End -> pure []
        _ -> (tok' :) <$> loop

includes' :: BSL.ByteString -> [FilePath]
includes' = either error id . getIncludes

split :: String -> [String]
split = filter (/= ":") . groupBy g
    where g ':' _ = False
          g _ ':' = False
          g _ _   = True

-- | Get any filepaths that were @#include@-ed in a C source file.
getCDepends :: MonadIO m
            => [FilePath] -- ^ Directories to search in
            -> FilePath -- ^ Path to C source file
            -> m [FilePath]
getCDepends incls src = liftIO $ do
    contents <- BSL.readFile src
    envPath <- fromMaybe "" <$> lookupEnv "C_INCLUDE_PATH"
    let incl = includes' contents
        dir = takeDirectory src
        allDirs = dir : incls ++ split envPath
    filterM doesFileExist ((++) <$> allDirs <*> incl)

-- | Get transitive dependencies of a C source file.
getAll :: MonadIO m
       => [FilePath] -- ^ Directories for included header/source files
       -> FilePath -- ^ File name
       -> m [FilePath]
getAll incls src = do
    deps <- getCDepends incls src
    level <- traverse (getAll incls) deps
    let rmdups = fmap head . group . sort
        next = rmdups (fold (deps : level))
    pure $ bool next deps (null level)

}
