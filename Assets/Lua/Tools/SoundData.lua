local SoundData = {}
function SoundData.LoadSoundList()    
    local txt = ABMgr:LoadRes("json","SoundData",typeof(TextAsset))
    local soundList = Json.decode(txt.text)
    return soundList
end

return SoundData