pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function vfx_init()
    vfx = {}
end

function add_new_vfx(_x, _y, _hsp, _vsp, _grav, _fric, _animation, _life, _anim_speed, _effect, _index) -- Effect 1 is after image, effect 2 is shimmer
    local index = _index or count(vfx)+1
    add(vfx,{ 
        x  = _x,
        y  = _y,
        bx = 0, -- Bounding box x offset 
        by = 0, -- Bounding box y offset
        bw = 0, -- Bounding box w offset
        bh = 0, -- Bounding box h offset
        vsp = _vsp, -- Vertical Speed 
        hsp = _hsp, -- Horizontal Speed 
        grav = _grav,
        fric = _fric,
        anim_index = 1,
        anim_speed = _anim_speed,
        anim_timer = 0,
        life = _life,
        animation = _animation,
        effect = _effect or 0,
        draw=function(self)
            -- After Image Effect
            if(self.effect == 1) pal({0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}, 0)

            -- Draw Sprite
            spr(self.animation[self.anim_index], self.x, self.y)   
            pal()  
        end,
        update=function(self)
            -- Animation 
            self.anim_timer += 1
            if(self.anim_timer >= self.anim_speed) then
                self.anim_timer = 0
                self.anim_index += 1
                if(self.anim_index > count(self.animation)) then
                    self.anim_index = 1
                    if(self.life <= 0) del(vfx,self)
                end
            end    
            -- Physics 
            if (self.grav > 0) self.vsp += self.grav
            if (self.fric > 0) self.hsp = approach(self.hsp, 0, self.fric)
            if (self.fric > 0) self.vsp = approach(self.vsp, 0, self.fric)
            self.x += self.hsp
            self.y += self.vsp
            self.life -= 1
        end,
    }, index)
end 
