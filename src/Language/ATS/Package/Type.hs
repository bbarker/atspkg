{-# OPTIONS_GHC -fno-warn-unused-top-binds -fno-warn-orphans #-}

{-# LANGUAGE DeriveAnyClass             #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE ScopedTypeVariables        #-}
{-# LANGUAGE StandaloneDeriving         #-}
{-# LANGUAGE TemplateHaskell            #-}

module Language.ATS.Package.Type ( -- * Types
                                   Pkg (..)
                                 , Dependency (..)
                                 , Bin (..)
                                 , Version (..)
                                 , Constraint (..)
                                 , TargetPair (..)
                                 -- * Lenses
                                 , dirLens
                                 ) where

import           Control.Lens
import           Data.Binary           (Binary (..))
import           Development.Shake.ATS
import           Dhall

-- TODO constraints?

data Constraint = Constraint { pkgName :: Text
                             , lower   :: Maybe Version
                             , upper   :: Maybe Version
                             }
                deriving (Eq, Show, Generic, Interpret)

deriving newtype instance Interpret Version

-- TODO make this a map from versions to tarballs etc.
-- | Type for a dependency
data Dependency = Dependency { libName    :: Text -- ^ Library name, e.g.
                             , dir        :: Text -- ^ Directory we should unpack to
                             , url        :: Text -- ^ Url pointing to tarball
                             , libVersion :: Version
                             }
                deriving (Eq, Show, Generic, Interpret, Binary)

makeLensesFor [("dir", "dirLens")] ''Dependency

-- | This is just a tuple, except I can figure out how to use it with Dhall.
data TargetPair = TargetPair { hs  :: Text
                             , ats :: Text
                             } deriving (Eq, Show, Generic, Interpret, Binary)

data Bin = Bin { src    :: Text -- ^ Source file (should end with @.dats@)
               , target :: Text -- ^ Binary to be built
               , libs   :: [Text] -- ^ Libraries to link against (e.g. @[ "pthread" ]@)
               , hsDeps :: [Text] -- ^ Haskell source files to link against final generated ATS
               , hs2ats :: [TargetPair] -- ^ List of sources and targets for @hs2ats@
               , gc     :: Bool -- ^ Whether to use the garbage collector
               }
         deriving (Show, Eq, Generic, Interpret, Binary)

-- | Data type associated with @atspkg.dhall@ file.
data Pkg = Pkg { bin          :: [Bin] -- ^ List of binaries to be built
               , test         :: [Bin] -- ^ List of test suites
               , man          :: Maybe Text -- ^ Optional (markdown) manpages to be converted using @pandoc@.
               , version      :: Version -- ^ Library version
               , compiler     :: Version -- ^ Compiler version
               , dependencies :: [Dependency] -- ^ List of dependencies
               , clib         :: [Dependency] -- ^ List of C dependencies
               , ccompiler    :: Text -- ^ The C compiler we should use
               , cflags       :: [Text] -- ^ List of flags to pass to the C compiler
               , atsSource    :: [Text] -- ^ Directory containing ATS source to be compile to C.
               , cDir         :: Text -- ^ Directory for generated C.
               }
         deriving (Show, Eq, Generic, Interpret, Binary)
