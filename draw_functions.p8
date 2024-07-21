pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- Draw message
function draw_game_message()
	local length = #game_message*4
	--local draw_x = 64-length/2
	--local draw_y = 32
	local draw_x = 64-length/2
	local draw_y = floor_y+2
	if(game_message != "") then
		rectfill( draw_x-2, draw_y-2, draw_x+length, draw_y+6, 0 )
		print(game_message, draw_x+1, draw_y, 1) 
		print(game_message, draw_x-1, draw_y, 1) 
		print(game_message, draw_x, draw_y+1, 1) 
		print(game_message, draw_x, draw_y-1, 1) 
		print(game_message, draw_x, draw_y, 7) 
	end 
end

-- Debug Print
function debug_print() 

	print("playerx:"..player.x, 64, 8)
	print("playery:"..player.y, 64, 16)

end

function draw_hud()
	print_shadow("score:"..game_score.."0", 0, 0, 7, 1)
	print_shadow("lives:", 0, 8, 7, 1)

	for i=1,game_lives do 
		sspr(9,0,6,4, 16+i*8, 9)
	end

	--draw_stage_hud(8, 120, 112)
	draw_stage_hud(64, 112)
	--print_shadow("stage:"..(flr(game_stage/4)+1).." act:"..((game_stage-1)%3)+1, 50, 105, 7, 1)
	print_shadow(game_stage_title, 40, 105, 7, 1)
end 


function draw_stage_hud(_x, _y)

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