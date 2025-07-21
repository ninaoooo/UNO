ChatPanel = {}
function ChatPanel:Init()
    if  self.panelObj == nil then
        -- 1.实例化面板对象，设置父对象
        -- LoadRes(abName,resName)
        self.panelObj = ABMgr:LoadRes("UI","ChatPanel")
        self.panelObj.transform:SetParent(Canvas,false)
        self.GInfo = ABMgr:LoadRes("modes","GInfo")
        self.SpriteEmoji = ABMgr:LoadRes("UI","Emoji")
        self.EmojiPrefab = ABMgr:LoadRes("modes","ImgEmoji")
        
        self.BtnClose = self.panelObj.transform:Find("Right/BtnClose"):GetComponent(typeof(Button))

        self.BtnVoice = self.panelObj.transform:Find("Midden/Input/BtnVoice"):GetComponent(typeof(Button))
        self.BtnEmoji = self.panelObj.transform:Find("Midden/Input/BtnEmoji"):GetComponent(typeof(Button))
        self.BtnSend = self.panelObj.transform:Find("Midden/Input/BtnSend"):GetComponent(typeof(Button))
        self.InputField = self.panelObj.transform:Find("Midden/Input/InputField"):GetComponent(typeof(TextMeshProInputField))
        
        self.GEmojiPanel = self.panelObj.transform:Find("Midden/EmojiPanel")
        self.BtnEmoji.onClick:AddListener(function () self:BtnEmojiOnClick() end)
        self.InputField.onSelect:AddListener(function () self:InputFieldOnClick() end)
        self.BtnClose.onClick:AddListener(function () self:BtnCloseOnClick() end)
        self.BtnSend.onClick:AddListener(function () self:BtnSendOnClick() end)
        self:InitEmojiPanel()
        print("25",self)
        MonoBehaviourMgr:Register(self)
    end
end

function ChatPanel:BtnCloseOnClick()
    self.GEmojiPanel.gameObject:SetActive(true)
end

function ChatPanel:BtnSendOnClick()
    self.GEmojiPanel.gameObject:SetActive(false)
    local inputText = self.InputField.text
    local renderText = renderChatMessage(inputText)
    self.InputField.text = renderText
    print("39 ",renderText)
end
function ChatPanel:BtnEmojiOnClick()
    self.GEmojiPanel.gameObject:SetActive(true)
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