using DataStructures



###########
# Display #
###########
WIDTH = 800
HEIGHT = 600
BACKGROUND = colorant"#B2E684"



#####################################
# Default info for the Snake(Actor) #
#####################################
snake_x = 0
snake_y = 0
snake_color = colorant"black"
snake_size = 10
snake_head = Rect(
    snake_x, snake_y, snake_size, snake_size
)

#snake_head_lastpos = (0, 0)
snake_body = Queue{Rect}()  # Snake vector for storing snake body, first item is snake head



##############################
# Default info for the apple #
##############################
#apple_x = 0     ### TODO
#apple_y = 0     ### TODO
apple_color = colorant"red"
apple_size = snake_size
apple = Rect(
    0, 0, snake_size, snake_size
)

###############
# Default obstacles #
###############
obstacles = []


###############
# Features #
###############
score = 0
gameover = false
gamepause = false




###############
# Snake moves #
###############
dx = 0
dy = 10

#########################################
# Draw actors (Snake, Apple, Obstacles) #
#########################################
function draw()
    # Draw Snake
    draw(snake_head, snake_color, fill=true)
    for s in snake_body
        draw(s, snake_color, fill=true)
    end

    # Apple
    draw(apple, apple_color, fill=true)

    # Draw obstacles
    for o in obstacles
        draw(o, colorant"black", fill=true)
    end

    if gamepause == false
        disp = ""
    else
        pause = TextActor("PAUSE","snakegame";
            font_size = 40, color = Int[0, 0, 0, 255]
        )
        pause.pos = (100, 100)
        draw(pause)
    end


    if gameover == false
        display = "Score: $score"
    else
        display = ("GAME OVER!\nYour Score: $score")
        replay = TextActor("Click to Play Again", "snakegame";
            font_size = 36, color = Int[0, 0, 255, 0]
        )
        replay.pos = (135, 390)
        draw(replay)
    end
    scoring = TextActor(display, "snakegame";
        font_size = 24, color = Int[255, 100, 0, 0]
    )
    scoring.pos = (30, 30)
    draw(scoring)
end

##############################################
# Draw a Menu bar / Status display for users #
##############################################
function user_interface(g::Game)
    # Side Menu Bar
    # draw(snake_head, snake_color, fill=true)
    # for s in 1:length(snake_body)
    #     draw(snake_body[s], snake_color, fill=true)
    # end

    # Displaying Status
    # draw(apple, apple_color, fill=true)
end



function update_snake_length!(snake_body::Queue{Rect}, snake_head_lastpos, snake_size)
    enqueue!(snake_body, Rect(snake_head_lastpos, (snake_size, snake_size)))
end


function update_snake_pos!(snake_head, snake_head_lastpos, snake_body::Queue{Rect}, dx, dy)
    global obstacles, gameover, score
    """
    Update snake position, also check if snake has
    * reached beyond border, if go ouside border, snake head appears on the other side of the map
    * collided with apple, increase snake length and regenerate apple position
    * collided with obstacles, game over
    """
    snake_head_lastpos = (snake_head.x, snake_head.y)
    snake_head.x += dx
    snake_head.y += dy
    update_snake_length!(snake_body, snake_head_lastpos, snake_size)
    dequeue!(snake_body)
    score = length(snake_body)

    # Check if reach border
    #  if border is reached and no obstacles,
    #  snake head should appear on another end
    if snake_head.x == WIDTH
        snake_head.x = 0
    end
    if snake_head.x < 0
        snake_head.x = WIDTH - snake_size
    end
    if snake_head.y == HEIGHT
        snake_head.y = 0
    end

    if snake_head.y < 0
        snake_head.y = HEIGHT - snake_size
    end

    # Check collision
    if collide(snake_head, apple)
        play_sound("ea")
        # y, fs = wavread("$(@__DIR__)/sounds/ea.wav")
        # Threads.@spawn wavplay(y, fs)
        update_snake_length!(snake_body, snake_head_lastpos, snake_size)
        apple.x, apple.y = spawn()
    end
    #gameover when head hits the obstacle
    for o in obstacles
        if collide(snake_head, o)
            gameover = true
        end
    end

    #gameover when head hits body
    for b in snake_body
        if collide(snake_head, b)
            gameover = true
        end
    end

end




function update()
    """
    Game loop
    """

    if gamepause || gameover
        return
    end

    update_snake_pos!(snake_head, snake_head_lastpos, snake_body, dx, dy)
    sleep(0.1)

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
    global WIDTH, HEIGHT, ini_x, ini_y, obstacles, snake_head, snake_head_lastpos, apple
    file = open("$(@__DIR__)/maps/level1.txt")

    h = 0
    w = length(readline(file))
    for line in eachline(file)
        w = length(line)
        h += 1

        if '#' in line
            for (i, c) in enumerate(line)
                if c == '#'  # Obstacle found
                    push!(obstacles, Rect((i-1)*10, (h-1)*10, snake_size, snake_size))
                end
            end
        end

        if '\$' in line
            for (i, c) in enumerate(line)
                if c == '\$'  # Actor found
                    snake_head.x = (i-1)*10
                    snake_head.y = (h-1)*10
                    snake_head_lastpos = (snake_head.x, snake_head.y)
                end
                ini_x = i
                ini_y = c
            end
        end

        if '@' in line
            for (i, c) in enumerate(line)
                if c == '@'  # Apple found
                    apple.x = (i-1)*10
                    apple.y = (h-1)*10
                end
            end
        end
    end
    WIDTH = w * 10
    HEIGHT = h * 10

end

#apple respawn anywhere but the snake body and obstacles
function spawn()
    global WIDTH, HEIGHT, snake_body, obstacles, snake_size
    #map size
    x = rand(20:snake_size:WIDTH-20)
    y = rand(20:snake_size:HEIGHT-20)


    #array of snake_body locations
    occupied = []
    for b in snake_body
        push!(occupied, b.x, b.y)
    end

    for o in obstacles
        push!(occupied, o.x, o.y)
    end

    if (x, y) in occupied
        spawn()
    else
        return x, y
    end


end



#########################
# Keyboard & Mouse Interactions #
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

    if key == Keys.P
        gamepause = !gamepause
    end

end

function on_mouse_down(g::Game)
    if gameover == true
        reset()
    end
end

function reset()
    global gameover, score, dx, dy, snake_head, snake_head_lastpos, snake_body

    gameover = false
    score = 0
    dx = 0
    dy = 10

    # Reset the snake's position and body
    snake_head.x = 0
    snake_head.y = 0
    snake_head_lastpos = (0, 0)
    while !isempty(snake_body)
        dequeue!(snake_body)
    end# Clear the queue to reset the snake's body
    apple_x = 0
    apple_y = 0
    obstacles = []
    build_map()
end


#################
# Main function #
#################
function main()
    build_map()
end

main()
