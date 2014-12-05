module Eval(reduce) where

import Control.Monad (liftM2)

import Expr

reduce :: Expr -> Expr
reduce t@(Var _)            = t
reduce t@(Rho _ _)          = t
reduce t@Null               = t
reduce t@(Struc _)          = t
reduce t@(Con _ _)          = t
reduce   (App e e')         = reduceApp e e'

reduceApp :: Expr -> Expr -> Expr
reduceApp (Var e) e'        = App (Var e) e'
reduceApp Null _            = Null
reduceApp (App a b) c       = reduceApp (reduceApp a b) c
reduceApp (Struc es) e      = Struc (map (`reduceApp` e) es)
reduceApp (Con e es) e'     = Con e (es ++ [reduce e'])
reduceApp (Rho pat e) e'    = maybe Null
                            ( reduce . flip (foldl (.) id . map substitute) e)
                            $ match pat e'


substitute :: (String, Expr) -> Expr -> Expr
substitute _ Null           = Null
substitute (n, s) t@(Var e) | n == e = s
                            | otherwise = t
substitute t (Rho p e)      = Rho (substitute t p) (substitute t e)
substitute t (App e e')     = App (substitute t e) (substitute t e')
substitute t (Struc es)     = Struc (map (substitute t) es)
substitute t (Con n es)     = Con n (map (reduce . substitute t) es)


type Match = Maybe [(String, Expr)]

zipMatch :: [Expr] -> [Expr] -> Match
zipMatch = (foldl (liftM2 (++)) (Just []) .). zipWith match

-- first argument is pattern
match :: Expr -> Expr -> Match
match Null Null                 = Just []
match (Var a) b                 = Just [(a, b)]
match (Struc es) (Struc es')    | length es == length es' = zipMatch es es'
match (Con e es) (Con e' es')   | e == e' && length es == length es' = zipMatch es es'
match p t@(App _ _)             = match p (reduce t)
match p@(App _ _) t             = match (reduce p) t
match _ _                       = Nothing

