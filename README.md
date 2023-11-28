# CSCI 6221
Team Julia in CSCI 6221-11 (Fall 2023 @ The George Washington University)
* Technologies Used
  * Julia Programming Language
  * GameZero.jl

# HOW TO RUN
* Install `GameZero` and `DataStructures` in your Julia programming language.
* In Julia IDE, type
  > `using GameZero` \
  > `rungame("SnakeGame/snakegame.jl")`

# HOW TO PLAY
* Arrow keys(Up, Down, Left, Right) to move the actor(Snake).
* ESC key to pause the game.
* All the information that user will need be in the side menu bar. (Choose the game mode, Restart the game, exit the game, etc.)

# BASIC FEATURES
* 2 Types of Game Mode
  * Classic Mode (Infinite mode without any obstacles)
    * Can keep playing the game until the actor(Snake) dies.
  * Difficulty Mode
    * User can choose the difficulty levels of the game.
    * It will include different maps based on the chosen difficulty.

# TO-DO
- [x] Need to display the side menu bar and the game display at the same time.
  - [x] Currently, window size needs to be 800x600, and the side menu bar should be on the left side with the size of 200x600.
- [x] Game over when snake collide with obstacles
- [x] Increase snake length when collide with apple
- [x] Regenerate apple when snake collide with apple
- [x] Score display
- [x] Game over display
- [x] Main menu
  - [x] Start game button
  - [x] Exit game button
  - [x] Different difficulty levels and different maps
- [x] Game pause and display when press a key
