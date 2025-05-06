local MusicData = {}

function MusicData.LoadMusicList()
    local txt = ABMgr:LoadRes("json","MusicData",typeof(TextAsset))
    local musicList = Json.decode(txt.text)
    return musicList
end

return MusicData