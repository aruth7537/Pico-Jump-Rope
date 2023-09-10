pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function birds_init()
    birds = {}
end

function add_new_bird(_x, _y, _hsp)
    add(birds,{
        x=_x,
        y=_y,
        bx = 2,
        by = 1,
        bw=14,
        bh=4,
        vsp = 0,
        hsp = -_hsp,
        anim_index = 1,
        anim_speed = 3,
        anim_timer = 0,
        animation = {
            {68,69,70}, -- Frame 1
            {71,72,73}, -- Frame 2
            {74,75,76}, -- Frame 3
            {77,78,79}  -- Frame 4
        },
        draw=function(self)
            spr(self.animation[self.anim_index][1],self.x,self.y)
            spr(self.animation[self.anim_index][2],self.x+8,self.y)
            spr(self.animation[self.anim_index][3],self.x+16,self.y)
        end,

        update=function(self)
            -- Animation
            self.anim_timer += 1
            if(self.anim_timer >= self.anim_speed) then
                self.anim_timer = 0
                self.anim_index += 1
                if(self.anim_index > count(self.animation)) then
                    self.anim_index = 1
                    sfx(10, 1)
                end 
            end

            -- Physics
            self.x+=self.hsp
            self.y+=self.vsp 
    
            -- Collide with player
            if(overlap(player, self)) then
                if(player_can_be_hit()) then
                    player_hit()
                    if(game_lives <= 0) then
                        self.hsp = 0
                        self.vsp = 0
                    end 
                end
            end 

            --Remove self if OoB
            if(self.x<-32 or self.x > 160 or self.y<-32 or self.y>160) del(birds,self)
        end,
    })
end