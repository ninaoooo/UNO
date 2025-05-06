local PlayerInfo = {
    playerId = "",
    playerName = "",
    playerAvatar = ""
}

function PlayerInfo:InitPlayerInfo(result,playerId,playerName)
    if result then
        local idx = playerId%13
        self:SetPlayerId(playerId)
        self:SetPlayerName(playerName)
        self:SetPlayerAvatar("avatar ("..idx..")")
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