pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function lightningbolt_init()
    lightningbolt = {}
end

function add_new_lightningbolt(_x, _fire_life)
    add(lightningbolt,{
        x=_x,
        y=0,
        bx = 1,
        by = 1,
        bw=8,
        bh=72,
        life = 4,
        fire_life = _fire_life or 60,
        draw=function(self)
            for i=0,9 do
                spr(93, self.x, self.y+(8*i))
            end
        end,

        update=function(self)
            -- Make the screen flash 
            game_sky_flash = true 

            -- Remove self and spawn fire
            if(self.life <= 0) then
                --remove self
                 del(lightningbolt,self)
                 sfx(18, 3)
                 add_new_fire(flr(self.x/8)*8, 72, fire_life)
                 mset(flr(self.x/8), 10, 24) 
                 game_sky_flash = false
                 --Spawn fire
            end
            -- See if we hit the player
            if(overlap(player, self)) then
                if(player_can_be_hit()) then
                    player_hit()
                end
            end
            self.life -= 1
        end,
    })
end