S2CDefine = require "defs/S2CRpc"
msgpack = require "msgpack"
-- require "common.Utils"

S2C = {}

function S2C.SyncName(a,b)
    print(a,b)
end

function S2C.SyncRoom(a,b,c)
    print(a,b,c)
end

function S2C.SyncIntAndS(a,b,c)
    print(a,b,c)
end

function S2C.NoParam()
    print("NoParam")
end

function S2C.RegisterUserResult(a)
    if a then
        print("Register Success")
    else
        print("Register Failed")
    end
end

function S2C.LoginUserResult(a, playerId, playername)
    if a then
        PlayerInfo.playerId = playerId
        PlayerInfo.playerName = playername
        print("Hello " .. playername)
        StartPanel:DestroyPanel()
        MainPanel:ShowMe()
    else
        TipsPanel:SetTipsText("通知", "账号或密码不正确")
        TipsPanel:ShowMe()
    end
end

function S2C.ChangePasswardResult(a)
    if a then
        print("Change Passward Success")
    else
        print("Change Passward Failed")
    end
end

function S2C.SyncUnoCardDraw(playerId, cardType, cardColor, confirmshow)
    print("SyncUnoCardDraw playerId: ", playerId, "cardType: ", cardType, "cardColor: ", cardColor, "confirmshow: ", confirmshow)
    GameMatch1V1Panel:OnUnoCardDraw(playerId, cardType, cardColor, confirmshow)
end

function S2C.SyncUnoCardPlay(playerId, cardType, cardColor)
    print("SyncUnoCardPlay playerId: ", playerId, "cardType: ", cardType, "cardColor: ", cardColor)

    if playerId == PlayerInfo.playerId then
        GameMatch1V1Panel:OnSelfUnoCardPlay(playerId,cardType, cardColor)
    elseif playerId ~= 0 then
        GameMatch1V1Panel:OnOtherUnoCardPlay(playerId)
    end
    -- 无论是谁 要出的牌都加入到弃牌区
    GameMatch1V1Panel:AddCardToDiscardPile(cardType, cardColor)

end

function S2C.ShowUnoWaitConfirmCard(playerId, cardIdx, cardType, cardColor)
    print("ShowUnoWaitConfirmCard playerId: ", playerId, "cardIdx: ", cardIdx,
    "cardType: ", cardType, "cardColor: ", cardColor)
end

function S2C.SyncUnoShoutUno(playerId, hasUno)
    print("SyncUnoShutUno playerId: ", playerId, "hasUno: ", hasUno)
end

function S2C.SyncUnoPlayEnd(winPlayerId, playerCardInfo_U)
    print("SyncUnoPlayEnd winPlayerId: ", winPlayerId)
    PlayEndPanel:Init(winPlayerId, msgpack.unpack(playerCardInfo_U))
end

function S2C.SyncUnoCards(playerId, cardNum, cards_U)
    print("SyncUnoCards playerId: ", playerId, "cardNum: ", cardNum)
end

function S2C.SyncUnoPlayRoundInfo(totalRestTime, curOpRestTime, curPlayerId, stage)
    GameMatch1V1Panel.curPlayerId = curPlayerId
    GameMatch1V1Panel:TimerMgr(curPlayerId,totalRestTime,curOpRestTime)
    GameMatch1V1Panel:PlayerStage(curPlayerId,stage) 
    print("SyncUnoPlayRoundInfo totalRestTime: ", totalRestTime, "curOpRestTime: ", curOpRestTime, "curPlayerId: ", curPlayerId, "stage: ", stage)
end

function S2C.SyncPlayerComeInPlay(matchType, playerIds_U)
    print("SyncPlayerComeInPlay MatchType: ", matchType)
    if matchType == 3 then
        PreMatch1V1Panel:DestroyPanel()
        GameMatch1V1Panel:Init(msgpack.unpack(playerIds_U))
    end
end

-- 检查定义的RPC是否都实现了
local function CheckS2CRpcImp()
    for _, v in pairs(S2CDefine) do 
        if not S2C[v[1]] then
            error("S2C Not Implement: " .. v[1])
            return
        end
    end
end

CheckS2CRpcImp()
