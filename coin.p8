pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function coin_init()
    coins = {}
    -- Coin Variables
	coin_sounds = {11,17,18,19,20}
    add_new_coin(80,36)
    add_new_coin(40,36)
    next_coin_x = 32+rnd(32)
    next_coin_y = 36+rnd(32)
    next_coin_anim = {49,50}
    next_coin_anim_index = 1
    next_coin_anim_speed = 5
end

function add_new_coin(_x,_y)
    add(coins, {
        x=_x,
        y=_y,
        bx=0,
        by=0,
        bw=6,
        bh=6,
        animation = {32, 33, 34, 33},
        animation2 = {50, 49, 48, 48},
        anim_index = 1,
        anim_speed = 3,
        anim_timer = 0,
        is_picked_up = 0,
        picked_up_x = 0,
        picked_up_y = 0,
        dist_pickup = 0,
        draw=function(self)
            if(self.is_picked_up == 0) then
                spr(self.animation[self.anim_index], self.x, self.y) 
            elseif(self.is_picked_up == 1) then
                spr(self.animation2[self.anim_index], self.x, self.y)
            end
            --print(self.anim_index, self.x+8, self.y+8)
        end,
        update=function(self)
            -- If the coin is not picked up 
            if(self.is_picked_up == 0) then
                -- Animtation 
                self.anim_timer += 1
                if(self.anim_timer >= self.anim_speed) then
                    self.anim_timer = 0
                    self.anim_index += 1
                    if(self.anim_index > count(self.animation)) self.anim_index = 1
                end
                -- Collision with player
                if(overlap(player, self)) then 
                    player_consecutive_score += 1
                    -- Incorporate the number of jumps taken minus 1 so we don't count the first jump
                    local score = player_consecutive_score --+ clamp(player_consecutive_jumps-1, 0, 2)
                    -- Play coin pickup 
                    sfx(17, -1, clamp((score-1)%10, 0, 9)*3, 3)
                    -- Increase Score 
                    increase_score(score)
                    -- Spawn VFX 
                    spawn_score_vfx(self.x, self.y, score)
                    -- Set Double Jump
                    player_double_jump = true

                    -- Spawn us a new coin
                    --spawn_new_coin()
                    add_new_coin(next_coin_x, next_coin_y)
                    if(next_coin_x > 64) then
                        next_coin_x = 32+rnd(32)
                        next_coin_y = 36+rnd(32)
                    else
                        next_coin_x = 64+rnd(32)
                        next_coin_y = 36+rnd(32)
                    end

                    -- Set Variables
                    self.is_picked_up = 1
                    self.anim_index = 1
                    self.picked_up_x = self.x
                    self.picked_up_y = self.y
                    self.dist_pickup = distance(self.picked_up_x, self.picked_up_y, game_stage_ui_x, game_stage_ui_y)

                end 
            -- If the coin has been picked up
            elseif(self.is_picked_up == 1) then
                -- Lerp to the location
                local dist_current = distance(self.x , self.y, game_stage_ui_x, game_stage_ui_y)
                local frame = flr((dist_current/self.dist_pickup)*3)+1
                self.anim_index = frame
                self.x = smooth_approach(self.x, game_stage_ui_x, 0.1)
                self.y = smooth_approach(self.y, game_stage_ui_y, 0.1)
                if(dist_current < 5) del(coins, self)
            end 
        end
    })
end

function spawn_new_coin()
    if(player.x+player.bw/2 > 64) then
        add_new_coin(32+rnd(32), 36+rnd(32))
    else
        add_new_coin(64+rnd(32), 36+rnd(32))
    end
end

-- Spawn Score
function spawn_score_vfx(_x, _y, _score,_vsp)
	vsp = _vsp or -1
    score_col = {5, 13, 6, 7, 15, 14, 8, 10, 9, 2}
    score_col_index = min(flr(_score/10)+1, 10) 
	add_new_vfx(_x, _y, 0, vsp, 0, 0.05, tostr(_score).."0", 30, 5, score_col[score_col_index] )
end
