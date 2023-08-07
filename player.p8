pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- Step player function
function player_init()
	--Player Variables
	player = {
		x = 61,
		y = 72,
		bx = 0,
		by = 0,
		bw = 6,
		bh = 7
	}
    
	player_bottom = player.y + player.bh
	player_vspd = 0
	player_hspd = 0


    player_hspd_max_normal = 2
    player_hspd_max_best = 3
	player_hspd_max = 2

    player_move_speed_normal = 0.25
    player_move_speed_best = 0.75
	player_move_speed = 0.15

	player_jumpspeed = 4
    player_consecutive_jumps = 0
    player_consecutive_jump_timer = 0
    player_consecutive_jump_timer_limit = 3
    player_consecutive_score = 0
    player_double_jump = false
    player_double_jump_flash = false
    player_double_jump_color = 12
	player_friction = 0.5
	player_air_friction = 0.1
	player_gravity = 0.25
	player_invol_timer = 60

    jump_forgivness_timer = 0
	jump_forgivness = 5 -- Frames of forgivness we give the player
    jump_pressed = false 
	jump_released = false

	player_on_ground = true 
	player_is_hit = false

	--Player Jump animations
	player_spr = 1
	player_jump_anim_index = 1
	player_jump_animations = {
		{2},
		{16},
		{18,19,20,21}
	}

    player_noescape_message = false
end 

function step_player()	
    
    -- Tick down invol timer
    player_invol_timer = max(player_invol_timer-1, 0) 
    
    -- Handle pressing the jump button 
    if(btnp(4)) then 
        jump_forgivness_timer = jump_forgivness
    end 

    -- Reduce jump_forgivness_timer
    jump_forgivness_timer = max(jump_forgivness_timer-1, 0) -- Don't let it fall below 0
    
    -- If player is on ground
    if (player_on_ground == true) then

        -- Consecutive Jumps 
        player_consecutive_jump_timer += 1
        if(player_consecutive_jump_timer > player_consecutive_jump_timer_limit) player_consecutive_jumps = 0

        -- Jump 
        if (jump_forgivness_timer > 0 and player_is_hit == false) then  
            player_on_ground = false
            player_vspd = -player_jumpspeed
            player_consecutive_jumps += 1
            player_jump_anim_index = clamp(player_consecutive_jumps, 1, 3)
            if(player_consecutive_jumps <= 2) sfx(3+player_jump_anim_index)
            if(player_consecutive_jumps > 2) sfx(13)
            if(btn(1)) player_hspd = player_hspd_max
            if(btn(0)) player_hspd = -player_hspd_max
            add_new_vfx(player.x+2, player.y+player.bh-1, player_hspd/2, player_vspd/2, 0.1, 0.05, {84,85}, 0, 10)
        end

        -- Friction
        player_hspd = approach(player_hspd, 0, player_friction)

    -- If player is not on ground
    else 
        -- Gravity
        player_vspd += player_gravity
        
        -- Control our fall speed
        if(btn(4) == false  and jump_released == false) then
            jump_released = true
            if(player_vspd < 0) player_vspd *= 0.5
        end

        --Double Jump 
        if(btn(4) == true and jump_released == true and player_double_jump == true and player_bottom < floor_y-4) then
            player_vspd = -player_jumpspeed
            jump_released = false
            player_double_jump = false
            player_consecutive_jumps = 3
            sfx(13)
            add_new_vfx(player.x+2, player.y+player.bh-1, 1, 0, -0.01, 0.02, {84,85}, 0, 10)
            add_new_vfx(player.x+2, player.y+player.bh-1, -1, 0, -0.01, 0.02, {84,85}, 0, 10)
        end

        -- Move player left and right
        if(btn(1)) then 
            player_hspd = approach(player_hspd, player_hspd_max, player_move_speed)
        elseif(btn(0)) then
            player_hspd = approach(player_hspd, -player_hspd_max, player_move_speed)
        else
            player_hspd = approach(player_hspd, 0, player_air_friction)
        end


        -- Jump bonus
        if (player_consecutive_jumps >= 3) then
            --After image
            if (game_time % 3 == 0) add_new_vfx(player.x, player.y, 0, 0, 0, 0, {player_jump_animations[player_jump_anim_index][frame_counter]}, 10, 0, 1)
            -- Increase move speed in air
            player_move_speed = 0.35
            player_hspd_max = 2.5
        else
            player_move_speed = 0.15
            player_hspd_max = 2
        end
        
        -- Fall Fast
        --if(btnp(5)) then
        --	player_vspd = player_jumpspeed
        --end
    end 
    
    -- Add speed to x and y
    if(player_is_hit == false) then
        player.y += player_vspd
        player.x += player_hspd
    end

    if(player.x > 128) then
        player.x -= 128
        play_noescape_message()
    end 

    if(player.x < 0) then
        player.x += 128
        play_noescape_message()
    end 

    -- Update where the bottom of the player is
    player_bottom = player.y + player.bh
    
    -- Check for ground
    if( player_bottom >= floor_y and player_on_ground == false) then
        --Create dust 
        if(player_vspd > 0) then
            add_new_vfx(player.x+2, player.y+player.bh-1, 1, 0, -0.01, 0.02, {84,85}, 0, 10)
            add_new_vfx(player.x+2, player.y+player.bh-1, -1, 0, -0.01, 0.02, {84,85}, 0, 10)
            sfx(16)
        end 
        player.y = floor_y - player.bh
        player_on_ground = true
        player_vspd = 0
        player_consecutive_jump_timer = 0
        player_consecutive_score = 0
        jump_released = false 
    end 
end

function play_noescape_message()
    if(player_noescape_message == false )then
        set_message("there's no escape", 60)
        player_noescape_message = true 
    end 
end 



-- Draw player function 
function draw_player()

    -- Count all of the frames in the animation 
    num_of_frames = count(player_jump_animations[player_jump_anim_index])
    
    -- Increment counter until we hit our frame time limit 
    anim_counter += 1
    if(anim_counter >= anim_frame_length) then
        -- Reset anim counter 
        anim_counter = 0
        -- Increase frame counter 
        frame_counter += 1
        if(frame_counter > num_of_frames) then
            -- Reset frame counter
            frame_counter = 1
        end
    end
    
    -- Play player animations
    if(player_is_hit) then 
        -- Draw hit sprite 

        if(player_on_ground) then
            player_spr = 5
        else
            player_spr = 3
        end
        draw_game_over( 48,48)
    elseif(player_on_ground) then
        -- Draw grounded sprite
        player_spr = 1
        if(btn(0)) player_spr = 7
        if(btn(1)) player_spr = 6
        frame_counter = 1		
    else
        -- Draw Jumping sprite
        player_spr = player_jump_animations[player_jump_anim_index][frame_counter] 
    end

    -- Flash Pallet if we have a double jump
    if(player_double_jump and game_time % 2 == 0) then
        if(player_double_jump_flash) then
            player_double_jump_flash = false
        else
            player_double_jump_flash = true
        end
    end

    if(player_double_jump_flash and player_double_jump) then
        pal(8, player_double_jump_color)
        pal(15, player_double_jump_color)
        pal(9, player_double_jump_color)
        pal(12, player_double_jump_color)
    end

    -- Finally Draw the player sprite 
    if(player_invol_timer % 2 == 0) spr(player_spr, player.x, player.y)
    pal()
end

-- Do player being hit
function player_hit()
    game_lives -= 1
    player_consecutive_jumps = 0
    if(game_lives > 0) then
        player_invol_timer = 60
        add_new_vfx(player.x, player.y, 0, 0, 0, 0, {22}, 80, 10)
        sfx(12)
    else
        player_is_hit = true
        dset(0, data_deaths)
        sfx(2)
        game_scale = 0
        game_scale_target = 0
        if(is_highscore(game_score) != -1) then
            game_has_highscore = true
            game_has_highscore_index = is_highscore(game_score)
        end 
    end 
end 

function player_can_be_hit()
    if( player_invol_timer <= 0 and player_is_hit == false) return true
end