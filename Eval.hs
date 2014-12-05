module Eval(reduce) where

import Control.Monad (liftM2)

import Expr

isStk :: Expr -> Bool
isStk Stk = True
isStk _   = False

reduce :: Expr -> Expr
reduce t@(Var _)                = t
reduce t@(Rho _ _)              = t
reduce t@Stk                    = t
reduce t@(Con _ _)              = t
reduce t@(Struc es)             = t -- reduceStruc es
reduce   (App e e')             = reduceApp e e'

reduceStruc :: [Expr] -> Expr
reduceStruc []                  = Stk
reduceStruc [e]                 = e
reduceStruc es = case filter isStk es of
            []                  -> Stk
            [e']                -> e'
            es'                 -> Struc es'

reduceApp :: Expr -> Expr -> Expr
reduceApp Stk _                 = Stk
reduceApp e@(Var _) e'          = App e e'
reduceApp e@(App (Var _) _) e'  = App e e'
reduceApp (App a b) c           = reduceApp (reduceApp a b) c
reduceApp (Struc es) e          = reduceStruc $ map (`reduceApp` e) es
reduceApp (Con e es) e'         = Con e (es ++ [reduce e'])
reduceApp (Rho pat e) e'        = maybe Stk
                                ( reduce . flip (foldl (.) id . map substitute) e)
                                $ match pat e'


substitute :: (String, Expr) -> Expr -> Expr
substitute _ Stk                = Stk
substitute (n, s) t@(Var e)     | n == e = s
                                | otherwise = t
substitute t (Rho p e)          = Rho (substitute t p) (substitute t e)
substitute t (App e e')         = App (substitute t e) (substitute t e')
substitute t (Struc es)         = Struc (map (substitute t) es)
substitute t (Con n es)         = Con n (map (reduce . substitute t) es)


type Match = Maybe [(String, Expr)]

zipMatch :: [Expr] -> [Expr] -> Match
zipMatch = (foldl (liftM2 (++)) (Just []) .). zipWith match

match :: Expr -> Expr -> Match
 --   pattern      term
match Stk          Stk           = Just []
match (Var a)      b             = Just [(a, b)]
match (Struc es)   (Struc es')   | length es == length es' = zipMatch es es'
match (Con e es)   (Con e' es')  | e == e' && length es == length es' = zipMatch es es'
match p            t@(App _ _)   = match p (reduce t)
match p@(App _ _)  t             = match (reduce p) t
match _            _             = Nothing

