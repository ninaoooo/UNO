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

local EMOJI_PATTERN = "#([1-9]|[1-3][0-9]|40)" 
function renderChatMessage(message)
    if not message or message == "" then
        return ""
    end

    local rendered_string = ""
    local last_byte_pos = 1 -- 记录上一个匹配结束后的字节位置

    -- `gmatch` 会遍历所有匹配项
    for start_match_byte, end_match_byte, emoji_id_str in message:gmatch("()" .. EMOJI_PATTERN .. "()") do
        -- 1. 添加当前匹配之前的普通文本
        local text_before = message:sub(last_byte_pos, start_match_byte - 1)
        rendered_string = rendered_string .. text_before

        -- 2. 处理表情标记（将#ID转换为<sprite>标签）
        local full_emoji_tag = "#" .. emoji_id_str

        if emoji_id_str>=1 and emoji_id_str < 40 then
            rendered_string = rendered_string .. "<sprite=\"Emoji\" name=\"" .. emoji_id_str .. "\">"
        else
            rendered_string = rendered_string .. full_emoji_tag
        end

        -- 更新下一个查找的起始位置
        last_byte_pos = end_match_byte 
    end

    -- 3. 添加字符串末尾可能存在的任何剩余文本
    local remaining_text = message:sub(last_byte_pos)
    rendered_string = rendered_string .. remaining_text

    return rendered_string
end




