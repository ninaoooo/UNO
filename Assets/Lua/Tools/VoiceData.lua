local VoiceData = {}

function VoiceData.LoadVoiceList()
    local txt = ABMgr:LoadRes("json","VoiceData",typeof(TextAsset))
    local voiceList = Json.decode(txt.text)
    return voiceList
end
return VoiceData