local PlayerInfo = {
    playerId = "",
    playerName = "",
    passWord = "",
}

-- Set 方法
function PlayerInfo:SetPlayerId(playerId)
    self.playerId = playerId
end

function PlayerInfo:SetPlayerName(playerName)
    self.playerName = playerName
end

function PlayerInfo:SetPassword(password)
    self.passWord = password
end

-- Get 方法
function PlayerInfo:GetPlayerId()
    return self.playerId
end

function PlayerInfo:GetPlayerName()
    return self.playerName
end

function PlayerInfo:GetPassword()
    return self.passWord
end

return PlayerInfo