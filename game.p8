pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function game_init()
    data_deaths = 0
	data_flag = { 0, 0, 0, 0, 0, 0, 0, 0} 
	data_high_score = 0

	data_load()
	coin_init()
	cans_init()
	birds_init()
	vfx_init()
	player_init()
	lightningbolt_init()
	fire_init()
	add_new_can(32, 76, 1, 1)
	
	game_message = ""
	game_message_life = 0

	-- Game Variables
	game_score = 0
	game_score_end = 100
	game_score_end_max = 400
	game_score_new_zero = 0
	game_lives = 3
	game_stage = 1
	game_stage_ui_x = 92
	game_stage_ui_y = 7
	game_stage_has_changed = false
	game_coins = 0
	game_coins_to_next_stage = 4
	game_scale = 1
	game_scale_target = 1
	game_script = nil
	game_script_timer = -1
	game_data_index = 0
	game_time = 0

	game_data_length = 0
	game_data_next = 0

	game_sky_flash = false
	game_map_pal_index = 1
	game_map_pal = {{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}, -- Default Stage 1 - 4
					{1,2,2,4,5,6,7,8,9,10,11,12,13,14,15}, -- Index 2 Stage 5 - 8
					{1,1,1,1,1,1,1,1,1,1 ,1 ,1 ,1 ,1 ,1 },}
	test = distance( 50, 50, 1, 1)

	anim_frame_length = 3
	anim_counter = 0
	frame_counter = 1
	num_of_anims = count(player_jump_animations)
	num_of_frames = count(player_jump_animations[player_jump_anim_index])

	--Game Over
	game_over_logo_x = 49
	game_over_logo_y = -16
	game_over_spr = 64
	game_over_w = 4
	game_over_h = 2
	game_over_gravity = 0.25
	game_over_vsp = 0
	game_over_floor = 54
	game_over_continue = false

	-- Timer Variables 
	timer = 15.38
	timer_speed = 0.02

	-- Rope Variables 
	rope_start_x = 0
	rope_start_x_target = 0
	rope_end_x = 128
	rope_end_x_target = 128
	rope_y = 54
	floor_y = 79

	rope_length  = rope_end_x - rope_start_x
	rope_mid = rope_length/2
	rope_max = 30
	rope_rot = 0
	rope_hit_point = 1
	rope_sound_played = false 
	rope_passed_center = false

	dist = 0
	dist_last = dist
	dist_sign = sgn(dist)
	dist_last_sign = sgn(dist)

	-- Color variables
	col_gradient = {0,1,5,13,6,7}
	col_max = 6
	col_index = 1
	col = 7
	alt_color = false
end

------------
------------ UPDATE STEP 
------------

function game_update() 

	-- Setup game_stage_has_changed 
	game_stage_has_changed = false

	-- Increase game timer 
	timer += timer_speed * game_scale

	-- Increase game time
	game_time += 1
	
	-- Lerp game scale
	game_scale = lerp(game_scale, game_scale_target, 0.05)
	
	--Record previous dist
	dist_last = dist
	dist_last_sign = sgn(dist_last)
	
	-- Increase Rope Rotation
	rope_rot = sin(timer)*rope_max
	dist = cos(timer)*rope_max
	dist_sign = sgn(dist)
	
	-- Do rope hitting ground sound
	sfx_hit_ground() 
	
	-- Game script timer step 
	--step_game_script_timer()
	
	-- Player step event
	step_player() 

	-- Update all coins
	for c in all (coins) do
		c:update()
	end

	-- Update  Cans
	for c in all (cans) do
		c:update()
	end

	-- Update  birds
	for b in all (birds) do
		b:update()
	end

	-- Update  vfx
	for v in all (vfx) do
		v:update()
	end

	for v in all (lightningbolt) do
		v:update()
	end
	
	for v in all (fire) do
		v:update()
	end

	-- Spawn things
	spawn_things()

	-- Game Message DO THIS AFTER EVERYTHING 
	game_message_update()

	-- Game over step event
	step_game_over()
	
	--if (btnp(3)) game_scale -= 0.2
end

------------
------------ DRAW STEP 
------------

function game_draw()



    -- Clear the screen
    cls()

	-- Debug 
	debug_print()

	--- Color the Map
    pal(game_map_pal[game_map_pal_index], 0)
	if(game_sky_flash) pal({0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},0) -- flash the sky
	
	--- Draw the map
    map(0,0,0,0,16,16)
    pal()

	-- Draw  Cans
	for c in all (cans) do
		c:draw()
	end

    -- Draw  vfx (This is drawn in reverse order to get older objects to appear in front of new objects)
    for i = #vfx, 1, -1 do
        vfx[i]:draw()
    end

    if(dist >= 0) then
        draw_player()
        draw_game_over()
    end

    -- Draw Coin
    for c in all (coins) do
        c:draw()
    end

    -- Draw Next Coin 
    -- spr(next_coin_anim[next_coin_anim_index],next_coin_x+1,next_coin_y+1)
    -- if(game_time % next_coin_anim_speed == 0) next_coin_anim_index += 1
    -- if(next_coin_anim_index > count(next_coin_anim)) next_coin_anim_index = 1

    -- Draw  birds
    for b in all (birds) do
        b:draw()
    end

    -- Draw  Lightningbolts
    for b in all (lightningbolt) do
        b:draw()
    end

	-- Draw  fire
	for b in all (fire) do
		b:draw()
	end
	

    -- Draw the rope
    for i=0,rope_length do
        -- Calculate the y position of each pixel of rope
        d_y = rope_y+sin(i/(rope_length*2))*rope_rot
        d_y_capped = min(d_y, floor_y)
        
        -- Calculate the color of each pixel of rope
        col_index = 4
        if(dist > 18.25) col_index = col_index+1
        if(dist > 7 ) col_index = col_index+1
        if(dist <-7 ) col_index = col_index-1
        if(dist <-14) col_index = col_index-1
        if(dist <-19) col_index = col_index-1
        
        dist_from_mid = abs(i - rope_mid)
        if(dist_from_mid > 30) push_to_mid() -- 30
        if(dist_from_mid > 35) push_to_mid() -- 45
        if(dist_from_mid > 55) push_to_mid() -- 55
        
        -- Cap Col_index
        col_index = max(min(col_index, col_max), 0)
        
        -- Grab Pixel color
        if(col_index == 1) then
            -- To add depth to the darkest pixel will alternate between black and grey
            if(alt_color == true) then
                alt_color = false
                col = col_gradient[2]
            else
                alt_color = true
                col = col_gradient[1]
            end
        else
            col = col_gradient[col_index]
        end
        
        -- Checks when rope passes the center

        if( dist_sign != dist_last_sign) then
			
            -- Detect player hit
            if (col_with_player(i + rope_start_x, d_y_capped) and player_is_hit == false and player_invol_timer <=0) then
                -- Player Was hit
                player_hit()
            end 
            -- Detect if a can is hit
            for c in all (cans) do
                c:point_overlap(i + rope_start_x, d_y_capped)
            end

			if (dist_last_sign == 1) rope_passed_center = true
        else
			rope_passed_center = false
		end
            
        -- Finally draw the pixel
        pset(i + rope_start_x, d_y_capped, col)
    end
    
    -- Draw the player in front of the rope 
    if(dist < 0)then 
        draw_player()
        draw_game_over()
    end
    
    -- Draw score
    draw_hud()

    -- Draw UI 
    -- draw_stage_hud(game_stage_ui_x, game_stage_ui_y)

    -- Draw game message 
    draw_game_message()
end 

------------
------------ OTHER SHIT
------------

-- Increase Score
function increase_score(_value)
	-- Set the score amount 
	local value = _value or 1
	game_score += value

	-- Increase the score incrementally that way we can check for each stage
	-- for i = 1, value do
	-- 	game_score += 1
	-- 	--game_data_check()
	-- 	if(game_score >=  game_score_end) then
	-- 		increase_stage()
	-- 	end

	-- 	-- if(game_stage == 1) then
	-- 	-- 	if(game_score%25 == 0) game_scale_target = 1.2
	-- 	-- elseif(game_stage == 2) then
	-- 	-- 	if(game_score%50 == 0) game_scale_target = 1.4
	-- 	-- elseif(game_stage == 3) then
	-- 	-- 	if(game_score%75 == 0) game_scale_target = 1.6
	-- 	-- elseif(game_stage >= 4) then
	-- 	-- 	if(game_score%25 == 0) game_scale_target += 0.2
	-- 	-- end
	-- end
end

function increase_coin(_value)
	local value = _value or 1
	game_coins += value
	if(game_coins >= game_coins_to_next_stage) then
		increase_stage() 
	end
end

function increase_stage()
	game_stage += 1
	game_coins = 0
	game_coins_to_next_stage = min(game_coins_to_next_stage+2, 24)
	-- game_score_new_zero = game_score
	-- game_score_end += min(game_score_end+50, game_score_end_max)--min(game_score_end*2, game_score_end_max)
	sfx(14, 2)
	game_stage_has_changed = true
end 

function spawn_things()
	if(game_stage == 1) then      -- STAGE 1 
		-- Nothing
	elseif (game_stage == 2) then -- STAGE 2 
		if(game_stage_has_changed) set_message("stage 2", 60)
		if(time()%5 == 0) add_new_can(-8, 76, rnd({1,1.1,1.2,1.3,1.4,1.5}), 1) -- Red Cans

	elseif (game_stage == 3) then -- STAGE 3
		if(game_stage_has_changed) set_message("stage 3", 60)
		if(time()%5 == 0) add_new_can(136, 76, -rnd({1.1,1.2,1.3,1.4,1.5,1.6,1.7}), 2) -- Blue Cans

	elseif (game_stage == 4) then -- STAGE 4
		if(game_stage_has_changed) set_message("stage 4", 60)
		if(time()%3 == 0) add_new_can(-32, 76, rnd({1.1,1.2,1.3,1.4,1.5,1.6,1.7}), 1)  -- Red Cans
		if(time()%5 == 0) add_new_bird(140, 30+rnd(30), rnd({1, 0.9, 0.8}))	

	elseif (game_stage == 5) then -- STAGE 5 
		if(game_stage_has_changed) then
			set_message("the sky rumbles", 60)
			add_new_can(-8, 76, rnd({1.2,1.3,1.4,1.5,1.6,1.7}), 1)
			add_new_lightningbolt(0, 0)
			add_new_lightningbolt(120, 0)
			game_map_pal_index = 2 
		end 
		game_scale_target = 1.1

	elseif (game_stage == 6) then -- STAGE 6
		if(game_stage_has_changed) set_message("stage 6", 60)
		if(time()%5 == 0) add_new_can(-8, 76, rnd({1.2,1.3,1.4,1.5,1.6,1.7}), 1)
	elseif (game_stage == 7) then -- STAGE 7
		if(game_stage_has_changed) set_message("stage 7", 60)
		if(time()%5 == 0) add_new_can(-8, 76, rnd({1.2,1.3,1.4,1.5,1.6,1.7}), 1)
		if(time()%6 == 0) add_new_bird(140, 30+rnd(30), 1.2)
	elseif (game_stage == 8) then -- STAGE 8
		if(game_stage_has_changed) set_message("stage 8", 60)
		if(time()%3 == 0) add_new_can(-8, 76, rnd({1.2,1.3,1.4,1.5,1.6,1.7}), 1)
		if(time()%5 == 0) add_new_bird(140, 30+rnd(30), 1.2)
	elseif (game_stage >= 9) then
		if(game_stage_has_changed and game_stage == 9) set_message("nothing beyond this point", 60)
		if(time()%3 == 0) add_new_can(-8, 76, rnd({0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2}), 3)
		if(time()%5 == 0) add_new_bird(140, 30+rnd(30), 1.2)
		game_map_pal_index = 3 
	end 
end

function set_message(_msg, _life)
	game_message = _msg
	game_message_life = _life
end

function game_message_update()
	if(game_message_life > 0) then
		game_message_life -= 1
	else
		game_message = ""
	end
end

-- Game Over sub state

function draw_game_over()
	if (player_is_hit == true) then
		spr(64, game_over_logo_x, game_over_logo_y, game_over_w, game_over_h) 
		--if(game_over_continue) print_shadow()
	end
end 

function step_game_over()
	if (player_is_hit == true) then 
		game_over_vsp += game_over_gravity
		game_over_logo_y += game_over_vsp
		if (game_over_logo_y > game_over_floor) then 
			if (abs(game_over_vsp) > 1) then 
				game_over_logo_y = game_over_floor
				game_over_vsp = -(game_over_vsp/2)
				sfx(3)
			else
				game_over_logo_y = game_over_floor
				game_over_vsp = 0
				game_over_continue = true
			end
		end
	end 
end 
