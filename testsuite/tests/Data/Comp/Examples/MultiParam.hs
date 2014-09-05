{-# LANGUAGE TypeOperators #-}
module Data.Comp.Examples.MultiParam where

import Examples.MultiParam.FOL as FOL

import Data.Comp.MultiParam
import Data.Comp.MultiParam.FreshM (Name)

import Test.Framework
import Test.Framework.Providers.HUnit
import Test.HUnit
import Test.Utils





--------------------------------------------------------------------------------
-- Test Suits
--------------------------------------------------------------------------------

tests = testGroup "Parametric Compositional Data Types" [
         testCase "FOL" folTest
        ]


--------------------------------------------------------------------------------
-- Properties
--------------------------------------------------------------------------------

folTest = show (foodFact7 :: INF Name TFormula) @=? "(Person(x1) and Food(x2)) -> (Food(Skol2(x1)) or Person(Skol6(x2)))\n" ++
          "(Person(x1) and Food(x2)) -> (Food(Skol2(x1)) or Eats(Skol6(x2), x2))\n" ++
                                                                                        "(Person(x1) and Eats(x1, Skol2(x1)) and Food(x2)) -> (Person(Skol6(x2)))\n" ++
                                                                                        "(Person(x1) and Eats(x1, Skol2(x1)) and Food(x2)) -> (Eats(Skol6(x2), x2))"