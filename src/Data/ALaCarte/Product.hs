{-# LANGUAGE TypeOperators, MultiParamTypeClasses, FunctionalDependencies,
             FlexibleInstances, UndecidableInstances, RankNTypes, GADTs #-}
--------------------------------------------------------------------------------
-- |
-- Module      :  Data.ALaCarte.Product
-- Copyright   :  3gERP, 2010
-- License     :  AllRightsReserved
-- Maintainer  :  Tom Hvitved, Patrick Bahr, and Morten Ib Nielsen
-- Stability   :  unknown
-- Portability :  unknown
--
-- This module defines products on signatures.
--
--------------------------------------------------------------------------------

module Data.ALaCarte.Product
    ( (:&:) (..),
      DistProd (..),
      RemoveP (..),
      liftP,
      liftP',
      stripP,
      productTermHom,
      constP,
      project'
    )where

import Data.ALaCarte.Term
import Data.ALaCarte.Sum
import Data.ALaCarte.Ops
import Data.ALaCarte.Algebra

import Control.Monad




{-| This function transforms a function with a domain constructed from
a functor to a function with a domain constructed with the same
functor but with an additional product. -}

liftP :: (RemoveP s s') => (s' a -> t) -> s a -> t
liftP f v = f (removeP v)


{-| This function transforms a function with a domain constructed from
a functor to a function with a domain constructed with the same
functor but with an additional product. -}

liftP' :: (DistProd s' p s, Functor s, Functor s')
       => (s' a -> Cxt h s' a) -> s a -> Cxt h s a
liftP' f v = let (v',p) = projectP v
             in constP p (f v')
    
{-| This function strips the products from a term over a
functor whith products. -}

stripP :: (Functor f, RemoveP g f, Functor g) => Cxt h g a -> Cxt h f a
stripP = applySigFun removeP


productTermHom :: (DistProd f p f', DistProd g p g', Functor g, Functor g') 
            => TermHom f g -> TermHom f' g'
productTermHom alg f' = constP p (alg f)
    where (f,p) = projectP f'


{-| This function annotates each sub term of the given term
with the given value (of type a). -}

constP :: (DistProd f p g, Functor f, Functor g) 
       => p -> Cxt h f a -> Cxt h g a
constP c = applySigFun (injectP c)


{-| This function is similar to 'project' but applies to signatures
with a product which is then ignored. -}
-- bug in type checker? below is the inferred type, however, the type checker
-- rejects it.
-- project' :: (RemoveP f g, f :<: f1) => Cxt h f1 a -> Maybe (g (Cxt h f1 a))
project' v = liftM removeP $ project v