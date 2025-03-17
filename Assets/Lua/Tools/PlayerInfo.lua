local PlayerInfo = {
    playerId = "",
    playerName = "",
}

-- Set 方法
function PlayerInfo:SetPlayerId(playerId)
    self.playerId = playerId
end

function PlayerInfo:SetPlayerName(playerName)
    self.playerName = playerName
end

-- Get 方法
function PlayerInfo:GetPlayerId()
    return self.playerId
end

function PlayerInfo:GetPlayerName()
    return self.playerName
end

function PlayerInfo:ClearUser()
    self.playerId = ""
    self.playerName = ""
end

return PlayerInfo