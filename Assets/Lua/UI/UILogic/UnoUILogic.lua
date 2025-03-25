local UnoUILogic = {}

UnoUILogic.WildCardColorButtons = {
    { name = "BtnRed", color = EnumUnoCardColor.eRed },
    { name = "BtnBlue", color = EnumUnoCardColor.eBlue },
    { name = "BtnGreen", color = EnumUnoCardColor.eGreen },
    { name = "BtnYellow", color = EnumUnoCardColor.eYellow },
}

-- 绑定按钮点击事件
function UnoUILogic.BindButtonClick(button, onClickCallback)
    if not button then return end
    -- 解绑已有的事件
    button.onClick:RemoveAllListeners()
    -- 绑定新的事件
    button.onClick:AddListener(onClickCallback)
end

return UnoUILogic


