2048Game.hs
===========

My implementation of the 2048 game in Haskell.

### Credits
Original game is [2048 by Gabriele Cirulli](http://gabrielecirulli.github.io/2048/). Also, in order to keep the game as accurate as possible, I looked in the JavaScript source to find the probability distribution of the new tiles that pop up (it's `[(2, 0.9), (4, 0.1)]`, by the way).

### How to Use
If you have a Haskell interpreter, load the file into it, then call `main`. It should display the initial board. To make a move, type in any string starting with one of the matching characters as shown below, then press Enter:

direction | string starts with
-- | --
left | `'l'` or `'L'`
right | `'r'` or `'R'`
up | `'u'` or `'U'`
down | `'d'` or `'D'`

If you type something else, the game won't continue and you will need to type a valid move. The game also won't continue if you input a move that won't change the board (like the original game does). The resulting board, including the next randomly placed tile, should print out below it. Continue until there are no more moves, after which the function will end and your interpreter should take control again. Note that your interpreter must support lazily evaluating input from `interact`/`getContents` in order for the game to function properly (which any good Haskell interpreter should); although I guess you could try giving your input all at once using [Ideone](http://ideone.com/) or something, if you're feeling lucky.