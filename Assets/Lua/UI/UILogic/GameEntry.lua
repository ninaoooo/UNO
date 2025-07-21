GameEntry = {
    currentGamePanel = nil
}


    


function GameEntry:Awake(matchType, playerIds_U)
    if self.currentGamePanel then
        self.currentGamePanel:DestroyPanel()
        self.currentGamePanel = nil
    end
    if matchType == UnoCommonConfig.matchType1V1 then
        self.currentGamePanel = GameMatch1V1Panel:New()
        self.currentGamePanel:Init(msgpack.unpack(playerIds_U))
    elseif matchType == UnoCommonConfig.matchType1V3 then
        self.currentGamePanel = GameMatch1V3Panel:New()
        self.currentGamePanel:Init(msgpack.unpack(playerIds_U))
    end
end
return GameEntry