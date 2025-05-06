-- MsgPrompt.lua
-- 提示条模块

local MsgPrompt = {}
local DestroyTime = 2 -- 默认销毁时间为 2 秒

-- 设置提示条预制体
function MsgPrompt:SetPromptPrefab(prefab)
    self.promptPrefab = prefab
end

-- 显示提示条
function MsgPrompt:ShowPrompt(message, parent)
    -- 检查预制体是否加载
    if not self.promptPrefab then
        print("提示条预制体未加载！")
        return
    end

    -- 实例化提示条
    local prompt = GameObject.Instantiate(self.promptPrefab, parent)
    local promptBackground = prompt:GetComponentInChildren(typeof(Image)) -- 获取背景组件
    local promptText = promptBackground:GetComponentInChildren(typeof(TextMeshPro)) -- 获取Text组件

    -- 设置提示内容
    promptText.text = message

    -- 动态调整提示条的宽高
    self:AdjustPromptSize(promptText, promptBackground)

    -- 显示提示条
    print("显示提示条: " .. message)

    GameObject.Destroy(prompt, DestroyTime)
end

-- 动态调整提示条的宽高
function MsgPrompt:AdjustPromptSize(promptText, promptBackground)
    -- 获取文本的宽高
    local textWidth = promptText.preferredWidth
    local textHeight = promptText.preferredHeight

    -- 设置内边距
    local padding = 20 -- 内边距
    local backgroundWidth = textWidth + padding * 2
    local backgroundHeight = textHeight

    -- 调整背景的大小
    local backgroundRect = promptBackground.rectTransform
    backgroundRect.sizeDelta = Vector2(backgroundWidth, backgroundHeight)

    -- 设置背景图的锚点为底部对齐父对象
    backgroundRect.anchorMin = Vector2(0.5, 0) -- 水平居中，底部对齐
    backgroundRect.anchorMax = Vector2(0.5, 0) -- 水平居中，底部对齐
    backgroundRect.anchoredPosition = Vector2(0, backgroundHeight / 2) -- 调整位置，确保底部对齐

    -- 调整文本的位置（居中）
    local textRect = promptText.rectTransform

    -- 将文本的锚点设置为背景图的中心
    textRect.anchorMin = Vector2(0.5, 0.5)
    textRect.anchorMax = Vector2(0.5, 0.5)
    textRect.anchoredPosition = Vector2(0, 0) -- 居中
end


-- 加载提示条预制体
function MsgPrompt:LoadPromptPrefab(prefab)
    self.promptPrefab = prefab
end

-- 返回模块
return MsgPrompt