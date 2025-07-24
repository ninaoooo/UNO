MsgDataMgr = {}

function MsgDataMgr:SaveToJson()
    local jsonMsgData = Json.encode(MsgData)
    PlayerPrefs.SetString("JsonMsgData", jsonMsgData)
end

function MsgDataMgr:LoadToMsgData()
    local jsonMsgData = PlayerPrefs.GetString("JsonMsgData", "")
    if jsonMsgData ~= "" then
        MsgData = Json.decode(jsonMsgData)
    else
        MsgData = {}
    end
end