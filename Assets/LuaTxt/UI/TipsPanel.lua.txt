TipsPanel = {}
TipsPanel.panelObj = nil
TipsPanel.ImgTipsLabel = nil
TipsPanel.ImgBG=nil
TipsPanel.TextTipsLabel=nil
TipsPanel.TextTipsContent=nil

local timer = 0
local isPanelActive = false

function TipsPanel:Init()
    if  self.panelObj == nil then
        -- 1.实例化面板对象，设置父对象
        -- LoadRes(abName,resName)
        self.panelObj = ABMgr:LoadRes("UI","TipsPanel")
        self.panelObj.transform:SetParent(Canvas,false)

        -- 2.找到对应控件 再找到挂在身上想要的脚本
        self.ImgTipsLabel = self.panelObj.transform:Find("ImgTipsLabel"):GetComponent(typeof(Image))
        self.ImgBG = self.panelObj.transform:Find("ImgBG"):GetComponent(typeof(Image))
        self.TextTipsLabel = self.panelObj.transform:Find("ImgTipsLabel/TextTipsLabel"):GetComponent(typeof(TextMeshPro))
        self.TextTipsContent = self.panelObj.transform:Find("ImgBG/TextTipsContent"):GetComponent(typeof(TextMeshPro))
        MonoBehaviourMgr:Register(self)
    end
end

function TipsPanel:Start()
    print("TipsPanel Start")
end

function TipsPanel:Update()
    if not isPanelActive then
        return -- 如果panel已经销毁，直接返回
    end
    
    timer = timer + Time.deltaTime
    if timer > 5 and isPanelActive then
        TipsPanel:DestroyPanel()
        isPanelActive = false
        showNextPanel = true
        timer = 0
    end
end

function TipsPanel:ShowMe()
    self:Init()
    self.panelObj:SetActive(true)
    isPanelActive = true
end

function TipsPanel:HideMe()
    self.panelObj:SetActive(false)
end

function TipsPanel:SetTipsText(TextTipsLabel,TextTipsContent)
    -- 确保面板已经初始化
    self:Init()

    -- 设置标题文本
    if self.TextTipsLabel then
        self.TextTipsLabel.text = TextTipsLabel
    end

    -- 设置内容文本
    if self.TextTipsContent then
        self.TextTipsContent.text = TextTipsContent
    end
end


function TipsPanel:OnDestroy()
    print("TipsPanel OnDestroy")
end

function TipsPanel:DestroyPanel()
    GameObject.Destroy(self.panelObj)
    TipsPanel.panelObj = nil
    TipsPanel.ImgTipsLabel = nil
    TipsPanel.ImgBG=nil
    TipsPanel.TextTipsLabel=nil
    TipsPanel.TextTipsContent=nil
end