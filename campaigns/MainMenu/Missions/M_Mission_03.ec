#define G2A(G) ((G)*256)
#define G2AMID(G) ((G)*256 + 128)

mission "MainMenu_Mission_03"
{
state Initialize;
state CreateObjects;
state StartCamera;

player m_pLC;
player m_pUCS;
	


int nTicks, nUCS, nLC, nWave;

state Initialize
{
	m_pUCS = GetPlayer(1);
	m_pLC = GetPlayer(3);

	m_pUCS.SetEnemy(m_pLC);
	m_pLC.SetEnemy(m_pUCS);
SetWind(30,100);//strenght[0-100],Direction[0-255]
    return StartCamera,1;
}


state StartCamera
{
	nTicks = PlayCutscene("Main_03.trc", false, false, false) - 100;
	return CreateObjects, 100;
}

state CreateObjects
{
	int nGx, nGy, i;
	int nTx, nTy;
	unit uUnit;

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
	if(nTicks>1600) 
	{
		nTicks=nTicks-1600;
		return CreateObjects, 1600;
	}
	else
		return StartCamera,nTicks;
}

}
