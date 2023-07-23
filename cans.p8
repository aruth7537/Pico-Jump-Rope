pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function cans_init()
    cans = {}
end

function add_new_can(_x, _y, _hsp, _can_type)
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
        can_type = _can_type or 1,
        animation = {{38, 37, 36, 35},
                     {35, 36, 37, 38},
                     {38, 37, 36, 35},},
        animation_flying = {{51,52,53,54,55,56,57,58},
                            {58,57,56,55,54,53,52,51},
                            {51,52,53,54,55,56,57,58},},
        main_color = {8,12,10},
        anim_index = 1,
        anim_speed = 3,
        anim_timer = 0,
        is_flying = false,
        can_fly = true,
        can_hurt = true,
        lightning_strike_timer = 60,
        draw=function(self)
            if(self.is_flying == false) then
                pal(8, self.main_color[self.can_type])
                spr(self.animation[self.can_type][self.anim_index],self.x,self.y)
            else
                pal(8, self.main_color[self.can_type])
                spr(self.animation_flying[self.can_type][self.anim_index],self.x,self.y)
            end
            pal()
        end,
        update=function(self)
            -- Animtation 
            self.anim_timer += 1
            if(self.is_flying == false) then
                if(self.anim_timer >= self.anim_speed) then
                    self.anim_timer = 0
                    self.anim_index += sgn(self.hsp)
                    if(self.anim_index > count(self.animation[self.can_type])) self.anim_index = 1
                    if(self.anim_index < 1) self.anim_index = count(self.animation[self.can_type])
                end
            else
                if(self.anim_timer >= self.anim_speed) then
                    self.anim_timer = 0
                    self.anim_index += 1
                    if(self.anim_index > count(self.animation_flying[self.can_type])) self.anim_index = 1
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

            --Lightning Strike
            if(self.can_type == 3) then
                self.lightning_strike_timer-= 1
                if(self.lightning_strike_timer == 30) then
                    add_new_vfx(self.x, self.y, self.hsp, -1, 0, 0, {87,88,89,90}, -1, 5)
                    sfx(19)
                end
                if(self.lightning_strike_timer <= 0) then
                    add_new_lightningbolt(self.x)
                    del(cans,self)
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
