local EmailData = {
    {
        id = os.time(),  -- 邮件ID，使用当前时间戳作为唯一ID
        subject = "你的特别奖励",  -- 邮件主题
        body = "恭喜你！你获得了特别奖励！",
        time = os.time(),  -- 邮件发送时间（当前时间）
        attachments = {    -- 附件：道具
            {itemId = 1, itemName = "生命药水", quantity = 5},
            {itemId = 2, itemName = "法力药水", quantity = 3},
            {itemId = 3, itemName = "金币", quantity = 100}
        },
        isRead = false,  -- 邮件是否已读
        isClaimed = false  -- 邮件是否已领取道具
    },
    {
        id = os.time() - 7200,  -- 邮件ID，当前时间前2小时
        subject = "节日快乐！",  -- 邮件主题
        body = "祝你节日快乐！享受节日特别奖励吧！",
        time = os.time() - 7200,  -- 邮件发送时间（2小时前）
        attachments = {    -- 附件：道具
            {itemId = 2, itemName = "法力药水", quantity = 3},
            {itemId = 4, itemName = "经验卷轴", quantity = 1}
        },
        isRead = false,  -- 邮件是否已读
        isClaimed = false  -- 邮件是否已领取道具
    },
    {
        id = os.time() - 14400,  -- 邮件ID，当前时间前4小时
        subject = "每日登录奖励",  -- 邮件主题
        body = "感谢你今天的登录！这是你的每日奖励！",
        time = os.time() - 14400,  -- 邮件发送时间（4小时前）
        attachments = {    -- 附件：道具
            {itemId = 1, itemName = "生命药水", quantity = 5}
        },
        isRead = true,  -- 邮件是否已读
        isClaimed = true  -- 邮件是否已领取道具
    }
}

function EmailData:sortEmail()
    table.sort(self,function(a,b)
        if a.isRead == false and b.isRead == true then
            return true
        elseif a.isRead == true and b.isRead == false then
            return false
        else
            return a.time > b.time
        end
    end)
end

EmailData:sortEmail()

return EmailData