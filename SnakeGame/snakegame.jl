# Screen Resolution
WIDTH = 800
HEIGHT = 600
BACKGROUND = colorant"white"

side_info_bar = 200

# Snake(Actor)
snake_x = (WIDTH - side_info_bar) / 2 + side_info_bar
snake_y = HEIGHT / 2
snake_size = 30
snake_color = colorant"blue"

text_actor = TextActor("Snake Game", "snakegame", font_size=72, color=[0, 0, 0, 0])
text_actor.pos = (100, 200)

function update()
    nothing
end

function draw()
    draw(text_actor)
end

