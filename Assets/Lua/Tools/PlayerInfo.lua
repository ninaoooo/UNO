local PlayerInfo = {
    playerId = "",
    playerName = "",
    playerAvatar = "",
    Friends = {
        ["1000001"] = { playerName = "一颗花椰菜", playerAvatar = "avatar (1)" },
        ["1000002"] = { playerName = "一瓶椰子水", playerAvatar = "avatar (2)" }
    },
    Bag = {},
    gold = 0,
    diamond = 0
}

local serverBagData = {size = 48, slots = {{slot = 1, ID = 1, count = 10 },{slot = 2, ID = 2, count = 5}}}
function PlayerInfo:InitPlayerInfo(result,playerId,playerName)
    if result then
        local idx = playerId%13
        self:SetPlayerId(playerId)
        self:SetPlayerName(playerName)
        self:SetPlayerAvatar("avatar ("..idx..")")
        self.Bag = BagMgr:CreateBag(serverBagData.slots,serverBagData.size)
    end
end
MessageSystem.RegisterListener("S2C.LoginUserResult",function(result,playerId,playerName)
    PlayerInfo:InitPlayerInfo(result,playerId,playerName)
end)


-- Set 方法
function PlayerInfo:SetPlayerId(playerId)
    self.playerId = playerId
end

function PlayerInfo:SetPlayerName(playerName)
    self.playerName = playerName
end

function PlayerInfo:SetPlayerAvatar(playerAvatar)
    self.playerAvatar = playerAvatar
end
-- Get 方法
function PlayerInfo:GetPlayerId()
    return self.playerId
end

function PlayerInfo:GetPlayerName()
    return self.playerName
end

function PlayerInfo:GetPlayerAvatar()
    return self.playerAvatar
end

function PlayerInfo:ClearUser()
    self.playerId = ""
    self.playerName = ""
    self.playerAvatar = ""
end

function PlayerInfo:IsSelf(playerId)
    return self.playerId == playerId
end




return PlayerInfo

