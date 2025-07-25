local Config = {}
local function loadConfigWithIDMap(filePath, keyField)
    local data = require(filePath)
    local map = {}
    for _, item in ipairs(data) do
        local key = item[keyField]
        map[key] = item
    end
    return data, map
end

Config.PorpItems, Config.PorpItemsByID = loadConfigWithIDMap("Data/PorpItems", "ID")

return Config