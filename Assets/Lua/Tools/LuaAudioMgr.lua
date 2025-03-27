LuaAudioMgr = {}

local MusicData = require("Tools/MusicData")
local SoundData = require("Tools/SoundData")

local musicABName = "music"
local soundABName = "sound"

local musicList = MusicData.LoadMusicList()
local soundList = SoundData.LoadSoundList()

-- 加载音乐音效
function LuaAudioMgr.LoadAudio(abName, audioList)
    for _, audioData in ipairs(audioList) do
        AudioMgr:LoadAudio(audioData.Name,abName)
    end
end

function LuaAudioMgr.Init()
    local musicVolume = PlayerPrefs.HasKey("MusicVolume") and PlayerPrefs.GetFloat("MusicVolume") or 1.0
    local soundVolume = PlayerPrefs.HasKey("SoundVolume") and PlayerPrefs.GetFloat("SoundVolume") or 1.0

    LuaAudioMgr.LoadAudio(musicABName, musicList)
    LuaAudioMgr.LoadAudio(soundABName, soundList)
    LuaAudioMgr.PlayMusic(musicABName,"Village Tarantella")
    LuaAudioMgr.SetMusicVolume(musicVolume)
    LuaAudioMgr.SetSoundVolume(soundVolume)
end

function LuaAudioMgr.PlayMusic(abName, musicName)
    AudioMgr:PlayMusic(abName, musicName)
end

function LuaAudioMgr.PlaySound(abName, soundName)
    AudioMgr:PlaySound(abName, soundName)
end

function LuaAudioMgr.SetMusicVolume(volume)
    AudioMgr:SetMusicVolume(volume)  
end

function LuaAudioMgr.SetSoundVolume(volume)
    AudioMgr:SetSoundVolume(volume)
end

LuaAudioMgr.Init()