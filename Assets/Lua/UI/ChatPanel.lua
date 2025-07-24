ChatPanel = {}
local VoiceData = require("Tools/VoiceData")
local VoiceList = VoiceData.LoadVoiceList()
local PoolMgr = require("UI/Pools/PoolMgr")
local MsgRightPool = PoolMgr:getPool("msgRightPool")
local MsgLeftPool = PoolMgr:getPool("msgLeftPool")

local PlayerInfo = require("Tools/PlayerInfo")

function ChatPanel:Init()
    if  self.panelObj == nil then
        -- 1.实例化面板对象，设置父对象
        -- LoadRes(abName,resName)
        self.panelObj = ABMgr:LoadRes("UI","ChatPanel")
        self.panelObj.transform:SetParent(Canvas,false)
        self.GInfo = ABMgr:LoadRes("modes","GInfo")
        self.SpriteEmoji = ABMgr:LoadRes("UI","Emoji")
        self.EmojiPrefab = ABMgr:LoadRes("modes","ImgEmoji")
        self.VoicePrefab = ABMgr:LoadRes("modes","ImgVoice")
        self.BtnClose = self.panelObj.transform:Find("Right/BtnClose"):GetComponent(typeof(Button))
        
        self.LeftRctPanel = self.panelObj.transform:Find("Left/Main/RecentPanel")
        self.LeftRctContent = self.LeftRctPanel.transform:Find("Scroll View/Viewport/Content")

        self.MiddenDefaultPanel = self.panelObj.transform:Find("Midden/DefaultPanel")

        self.MiddenChatPanel = self.panelObj.transform:Find("Midden/ChatPanel")
        self.BtnVoice = self.MiddenChatPanel.transform:Find("Input/BtnVoice"):GetComponent(typeof(Button))
        self.BtnEmoji = self.MiddenChatPanel.transform:Find("Input/BtnEmoji"):GetComponent(typeof(Button))
        self.BtnSend = self.MiddenChatPanel.transform:Find("Input/BtnSend"):GetComponent(typeof(Button))
        self.InputField = self.MiddenChatPanel.transform:Find("Input/InputField"):GetComponent(typeof(TextMeshProInputField))
        self.MsgScrollRect = self.MiddenChatPanel.transform:Find("Scroll View"):GetComponent(typeof(ScrollRect))
        self.MsgContent = self.MiddenChatPanel.transform:Find("Scroll View/Viewport/Content")
        self.GEmojiPanel = self.MiddenChatPanel.transform:Find("EmojiPanel")
        self.GVoicePanel = self.MiddenChatPanel.transform:Find("VoicePanel")
        self.BtnEmoji.onClick:AddListener(function () self:BtnEmojiOnClick() end)
        self.InputField.onSelect:AddListener(function () self:InputFieldOnClick() end)
        self.BtnClose.onClick:AddListener(function () self:BtnCloseOnClick() end)
        self.BtnSend.onClick:AddListener(function () self:BtnSendOnClick() end)

        self.BtnVoice.onClick:AddListener(function () self:BtnVoiceOnClick() end)


        self.AddFrendPanel = self.panelObj.transform:Find("Midden/AddFrendPanel")


        self.RightBtnClose = self.panelObj.transform:Find("Right/BtnClose"):GetComponent(typeof(Button))
        self.RightBtnClose.onClick:AddListener(function () self:DestroyPanel() end)

        self:InitData()
        self:InitLeftRctPanel()
        self:InitEmojiPanel()
        self:InitVoicePanel()
        MonoBehaviourMgr:Register(self)
    end
end

function ChatPanel:InitData()
    self.playerId = PlayerInfo:GetPlayerId()
    MsgDataMgr:LoadToMsgData()
end
function ChatPanel:InitLeftRctPanel()
    
    for playerId, _ in pairs(MsgData) do
        local rctInfoObj = GameObject.Instantiate(self.GInfo, self.LeftRctContent)
        rctInfoObj.transform:Find("ImgAvatar"):GetComponent(typeof(Image)).sprite = AvatarSpriteAltas:GetSprite(PlayerInfo.Friends[playerId].playerAvatar)
        rctInfoObj.transform:Find("TextPlayerName"):GetComponent(typeof(TextMeshPro)).text = PlayerInfo.Friends[playerId].playerName
        rctInfoObj:GetComponent(typeof(Button)).onClick:AddListener(function() 
            self.curChatPlayerId = playerId
            self:clearChatMsg()
            self.MiddenDefaultPanel.gameObject:SetActive(false)
            self.MiddenChatPanel.gameObject:SetActive(true)
            self:LoadMsgToMiddenChatPanel(self.curChatPlayerId)
            self.MsgScrollRect.verticalNormalizedPosition = 0
        end)
    end
end

function ChatPanel:clearChatMsg()
    for i = self.MsgContent.transform.childCount -1,0,-1 do
        local child = self.MsgContent.transform:GetChild(i).gameObject
        if child.name == "MsgRight(Clone)" then
            MsgRightPool:clean(child)
            MsgRightPool:put(child)
        elseif child.name == "MsgLeft(Clone)" then
            MsgLeftPool:clean(child)
            MsgLeftPool:put(child)
        else
            GameObject.Destroy(child)
        end
    end
end
    
function ChatPanel:SetMsgPrefabs(msgType,msgHolder,renderedMsg)
    if(msgHolder == "self") then
        local msgObj = MsgRightPool:get()
        msgObj.transform:SetParent(self.MsgContent,false)
        msgObj.transform:Find("HorizonCnt/ImgAvatar"):GetComponent(typeof(Image)).sprite = AvatarSpriteAltas:GetSprite(PlayerInfo.playerAvatar)
        local msgText = msgObj.transform:Find("HorizonCnt/Image/Text"):GetComponent(typeof(TextMeshPro))
        if msgType == "voice" then
            msgText.text = "语音消息，点击播放"
            msgObj.transform:Find("HorizonCnt/Image"):GetComponent(typeof(Button)).onClick:AddListener(function() 
                LuaAudioMgr:PlaySound("sound",LuaAudioMgr:GetVoiceNameById(tonumber(renderedMsg)))
            end)
        else  msgText.text = renderedMsg
        end
    else 
        local msgObj = MsgLeftPool:get()
        msgObj.transform:SetParent(self.MsgContent,false)
        msgObj.transform:Find("HorizonCnt/ImgAvatar"):GetComponent(typeof(Image)).sprite = AvatarSpriteAltas:GetSprite(PlayerInfo.Friends[self.curChatPlayerId].playerAvatar)
        local msgText = msgObj.transform:Find("HorizonCnt/Image/Text"):GetComponent(typeof(TextMeshPro))
        if msgType == "voice" then
            msgText.text = "语音消息，点击播放"
            msgObj.transform:Find("HorizonCnt/Image"):GetComponent(typeof(Button)).onClick:AddListener(function() 
                LuaAudioMgr:PlaySound("sound",LuaAudioMgr:GetVoiceNameById(tonumber(renderedMsg)))
            end)
            else  msgText.text = renderedMsg
        end
    end

end

function ChatPanel:BtnCloseOnClick()
    self.GEmojiPanel.gameObject:SetActive(true)
end

function ChatPanel:InputFieldOnClick()
    self.GEmojiPanel.gameObject:SetActive(false)
end

function ChatPanel:InitVoicePanel()
    self.voiceCnt = #VoiceList
    for i=1, self.voiceCnt do
        local voiceObj = GameObject.Instantiate(self.VoicePrefab, self.GVoicePanel)
        voiceObj.transform:Find("Text (TMP)"):GetComponent(typeof(TextMeshPro)).text = VoiceList[i].Name
        voiceObj:GetComponent(typeof(Button)).onClick:AddListener(function() self:OnVoiceSelectedHandler(VoiceList[i].ID) end)
    end
end

function ChatPanel:OnVoiceSelectedHandler(Id)
    self.GVoicePanel.gameObject:SetActive(false)
    local msg = "#V"..Id.."#n"
    local renderedMsg = renderedMsg(msg)
    self:SetMsgPrefabs("voice","self",renderedMsg)
    table.insert(MsgData[self.curChatPlayerId],{msgId = nil, timestamp = os.time(), msgType = "voice", content = renderedMsg, senderId = self.playerId})
    MsgDataMgr:SaveToJson()
end
function ChatPanel:BtnVoiceOnClick()
    self.GVoicePanel.gameObject:SetActive(not self.GVoicePanel.gameObject.activeSelf)
end
function ChatPanel:BtnSendOnClick()
    self.GEmojiPanel.gameObject:SetActive(false)
    local inputText = self.InputField.text
    local msg = inputText.."#n"
    local renderedMsg = renderedMsg(msg)
    self:SetMsgPrefabs("text","self",renderedMsg)
    self.MsgScrollRect.verticalNormalizedPosition = 0
    self.InputField.text = ""
    if not MsgData[self.curChatPlayerId] then
        MsgData[self.curChatPlayerId] = {}
    end
    table.insert(MsgData[self.curChatPlayerId],{msgId = nil, timestamp = os.time(), msgType = "text", content = renderedMsg, senderId = self.playerId})
    MsgDataMgr:SaveToJson()
end

function ChatPanel:BtnEmojiOnClick()
    self.GEmojiPanel.gameObject:SetActive(not self.GEmojiPanel.gameObject.activeSelf)
end

function ChatPanel:InitEmojiPanel()
    self.emojiCnt = self.SpriteEmoji.spriteCount
    for i=1, self.emojiCnt do
        local emojiObj = GameObject.Instantiate(self.EmojiPrefab, self.GEmojiPanel)
        emojiObj:GetComponent(typeof(Image)).sprite = self.SpriteEmoji:GetSprite(tostring(i))
        emojiObj:GetComponent(typeof(Button)).onClick:AddListener(function() self:OnEmojiSelectedHandler(tostring(i)) end)
    end
end

function ChatPanel:OnEmojiSelectedHandler(EmojiName)
    local emojiText = "#"..EmojiName
    local currentTextLegth = utf8.len(self.InputField.text)
    -- 获取光标位置
    local currentPos = self.InputField.caretPosition

    if currentPos < 0 or currentPos > currentTextLegth then
        -- 如果光标位置无效，插入到末尾
        self.InputField.text = self.InputField.text .. emojiText
    else
        local part1 = utf8_sub(self.InputField.text, 1, currentPos)
        local part2 = utf8_sub(self.InputField.text, currentPos + 1)
        self.InputField.text = part1 .. emojiText .. part2
        -- 移动光标到插入文本之后
        self.InputField.caretPosition = currentPos + utf8.len(emojiText)
    end
end



function ChatPanel:LoadMsgToMiddenChatPanel(playerId)
    MsgDataMgr:LoadToMsgData()
    if MsgData[playerId] then
        local preTimestamp = nil
        for i, msg in ipairs(MsgData[playerId]) do
            if preTimestamp then
                if msg.timestamp - preTimestamp >= 10*60 then
                    self:SetTimeStamp(msg.timestamp)
                end
            else 
                self:SetTimeStamp(msg.timestamp)
            end
                
            if msg.senderId == self.playerId then
                self:SetMsgPrefabs(msg.msgType, "self", msg.content)
            else
                self:SetMsgPrefabs(msg.msgType, "other", msg.content)
            end
            preTimestamp = msg.timestamp
        end
    end
end

function ChatPanel:SetTimeStamp(timestamp)
    local timeString = os.date("%Y-%m-%d %H:%M", timestamp)
    local textObj = GameObject("TimeStampText")  
    textObj.transform:SetParent(self.MsgContent.transform, false)
    local text = textObj:AddComponent(typeof(TextMeshPro))
    text.text = timeString
    text.fontSize = 18
    text.alignment = CS.TMPro.TextAlignmentOptions.Center
    text.color = CS.UnityEngine.Color.black
end

function ChatPanel:Start()
end

function ChatPanel:ShowMe()
    self:Init()
    self.panelObj:SetActive(true)
    
end

function ChatPanel:HideMe()
    self.panelObj:SetActive(false)
end

function ChatPanel:DestroyPanel()
    self.panelObj:SetActive(false)
    self:clearChatMsg()
    GameObject.Destroy(self.panelObj)
    ChatPanel.panelObj = nil
end