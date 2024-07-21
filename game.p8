pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function game_init()

    data_deaths = 0
	data_flag = { 0, 0, 0, 0, 0, 0, 0, 0} 
	data_high_score = 0

	coin_init()
	cans_init()
	birds_init()
	vfx_init()
	player_init()
	lightningbolt_init()
	fire_init()
	renew_ground(true)
	--add_new_can(32, 76, 1, 1)

	game_message = ""
	game_message_life = 0

	-- Game Variables
	game_score = 0
	game_score_end = 100
	game_score_end_max = 400
	game_score_new_zero = 0
	game_has_highscore = false
	game_has_highscore_index = 8
	game_lives = 3
	game_stage = 1
	game_stage_ui_x = 92
	game_stage_ui_y = 7
	game_stage_has_changed = true
	game_stage_title = "stage 1 act 1"
	game_coins = 0
	game_coins_to_next_stage = 8
	game_coins_to_next_stage_max = 16
	game_scale = 1
	game_scale_target = 1
	game_script = nil
	game_script_timer = -1
	game_data_index = 0
	game_time = 0

	-- Extra life
	extra_life_highest_combo_number = 0
	extra_life_combo_number = 0

	game_data_length = 0
	game_data_next = 0

	-- Game Sky flashing nonsense

	game_sky_flash = false
	game_map_pal_index = 1
	game_map_pal = {{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}, -- 1 Default 
					{1,2,5,4,5,6,7,8,8,10,11,12,13,14,15}, -- 2 Slightly Darker
					{0,0,1,2,5,6,7,8,5,10,11,12,13,14,15}, -- 3 Night Time
					{1,1,1,1,1,1,1,1,1,1 ,1 ,1 ,1 ,1 ,1 }, -- 4 I don't remember	
					{1,2,9,4,5,6,7,8,10,10,11,12,13,14,15}, -- 5 Orange Morning
					{1,2,8,4,5,6,7,8,8,10,11,12,13,14,15}, -- 6 Blood
					{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- 7 Blackout
					{1,2,14,4,5,6,7,8,15,10,11,12,13,14,15}, -- 8 Pink 
					{1,2,7,4,4,6,7,8,7,10,11,12,13,14,15}, -- 9 Ice 
					{1,2,5,4,4,6,7,8,5,10,11,12,13,14,15}, -- 10 Darker Ice
					{0,0,5,2,5,6,7,8,5,10,11,12,13,14,15}, -- 11 Night time ice
					} 
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
	game_over_restart_delay = 15

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

	clouds_active = false
	clouds_y = -24
	clouds_y_target = -24
	clouds_x = 0
	clouds_speed = 0

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
	hide_rope = false

	add_new_coin(80,36)
    add_new_coin(40,36)
	s_flower(78, floor_y-8)
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
	--debug_print()
	--print(is_highscore(game_score), 64, 0)

	-- Draw Clouds
	if (player_wind != 0) then
		clouds_speed = approach(clouds_speed, sgn(player_wind), 0.05)
	else
		clouds_speed = approach(clouds_speed, 0.1, 0.05)
	end 
	clouds_x += clouds_speed
	clouds_y_target = -24
	if(clouds_active) clouds_y_target = 0
	clouds_y = smooth_approach(clouds_y, clouds_y_target, 0.1)
	if(clouds_x < -8) clouds_x+=8
	if(clouds_x > 8) clouds_x-=8
	for i = 0, 19 do
		spr(15, clouds_x+i*8-8, clouds_y)
		spr(31, clouds_x+i*8-8, clouds_y+8)
		spr(47, clouds_x*0.5+i*8-8, clouds_y+16)
	end

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
			col = 8
        else
			rope_passed_center = false
		end
            
        -- Finally draw the pixel
		if(hide_rope == false) then 
			pset(i + rope_start_x, d_y_capped, col)
		elseif( col == 8) then 
			pset(i + rope_start_x, d_y_capped, col)
		end 
		--pset(i + rope_start_x, d_y_capped-1, col_gradient[col_index-1])
		--pset(i + rope_start_x, d_y_capped+1, 1)
    end
    
    -- Draw the player in front of the rope 
    if(dist < 0)then 
        draw_player()
        draw_game_over()
    end

	--- Color the Map
	pal(game_map_pal[game_map_pal_index], 0)
	if(game_sky_flash) pal({0,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7},0) -- flash the sky
	
	--- Draw the map
	map(0,0,0,0,16,16)
	pal()

	-- Reset Camera shake before hud is drawn
	camera()
    
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

	-- if(player_consecutive_score % 25 == 0) then
	-- 	extra_life_combo_number+=1
	-- 	if(extra_life_combo_number > extra_life_highest_combo_number) then
	-- 		extra_life_highest_combo_number+=1
	-- 		add_new_coin(60,25,true)
	-- 	end 
	-- end
end

-- Increase Coins
function increase_coin(_value)
	local value = _value or 1
	game_coins += value
	total_coins_collected+=1
	if(game_coins >= game_coins_to_next_stage) then
		increase_stage() 
	end
end

-- Increase Stage
function increase_stage()
	game_stage += 1
	game_coins = 0
	game_coins_to_next_stage = min(game_coins_to_next_stage+2, game_coins_to_next_stage_max)
	sfx(14, 3)
	game_stage_has_changed = true
end 

function s_sprinkle()
	if(time()%0.25 == 0) then
		add_new_vfx( rnd(140), -8, -2, 5, 0.1, 0, {45}, 15, 1)
		add_new_vfx( rnd(140), -24, -2, 5, 0.1, 0, {45}, 18, 1)
		add_new_vfx( rnd(140), -48, -2, 5, 0.1, 0, {45}, 21, 1)
	end 
end

function s_rain()
	add_new_vfx( rnd(140), -8, -2, 5, 0.1, 0, {45}, 15, 1) 
end

function s_snow() 
	if(time()%0.25 == 0) add_new_vfx( rnd(140), -rnd(8), 0.2, 1, 0, 0, {155,156,157,156}, 80, 10) 
end 

function s_leaves(_x) 
	if(time()%0.5 == 0) add_new_vfx(_x, rnd(32), sgn(_x*-1)*3 + sgn(_x*-1)*rnd(2), 1+rnd(1), -0.05, 0, {91,92,107}, 160, rnd({2,3,4}))
end 

function s_leaves_pink() 
	if(time()%0.5 == 0) add_new_vfx(rnd(128), -8, 0, 1+rnd(1), 0, 0, {108,123,124}, 160, rnd({2,3,4}))
end 

function s_tortle()
	add_new_bird(-16, 72, -0.25, {{59,60,23}, {59,60,23}, {61, 62, 23}, {61, 62, 23}}, 2, 3, 8, 4, 21) -- Tortle
end 

function s_tortle_shell(_x)
	add_new_bird(_x, 73, sgn(_x)*-1, {{23,203,23}, {23,204,23}, {23, 205, 23}, {23, 203, 23}, {23, 206, 23}, {23, 207, 23}, {23, 203, 23}}, 7, 3, 8, 4, 21) -- Tortle
end 

function s_bird(_x)
	add_new_bird(_x, 24+rnd(36), sgn(_x)*rnd({1.2, 1, 0.8, 0.6}))
end 

function s_lightning_strike(_time, _firelife)
	local firelife = _firelife or -1
	if(time()%_time == 0) add_new_can(player.x, 80, 0, 3, firelife)
end

function renew_ground(_plantFlower)
	for i = 0, 16 do
		if(mget(i, 10) == 24 and rnd(5) <= 1 and _plantFlower == true) then
			s_flower(i*8, floor_y-8)
		end
		mset(i, 10, 8)
	end 
end

function s_flower(_x, _y)
	add_new_vfx(_x, _y, 0, 0, 0, 0, {139, 140, 141, 142, 143}, 0, 300+rnd(60), flower_step)
end 

function flower_step(self)
	if (col_with_player(self.x, self.y+2) or col_with_player(self.x+7, self.y+2)) then
		if (self.anim_index == 1) then
			del(vfx, self)
		elseif (self.anim_index == 2) then
			self.animation = {158,158,158,158,158}
			self.anim_index = 4
			set_message("you've killed it!", 60)
			sfx(12, 3)
		elseif (self.anim_index == 3) then
			s_one_up()
			player_double_jump = true
			self.animation = {159,159,159,159,159}
			self.anim_index = 4
			sfx(20, 3)
			set_message("1up!", 60)
		end 
	end 
end

function s_clear_fire()
	for b in all (fire) do
		b:clear()
	end
end 

function s_can(_x, _time, _type, _extraspeed)
	local extraspeed = _extraspeed or 0
	if(time()%_time == 0) add_new_can(_x, 76, sgn(_time*-1)*rnd({1,1.1,1.2,1.3,1.4,1.5})+extraspeed, _type)
end 

function s_one_up()
	add_new_coin(60, 16, true) 
end 

function s_conditional_one_up()
	if(game_lives <= 2) s_one_up()
end 

-- Spawn things
function spawn_things()
	if    (game_stage == 1 ) then 

	elseif(game_stage == 2 ) then
		if(game_stage_has_changed) then
			set_message("stage 1 act 2", 60, true)
		end
		s_can(-8, 5, 1)

	elseif(game_stage == 3 ) then 
		if(game_stage_has_changed) set_message("stage 1 act 3", 60, true)
		s_can(-8, 5, 1)
		clouds_active=true

	elseif(game_stage == 4 ) then
		if(game_stage_has_changed) then 
			set_message("stage 2 act 1", 60, true)
			s_conditional_one_up()
			s_tortle()
		end 
		player_wind = 0

	elseif(game_stage == 5 ) then
		if(game_stage_has_changed) set_message("stage 2 act 2", 60, true)
		player_wind = 0.125
		s_can(-8, 3, 1, 1)
		s_leaves(-8)
		game_map_pal_index = 2 

	elseif(game_stage == 6 ) then
		if(game_stage_has_changed) set_message("stage 2 act 3", 60, true)
		player_wind = -0.125
		s_can(136, 3, 2, -1)
		s_leaves(136)

	elseif(game_stage == 7 ) then
		if(game_stage_has_changed) then
			set_message("stage 3 act 1", 60, true)
			s_conditional_one_up()
		end 
		game_map_pal_index = 3 
		player_wind = 0
		s_sprinkle()
		--if(game_stage_has_changed) add_new_lightningbolt(-32, 1)
		s_lightning_strike(5)

	elseif(game_stage == 8 ) then
		if(game_stage_has_changed) then
			set_message("stage 3 act 2", 60, true)
			s_clear_fire()
		end
		s_rain()
		s_lightning_strike(4)

	elseif(game_stage == 9 ) then
		if(game_stage_has_changed) then
			set_message("stage 3 act 3", 60, true)
			player_wind = -0.125
			s_clear_fire()
		end
		s_rain() 
		s_rain()
		s_lightning_strike(3)
		s_leaves(136)

	
	elseif(game_stage == 10 ) then
		if(game_stage_has_changed) then
			set_message("intermission 1", 60, true)
			s_clear_fire()
		end 
		player_wind = 0
		s_sprinkle()
		game_scale_target = 0.5
		if(game_stage_has_changed) s_one_up()


	elseif(game_stage == 11 ) then
		if(game_stage_has_changed) then
			set_message("stage 4 act 1", 60, true)
			s_conditional_one_up()
			s_clear_fire()
		end 
		game_map_pal_index = 5
		clouds_active=false
		coin_spawn_w = 48
		coin_spawn_h = 48
		game_scale_target = 1.3
		--if(game_stage_has_changed) add_new_coin(64,64)
		--if(time()%5 == 0) add_new_bird(140, 24+rnd(36), rnd({1, 0.8}))	
		--s_sprinkle()
		if(time()%5 == 0) s_bird(140)

	elseif(game_stage == 12 ) then
		if(game_stage_has_changed) set_message("stage 4 act 2", 60, true)
		if(time()%5 == 0) s_bird(140)
		--player_wind = 0.125
		--s_leaves(-8)
		if(time()%4 == 0) s_tortle_shell(-16)


	elseif(game_stage == 13 ) then
		if(game_stage_has_changed) set_message("stage 4 act 3", 60, true)
		if(time()%4 == 0) s_bird(-16)
		if(time()%5 == 0) s_tortle_shell(132)
		player_wind = 0.125
		s_leaves(-8)


	elseif(game_stage == 14 ) then
		if(game_stage_has_changed) then 
			set_message("stage 5 act 1", 60, true)
 			renew_ground(true)
			s_bird(140)
			player_wind = 0
			game_map_pal_index = 8
			s_conditional_one_up()
		end
		s_leaves_pink()

	elseif(game_stage == 15 ) then
		if(game_stage_has_changed) then
			set_message("stage 5 act 2", 60, true)
			s_tortle() 
		end
		if(time()%5 == 0) s_bird(140)
		s_leaves_pink()

	elseif(game_stage == 16 ) then
		if(game_stage_has_changed) set_message("stage 5 act 3", 60, true)
		s_can(136, 3, 2, -1)
		s_can(-8, 3, 1, 1)
		if(time()%5 == 0) s_bird(140)
		s_leaves_pink()

	elseif(game_stage == 17 ) then
		if(game_stage_has_changed) then
			set_message("stage 6 act 1", 60, true)
			s_tortle()
			clouds_active = true
			game_map_pal_index = 9
			player_friction = 0
			s_conditional_one_up()
		end
		s_snow() 
		if(time()%5 == 0) s_bird(140)

	elseif(game_stage == 18 ) then
		if(game_stage_has_changed) then
			set_message("stage 6 act 2", 60, true)
		end 
		s_snow() 
		s_snow() 
		s_can(-8, 5, 1)
		if(time()%5 == 0) s_bird(140)

	elseif(game_stage == 19 ) then
		if(game_stage_has_changed) then
			set_message("stage 6 act 3", 60, true)
			s_tortle()
		end 
		s_snow() 
		s_snow() 
		s_snow() 
		s_snow() 
		s_can(-8, 5, 1)
		s_can(136, 3, 2, -1)
		if(time()%5 == 0) s_bird(140)

	elseif(game_stage == 20 ) then
		if(game_stage_has_changed) then
			set_message("Intermission 2", 60, true)
			game_map_pal_index = 11
			game_scale_target = 0.5
			s_one_up()
		end 
	elseif(game_stage == 21 ) then
		if(game_stage_has_changed) then
			set_message("nine", 60, true)
			game_scale_target = 1.6
			s_conditional_one_up()
			add_new_lightningbolt(0)
			add_new_lightningbolt(120)
		end 
	elseif(game_stage == 22 ) then
		if(game_stage_has_changed) then
			set_message("eight", 60, true)
			game_scale_target = 1.7
			add_new_lightningbolt(8)
			add_new_lightningbolt(112)
		end 
	elseif(game_stage == 23 ) then
		if(game_stage_has_changed) then
			set_message("seven", 60, true)
			game_scale_target = 1.8
			add_new_lightningbolt(16)
			add_new_lightningbolt(104)
		end 
	elseif(game_stage == 24 ) then
		if(game_stage_has_changed) then
			set_message("six", 60, true)
			game_scale_target = 1.9
			add_new_lightningbolt(24)
			add_new_lightningbolt(96)
			game_map_pal_index = 10
		end 
	elseif(game_stage == 25 ) then
		if(game_stage_has_changed) then
			set_message("five", 60, true)
			game_scale_target = 2
			add_new_lightningbolt(32)
			add_new_lightningbolt(88)
		end 
	elseif(game_stage == 26 ) then
		if(game_stage_has_changed) then
			set_message("four", 60, true)
			add_new_lightningbolt(40)
			add_new_lightningbolt(80)
		end 
	elseif(game_stage == 27 ) then
		if(game_stage_has_changed) then
			set_message("three", 60, true)
			add_new_lightningbolt(48)
			add_new_lightningbolt(72)
		end 
	elseif(game_stage == 28 ) then
		if(game_stage_has_changed) then
			set_message("two", 60, true)
			add_new_lightningbolt(56)
			add_new_lightningbolt(64)
		end 
	elseif(game_stage == 28 ) then
		if(game_stage_has_changed) then
			set_message("one", 60, true)
		end 
	elseif(game_stage >= 29 ) then
		if(game_stage_has_changed) then
			set_message("zero", 60, true)
			game_scale_target +=0.1
		end 
	end 
end

function set_message(_msg, _life, _change_title)
	game_message = _msg
	game_message_life = _life
	if(_change_title == true) game_stage_title = _msg
end

function game_message_update()
	if(game_message_life > 0) then
		game_message_life -= 1
	else
		game_message = ""
	end
end

-- Game Over sub state
function step_game_over()
	if (player_is_hit == true) then 
		game_over_restart_delay -= 1
		if(game_over_restart_delay <= 0) then
			if(game_has_highscore) then
				if(btnp(4) or btnp(5)) then
					goto_score_entry(game_score, game_has_highscore_index)
				end 
			else
				if(btnp(4)) then
					save_highscores()
					game_init()
				end 

				if(btnp(5)) then
					save_highscores()
					goto_title()
				end 
			end
		end

		game_over_vsp += game_over_gravity
		game_over_logo_y += game_over_vsp
		if (game_over_logo_y > game_over_floor) then 
			if (abs(game_over_vsp) > 1) then 
				game_over_logo_y = game_over_floor
				game_over_vsp = -(game_over_vsp/2)
				sfx(3, 1)
			else
				game_over_logo_y = game_over_floor
				game_over_vsp = 0
				game_over_continue = true
			end
		end
	end 
end 

function draw_game_over()
	if (player_is_hit == true) then
		spr(64, game_over_logo_x, game_over_logo_y, game_over_w, game_over_h) 
		--if(game_over_continue) print_shadow()
		if(game_has_highscore) then
			print_shadow("new highscore!", 38, 72, 7, 1)
		else
			print_shadow("🅾️ retry  ❎ title", 32, 72, 7, 1)
		end

	end
end 