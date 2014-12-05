# Rho Calculus

Rho Calculus in Haskell

An attempt at creating an evaluator for the Rho Calculus. It might not
be a fully compliant implementation. Currently in a fairly stable state.
It can eval expressions like
`(Pair a b -> a , Pair a b -> b) (Pair x y)`, which would become
`(x , y)`.

`Main.hs` can be used from the command line to test it:

```shell
$ ghc Main
[...]
$ ./Main "(Cons a b -> a) (Cons x Nil)"
Right x
$ ./Main "(Cons a b -> a) Nil"
Right stk
$ ./Main "("
Left [...]
```
It is completely untyped, so `Cons a b` is just as valid as `Cons a Nil Cons d e Nil g`.
I also added rewriting of patterns, not sure if that is in the real calculus:

```shell
$ ./Main "(a -> a -> Eq) A A"
Right (Eq)
$ ./Main "(a -> a -> Eq) A B"
Right stk
```


