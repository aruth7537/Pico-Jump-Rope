pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- Ease out bounce 
function easeOutBounce(x)
    local n1 = 7.5625
    local d1 = 2.75

    if(x < 1 / d1) then
        return n1 * x * x
    elseif(x < 2 / d1) then
        x = x - (1.5 / d1)
        return n1 * x * x + 0.75
    elseif(x < 2.5 / d1) then
        x = x - (2.25 / d1)
        return n1 * x * x + 0.9375
    else
        x = x - (2.625 / d1)
        return n1 * x * x + 0.984375
    end
end

-- Ease in bounce
function easeInBounce(x)
    return 1 - easeOutBounce(1 - x)
end 

-- Lerp function
function lerp( a, b, t) 
    return a+(b-a)*t
end

-- Approach a value
function approach(c, t, a)
    if (c < t) then
        c = min(c+a, t)
    else
        c = max(c-a, t)
    end
    return c
end

function clamp(v, mi, ma)
    return max(mi, min(ma, v))
end 

-- Smoothly approach a value
function smooth_approach(c, t, a) 
	
	 -- Example use (smooth camera movement):
	 -- view_xview = smooth_approach(view_xview, x-view_wview/2, 0.1);
	 -- view_yview = smooth_approach(view_yview, y-view_hview/2, 0.1);
	 
	local diff = t-c
	if (abs(diff) < 0.01) then
	   return t
	else 
	   return c+sgn(diff)*abs(diff)*a
    end
end

-- Distance between two points
function distance(_x_start, _y_start, _x_end, _y_end)
    return sqrt((_x_end - _x_start)^2 + (_y_end - _y_start)^2)
end

-- Compress 3 values (base 40) into one 32 bit value Returns a 16.16 value
function compress40(_v1, _v2, _v3)
    -- local x1 = _v1 
    -- local x2 = _v2 * 40
    -- local x3 = _v3 * 1600
    -- return x1 + x2 + x3
    local data = 0
    data = data | (_v1 << 6)
    data = data | _v2 
    data = data | (_v3 >> 6)
    return data
end

-- Decrompress data into 3 seperate values (6 bit) Returns Table 
function decompress40(_data)
    -- local data = _data
    -- local v1 = data % 40 
    -- local v2 = ((data - v1) / 40) % 40 
    -- local v3 = (((data - v1) / 40) - v2) / 40 
    -- return {v1, v2, v3}
    local mask1 = 0b0000111111000000.0000000000000000
    local mask2 = 0b0000000000111111.0000000000000000
    local mask3 = 0b0000000000000000.1111110000000000
    local data = _data
    local v1 = (data & mask1) >> 6
    local v2 = data & mask2
    local v3 = (data & mask3) << 6
    return {v1, v2, v3}
end 