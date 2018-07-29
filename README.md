# ATS

This is a collection of several Haskell packages for use with the
[ATS](http://ats-lang.org/) language.

## Goals

The following are goals of the libraries and tools contained herein:

  * Make handling ATS code in Haskell easy

  * Make building ATS easy

  * Make dependency resolution for ATS packages easy

  * Make building Haskell with ATS dependencies easy

  * Make building ATS with Haskell dependencies easy
  
As of writing, building ATS code in Haskell is quite smooth, package management
is unfortunately maladroit, and handling ATS code in Haskell is mostly
manageable.

## Tools

* [ats-pkg](ats-pkg/README.md): package management
* [ats-format](ats-format/README.md): automated formatter
* [hs2ats](hs2ats/README.md): convert Haskell types to ATS types
* [language-ats](language-ats/README.md): Haskell parser & pretty-printer for ATS

More to come!

## Contents

```
-------------------------------------------------------------------------------
 Language             Files       Lines         Code     Comments       Blanks
-------------------------------------------------------------------------------
 Alex                     2         784          676           16           92
 Bash                     1           8            6            0            2
 Cabal                   10         834          790            0           44
 Cabal Project            1          35           30            0            5
 Dhall                    4         518          452            0           66
 Happy                    1        1009          863           34          112
 Haskell                 54        5450         4447          220          783
 Justfile                 1          56           44            0           12
 Markdown                23         841          610            0          231
 TeX                      1          66           46            0           20
 TOML                     1           3            3            0            0
 YAML                     4         182          166            0           16
-------------------------------------------------------------------------------
 Total                  103        9786         8133          270         1383
-------------------------------------------------------------------------------
```
