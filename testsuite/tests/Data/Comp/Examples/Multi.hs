{-# LANGUAGE TypeOperators #-}
module Data.Comp.Examples.Multi where

import qualified Examples.Multi.Eval as Eval
import qualified Examples.Multi.EvalM as EvalM
import qualified Examples.Multi.DesugarEval as DesugarEval
import qualified Examples.Multi.DesugarPos as DesugarPos

import Data.Comp.Multi

import Test.Framework
import Test.Framework.Providers.QuickCheck2
import Test.QuickCheck
import Test.Utils





--------------------------------------------------------------------------------
-- Test Suits
--------------------------------------------------------------------------------

tests = testGroup "Generalised Compositional Data Types" [
         testProperty "eval" evalTest,
         testProperty "evalM" evalMTest,
         testProperty "desugarEval" desugarEvalTest,
         testProperty "desugarPos" desugarPosTest
        ]


--------------------------------------------------------------------------------
-- Properties
--------------------------------------------------------------------------------

instance (HEqF f, Eq p) => HEqF (f :&: p) where
    heqF (v1 :&: p1) (v2 :&: p2) = p1 == p2 && v1 `heqF` v2

evalTest = Eval.evalEx == Eval.iConst 2
evalMTest = EvalM.evalMEx == Just (EvalM.iConst 5)
desugarEvalTest = DesugarEval.evalEx == DesugarEval.iPair (DesugarEval.iConst 2) (DesugarEval.iConst 1)
desugarPosTest = DesugarPos.desugPEx ==
                 DesugarPos.iPairP
                               (DesugarPos.Pos 1 0)
                               (DesugarPos.iSndP
                                              (DesugarPos.Pos 1 0)
                                              (DesugarPos.iPairP
                                                             (DesugarPos.Pos 1 1)
                                                             (DesugarPos.iConstP (DesugarPos.Pos 1 2) 1)
                                                             (DesugarPos.iConstP (DesugarPos.Pos 1 3) 2)))
                               (DesugarPos.iFstP
                                              (DesugarPos.Pos 1 0)
                                              (DesugarPos.iPairP
                                                             (DesugarPos.Pos 1 1)
                                                             (DesugarPos.iConstP (DesugarPos.Pos 1 2) 1)
                                                             (DesugarPos.iConstP (DesugarPos.Pos 1 3) 2)))