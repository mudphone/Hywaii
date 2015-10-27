# Hywai‘i

This is my attempt at implementing μKanren in [Hy].

All credit for [μKanren to Jason Hemann and Daniel P. Friedman (clearly explained in their paper)][muKanren paper], and for [miniKanren] to Daniel P. Friedman, William E. Byrd and Oleg Kiselyov (see their book [The Reasoned Schemer]).

Much appreciation to Bodil Stokke for explaining things clearly in her talk:
[μKanren: Running the Little Things Backwards, EuroClojure, Barcelona, Spain, 25 June 2015][talk at EuroClojure].

## μKanren Relational Programming Basics, with Hy
In ["How to Become a Hacker,"][hacker-howto] Eric Raymond explains that "Lisp is worth learning" to "make you a better programmer... even if you never actually use Lisp itself a lot." With [Hy], a fun Lisp powered by—and bi-directionally interoperable with—Python, we'll explore the μKanren relational logic system without leaving Python's comfy surroundings.

### Why Lisp?
The Lisp family of languages has inspired features which have found their way into Python and many other languages. Are you interested in Lisp, but unwilling to give up your investment in Python’s vast ecosystem? With [Hy], and the magical [Python AST], you can have it all: call [Hy] from Python, and Python from [Hy], learn some Lisp, and keep the Python tools you’ve come to love. [Hy] extends your reach into Lisp’s five-decade long heritage, while remaining interoperable with Python.

### What is this?
This is an implementation of a relational logic programming system, μKanren, a minimalist version of [miniKanren].

I’m not an expert on any of these things, just interested in hacking on fun tools and learning about new things. I’ve found [Hy] to be a unique opportunity to explore Python internals and data science libraries, while also playing to the strengths of Python.

This μKanren implementation in [Hy] is heavily inspired by [Bodil Stokke’s Clojure implementation] and [talk at EuroClojure] and reading ["μKanren: A Minimal Functional Core for Relational Programming," by Jason Hemann and Daniel P. Friedman][muKanren paper].

### I don't understand how any of this works.
It's kind of tough to understand what relational programming is just by reading someone's website. But there are a lot of good online resources for learning about how to use μKanren. Once you understand what it's for, you can dive into how it's built.

Generally useful:
* Everything on the [miniKanren] website

Helped me understand how to use relational programming:
* Will Byrd's [miniKanren uncourse]
* [The Reasoned Schemer] book, by Daniel P. Friedman, William E. Byrd and Oleg Kiselyov
* [Code from The Reasoned Schemer]

Helped me understand how it works:
* [Bodil Stokke's Clojure implementation] of μKanren
* The [muKanren paper], by Jason Hemann and Daniel P. Friedman
* The [muKanren repo] for the paper

### License
GNU GENERAL PUBLIC LICENSE, see LICENSE file
(Due to use of code from Hydiomatic)

[hacker-howto]: http://www.catb.org/esr/faqs/hacker-howto.html
[Hy]: http://hylang.org
[Python AST]: https://docs.python.org/3.5/library/ast.html
[miniKanren]: http://minikanren.org
[Bodil Stokke’s Clojure implementation]: https://github.com/bodil/microkanrens/blob/master/mk.clj
[talk at EuroClojure]: https://www.youtube.com/watch?v=2e8VFSSNORg
[muKanren paper]: http://webyrd.net/scheme-2013/papers/HemannMuKanren2013.pdf
[muKanren repo]: https://github.com/jasonhemann/microKanren
[miniKanren uncourse]: https://www.youtube.com/playlist?list=PLO4TbomOdn2cks2n5PvifialL8kQwt0aW
[The Reasoned Schemer]: http://mitpress.mit.edu/books/reasoned-schemer
[Code from The Reasoned Schemer]: https://github.com/miniKanren/TheReasonedSchemer