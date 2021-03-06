#define G2A(G) ((G)*256)
#define G2AMID(G) ((G)*256 + 128)

mission "MainMenu_Mission_07"
{
	function void CommandMoveUnitToMarker(unit uUnit, int nMarker)
	{
		int nGx, nGy;

		GetMarker(nMarker, nGx, nGy);

		uUnit.CommandMove(G2AMID(nGx), G2AMID(nGy));
	}

	function unit CreatePlayerObjectAtMarker(player pPlayer, string strObject, int nMarker, int nAlpha)
	{
		int nGx, nGy;

		GetMarker(nMarker, nGx, nGy);

		return pPlayer.CreateObject(strObject, nGx, nGy, 0, nAlpha);
	}
	function unit CreatePlayerObjectAtMarker(player pPlayer, string strObject, int nMarker)
	{
		int nGx, nGy, nAlpha;

		GetMarker(nMarker, nGx, nGy);

		nAlpha = 0; // bo narazie markery bez kierunku

		return pPlayer.CreateObject(strObject, nGx, nGy, 0, nAlpha);
	}
	
state Initialize;
state CreateObjects;
state StartCamera;

player m_pLC;
player m_pED;
player m_pUCS;
	
unit m_auAttackers[];
unit m_auDefenders[];


int nTicks, nType, nPhase, nWave;

state Initialize
{
	int i;
    unit uUnit;

	m_pUCS = GetPlayer(1);
	m_pED = GetPlayer(2);
	m_pLC = GetPlayer(3);


	m_pUCS.SetEnemy(m_pLC);
	m_pLC.SetEnemy(m_pUCS);
	SetWind(30,100);//strenght[0-100],Direction[0-255]


	m_auAttackers.Create(0);
	m_auDefenders.Create(0);

	nType = Rand(4);

	for(i = 9; i < 13; i = i+1)
	{
		if(nType==0) uUnit = CreatePlayerObjectAtMarker(m_pLC, "L_CH_GT_04_1#L_WP_PB_04_2,L_AR_CL_04_1,L_EN_NO_04_1", i);
		if(nType==1) uUnit = CreatePlayerObjectAtMarker(m_pLC, "L_IN_RG_01_1", i);
		if(nType==2) uUnit = CreatePlayerObjectAtMarker(m_pED, "E_CH_GJ_02_1#E_WP_SL_02_1,E_AR_CH_02_1,E_EN_SP_02_1", i);
		if(nType==3) uUnit = CreatePlayerObjectAtMarker(m_pED, "E_IN_MA_01_1", i);
		m_auDefenders.Add(uUnit);
		uUnit.CommandSetMovementMode(2); 
		CommandMoveUnitToMarker(uUnit, i+3);
	}
	
    return StartCamera,1;
}


state StartCamera
{
	nTicks = PlayCutscene("Main_07.trc", false, false, false) - 100;
	return CreateObjects, 100;
}

state CreateObjects
{
	int nGx, nGy, i;
	int nTx, nTy;
	unit uUnit;



	for(i = 9; i < 13; i = i+1)
	{
		if(nType==0) uUnit = CreatePlayerObjectAtMarker(m_pLC, "L_CH_GT_04_1#L_WP_PB_04_2,L_AR_CL_04_1,L_EN_NO_04_1", i);
		if(nType==1) uUnit = CreatePlayerObjectAtMarker(m_pLC, "L_IN_RG_01_1", i);
		if(nType==2) uUnit = CreatePlayerObjectAtMarker(m_pED, "E_CH_GJ_02_1#E_WP_SL_02_1,E_AR_CH_02_1,E_EN_SP_02_1", i);
		if(nType==3) uUnit = CreatePlayerObjectAtMarker(m_pED, "E_IN_MA_01_1", i);
		m_auDefenders.Add(uUnit);
		uUnit.CommandSetMovementMode(2); 
		CommandMoveUnitToMarker(uUnit, i+3);
	}
	
	if(m_pLC.GetNumberOfUnits()==0)
		for(i=21;i<=26;i=i+1)
		{
			GetMarker(i+5, nTx, nTy);
			GetMarker(i, nGx, nGy);
			
			uUnit = m_pLC.CreateObject("L_CH_GT_04_1#L_WP_PB_04_2,L_AR_CH_04_1,L_EN_PR_04_1", nGx, nGy, 0, 0);
			uUnit.CommandMove(G2AMID(nTx), G2AMID(nTy));
		}


	if(m_pUCS.GetNumberOfUnits()==0)
	{
		if(nWave==10) nWave=0;
		else nWave=10;
		for(i=1;i<=6;i=i+1)
		{
			
			GetMarker(i+5+nWave, nTx, nTy);
			GetMarker(i+nWave, nGx, nGy);
			
			if(Rand(2)) uUnit = m_pUCS.CreateObject("U_CH_GT_03_1#U_WP_AR_03_1,U_AR_CH_03_1,U_EN_NO_03_1", nGx, nGy, 0, 0);
			else uUnit = m_pUCS.CreateObject("U_CH_GJ_02_1#U_WP_NG_02_1,U_AR_CH_02_1,U_EN_PR_02_1", nGx, nGy, 0, 0);
			uUnit.CommandMove(G2AMID(nTx), G2AMID(nTy));
		}
	}



	if(nTicks>900) 
	{
		nTicks=nTicks-900;
		return CreateObjects, 900;
	}
	else
		return StartCamera,nTicks;
}

}
