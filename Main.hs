module Main(main) where

import System.Environment (getArgs)

import Expr
import Eval
import Parse

main :: IO ()
main = getArgs >>= mapM_ putStrLn . fmap (show . fmap reduce . parse)

