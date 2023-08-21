pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function fire_init()
    fire = {}
end

function add_new_fire(_x, _y, _life)
    add(fire,{
        x=_x,
        y=_y,
        bx = 1,
        by = 4,
        bw=8,
        bh=8,
        flicker = false,
        animation = {109,110,111},
        animation_flicker = {125,126,127},
        anim_index = 1,
        anim_timer = 0,
        anim_speed = 3,
        life = _life or 0,

        draw=function(self)
            spr(self.animation[self.anim_index], self.x, self.y) 
        end,

        update=function(self)
            -- Animation Shit
            self.anim_timer += 1
            if(self.anim_timer >= self.anim_speed) then
                self.anim_timer = 0
                self.anim_index += 1
                if(self.anim_index > count(self.animation)) self.anim_index = 1 
            end
            -- See if we hit the player
            if(overlap(player, self)) then
                if(player_can_be_hit()) then
                    player_hit()
                end
            end

            self.life -= 1

            -- Kill after life is up 
            if(self.life <= 0) then
                del(fire,self)
            end

        end,

        clear=function(self)
            del(fire,self)
        end,
    })
end