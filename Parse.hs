module Parse(Parse.parse, expr) where

import Control.Applicative hiding ((<|>), many)
import Text.ParserCombinators.Parsec as Parsec

import Expr

var, nil, con :: Parser Expr
var     = (Var .). (:) <$> lower <*> many letter
nil     = Null <$ string "null"
con     = (flip Con [] .). (:) <$> upper <*> many letter

struc, rho, app, term :: Parser Expr
term    = sp $ (char '(' *> struc <* char ')') <|> nil <|> var <|> con
app     = sp $ foldl1 App <$> many1 term
rho     = sp $ app `chainr1` (Rho <$ string "->")
struc   = sp $ rho `sepBy1` char ',' >>= \xs -> return $ case xs of
                [x] -> x
                xs  -> Struc xs

sp :: Parser Expr -> Parser Expr
sp = (skipMany space *>) . (<* skipMany space)

expr :: Parser Expr
expr = struc

parse :: String -> Either ParseError Expr
parse = Parsec.parse (expr <* eof) "test"

