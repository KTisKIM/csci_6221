#########################################################
#########################################################
#   Team: Team Julia                                    #
#   Members: Qicheng Chen / JiaHua Hu / Keuntae Kim     #
#            / Harsha Talapaka / Anh Nguyen             #
#   Course: CSCI 6221 - 11                              #
#   Professor: Walt Melo                                #
#                     < Project >                       #
#########################################################
#########################################################
using DataStructures

###########
# Display #
###########
WIDTH = 800
HEIGHT = 600
side_bar = 200
BACKGROUND = colorant"#B2E684"

#####################################
# Default info for the Snake(Actor) #
#####################################
snake_x = (WIDTH - side_bar) / 2 + side_bar
snake_y = HEIGHT / 2
snake_color = colorant"black"
snake_size = 10
snake_head = Rect(
    0, 0, snake_size, snake_size
)

snake_head_lastpos = (0, 0)
snake_body = Queue{Rect}()  # Snake vector for storing snake body

##############################
# Default info for the apple #
##############################
# apple_x = 0
# apple_y = 0
# apple_color = colorant"red"
# apple_size = snake_size
# apple = Rect(0, 0, snake_size, snake_size)

apple = Actor("apple")
apple.position = Rect((0, 0), (snake_size, snake_size))

##################################
# Default info for the obstacles #
##################################
obstacles = []

#################
# Side Info Bar #
#################
side_info_bar = Rect(0, 0, side_bar, HEIGHT)

#################
# Other Variables #
#################
score = 0
gamepause = false
gameover = false
gamestart = false

###############
# Snake moves #
###############
dx = 0
dy = snake_size


##########
# Button #
##########
menu_page = 1
level_num = 1

new_game_button1 = Actor("button_new_game1")
new_game_button1.pos = (30, 200)
exit_button1 = Actor("button_exit1")
exit_button1.pos = (30, 300)
new_game_button2 = Actor("button_new_game2")
new_game_button2.pos = new_game_button1.pos
exit_button2 = Actor("button_exit2")
exit_button2.pos = exit_button1.pos

easy_button1 = Actor("button_easy1")
easy_button1.pos = (30, 200)
medium_button1 = Actor("button_medium1")
medium_button1.pos = (30, 250)
hard_button1 = Actor("button_hard1")
hard_button1.pos = (30, 300)
back_button1 = Actor("button_back1")
back_button1.pos = (30, 350)
easy_button2 = Actor("button_easy2")
easy_button2.pos = easy_button1.pos
medium_button2 = Actor("button_medium2")
medium_button2.pos = medium_button1.pos
hard_button2 = Actor("button_hard2")
hard_button2.pos = hard_button1.pos
back_button2 = Actor("button_back2")
back_button2.pos = back_button1.pos

new_game_button = new_game_button1
exit_button = exit_button1
easy_button = easy_button1
medium_button = medium_button1
hard_button = hard_button1
back_button = back_button1


#########################################
# Draw actors (Snake, Apple, Obstacles) #
#########################################
function draw()
    """
    Draw all game objects every frame including snake, apple, obstacles, buttons
    """
    # Draw Snake
    draw(snake_head, snake_color, fill=true)
    for s in snake_body
        draw(s, snake_color, fill=true)
    end

    # Apple
    # draw(apple, apple_color, fill=true)
    draw(apple)

    # Draw obstacles
    for o in obstacles
        # draw(o, colorant"black", fill=true)
        draw(o)
    end

    # Draw info bar
    draw(Rect(0, 0, side_bar, HEIGHT), colorant"gray", fill=true)

    if gameover == true
        gg = TextActor("GAME OVER", "snakegame";
            font_size = 24, color = [255, 0, 0, 0]
        )
        replay = TextActor("Click to Play Again", "snakegame";
            font_size = 36, color = Int[0, 0, 255, 0]
        )
        gg.pos = (10, 30)
        draw(gg)
        replay.pos = (((WIDTH - side_bar)/2), HEIGHT/2)
        draw(replay)
    end
    score_label = "Score"
    score_label_actor = TextActor(score_label, "snakegame";
        font_size = 20, color = Int[0, 0, 0, 0]
    )
    score_val_actor = TextActor(lpad(score, 10, '0'), "snakegame";
        font_size = 14, color = Int[0, 0, 0, 0]
    )
    score_label_actor.pos = (10, 50)
    score_val_actor.pos = (10, 70)
    draw(score_label_actor)
    draw(score_val_actor)

    # Render buttons
    if menu_page == 1
        draw(new_game_button)
        draw(exit_button)
    elseif menu_page == 2
        draw(easy_button)
        draw(medium_button)
        draw(hard_button)
        draw(back_button)
    end


    # score Pause message
    if gamepause == false
        disp = ""
    else
        pause = TextActor("PAUSE","snakegame";
            font_size = 80, color = Int[0, 0, 204, 255]
        )
        pause.pos = (((WIDTH - side_bar)/2), (HEIGHT/2))
        draw(pause)
    end
end


update_snake_length! = (snake_body::Queue{Rect}, snake_head_lastpos, snake_size) -> 
                            enqueue!(snake_body, Rect(snake_head_lastpos, (snake_size, snake_size)))


function spawn_apple()
    """
    Spawn apple at random position
    Cannot overlap with snake or obstacles
    """
    global apple
    is_valid_pos = false
    
    while !is_valid_pos
        global x, y
        is_valid_pos = true
        x = rand(side_bar:snake_size:WIDTH - snake_size)  # Spawn at border will result in invisible apple
        y = rand(0:snake_size:HEIGHT - snake_size)  # Spawn at border will result in invisible apple
        
        for o in obstacles
            if o.x == x && o.y == y
                is_valid_pos = false
                # println("Not valid pos!")
            end
        end
        for s in snake_body
            if s.x == x && s.y == y
                is_valid_pos = false
                println("Not valid pos!")
            end
        end
        if snake_head.x == x && snake_head.y == y
            is_valid_pos = false
            # println("Not valid pos!")
        end
    end

    apple.x = x
    apple.y = y
    # println("WIDTH: $WIDTH, HEIGHT: $HEIGHT")
    # println("New apple pos: $x, $y")
end


function update_snake_pos!(snake_head, snake_head_lastpos, snake_body::Queue{Rect}, dx, dy)
    """
    Update snake position, also check if snake has 
    * reached beyond border, if go ouside border, snake head appears on the other side of the map
    * collided with apple, increase snake length and regenerate apple position
    * collided with obstacles, game over
    """
    global score, gameover
    snake_head_lastpos = (snake_head.x, snake_head.y)
    snake_head.x += dx
    snake_head.y += dy
    update_snake_length!(snake_body, snake_head_lastpos, snake_size)

    # Check if reach border
    #  if border is reached and no obstacles, 
    #  snake head should appear on another end
    if snake_head.x == WIDTH
        snake_head.x = side_bar
    end
    if snake_head.x < side_bar
        snake_head.x = WIDTH - snake_size
    end
    if snake_head.y == HEIGHT
        snake_head.y = 0
    end

    if snake_head.y < 0
        snake_head.y = HEIGHT - snake_size
    end

    # Check collision
    # If collide with apple, don't dequeue 
    #   spawn new apple
    if collide(snake_head, apple)  
        play_sound("eat-apple")
        spawn_apple()
        score += 100
    else
        dequeue!(snake_body)
    end
    
    for o in obstacles
        if collide(snake_head, o)
            play_sound("collide")
            gameover = true
        end
    end

    for s in snake_body
        if collide(snake_head, s)
            play_sound("collide")
            gameover = true
        end
    end
end


function update()
    """
    Game loop
    """
    if gamepause || gameover || !gamestart
        return
    end

    update_snake_pos!(snake_head, snake_head_lastpos, snake_body, dx, dy)
    sleep(0.05)
end

#######
# Map #
#######
function build_map()
    """
    Build map from text files in ./maps/:
    '*' represents Space
    '#' represents Obstacle
    '\$' represents Actor initial position
    '@' represents Apple initial position
    """
    global WIDTH, HEIGHT, obstacles, snake_head, snake_head_lastpos, apple
    println("$(@__DIR__)/maps/level$level_num.txt")
    file = open("$(@__DIR__)/maps/level$level_num.txt")
    
    h = 0
    w = 0
    for line in eachline(file)
        w = length(line)
        h += 1

        if '#' in line
            for (i, c) in enumerate(line)
                if c == '#'  # Obstacle found
                    o = Actor("obstacle")
                    o.pos = ((i-1)*snake_size + side_bar, (h-1)*snake_size)
                    o.position = Rect(o.pos, (snake_size, snake_size))
                    push!(obstacles, o)
                end
            end
        end

        if '\$' in line
            for (i, c) in enumerate(line)
                if c == '\$'  # Actor found
                    snake_head.x = (i-1)*snake_size + side_bar
                    snake_head.y = (h-1)*snake_size
                    snake_head_lastpos = (snake_head.x, snake_head.y)
                end
            end
        end

        if '@' in line
            for (i, c) in enumerate(line)
                if c == '@'  # Apple found
                    apple.x = (i-1)*snake_size + side_bar
                    apple.y = (h-1)*snake_size
                end
            end
        end
    end
    WIDTH = w * snake_size + side_bar
    HEIGHT = h * snake_size
    update_snake_pos!(snake_head, snake_head_lastpos, snake_body, dx, dy)
    update_snake_length!(snake_body, snake_head_lastpos, snake_size)
end


function reset()
    """
    Reset game objects and rebuild game map
    """
    global WIDTH, HEIGHT, side_bar, score, dx, dy, snake_head, snake_head_lastpos, snake_body, gameover, gamepause, obstacles

    WIDTH = 800
    HEIGHT = 600
    side_bar = 200

    gameover = false
    gamepause = false
    score = 0
    dx = 0
    dy = 10

    # Reset the snake's position and body
    snake_head.x = 0
    snake_head.y = 0
    snake_head_lastpos = (0, 0)
    snake_body = Queue{Rect}()
    apple_x = 0
    apple_y = 0
    obstacles = []
    build_map()
end

#########################
# Keyboard Interactions #
#########################
function on_key_down(g::Game, key)
    global dx, dy, gamepause
    if key == Keys.UP
        if dy == 0
            dx = 0
            dy = -snake_size
        end
    end

    if key == Keys.DOWN
        if dy == 0
            dx = 0
            dy = snake_size
    
        end
    end

    if key == Keys.LEFT
        if dx == 0
            dx = -snake_size
            dy = 0
        end
    end

    if key == Keys.RIGHT
        if dx == 0
            dx = snake_size
            dy = 0
        end
    end

    if key == Keys.ESCAPE
        gamepause = !gamepause
    end

end


######################
# Mouse Interactions #
######################
function on_mouse_down(g::Game, pos)
    """
    Called when mouse is clicked, change button image to gray
    Mouse down listener only changes button appearance
    Triggered functions are in mouse up listener
    """
    global new_game_button, exit_button, easy_button, medium_button, hard_button, back_button
    if gameover == true
        reset()
    end

    if menu_page == 1
        if new_game_button.pos[1] <= pos[1] <= new_game_button.pos[1] + new_game_button.position.w &&
            new_game_button.pos[2] <= pos[2] <= new_game_button.pos[2] + new_game_button.position.h
            new_game_button = new_game_button2
        end

        if exit_button.pos[1] <= pos[1] <= exit_button.pos[1] + exit_button.position.w &&
            exit_button.pos[2] <= pos[2] <= exit_button.pos[2] + exit_button.position.h
            exit_button = exit_button2
        end
    elseif menu_page == 2

        if easy_button.pos[1] <= pos[1] <= easy_button.pos[1] + easy_button.position.w &&
            easy_button.pos[2] <= pos[2] <= easy_button.pos[2] + easy_button.position.h
            easy_button = easy_button2
        end

        if medium_button.pos[1] <= pos[1] <= medium_button.pos[1] + medium_button.position.w &&
            medium_button.pos[2] <= pos[2] <= medium_button.pos[2] + medium_button.position.h
            medium_button = medium_button2
        end

        if hard_button.pos[1] <= pos[1] <= hard_button.pos[1] + hard_button.position.w &&
            hard_button.pos[2] <= pos[2] <= hard_button.pos[2] + hard_button.position.h
            hard_button = hard_button2
        end

        if back_button.pos[1] <= pos[1] <= back_button.pos[1] + back_button.position.w &&
            back_button.pos[2] <= pos[2] <= back_button.pos[2] + back_button.position.h
            back_button = back_button2
        end
    end
end

function on_mouse_up(g::Game, pos)
    """
    Called when mouse is released, change button image back to original
    * If cursor is inside new game button, start new game
    * If cursor is inside exit button, exit game
    """
    global new_game_button, exit_button, gamestart, menu_page, easy_button, medium_button, hard_button, back_button, level_num
    if menu_page == 1
        # When new game button is clicked, render easy, medium, hard, back buttons
        if new_game_button.pos[1] <= pos[1] <= new_game_button.pos[1] + new_game_button.position.w &&
            new_game_button.pos[2] <= pos[2] <= new_game_button.pos[2] + new_game_button.position.h
            menu_page = 2
        end

        if exit_button.pos[1] <= pos[1] <= exit_button.pos[1] + exit_button.position.w &&
            exit_button.pos[2] <= pos[2] <= exit_button.pos[2] + exit_button.position.h
            exit()
        end

        new_game_button = new_game_button1
        exit_button = exit_button1
    elseif menu_page == 2
        if easy_button.pos[1] <= pos[1] <= easy_button.pos[1] + easy_button.position.w &&
            easy_button.pos[2] <= pos[2] <= easy_button.pos[2] + easy_button.position.h
            gamestart = true
            level_num = 1
            reset()
        end

        if medium_button.pos[1] <= pos[1] <= medium_button.pos[1] + medium_button.position.w &&
            medium_button.pos[2] <= pos[2] <= medium_button.pos[2] + medium_button.position.h
            gamestart = true
            level_num = 2
            reset()
        end

        if hard_button.pos[1] <= pos[1] <= hard_button.pos[1] + hard_button.position.w &&
            hard_button.pos[2] <= pos[2] <= hard_button.pos[2] + hard_button.position.h
            gamestart = true
            level_num = 3
            reset()
        end

        if back_button.pos[1] <= pos[1] <= back_button.pos[1] + back_button.position.w &&
            back_button.pos[2] <= pos[2] <= back_button.pos[2] + back_button.position.h
            menu_page = 1
        end

        easy_button = easy_button1
        medium_button = medium_button1
        hard_button = hard_button1
        back_button = back_button1
    end

    
    
end
