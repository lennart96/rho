module Expr(Expr(..)) where

import Data.List (intersperse)

type Name = String

data Expr = Var Name            -- a
          | Rho Expr Expr       -- a -> b
          | App Expr Expr       -- a * b
          | Struc [Expr]        -- a , b
          | Null                -- null
          | Con String [Expr]   -- Pair a b

instance Show Expr where
    showsPrec _ Null        = showString "null"
    showsPrec _ (Var s)     = showString s
    showsPrec _ (Rho e1 e2) = showString $ concat ["(", show e1, " -> ", show e2, ")"]
    showsPrec _ (App e1 e2) = showString $ concat ["(", show e1, " ",    show e2, ")"]
    showsPrec _ (Con c e)   = showString $ "(" ++ unwords (c:map show e) ++ ")"
    showsPrec _ (Struc e)   = showString $ "(" ++ unwords (intersperse "," $ map show e) ++ ")"
