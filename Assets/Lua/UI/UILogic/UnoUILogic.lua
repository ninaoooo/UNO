local UnoUILogic = {}

-- 绑定按钮点击事件
function UnoUILogic.BindButtonClick(button, onClickCallback)
    if not button then return end
    -- 解绑已有的事件
    button.onClick:RemoveAllListeners()
    -- 绑定新的事件
    button.onClick:AddListener(onClickCallback)
end

return UnoUILogic


