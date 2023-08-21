pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- Draw message
function draw_game_message()
	local length = #game_message*4
	local draw_x = 64-length/2
	local draw_y = 32
	print(game_message, draw_x+1, draw_y, 1) 
	print(game_message, draw_x-1, draw_y, 1) 
	print(game_message, draw_x, draw_y+1, 1) 
	print(game_message, draw_x, draw_y-1, 1) 
	print(game_message, draw_x, draw_y, 7) 
end

-- Debug Print
function debug_print() 

	print("playerx:"..player.x, 64, 8)
	print("playery:"..player.y, 64, 16)
	-- print("gd_next:"..game_data_next,0,24)
	
	-- print("dist sign:"..dist_sign, 64, 0)
	-- print("last sign:"..dist_last_sign, 64, 8)
	-- print(player_is_hit, 64, 16) 
	-- print("player feet:"..player_bottom, 64, 24)
	-- print("floor:"..floor_y, 64, 32)
end

function draw_hud()
	print_shadow("score:"..game_score.."0", 0, 0, 7, 1)
	print_shadow("lives:", 0, 8, 7, 1)

	for i=1,game_lives do 
		sspr(9,0,6,4, 16+i*8, 9)
	end

	--draw_stage_hud(8, 120, 112)
	draw_stage_hud(64, 112)
	print_shadow("stage:"..(flr(game_stage/4)+1).." act:"..((game_stage-1)%3)+1, 50, 105, 7, 1)

end 

-- function draw_stage_hud(_x,_y)
-- 	local spr_w = 33
-- 	local draw_w = flr(spr_w * (game_score/game_score_end))
-- 	local draw_w2 = flr(spr_w * ((game_score-game_score_end)/game_score_end))
-- 	-- Draw the text "stage"
-- 	print("stage: "..game_stage, _x+1, _y-6, 1)
-- 	print("stage: "..game_stage, _x, _y-7, 7)

-- 	-- Draw The First progress bar
-- 	sspr(89,0,draw_w,4,_x+1,_y) -- Draw the progress bar
-- 	sspr(88,8,34,6,_x,_y) -- Draw the UI

-- 	-- Draw the Second Progress bar
-- 	if(game_stage >= 5) then
-- 		sspr(89,4,draw_w2,4,_x+1,_y+7) -- Progress Bar
-- 		sspr(88,8,34,6,_x,_y+6) -- Draw UI 
-- 	end
-- end 

function draw_stage_hud(_x, _y)
	-- local draw_w = clamp(((game_score-game_score_new_zero)/(game_score_end-game_score_new_zero)) * _w,  0, _w)

	-- sspr(88,8, 1,3, _x, _y+1, draw_w, 3)

	-- sspr(104, 8, 1, 6, _x-1, _y)
	-- sspr(105, 8, 6, 6, _x, _y, _w, 6)
	-- sspr(112, 8, 2, 6, _x+_w, _y)
	local draw_x = _x - ((game_coins_to_next_stage/2) * 8) / 2 
	local draw_y = _y 
	local rows = 2
	local sprite = 11 

	for i = 0, game_coins_to_next_stage-1 do
		sprite = 11 
		if (i <= game_coins-1) sprite = 32
		spr(sprite, draw_x + flr(i/rows)*8, draw_y + (8*(i%rows)))
	end

end 

function print_shadow(_str, _x , _y, _col, _col2)
	print(_str, _x+1,_y+1,_col2)
	print(_str, _x, _y, _col)
end 