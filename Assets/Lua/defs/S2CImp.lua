S2CDefine = require "defs/S2CRpc"
msgpack = require "msgpack"
local PlayerInfo = require("Tools/PlayerInfo")
local UnoGameLogic = require("UI/UILogic/UnoUILogic")
local currentGamePanel = nil  -- 全局变量，保存当前游戏面板实例
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
        
        RegisterPanel:HandleRegisterResult(true)
    else
        RegisterPanel:HandleRegisterResult(false)
    end
end

function S2C.LoginUserResult(a, playerId, playername)
    if a then
        PlayerInfo:SetPlayerId(playerId)
        PlayerInfo:SetPlayerName(playername)
        LoginPanel:HandleLoginResult(true)
    else
        LoginPanel:HandleLoginResult(false)
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
    if currentGamePanel then
        currentGamePanel:OnUnoCardDraw(playerId, cardType, cardColor, confirmshow)
    end
end

function S2C.SyncUnoCardPlay(playerId, cardType, cardColor)
    print("SyncUnoCardPlay playerId: ", playerId, "cardType: ", cardType, "cardColor: ", cardColor)

    if currentGamePanel then
        if PlayerInfo:IsSelf(playerId) then
            currentGamePanel:OnSelfUnoCardPlay(playerId, cardType, cardColor)
        elseif playerId ~= 0 then
            currentGamePanel:OnOtherUnoCardPlay(playerId, cardType, cardColor)
        end
        currentGamePanel:AddCardToDiscardPile(cardType, cardColor)
    end
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
    local playerCardList,playerId2Score = table.unpack(msgpack.unpack(playerCardInfo_U))
    if currentGamePanel then
        currentGamePanel:PlayEndShowCard(playerCardList)
    end
    PlayEndPanel:Init(winPlayerId, playerId2Score)
    -- PlayEndPanel:Init(winPlayerId,playerCardInfo_U)
end

function S2C.SyncUnoCards(playerId, cardNum, cards_U)
    print("SyncUnoCards playerId: ", playerId, "cardNum: ", cardNum)
end

function S2C.SyncUnoPlayRoundInfo(totalRestTime, curOpRestTime, curPlayerId, stage)
    if currentGamePanel then
        currentGamePanel.gameInstance.m_currentPlayerId = curPlayerId
        currentGamePanel:TimerMgr(curPlayerId, totalRestTime, curOpRestTime)
        currentGamePanel:PlayerStage(curPlayerId, stage)
    end
    print("SyncUnoPlayRoundInfo totalRestTime: ", totalRestTime, "curOpRestTime: ", curOpRestTime, "curPlayerId: ", curPlayerId, "stage: ", stage)
end

function S2C.SyncPlayerComeInPlay(matchType, playerIds_U)
    print("SyncPlayerComeInPlay MatchType: ", matchType)
    -- 如果有旧的实例，先销毁
    if currentGamePanel then
        currentGamePanel:DestroyPanel()
        currentGamePanel = nil
    end
    if matchType == UnoCommonConfig.matchType1V1 then
        currentGamePanel = GameMatch1V1Panel:New()
        currentGamePanel:Init(msgpack.unpack(playerIds_U))
    elseif matchType == UnoCommonConfig.matchType1V3 then
        currentGamePanel = GameMatch1V3Panel:New()
        currentGamePanel:Init(msgpack.unpack(playerIds_U))
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
