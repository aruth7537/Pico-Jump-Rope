pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- Check for overlap - Returns true if two boxes collide (A over B)
function overlap(a,b)
    return not (a.x + a.bx > b.x + b.bx + b.bw 
             or a.y + a.by > b.y + b.by + b.bh 
             or a.x + a.bx + a.bw < b.x + b.bx 
             or a.y + a.by + a.bh < b.y + b.by)
   end

