ChatPanel = {}
local VoiceData = require("Tools/VoiceData")
local VoiceList = VoiceData.LoadVoiceList()
local PoolMgr = require("UI/Pools/PoolMgr")
local MsgRightPool = PoolMgr:getPool("msgRightPool")
local MsgLeftPool = PoolMgr:getPool("msgLeftPool")
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

        self.BtnVoice = self.panelObj.transform:Find("Midden/Input/BtnVoice"):GetComponent(typeof(Button))
        self.BtnEmoji = self.panelObj.transform:Find("Midden/Input/BtnEmoji"):GetComponent(typeof(Button))
        self.BtnSend = self.panelObj.transform:Find("Midden/Input/BtnSend"):GetComponent(typeof(Button))
        self.InputField = self.panelObj.transform:Find("Midden/Input/InputField"):GetComponent(typeof(TextMeshProInputField))
        self.MsgContent = self.panelObj.transform:Find("Midden/Scroll View/Viewport/Content")
        self.GEmojiPanel = self.panelObj.transform:Find("Midden/EmojiPanel")
        self.GVoicePanel = self.panelObj.transform:Find("Midden/VoicePanel")
        self.BtnEmoji.onClick:AddListener(function () self:BtnEmojiOnClick() end)
        self.InputField.onSelect:AddListener(function () self:InputFieldOnClick() end)
        self.BtnClose.onClick:AddListener(function () self:BtnCloseOnClick() end)
        self.BtnSend.onClick:AddListener(function () self:BtnSendOnClick() end)

        self.BtnVoice.onClick:AddListener(function () self:BtnVoiceOnClick() end)
        self:InitEmojiPanel()
        self:InitVoicePanel()
        MonoBehaviourMgr:Register(self)
    end
end

function ChatPanel:SetMsgPrefabs(msgType,msgHolder,renderedMsg)
    if(msgHolder == "self") then
        local msgObj = MsgRightPool:get()
        msgObj.transform:SetParent(self.MsgContent,false)
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
    self:SetMsgPrefabs("voice","self",renderedMsg(msg))
end
function ChatPanel:BtnVoiceOnClick()
    self.GVoicePanel.gameObject:SetActive(not self.GVoicePanel.gameObject.activeSelf)
end
function ChatPanel:BtnSendOnClick()
    self.GEmojiPanel.gameObject:SetActive(false)
    local inputText = self.InputField.text
    local msg = inputText.."#n"
    self:SetMsgPrefabs("text","self",renderedMsg(msg))
    self.InputField.text = ""

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

function ChatPanel:InputFieldOnClick()
    self.GEmojiPanel.gameObject:SetActive(false)
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
function ChatPanel:Start()
end

function ChatPanel:ShowMe()
    self:Init()
    self.panelObj:SetActive(true)
    
end

function ChatPanel:HideMe()
    self.panelObj:SetActive(false)
end



function OnEmojiSelectedHandler(i)
    print("这是表情i")
end
function ChatPanel:DestroyPanel()
    GameObject.Destroy(self.panelObj)
    LoginPanel.panelObj = nil
end