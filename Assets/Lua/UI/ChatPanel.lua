ChatPanel = {}
local VoiceData = require("Tools/VoiceData")
local VoiceList = VoiceData.LoadVoiceList()
local PoolMgr = require("UI/Pools/PoolMgr")
local MsgRightPool = PoolMgr:getPool("msgRightPool")
local MsgLeftPool = PoolMgr:getPool("msgLeftPool")

local PlayerInfo = require("Tools/PlayerInfo")
local EmailData = require("Tools/EmailData")
function ChatPanel:Init()
    if  self.panelObj == nil then
        -- 1.实例化面板对象，设置父对象
        -- LoadRes(abName,resName)
        self.panelObj = ABMgr:LoadRes("UI","ChatPanel")
        self.panelObj.transform:SetParent(Canvas,false)
        self.TogInfo = ABMgr:LoadRes("modes","TogInfo")
        self.TogEmailInfo = ABMgr:LoadRes("modes","TogEmailInfo")
        self.SpriteEmoji = ABMgr:LoadRes("UI","Emoji")
        self.EmojiPrefab = ABMgr:LoadRes("modes","ImgEmoji")
        self.VoicePrefab = ABMgr:LoadRes("modes","ImgVoice")
        self.PropPrefab = ABMgr:LoadRes("modes","ImgPorp")
        self.BtnClose = self.panelObj.transform:Find("Right/BtnClose"):GetComponent(typeof(Button))
        
        self.LeftTogRct = self.panelObj.transform:Find("Left/Up/TogRecent"):GetComponent(typeof(Toggle))
        self.LeftTogCon = self.panelObj.transform:Find("Left/Up/TogContact"):GetComponent(typeof(Toggle))
        self.LeftTogAddFri = self.panelObj.transform:Find("Left/Up/TogAddFriend"):GetComponent(typeof(Toggle))
        self.LeftRctPanel = self.panelObj.transform:Find("Left/Main/RecentPanel")
        self.LeftRctContent = self.LeftRctPanel.transform:Find("Scroll View/Viewport/Content")
        self.LeftRctCntTogGroup = self.LeftRctContent:GetComponent(typeof(ToggleGroup))
        self.LeftRctTogSys = self.LeftRctContent.transform:Find("TogInfoSys"):GetComponent(typeof(Toggle))
        self.LeftRctTogSys.onValueChanged:AddListener(function(isOn) if isOn then self:clearChatMsg() end end)
        self.LeftConPanel = self.panelObj.transform:Find("Left/Main/FriendPanel")
        self.LeftConContent = self.LeftConPanel.transform:Find("Scroll View/Viewport/Content")
        self.LeftConCntTogGroup = self.LeftConContent:GetComponent(typeof(ToggleGroup))
        self.LeftTogRct.onValueChanged:AddListener(function (isOn) self:ShowRecent(isOn) end)
        self.LeftTogCon.onValueChanged:AddListener(function (isOn) self:ShowContacts(isOn) end)
        self.LeftTogAddFri.onValueChanged:AddListener(function (isOn) self:ShowAddFriends(isOn) end)
        self.LeftFriReqPanel = self.panelObj.transform:Find("Left/Main/FriendRequestPanel")
        
        self.Midden = self.panelObj.transform:Find("Midden")
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
        self.MiddenAddFrendPanel = self.panelObj.transform:Find("Midden/AddFrendPanel")

        self.RightBtnClose = self.panelObj.transform:Find("Right/BtnClose"):GetComponent(typeof(Button))
        self.RightBtnClose.onClick:AddListener(function () self:DestroyPanel() end)
        
        self.RightTogFri = self.panelObj.transform:Find("Right/List/TogFriend"):GetComponent(typeof(Toggle))
        self.RightTogEmail = self.panelObj.transform:Find("Right/List/TogEmail"):GetComponent(typeof(Toggle))
        self.RightTogEmail.onValueChanged:AddListener(function (isOn) self:ShowEmail(isOn) end)
        self.LeftEmailContent = self.panelObj.transform:Find("Left/Whole/Scroll View/Viewport/Content")
        self.LeftEmailCntTogGroup = self.LeftEmailContent:GetComponent(typeof(ToggleGroup))
        self.MiddenEmailDescPanel = self.panelObj.transform:Find("Midden/EmailDescPanel")
        
        self.TextSubject = self.MiddenEmailDescPanel.transform:Find("TextSubject"):GetComponent(typeof(TextMeshPro))
        self.TextSendTime = self.MiddenEmailDescPanel.transform:Find("TextSendTime"):GetComponent(typeof(TextMeshPro))
        self.TextBody = self.MiddenEmailDescPanel.transform:Find("TextBody"):GetComponent(typeof(TextMeshPro))
        self.GAttach = self.MiddenEmailDescPanel.transform:Find("GAttach")

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
        local rctInfoObj = GameObject.Instantiate(self.TogInfo, self.LeftRctContent):GetComponent(typeof(Toggle))
        rctInfoObj.group = self.LeftRctCntTogGroup
        rctInfoObj.transform:Find("ImgAvatar"):GetComponent(typeof(Image)).sprite = AvatarSpriteAltas:GetSprite(PlayerInfo.Friends[playerId].playerAvatar)
        rctInfoObj.transform:Find("TextPlayerName"):GetComponent(typeof(TextMeshPro)).text = PlayerInfo.Friends[playerId].playerName
        rctInfoObj.onValueChanged:AddListener(function(isOn) 
            if isOn then
                self.curChatPlayerId = playerId
                self:clearChatMsg()
                self.MiddenDefaultPanel.gameObject:SetActive(false)
                self.MiddenChatPanel.gameObject:SetActive(true)
                self:LoadMsgToMiddenChatPanel(self.curChatPlayerId)
                self.MsgScrollRect.verticalNormalizedPosition = 0
            end
        end)
    end
    self.LeftRctTogSys.isOn = false
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

function ChatPanel:ShowRecent(isOn)
    if isOn then
        self.LeftRctPanel.gameObject:SetActive(true)
        self.MiddenDefaultPanel.gameObject:SetActive(true)
        self.MiddenChatPanel.gameObject:SetActive(false)
    else
        self.LeftRctPanel.gameObject:SetActive(false)
        self.MiddenDefaultPanel.gameObject:SetActive(false)
    end
end
function ChatPanel:ShowContacts(isOn)
    if isOn then 
        self.LeftConPanel.gameObject:SetActive(true)
        for i = self.LeftConContent.transform.childCount -1,0,-1 do
            local child = self.LeftConContent.transform:GetChild(i).gameObject
            GameObject.Destroy(child)
        end

        for playerId, _ in pairs(PlayerInfo.Friends) do
            local rctInfoObj = GameObject.Instantiate(self.TogInfo, self.LeftConContent):GetComponent(typeof(Toggle))
            rctInfoObj.group = self.LeftConCntTogGroup
            rctInfoObj.transform:Find("ImgAvatar"):GetComponent(typeof(Image)).sprite = AvatarSpriteAltas:GetSprite(PlayerInfo.Friends[playerId].playerAvatar)
            rctInfoObj.transform:Find("TextPlayerName"):GetComponent(typeof(TextMeshPro)).text = PlayerInfo.Friends[playerId].playerName
            rctInfoObj.onValueChanged:AddListener(function(isOn) 
                if isOn then
                    self.curChatPlayerId = playerId
                    self:clearChatMsg()
                    self.MiddenDefaultPanel.gameObject:SetActive(false)
                    self.MiddenChatPanel.gameObject:SetActive(true)
                    self:LoadMsgToMiddenChatPanel(self.curChatPlayerId)
                    self.MsgScrollRect.verticalNormalizedPosition = 0
                end
            end)
        end
    else
        self.LeftConPanel.gameObject:SetActive(false)
        self.MiddenChatPanel.gameObject:SetActive(false)
    end
end

function ChatPanel:ShowAddFriends(isOn)
    if isOn then
        self.LeftFriReqPanel.gameObject:SetActive(true)
        self.MiddenAddFrendPanel.gameObject:SetActive(true)
    else
        self.LeftFriReqPanel.gameObject:SetActive(false)
        self.MiddenAddFrendPanel.gameObject:SetActive(false)
    end
end

function ChatPanel:ShowEmail(isOn)
    if isOn then
        for i = 0,self.panelObj.transform:Find("Left").transform.childCount-1 do
            local child = self.panelObj.transform:Find("Left").transform:GetChild(i).gameObject
            if child.tag ~= "Email" then
                child:SetActive(false)
            else
                child:SetActive(true)
            end
        end
        for i = 0,self.Midden.transform.childCount-1 do
            local child = self.Midden.transform:GetChild(i).gameObject
            if child.tag ~= "Email" then
                child:SetActive(false)
            else
                child:SetActive(true)
            end
        end
        self:InitEmailList()
    else
        self.MiddenEmailDescPanel.gameObject:SetActive(false)
        self.MiddenDefaultPanel.gameObject:SetActive(true)
        for i = 0,self.panelObj.transform:Find("Left").transform.childCount-1 do
            local child = self.panelObj.transform:Find("Left").transform:GetChild(i).gameObject
            if child.tag ~= "Email" then
                child:SetActive(true)
            else
                child:SetActive(false)
            end
        end
    end
    
end
function ChatPanel:ShowEmailDesc(mail)
    self.TextSubject.text = mail.subject
    self.TextSendTime.text = os.date("%Y-%m-%d %H:%M:%S", mail.time)
    self.TextBody.text = mail.body
    self.GAttach.gameObject:SetActive(#mail.attachments > 0)
    self.AttachCells = self.GAttach:Find("AttachCells")
    if self.GAttach.gameObject.activeSelf then
        for i = 0, self.AttachCells.childCount -1 do
                local child = self.AttachCells:GetChild(i).gameObject
                GameObject.Destroy(child)
        end
        for i = 0, #mail.attachments -1 do 
            local PropPrefab = GameObject.Instantiate(self.PropPrefab, self.AttachCells)
            -- PropPrefab.transform:GetComponent(typeof(Image)).sprite = 
            if mail.isClaimed then
                PropPrefab.transform:Find("Image").gameObject:SetActive(true)
            end
            PropPrefab.transform:Find("TextNum"):GetComponent(typeof(TextMeshPro)).text = tostring(mail.attachments[i+1].quantity)
        end
    end
end
function ChatPanel:InitEmailList()
    print(type(EmailData))
    for _, mail in ipairs(EmailData) do
        local emailObj = GameObject.Instantiate(self.TogEmailInfo, self.LeftEmailContent):GetComponent(typeof(Toggle))
        emailObj.group = self.LeftEmailCntTogGroup
        emailObj.onValueChanged:AddListener(function(isOn) if isOn then self:ShowEmailDesc(mail) end end)
        emailObj.transform:Find("TextSubject"):GetComponent(typeof(TextMeshPro)).text = mail.subject
    end
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