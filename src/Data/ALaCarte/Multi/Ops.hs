{-# LANGUAGE TypeOperators, KindSignatures, MultiParamTypeClasses,
  FunctionalDependencies, FlexibleInstances,UndecidableInstances #-}

--------------------------------------------------------------------------------
-- |
-- Module      :  Data.ALaCarte.Ops
-- Copyright   :  3gERP, 2010
-- License     :  AllRightsReserved
-- Maintainer  :  Tom Hvitved, Patrick Bahr, and Morten Ib Nielsen
-- Stability   :  unknown
-- Portability :  unknown
--
-- This module provides operators on higher-order functors.
--
--------------------------------------------------------------------------------

module Data.ALaCarte.Multi.Ops where

import Data.ALaCarte.Multi.HFunctor
import Data.ALaCarte.Ops
import Control.Monad


infixr 5 :++:


-- |Data type defining coproducts.
data (f :++: g) (h :: * -> *) e = HInl (f h e)
                    | HInr (g h e)

instance (HFunctor f, HFunctor g) => HFunctor (f :++: g) where
    hfmap f (HInl v) = HInl $ hfmap f v
    hfmap f (HInr v) = HInr $ hfmap f v

instance (HFoldable f, HFoldable g) => HFoldable (f :++: g) where
    hfoldr f b (HInl e) = hfoldr f b e
    hfoldr f b (HInr e) = hfoldr f b e
    hfoldl f b (HInl e) = hfoldl f b e
    hfoldl f b (HInr e) = hfoldl f b e

instance (HTraversable f, HTraversable g) => HTraversable (f :++: g) where
    hmapM f (HInl e) = HInl `liftM` hmapM f e
    hmapM f (HInr e) = HInr `liftM` hmapM f e

-- |The subsumption relation.
class (sub :: (* -> *) -> * -> *) :<<: sup where
    hinj :: sub a :-> sup a
    hproj :: NatM Maybe (sup a) (sub a)

instance (:<<:) f f where
    hinj = id
    hproj = Just

instance (:<<:) f (f :++: g) where
    hinj = HInl
    hproj (HInl x) = Just x
    hproj (HInr _) = Nothing

instance (f :<<: g) => (:<<:) f (h :++: g) where
    hinj = HInr . hinj
    hproj (HInr x) = hproj x
    hproj (HInl _) = Nothing

-- Products

infixr 8 :**:

data (f :**: g) a = f a :**: g a


hfst :: (f :**: g) a -> f a
hfst (x :**: _) = x

hsnd :: (f :**: g) a -> g a
hsnd (_ :**: x) = x

-- Constant Products

infixr 7 :&&:

-- | This data type adds a constant product to a
-- signature. Alternatively, this could have also been defined as
-- 
-- @data (f :&&: a) (g ::  * -> *) e = f g e :&&: a e@
-- 
-- This is too general, however, for example for 'productTermHom'.

data (f :&&: a) (g ::  * -> *) e = f g e :&&: a


instance (HFunctor f) => HFunctor (f :&&: a) where
    hfmap f (v :&&: c) = hfmap f v :&&: c

instance (HFoldable f) => HFoldable (f :&&: a) where
    hfoldr f e (v :&&: _) = hfoldr f e v
    hfoldl f e (v :&&: _) = hfoldl f e v


instance (HTraversable f) => HTraversable (f :&&: a) where
    hmapM f (v :&&: c) = liftM (:&&: c) (hmapM f v)

-- | This class defines how to distribute a product over a sum of
-- signatures.

class HDistProd (s :: (* -> *) -> * -> *) p s' | s' -> s, s' -> p where
        
    -- | This function injects a product a value over a signature.
    hinjectP :: p -> s a :-> s' a
    hprojectP :: s' a :-> (s a :&: p)


class HRemoveP (s :: (* -> *) -> * -> *) s' | s -> s'  where
    hremoveP :: s a :-> s' a


instance (HRemoveP s s') => HRemoveP (f :&&: p :++: s) (f :++: s') where
    hremoveP (HInl (v :&&: _)) = HInl v
    hremoveP (HInr v) = HInr $ hremoveP v


instance HRemoveP (f :&&: p) f where
    hremoveP (v :&&: _) = v


instance HDistProd f p (f :&&: p) where

    hinjectP p v = v :&&: p

    hprojectP (v :&&: p) = v :&: p


instance (HDistProd s p s') => HDistProd (f :++: s) p ((f :&&: p) :++: s') where
    hinjectP p (HInl v) = HInl (v :&&: p)
    hinjectP p (HInr v) = HInr $ hinjectP p v

    hprojectP (HInl (v :&&: p)) = (HInl v :&: p)
    hprojectP (HInr v) = let (v' :&: p) = hprojectP v
                        in  (HInr v' :&: p)