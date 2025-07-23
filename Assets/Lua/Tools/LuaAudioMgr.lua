LuaAudioMgr = {}

local MusicData = require("Tools/MusicData")
local SoundData = require("Tools/SoundData")
local VoiceData = require("Tools/VoiceData")





local musicVolume = PlayerPrefs.HasKey("MusicVolume") and PlayerPrefs.GetFloat("MusicVolume") or 1.0
local soundVolume = PlayerPrefs.HasKey("SoundVolume") and PlayerPrefs.GetFloat("SoundVolume") or 1.0

local ToggleMusicIsOn = PlayerPrefs.GetInt("ToogleMusicIsOn",1) == 1 
local ToggleSoundIsOn = PlayerPrefs.GetInt("ToogleSoundIsOn",1) == 1
-- 加载音乐音效
function LuaAudioMgr:LoadAudio(abName, audioList)
    for _, audioData in ipairs(audioList) do
        AudioMgr:LoadAudio(abName, audioData.Name)
    end
end

function LuaAudioMgr:Init()
    self.musicABName = "music"
    self.soundABName = "sound"
    self.musicList = MusicData.LoadMusicList()
    self.soundList = SoundData.LoadSoundList()
    self.voiceList = VoiceData.LoadVoiceList()
    LuaAudioMgr:LoadAudio(self.musicList, self.musicABName)
    LuaAudioMgr:LoadAudio(self.soundList, self.soundABName)
    LuaAudioMgr:PlayMusic(self.musicABName,"Village Tarantella")
    if not ToggleMusicIsOn then
        LuaAudioMgr.SetMusicVolume(0)
    else
        LuaAudioMgr.SetMusicVolume(musicVolume)
    end
    if not ToggleSoundIsOn then
        LuaAudioMgr.SetSoundVolume(0)
    else 
        LuaAudioMgr.SetSoundVolume(soundVolume)
    end
    
    
end

function LuaAudioMgr:PlayMusic(abName, musicName)
    AudioMgr:PlayMusic(abName, musicName)
end

function LuaAudioMgr:PlaySound(abName, soundName)
    AudioMgr:PlaySound(abName, soundName)
end

function LuaAudioMgr.SetMusicVolume(volume)
    AudioMgr:SetMusicVolume(volume)  
end

function LuaAudioMgr.SetSoundVolume(volume)
    AudioMgr:SetSoundVolume(volume)
end

function LuaAudioMgr:GetSoundNameById(Id)
    for _, soundData in ipairs(self.soundList) do
        if soundData.ID == Id then
            print(soundData.Name)
            return soundData.Name
        end
    end
    return ""
end

function LuaAudioMgr:GetMusicNameById(Id)
    for _, musicData in ipairs(self.musicList) do
        if musicData.ID == Id then
            return musicData.Name
        end
    end
    return ""
end

function LuaAudioMgr:GetVoiceNameById(Id)
    for _, voiceData in ipairs(self.voiceList) do
        if voiceData.ID == Id then
            return voiceData.Name
        end
    end
    return ""
end

LuaAudioMgr:Init()