using DataStructures

###########
# Display #
###########
WIDTH = 800
HEIGHT = 600
side_info_bar = 200
BACKGROUND = colorant"#B2E684"

#####################################
# Default info for the Snake(Actor) #
#####################################
snake_x = (WIDTH - side_info_bar) / 2 + side_info_bar
snake_y = HEIGHT / 2
snake_size = 10
snake_color = colorant"blue"

snake_head = Rect(
    0, 0, snake_size, snake_size
)
snake_head_lastpos = (0, 0)
snakebody = Queue{Rect}()  # Snake vector for storing snake body, first item is snake head
obstacles = []
apple = Rect(0, 0, snake_size, snake_size)

dx = 0
dy = 10


function update_snake_length!(snakebody::Queue{Rect}, snake_head_lastpos, snake_size)
    enqueue!(snakebody, Rect(snake_head_lastpos, (snake_size, snake_size)))
end


function update_snake_pos!(snake_head, snake_head_lastpos, snakebody::Queue{Rect}, dx, dy)
    """
    Update snake position, also check if snake has 
    * reached beyond border, if go ouside border, snake head appears on the other side of the map
    * collided with apple, increase snake length and regenerate apple position
    * collided with obstacles, game over
    """
    snake_head_lastpos = (snake_head.x, snake_head.y)
    snake_head.x += dx
    snake_head.y += dy
    update_snake_length!(snakebody, snake_head_lastpos, snake_size)
    dequeue!(snakebody)

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
    end
end


function draw()
    """
    Game loop
    """
    # Draw snake
    draw(snake_head, colorant"gray", fill=true)
    for s in snakebody
        draw(s, colorant"black", fill=true)
    end

    # Draw obstacles
    for o in obstacles
        draw(o, colorant"black", fill=true)
    end

    # Draw apple
    draw(apple, colorant"red", fill=true)
end


function update()
    """
    Game loop
    """
    update_snake_pos!(snake_head, snake_head_lastpos, snakebody, dx, dy)
    sleep(0.05)
end


function on_key_down(g::Game, key)
    global dx, dy
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


#################
# Main function #
#################
function main()
    build_map()
    update_snake_pos!(snake_head, snake_head_lastpos, snakebody, dx, dy)
    update_snake_length!(snakebody, snake_head_lastpos, snake_size)
end

main()
