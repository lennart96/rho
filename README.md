# Rho Calculus

An attempt at creating an evaluator for the Rho Calculus. It might not be fully
compliant (I did not read the papers in detail). Currently in a fairly stable
state. It can eval expressions like `(Pair a b -> a , Pair a b -> b) (Pair x
y)`, which would become `(x , y)`. In Haskell, that would be something like this
(with the difference that a matching failure would be an error):

```haskell
-- data Pair a = Pair a a
-- appChoice = flip (fmap . flip ($))
[\(Pair a b) -> a, \(Pair a b) -> b] `appChoice` Pair "x" "y"
```

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

It is completely untyped, so `Cons a b` is just as valid as `Cons a Nil Cons d
e Nil g`. I also added name substitution in patterns, not sure if that is in
the real calculus. At the moment is seems to give problems in more complex
expressions. Small example:

```shell
$ ./Main "(a -> a -> Eq) A A"
Right (Eq)
$ ./Main "(a -> a -> Eq) A B"
Right stk
```

More useful example:

```shell
$ ./Main "(a -> b -> (Eq->True,stk->False) ((x->x->Eq)a b)) A A"
Right (True)
$ ./Main "(a -> b -> (Eq->True,stk->False) ((x->x->Eq)a b)) A B"
Right (False)
```

