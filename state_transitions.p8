pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function goto_game()
    game_init()
    update_state = game_update
    draw_state = game_draw   
end 

function goto_title()
    update_state = title_update
    draw_state = title_draw
end 

function goto_score_entry(_score, _index) 
    score_entry_init(_score, _index)
    update_state = score_entry_update
    draw_state = score_entry_draw
end

function goto_highscore()
    update_state = highscore_update
    draw_state = highscore_draw
end 