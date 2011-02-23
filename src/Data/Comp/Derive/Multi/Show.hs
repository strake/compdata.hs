{-# LANGUAGE TemplateHaskell, TypeOperators #-}
--------------------------------------------------------------------------------
-- |
-- Module      :  Data.Comp.Derive.Multi.Show
-- Copyright   :  (c) 2011 Patrick Bahr
-- License     :  BSD3
-- Maintainer  :  Patrick Bahr <paba@diku.dk>
-- Stability   :  experimental
-- Portability :  non-portable (GHC Extensions)
--
-- Automatically derive instances of @HShowF@.
--
--------------------------------------------------------------------------------

module Data.Comp.Derive.Multi.Show
    (
     HShowF(..),
     KShow(..),
     instanceHShowF
    ) where

import Data.Comp.Derive.Utils
import Data.Comp.Multi.Functor
import Data.Comp.Multi.Algebra
import Language.Haskell.TH

{-| Signature printing. An instance @HShowF f@ gives rise to an instance
  @KShow (HTerm f)@. -}
class HShowF f where
    hshowF :: HAlg f (K String)
    hshowF = K . hshowF'
    hshowF' :: f (K String) :=> String
    hshowF' = unK . hshowF

class KShow a where
    kshow :: a i -> K String i

showConstr :: String -> [String] -> String
showConstr con [] = con
showConstr con args = "(" ++ con ++ " " ++ unwords args ++ ")"

{-| Derive an instance of 'HShowF' for a type constructor of any higher-order
  kind taking at least two arguments. -}
instanceHShowF :: Name -> Q [Dec]
instanceHShowF fname = do
  TyConI (DataD _cxt name args constrs _deriving) <- abstractNewtypeQ $ reify fname
  let args' = init args
      fArg = VarT . tyVarBndrName $ last args'
      argNames = (map (VarT . tyVarBndrName) (init args'))
      complType = foldl AppT (ConT name) argNames
      preCond = map (ClassP ''Show . (: [])) argNames
      classType = AppT (ConT ''HShowF) complType
  constrs' <- mapM normalConExp constrs
  showFDecl <- funD 'hshowF (showFClauses fArg constrs')
  return [InstanceD preCond classType [showFDecl]]
      where showFClauses fArg = map (genShowFClause fArg)
            filterFarg fArg ty x = (containsType ty fArg, varE x)
            mkShow (isFArg, var)
                | isFArg = [|unK $var|]
                | otherwise = [| show $var |]
            genShowFClause fArg (constr, args) = do 
              let n = length args
              varNs <- newNames n "x"
              let pat = ConP constr $ map VarP varNs
                  allVars = zipWith (filterFarg fArg) args varNs
                  shows = listE $ map mkShow allVars
                  conName = nameBase constr
              body <- [|K $ showConstr conName $shows|]
              return $ Clause [pat] (NormalB body) []