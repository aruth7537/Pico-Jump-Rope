pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function title_init()
    menu = {"play","unlockables","highscores"}
    menu_index = 1
end 

function title_update()
    if(btnp(2)) menu_index -= 1
    if(btnp(3)) menu_index += 1
    menu_index = clamp(menu_index, 1, 3)

    if(btnp(4) and menu_index == 1) goto_game()
end

function title_draw()
    -- Clear screen 
    cls()

    -- Draw title
    spr(96,24,16,11,8)

    -- Me!
    print("a game by avery ruth.", 0, 120, 1)

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