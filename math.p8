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
	if (abs(diff) < 0.05) then
	   return t
	else 
	   return c+sgn(diff)*abs(diff)*a
    end
end

-- Distance between two points
function distance(_x_start, _y_start, _x_end, _y_end)
    return sqrt((_x_end - _x_start)^2 + (_y_end - _y_start)^2)
end