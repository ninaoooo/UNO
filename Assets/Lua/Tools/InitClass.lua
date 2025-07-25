ABMgr = CS.ABMgr.GetInstance()

-- 常用别名都在这里定位
require("Tools/Object")
require("Tools/SplitTools")
require("Base/HotReloadManager")
require("Tools/UnoCardImageReflect")
require("Tools/Quaternion")
DynamicEffects = require("DynamicEffect/DynamicEffects")
require("Tools/CountdownTimer")
require("defs/UnoConfig")
require("Base/RpcMgr")
require("Base/MonoBehaviourMgr")
require("Base/InputMgr")
require("Base/UpdateTimeMgr")
require("Tools/CountdownTimer")
MsgPrompt = require("/UI/Tools/MsgPrompt")
Json = require("Tools/JsonUtility")
require("Tools/SplitTools")
require("Tools/MsgData")
require("Tools/MsgDataMgr")
require("GameLogic/BagMgr")
Config = require("Data/Config")
PlayerInfo = require("Tools/PlayerInfo")
if type(CountdownTimer) ~= "table" then
    error("Failed to load CountdownTimer module: " .. tostring(CountdownTimer))
end
-- unity 相关
GameObject = CS.UnityEngine.GameObject
Resources = CS.UnityEngine.Resources
Transform = CS.UnityEngine.Transform
RectTransform = CS.UnityEngine.RectTransform
-- 图集对象类
SpriteAtlas = CS.UnityEngine.U2D.SpriteAtlas
TextAsset = CS.UnityEngine.TextAsset
Sprite = CS.UnityEngine.Sprite

Vector3 = CS.UnityEngine.Vector3
Vector2 = CS.UnityEngine.Vector2
-- Canvas
Canvas = GameObject.Find("Canvas").transform

MainCamara = CS.UnityEngine.Camera.main

-- UI相关
UIBehaviour = CS.UnityEngine.EventSystems.UIBehaviour
UI = CS.UnityEngine.UI
Image = UI.Image
Text = UI.Text
TextMeshPro = CS.TMPro.TextMeshProUGUI
TextMeshProInputField = CS.TMPro.TMP_InputField
Button = UI.Button 
Toggle = UI.Toggle
ToggleGroup = UI.ToggleGroup
ScrollRect = UI.ScrollRect
Slider = CS.UnityEngine.UI.Slider
-- 操作相关
Input = CS.UnityEngine.Input
KeyCode = CS.UnityEngine.KeyCode
PlayerPrefs = CS.UnityEngine.PlayerPrefs

-- 时间相关
Time = CS.UnityEngine.Time
WaitForSeconds = CS.UnityEngine.WaitForSeconds

-- 自己写的C#相关脚本 直接获得单例对象

AudioMgr = CS.AudioMgr.GetInstance()
LuaBehaviour = CS.LuaBehaviour
TimerUtility = CS.TimerUtility.GetInstance()

require("Tools/LuaAudioMgr")

-- 自己打的图集
AvatarSpriteAltas = ABMgr:LoadRes("UI", "Avatar")
PorpSpriteAltas = ABMgr:LoadRes("UI", "Porp")
