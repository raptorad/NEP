#define G2A(G) ((G)*256)
#define G2AMID(G) ((G)*256 + 128)

mission "MainMenu_Mission_01"
{
state Initialize;
state CreateObjects;
state StartCamera;

//marker 1 - ucs - atak
//marker 2  - posilki
//marker 3 - miejsce do ktorego ida.

player m_pLC;
player m_pUCS;
	


int nTicks, nUCS, nLC;

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
	nTicks = PlayCutscene("Main_01.trc", false, false, false);
	return CreateObjects, (nTicks/2)-1;
}

state CreateObjects
{
	int nGx, nGy, i;
	int nTx, nTy;
	unit uUnit;

	if(m_pLC.GetNumberOfUnits()==0)
	for(i=1;i<=5;i=i+2)
	{
	//TraceD("                                          Create LC unit on marker ");
	//TraceD(i); TraceD("      \n");
	GetMarker(i+1, nTx, nTy);
	GetMarker(i, nGx, nGy);
	
	uUnit = m_pLC.CreateObject("L_CH_GT_04_1#L_WP_PB_04_2,L_AR_RL_04_1,L_EN_NO_04_1", nGx, nGy, 0, 0);
	uUnit.CommandMove(G2AMID(nTx), G2AMID(nTy));
	}
	if(m_pUCS.GetNumberOfUnits()==0)
	for(i=11;i<=17;i=i+2)
	{
	//TraceD("                                             Create UCS unit on marker ");
	//TraceD(i); TraceD("      \n");
	
	GetMarker(i+1, nTx, nTy);
	GetMarker(i, nGx, nGy);
	
	if(i<14) uUnit = m_pUCS.CreateObject("U_CH_GT_03_1#U_WP_AR_03_1,U_AR_CL_03_1,U_EN_NO_03_1", nGx, nGy, 0, 0);
	else uUnit = m_pUCS.CreateObject("U_CH_GJ_02_1#U_WP_NG_02_1,U_AR_CL_02_1,U_EN_PR_02_1", nGx, nGy, 0, 0);
	uUnit.CommandMove(G2AMID(nTx), G2AMID(nTy));
	}
	return StartCamera,(nTicks/2)-1;
}

}
