pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function cans_init()
    cans = {}
end

function add_new_can(_x, _y, _hsp)
    add(cans,{
        x=_x,
        y=_y,
        bx = 0,
        by = 0,
        bw=8,
        bh=3,
        vsp = 0,
        hsp = _hsp,
        grav = 0.25,
        animation = {38, 37, 36, 35},
        animation_flying = {51,52,53,54,55,56,57,58},
        anim_index = 1,
        anim_speed = 3,
        anim_timer = 0,
        is_flying = false,
        can_fly = true,
        can_hurt = true,
        draw=function(self)
            if(self.is_flying == false) then
                spr(self.animation[self.anim_index],self.x,self.y)
            else
                spr(self.animation_flying[self.anim_index],self.x,self.y)
            end
        end,
        update=function(self)
            -- Animtation 
            self.anim_timer += 1
            if(self.is_flying == false) then
                if(self.anim_timer >= self.anim_speed) then
                    self.anim_timer = 0
                    self.anim_index += sgn(self.hsp)
                    if(self.anim_index > count(self.animation)) self.anim_index = 1
                    if(self.anim_index < 1) self.anim_index = count(self.animation)
                end
            else
                if(self.anim_timer >= self.anim_speed) then
                    self.anim_timer = 0
                    self.anim_index += 1
                    if(self.anim_index > count(self.animation_flying)) self.anim_index = 1
                end
            end
            -- Can is flying
            if(self.is_flying == true) then 
                self.vsp += self.grav
                -- Can hit ground again
                if(self.y+self.bh+self.vsp >= floor_y and self.vsp > 0) then
                    self.is_flying = false
                    self.can_fly = false
                    self.y = floor_y-self.bh
                    self.vsp = 0
                    self.anim_index = 1
                    add_new_vfx(self.x+8, self.y+self.bh-1, 1, 0, -0.01, 0.02, {84,85}, 0, 10)
                    add_new_vfx(self.x, self.y+self.bh-1, -1, 0, -0.01, 0.02, {84,85}, 0, 10)
                end
            end

            -- Collide with player
            if(overlap(player, self) and self.can_hurt == true) then
                if(player_can_be_hit()) then
                    player_hit()
                    if(game_lives <= 0) then
                        self.hsp = 0
                        self.vsp = 0
                        self.can_fly = false
                        self.grav = 0
                    end 
                end
            end 

            -- Physics
            self.x+=self.hsp
            self.y+=self.vsp  
            
            --Remove self if OoB
            if(self.x<-32 or self.x > 160 or self.y<-32 or self.y>160) del(cans,self)
        end,
        -- Bounce after being hit by rope
        point_overlap=function(self,_x,_y)
            if(_x >= self.x and _x <= self.x+self.bh and _y >= self.y and _y <= self.y+self.bh and self.can_fly == true) then
                self.vsp = -3
                self.hsp = self.hsp
                self.is_flying = true
                self.can_fly = false
                self.anim_speed = 2
                sfx(7)
            end
        end
    })
end
