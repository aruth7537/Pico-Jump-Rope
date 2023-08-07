pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function score_entry_init(_score, _index)
    score_entry_name = {39,39,39}
    score_entry_index = 1
    wheel_index = 4
    anim = 0
    s_index = _index or 1
    new_score = _score or 1001
end

function score_entry_update() 
    anim = smooth_approach(anim, 1, 0.05)

    if(btnp(0)) then
        wheel_index -= 1
        sfx(7)
    end
    if(btnp(1)) then
        wheel_index += 1
        sfx(7)
    end
    if(wheel_index>39) wheel_index = 1
    if(wheel_index<1) wheel_index = 39
    score_entry_name[score_entry_index] = wheel_index

    if(btnp(4)) then
        if(score_entry_index >= 3) then 
            -- Save score to table
            set_highscore(s_index, new_score, score_entry_name[1], score_entry_name[2], score_entry_name[3])
            goto_highscore()
        else
            -- Finish entry
            score_entry_index+=1
            sfx(16)
        end 
    end 

    if(btnp(5)) then
        score_entry_name[score_entry_index-1] = 39
        score_entry_name[score_entry_index] = 39
        score_entry_index -= 1
        if(score_entry_index < 1) score_entry_index = 1
        sfx(12)
    end 
end

function score_entry_draw()
    cls()
    draw_score_entry(64,64)
    print(highscore_table[1][2])
    print(highscore_characters[16])
    print(tostr(count(highscore_table)))
end

function draw_score_entry(_x, _y)
    local name = highscore_characters[score_entry_name[1]]..highscore_characters[score_entry_name[2]]..highscore_characters[score_entry_name[3]]
    local offset = (score_entry_index-1) * 4
    local score_offset = #(tostr(new_score).."0") * 4

    print(name, _x-offset, _y, 7)
    draw_wheel(_x, _y, 48)


    local substr = "th"
    if(s_index==1)substr = "st"
    if(s_index==2)substr = "nd"
    if(s_index==3)substr = "rd"

    print("new "..tostr(s_index)..substr.." place score!", 0, 0, 8)
    print(tostr(new_score).."0", 128 - score_offset, 0, 7)
end

function draw_wheel(_x, _y, _r)
    local length = #highscore_characters
    local adjust = 2.25 * anim
    local r = _r * anim
    for i = 1, length do
        local col = 1 
        if(i == wheel_index) col = 7
        local dx = -(r * cos((i-wheel_index)/length + adjust))
        local dy = r * sin((i-wheel_index)/length + adjust)
        print(highscore_characters[i], _x+dx, _y+dy, col)
    end 
end 