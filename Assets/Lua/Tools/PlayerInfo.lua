-- 定义 PlayerInfo 类
PlayerInfo = {
    playerId = "",
    playerName = "",
    passWord = "",
}



function PlayerInfo:ClearUser()
    self.playerId = ""
    self.playerName = ""
    self.passWord = ""
end
