let cfg = 
  { defaultPkgs = "https://raw.githubusercontent.com/vmchale/atspkg/master/pkgs/pkg-set.dhall"
  , path = ([] : Optional Text)
  , githubUsername = ""
  , filterErrors = False
  }

in cfg
