local PlayerInfo = {
    playerId = "",
    playerName = "",
    playerAvatar = ""
}

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