# Hywai‘i

This is my attempt at implementing μKanren in Hy.
All credit for μKanren to Jason Hemann and Daniel P. Friedman:
[http://webyrd.net/scheme-2013/papers/HemannMuKanren2013.pdf](http://webyrd.net/scheme-2013/papers/HemannMuKanren2013.pdf)

Much appreciation to Bodil Stokke for explaining things clearly in her talk:
μKanren: Running the Little Things Backwards
EuroClojure, Barcelona, Spain, 25 June 2015.
[https://www.youtube.com/watch?v=2e8VFSSNORg](https://www.youtube.com/watch?v=2e8VFSSNORg)

## μKanren Relational Programming Basics, with Hy
In "How to Become a Hacker," Eric Raymond explains that "Lisp is worth learning" to "make you a better programmer... even if you never actually use Lisp itself a lot." With Hy, a fun Lisp powered by—and bi-directionally interoperable with—Python, we'll explore the μKanren relational logic system without leaving Python's comfy surroundings.

### Why Lisp?
The Lisp family of languages has inspired features which have found their way into Python and many other languages. Are you interested in Lisp, but unwilling to give up your investment in Python’s vast ecosystem? With [Hy], and the magical [Python AST], you can have it all: call [Hy] from Python, and Python from [Hy], learn some Lisp, and keep the Python tools you’ve come to love. [Hy] extends your reach into Lisp’s five-decade long heritage, while remaining interoperable with Python.

### What is this?
This is an implementation of a relational logic programming system, μKanren, a minimalist version of [miniKanren].

I’m not an expert on any of these things, just interested in hacking on fun tools and learning about new things. I’ve found [Hy] to be a unique opportunity to explore Python internals and data science libraries, while also playing to the strengths of Python.

This μKanren implementation in [Hy] is heavily inspired by [Bodil Stokke’s Clojure implementation] and [talk at EuroClojure] and reading ["μKanren: A Minimal Functional Core for Relational Programming," by Jason Hemann and Daniel P. Friedman][muKanren paper].

### License
GNU GENERAL PUBLIC LICENSE, see LICENSE file
(Due to use of code from Hydiomatic)

[Hy]: http://hylang.org
[Python AST]: https://docs.python.org/3.5/library/ast.html
[miniKanren]: http://minikanren.org
[Bodil Stokke’s Clojure implementation]: https://github.com/bodil/microkanrens/blob/master/mk.clj
[talk at EuroClojure]: https://www.youtube.com/watch?v=2e8VFSSNORg
[muKanren paper]: http://webyrd.net/scheme-2013/papers/HemannMuKanren2013.pdf