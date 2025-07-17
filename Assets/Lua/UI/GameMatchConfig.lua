local GameMacthConfig = {}

GameMacthConfig.WildCardColorButtons = {
    { name = "BtnRed", color = EnumUnoCardColor.eRed },
    { name = "BtnBlue", color = EnumUnoCardColor.eBlue },
    { name = "BtnGreen", color = EnumUnoCardColor.eGreen },
    { name = "BtnYellow", color = EnumUnoCardColor.eYellow },
}

GameMacthConfig.PlaySoundByType = {
    [10] = true,     -- 10
    [11] = true,  -- 11
    [12] = true,  -- 12
}
GameMacthConfig.PlaySoundByColor = {
    [EnumUnoCardColor.eRed] = true,        
    [EnumUnoCardColor.eGreen] = true,
    [EnumUnoCardColor.eBlue] = true,
    [EnumUnoCardColor.eYellow] = true,
}

GameMacthConfig.ShowTextByType = {
    [EnumUnoCardType.eSkip] = "Skip",     -- 10
    [EnumUnoCardType.eReverse] = "Reverse",  -- 11
    [EnumUnoCardType.eDrawTwo] = "Draw 2",  -- 12
}

GameMacthConfig.ShowTextByColor = {
    [EnumUnoCardColor.eRed] = "Red",        
    [EnumUnoCardColor.eGreen] = "Green",
    [EnumUnoCardColor.eBlue] = "Blue",
    [EnumUnoCardColor.eYellow] = "Yellow",
}

return GameMacthConfig