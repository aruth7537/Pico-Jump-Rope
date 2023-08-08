pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function highscore_init()
    hs_x = 24
    hs_y = 8
    hs_sep = 10
    highscore_colors = {8,10,11,11,12,12,13,2}
    highscore_characters = " abcdefghijklmnopqrstuvwxyz0123456789._"
    highscore_table = {{{1, 1, 1}, 0}, {{1, 1, 1}, 0}, {{1, 1, 1}, 0}, {{1, 1, 1}, 0}, {{1, 1, 1}, 0}, {{1, 1, 1}, 0}, {{1, 1, 1}, 0}, {{1, 1, 1}, 0}}
    highscore_table_default = {{{2, 11, 19}, 1000}, {{4, 16, 15}, 900}, {{5, 4, 1}, 800}, {{11, 26, 1}, 700}, {{12, 14, 14}, 600}, {{2, 2, 2}, 500}, {{2, 2, 2}, 400}, {{2, 2, 2}, 300}}

    total_coins_collected = 0
    total_deaths = 0
    
    load_highscores()
end

function highscore_update()
    if(btnp(4)) then
        save_highscores()
        goto_title()
    end
end 

function highscore_draw()

    cls()
      
    print("highscores", hs_x+24, hs_y, 8)

    -- Draw the table
    for i = 1, 8 do
        local v1 = highscore_table[i][1][1]
        local v2 = highscore_table[i][1][2]
        local v3 = highscore_table[i][1][3]
        local score = tostr(highscore_table[i][2]).."0"
        local name = convert_to_name(v1, v2, v3)
        local draw_y = hs_y + (i*hs_sep)
        local c = highscore_colors[i]
        local substr = "th"
        if(i==1)substr = "st"
        if(i==2)substr = "nd"
        if(i==3)substr = "rd"
        print(i..substr, hs_x, draw_y, c)
        print(name, hs_x+20, draw_y, c)
        print(score, hs_x+64, draw_y, c)
    end 

    print("coins collected: "..total_coins_collected, hs_x, hs_y+92)
    print("total deaths: "..total_coins_collected, hs_x+12, hs_y+100)


    -- local v1 = highscore_table[2][1][1]
    -- local v2 = highscore_table[2][1][2]
    -- local v3 = highscore_table[2][1][3]
    -- print(convert_to_name(v1,v2,v3), 0, 0)
    -- print(tostr(#highscore_characters), 0, 8)
end

function convert_to_name(_v1, _v2, _v3)
    return highscore_characters[_v1]..highscore_characters[_v2]..highscore_characters[_v3]
end 

function set_highscore(_pos, _score, _v1, _v2, _v3)
    add(highscore_table, {{_v1, _v2, _v3}, _score}, _pos)
    del(highscore_table, highscore_table[9])
end 

function is_highscore(_score) -- Returns index or -1 if no highscore
    local val = -1
    for i = 1, 8 do
        if(_score>=highscore_table[9-i][2]) then
            val =  9-i
        end 
    end 
    return val
end 

function save_highscores()

    -- Save High Score table 
    for i=1, 8 do
        local v1 = highscore_table[i][1][1]
        local v2 = highscore_table[i][1][2]
        local v3 = highscore_table[i][1][3]
        local score = highscore_table[i][2]
        local name_data = compress40( v1, v2, v3)
        dset(i-1, name_data)
        dset(i+7, score)
    end 

    --Save Deaths and coins
    dset(16,total_coins_collected)
    dset(17,total_deaths)
end 

function load_highscores()

    -- Load highscore table
    if(dget(7) == 0) then 
        highscore_table = highscore_table_default
        save_highscores()
    else
        for i=1, 8 do
            local score = dget(i+7)
            printh(score)
            local name_data = dget(i-1)
            local name_table = decompress40(name_data)
            printh(name_table[1])
            printh(name_table[2])
            printh(name_table[3])
            set_highscore(i, score, name_table[1], name_table[2], name_table[3])
        end 
    end 
    
    -- Load Deaths and Coins 
    total_coins_collected = dget(16)
    total_deaths = dget(17)
end 