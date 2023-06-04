pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function title_init()
    menu = {"Play","Unlockables","Highscores"}
    menu_index = 1
end 

function title_update()
    
end

function title_draw()
    cls()
    spr(96,24,16,11,8)
end