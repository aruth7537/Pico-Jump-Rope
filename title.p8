pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function title_init()
    menu = {"play","peepee!","poopoo!"}
    menu_index = 1
    author_string = "a game by avery ruth"
    author_string_x = 20
    author_string_y = 112
    author_string_start_timer = 90
    author_string_timer = author_string_start_timer
    animation_timer = 20
end 

function title_update()
    if(btnp(2)) menu_index -= 1
    if(btnp(3)) menu_index += 1
    menu_index = clamp(menu_index, 1, 3)

    if(btnp(4) and menu_index == 1) goto_game()
    if(btnp(4) and menu_index == 2) author_string = "poopoo!"
    if(btnp(4) and menu_index == 3) author_string = "peepee!"
    if(btnp(4)) author_string_timer = author_string_start_timer-10
end

function title_draw()
    -- Clear screen 
    cls()

    -- Draw title
    spr(96,24,16,11,8)

    -- Me!
    if(animation_timer <= 0) then
        local index = 0
        if(author_string_timer >= 0) author_string_timer-=1
        for letter in all(author_string) do 
            index += 1
            print(letter, author_string_x + index*4, author_string_y - easeInBounce((clamp(author_string_timer-index,0,author_string_start_timer))/author_string_start_timer)*-32, 1)
        end
    else
        animation_timer -= 1
    end

    -- Draw menu 
    for i=1,3 do 
        local col = 2
        if(menu_index == i) col = 7
        print(menu[i], 60, 70+i*8, col)
    end
end

function goto_game()
    update_state = game_update
    draw_state = game_draw   
end 