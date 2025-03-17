InputMgr = {}
function InputMgr:GetKey(keycode, source)
    -- 默认来源是键盘 还可以是远程网络输入
    if source == nil then
        return Input.GetKey(keycode)
    end
    
end