function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then
        return false
    end
    local pos,arr = 0, {}

    local find = function() 
        return string.find(input, delimiter, pos, true) 
    end

    for st,sp in find do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end


function utf8_sub(s, i, j)
    i = i or 1
    j = j or -1

    local start_pos = utf8.offset(s, i)
    local end_pos = utf8.offset(s, j + 1)

    if not start_pos then return "" end
    if not end_pos then
        return s:sub(start_pos)
    else
        return s:sub(start_pos, end_pos - 1)
    end
end

function renderedMsg(msg)
    local MIN_EMOJI_ID = 0
    local MAX_EMOJI_ID = 40
    local EMOJI_PATTERN = "^#(%d+)"
    local COLOR_PATTERN = "^#(%a)"
    local ColorCode = {R = "red",G = "green",B = "blue",Y = "yellow",C = "cyan",M = "magenta",W = "white",K = "black",O = "orange",P = "purple",
    S = "silver",L = "lime",N = "navy",T = "teal",A = "aqua",D = "darkblue",V = "violet"}

    local result = {}
    local stack = {}
    local idx = 1;

    while(idx < #msg) do
        local c = string.sub(msg,idx,idx)
        if c == '#' then
            local emoji_id_str = string.match(msg,EMOJI_PATTERN,idx)
            if emoji_id_str then
                local emoji_id = tonumber(emoji_id_str)
                if emoji_id > MIN_EMOJI_ID and emoji_id < MAX_EMOJI_ID then
                    table.insert(result,'<sprite name="' .. emoji_id .. '">')
                else 
                    table.insert(result,emoji_id)
                end
                idx = idx + 1 + #emoji_id_str
            else
                local color_str = string.match(msg,COLOR_PATTERN,idx)
                if color_str then
                    if color_str == 'n' then
                        if #stack > 0 then
                            table.insert(result, "</color>")
                            table.remove(stack)
                        end
                        idx = idx+2
                    else 
                        local color = ColorCode[color_str]
                        if color then
                            if #stack > 0 then
                                table.insert(result, "</color>")
                                table.remove(stack)
                            end
                            table.insert(stack,color)
                            table.insert(result,"<color=" .. color .. ">")
                            idx = idx + 2
                        end
                    end
                end
            end
        else 
            table.insert(result,c)
            idx = idx + 1
        end
    end
    return  table.concat(result)
end




