EnumUnoCardType = {
    eZero = 0,
    eOne = 1,
    eTwo = 2,
    eThree = 3,
    eFour = 4,
    eFive = 5,
    eSix = 6,
    eSeven = 7,
    eEight = 8,
    eNine = 9,
    eSkip = 10,
    eReverse = 11,
    eDrawTwo = 12,
    eWild = 13,
    eWildDrawFour = 14,
    eUnknown = 15,
}

EnumUnoCardColor = {
    eRed = 1,
    eGreen = 2,
    eBlue = 3,
    eYellow = 4,
    eWild = 5,           -- 这个是不是多余的，先留着
    eUnknown = 6,
}

EnumRoundStage = {
    eWaitPlay = 1,                  -- 等待玩家出牌
    eWaitConfirmDrawFour = 2,       -- 等待玩家接受+4牌
    eWaitConfirmPlay = 3,           -- 等待玩家确认是否打出摸到的牌
    eWaitShowSkip = 4,              -- 等待动画展示，比如+2，跳过等
    eWaitShowDraw = 5,              -- 等待动画展示抽卡
    eWaitShowReverse = 6,           -- 等待动画展示翻转
    eEnd = 7,                       -- 已经结束
}

-- UNO通用配置
UnoCommonConfig = {
    PrepreDuration = 10,    -- 准备时间
    PlayDuration = 300,     -- 游戏时间
    EndDuration = 10,       -- 结算时间
    SingleOpDuration = 6,   -- 单次操作时间
    ConfirmDuration = 6,    -- 确认时间
    ShowDuration = 1,       -- 展示时间
    CardType2Score = {
        [EnumUnoCardType.eZero] = 0,
        [EnumUnoCardType.eOne]  = 1,
        [EnumUnoCardType.eTwo]  = 2,
        [EnumUnoCardType.eThree] = 3,
        [EnumUnoCardType.eFour] = 4,
        [EnumUnoCardType.eFive] = 5,
        [EnumUnoCardType.eSix] = 6,
        [EnumUnoCardType.eSeven] = 7,
        [EnumUnoCardType.eEight] = 8,
        [EnumUnoCardType.eNine] = 9,
        [EnumUnoCardType.eSkip] = 20,
        [EnumUnoCardType.eReverse] = 20,
        [EnumUnoCardType.eDrawTwo] = 20,
        [EnumUnoCardType.eWild] = 50,
        [EnumUnoCardType.eWildDrawFour] = 50,
    }
}


