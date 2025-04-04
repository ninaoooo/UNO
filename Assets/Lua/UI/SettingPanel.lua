SettingPanel = {}
local PlayerInfo = require("Tools/PlayerInfo")
function SettingPanel:Init()
    if self.panelObj == nil then
        self.panelObj = ABMgr:LoadRes("UI", "SettingPanel")
        self.panelObj.transform:SetParent(Canvas,false)  
        self.BtnReturn = self.panelObj.transform:Find("GReturn/BtnReturn"):GetComponent("Button")
        self.ImgAvatar = self.panelObj.transform:Find("GAvatar/BtnAvatar"):GetComponent("Image")
        self.TextPlayerName = self.panelObj.transform:Find("GPlayerName/TextPlayerName"):GetComponent(typeof(TextMeshPro))
        self.TextPlayerId = self.panelObj.transform:Find("GPlayerId/TextPlayerId"):GetComponent(typeof(TextMeshPro))
        self.ToggleMusic = self.panelObj.transform:Find("GMusicSetting/Toggle"):GetComponent(typeof(Toggle))
        self.ToggleSound = self.panelObj.transform:Find("GSoundSetting/Toggle"):GetComponent(typeof(Toggle))


        self.SliderMusicVolume = self.panelObj.transform:Find("GMusicSetting/Slider"):GetComponent(typeof(Slider))
        self.SliderSoundVolume = self.panelObj.transform:Find("GSoundSetting/Slider"):GetComponent(typeof(Slider))

        self.musicVolume = PlayerPrefs.GetFloat("MusicVolume")
        self.soundVolume = PlayerPrefs.GetFloat("SoundVolume")

        self.ToggleMusic.isOn = PlayerPrefs.GetInt("ToogleMusicIsOn",1) == 1 
        self.ToggleSound.isOn = PlayerPrefs.GetInt("ToogleSoundIsOn",1) == 1

        self.SliderMusicVolume.value = self.musicVolume
        self.SliderSoundVolume.value = self.soundVolume
        self.avatarString = PlayerInfo:GetPlayerAvatar()
        self.ImgAvatar.sprite = AvatarSpriteAltas:GetSprite(self.avatarString)
        self.TextPlayerName.text = PlayerInfo:GetPlayerName()
        self.TextPlayerId.text = PlayerInfo:GetPlayerId()
        self.BtnReturn.onClick:AddListener(function() self:OnBtnReturnClick() end)
        


        -- 添加值变化监听
        self.ToggleMusic.onValueChanged:AddListener(function(isOn)
            if isOn then
                LuaAudioMgr.SetMusicVolume(self.musicVolume)
                PlayerPrefs.SetInt("ToogleMusicIsOn", 1)
            elseif not isOn then
                LuaAudioMgr.SetMusicVolume(0)
                PlayerPrefs.SetInt("ToogleMusicIsOn", 0)
            end
            PlayerPrefs.Save()
        end)
        self.ToggleSound.onValueChanged:AddListener(function(isOn)
            if isOn then
                LuaAudioMgr.SetSoundVolume(self.soundVolume)
                PlayerPrefs.SetInt("ToogleSoundIsOn", 1)
            elseif not isOn then
                LuaAudioMgr.SetSoundVolume(0)
                PlayerPrefs.SetInt("ToogleSoundIsOn", 0)
            end
            PlayerPrefs.Save()
        end)
        self.SliderMusicVolume.onValueChanged:AddListener(function(value)
            print("value: " .. value)
            if self.ToggleMusic.isOn then
                LuaAudioMgr.SetMusicVolume(value)
            end
            PlayerPrefs.SetFloat("MusicVolume", value)
            PlayerPrefs.Save()
        end)
        self.SliderSoundVolume.onValueChanged:AddListener(function(value)
            print("value: " .. value)
            if self.ToggleSound.isOn then
                LuaAudioMgr.SetSoundVolume(value)
            end
            PlayerPrefs.SetFloat("SoundVolume", value)
            PlayerPrefs.Save()
        end)    
        MonoBehaviourMgr:Register(self)
    end
end


function SettingPanel:OnBtnReturnClick()
    self:DestroyPanel()
    MainPanel:ShowMe()
end


function SettingPanel:DestroyPanel()
    GameObject.Destroy(self.panelObj)
    self.panelObj = nil
end

function SettingPanel:ShowMe()
    self:Init()
    self.panelObj:SetActive(true)
end