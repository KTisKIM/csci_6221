#########################################################
#########################################################
#   Team: Team Julia                                    #
#   Members: Qicheng Chen / JiaHua Hu / Keuntae Kim     #
#            / Harsha Talapaka / Anh Nguyen             #
#   Course: CSIC 6221 - 11                              #
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
snake_body = Queue{Rect}()  # Snake vector for storing snake body, first item is snake head

##############################
# Default info for the apple #
##############################
apple_x = 0     ### TODO
apple_y = 0     ### TODO
apple_color = colorant"red"
apple_size = snake_size
apple = Rect(
    0, 0, snake_size, snake_size
)

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

    # Draw info bar
    draw(Rect(0, 0, side_bar, HEIGHT), colorant"gray", fill=true)

    if gameover == false
        display = "Score: $score"
    else
        gg = TextActor("GAME OVER", "snakegame";
            font_size = 24, color = [255, 0, 0, 0]
        )
        display = ("Your Score: $score")
        replay = TextActor("Click to Play Again", "snakegame";
            font_size = 36, color = Int[0, 0, 255, 0]
        )
        gg.pos = (10, 30)
        draw(gg)
        replay.pos = (((WIDTH - side_bar)/2), 390)
        draw(replay)
    end
    scoring = TextActor(display, "snakegame";
        font_size = 20, color = Int[0, 0, 0, 0]
    )
    scoring.pos = (10, 50)
    draw(scoring)


    # Display Pause message
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

##############################################
# Draw a info bar / Status display for users #
##############################################
function user_interface(g::Game)
    # Side Info Bar
    # draw(snake_head, snake_color, fill=true)
    # for s in 1:length(snake_body)
    #     draw(snake_body[s], snake_color, fill=true)
    # end

    # Displaying Status
    # draw(apple, apple_color, fill=true)
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
        x = rand(side_bar:10:WIDTH - snake_size)  # Spawn at border will result in invisible apple
        y = rand(0:10:HEIGHT - snake_size)  # Spawn at border will result in invisible apple

        for o in obstacles
            if o.x == x && o.y == y
                is_valid_pos = false
                println("Not valid pos!")
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
            println("Not valid pos!")
        end
    end

    apple.x = x
    apple.y = y
    #println("WIDTH: $WIDTH, HEIGHT: $HEIGHT")
    #println("New apple pos: $x, $y")
end


function update_snake_pos!(snake_head, snake_head_lastpos, snake_body::Queue{Rect}, dx, dy)
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
    global score, gameover

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
        score += 1
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

    if gamepause || gameover
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
    file = open("$(@__DIR__)/maps/level1.txt")

    h = 1
    w = length(readline(file))
    for line in eachline(file)
        w = length(line)
        h += 1

        if '#' in line
            for (i, c) in enumerate(line)
                if c == '#'  # Obstacle found
                    push!(obstacles, Rect((i-1)*10 + side_bar, (h-1)*10, snake_size, snake_size))
                end
            end
        end

        if '\$' in line
            for (i, c) in enumerate(line)
                if c == '\$'  # Actor found
                    snake_head.x = (i-1)*10 + side_bar
                    snake_head.y = (h-1)*10
                    snake_head_lastpos = (snake_head.x, snake_head.y)
                end
            end
        end

        if '@' in line
            for (i, c) in enumerate(line)
                if c == '@'  # Apple found
                    apple.x = (i-1)*10 + side_bar
                    apple.y = (h-1)*10
                end
            end
        end
    end
    WIDTH = w * 10 + side_bar
    HEIGHT = h * 10
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


function reset()
    global WIDTH, HEIGHT, side_bar, score, dx, dy, snake_head, snake_head_lastpos, snake_body, gameover, gamepause

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
    while !isempty(snake_body)
        dequeue!(snake_body)
    end
    apple_x = 0
    apple_y = 0
    obstacles = []
    build_map()
end

function on_mouse_down(g::Game)
    if gameover == true
        reset()
    end
end

#################
# Main function #
#################
function main()
    build_map()
    update_snake_pos!(snake_head, snake_head_lastpos, snake_body, dx, dy)
    update_snake_length!(snake_body, snake_head_lastpos, snake_size)
end

main()
