return {
	{"SyncName", "ss"},	 -- 这里的value写函数参数，注释写参数含义会比较好
	{"SyncRoom", "sss"},
	{"SyncIntAndS","IIs"},
	{"NoParam", ""},
	{"RegisterUserResult", "y"},
	{"LoginUserResult", "yIs"},
	{"ChangePasswardResult", "y"},
	{"SyncPlayerComeInPlay", "Is"},		-- matchType, playerIds_U
	{"SyncUnoCards", "IIs"},			-- playerId, cardNum, cards_U
	{"SyncUnoCardDraw", "IIIy"},		-- playerId, cardType, cardColor, confirmshow
	{"SyncUnoCardPlay", "III"},			-- playerId, cardType, cardColor
	{"ShowUnoWaitConfirmCard", "IIII"}, -- playerId, cardIdx, cardType, cardColor
	{"SyncUnoPlayRoundInfo", "IIII"},	-- totalRestTime, curOpRestTime, curPlayerId, stage
	{"SyncUnoShoutUno", "Iy"},			-- playerId, hasUno
	{"SyncUnoPlayEnd", "Is"},			-- winPlayerId, playerCardInfo_U
}