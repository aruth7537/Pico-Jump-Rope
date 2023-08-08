pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function debug_init()
    debug_data  = 0b0000000000000000.0000000000000000
    debug_value = 0b0000100111100111.1001110000000000
    value1 = 1
    value2 = 39
    value3 = 1
    return_table = {0,0,0}
    mask1 = 0b0000111111000000.0000000000000000
    mask2 = 0b0000000000111111.0000000000000000
    mask3 = 0b0000000000000000.1111110000000000

    debug_data = debug_data | (value1 <<6)
    debug_data = debug_data | value2
    debug_data = debug_data | (value3 >>6)

end

function debug_update() 

    if(btnp(4)) then
        return_table[1] = (debug_data & mask1) >> 6
        return_table[2] = debug_data & mask2
        return_table[3] = (debug_data & mask3) << 6
    end 
end 

function debug_draw()
    cls()
    print(debug_data)
    print(return_table[1])
    print(return_table[2])
    print(return_table[3])
end