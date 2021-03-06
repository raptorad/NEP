#define G2A(G) ((G)*256)
#define G2AMID(G) ((G)*256 + 128)

mission "MainMenu_Mission_02"
{
state Initialize;
state CreateObjects;
state StartCamera;


player m_pUCS;
player m_pED;
player m_pLC;
int nRace;

function void InitializeUCS()
{
	int nGx, nGy, i, k;
	int nTx, nTy;
	unit uUnit;

	if(m_pUCS.GetNumberOfUnits()==0)
	{
		for(i=21;i<=25;i=i+1)
		{
			GetMarker(i+10, nTx, nTy);
			GetMarker(i, nGx, nGy);

			k=Rand(12);

			if(k<3)	uUnit = m_pUCS.CreateObject("U_CH_GJ_02_1#U_WP_NG_02_1,U_AR_RL_02_1,U_EN_PR_02_1", nGx, nGy, 0, 0);
			
			if(k==3)	uUnit = m_pUCS.CreateObject("U_CH_GT_03_1#U_WP_CH_03_1,U_AR_RL_03_1,U_EN_SP_03_1", nGx, nGy, 0, 0);
			if(k==4)	uUnit = m_pUCS.CreateObject("U_CH_GT_03_1#U_WP_NG_03_1,U_AR_CH_03_1,U_EN_NO_03_1", nGx, nGy, 0, 0);
			if(k==5)	uUnit = m_pUCS.CreateObject("U_CH_GT_03_1#U_WP_CH_03_3,U_AR_CL_03_1,U_EN_PR_03_1", nGx, nGy, 0, 0);
			

			if(k==6)	uUnit = m_pUCS.CreateObject("U_CH_GT_04_1#U_WP_AR_04_1#U_WP_NG_04_1,U_AR_CL_04_1,U_EN_NO_04_1", nGx, nGy, 0, 0);
			if(k==7)	uUnit = m_pUCS.CreateObject("U_CH_GT_04_1#U_WP_PB_04_1#U_WP_XR_04_1,U_AR_CH_04_1,U_EN_SP_04_1", nGx, nGy, 0, 0);
			if(k==8)	uUnit = m_pUCS.CreateObject("U_CH_GT_04_1#U_WP_GB_04_1#U_WP_FT_04_1,U_AR_RL_04_1,U_EN_PR_04_1", nGx, nGy, 0, 0);
			

			if(k==9)	uUnit = m_pUCS.CreateObject("U_CH_GT_05_1#U_WP_AR_05_1,U_WP_AR2_05_1,U_AR_CL_05_1,U_EN_NO_05_1", nGx, nGy, 0, 0); 
			if(k==10)	uUnit = m_pUCS.CreateObject("U_CH_GT_05_1#U_WP_PB_05_1,U_WP_PB2_05_1,U_AR_CH_05_1,U_EN_SP_05_1", nGx, nGy, 0, 0); 
			if(k==11)	uUnit = m_pUCS.CreateObject("U_CH_GT_05_1#U_WP_GB_05_1,U_WP_GB2_05_1,U_AR_RL_05_1,U_EN_PR_05_1", nGx, nGy, 0, 0); 


			uUnit.CommandMove(G2AMID(nTx), G2AMID(nTy));
		}
	}
}

function void InitializeED()
{
	int nGx, nGy, i, k;
	int nTx, nTy;
	unit uUnit;

	if(m_pED.GetNumberOfUnits()==0)
	{
		for(i=21;i<=25;i=i+1)
		{
			GetMarker(i+10, nTx, nTy);
			GetMarker(i, nGx, nGy);

			k=Rand(15);

			if(k==0)	uUnit = m_pED.CreateObject("E_CH_GJ_02_1#E_WP_SL_02_1,E_AR_CH_02_1,E_EN_SP_02_1", nGx, nGy, 0, 0);
			if(k==1)	uUnit = m_pED.CreateObject("E_CH_GJ_02_1#E_WP_IO_02_1,E_AR_CL_02_1,E_EN_NO_02_1", nGx, nGy, 0, 0);
			if(k==2)	uUnit = m_pED.CreateObject("E_CH_GJ_02_1#E_WP_CR_02_1,E_AR_CL_02_1,E_EN_SP_02_1", nGx, nGy, 0, 0);
		
			if(k==3)	uUnit = m_pED.CreateObject("E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_CH_03_1,E_EN_SP_03_1", nGx, nGy, 0, 0);
			if(k==4)	uUnit = m_pED.CreateObject("E_CH_GJ_03_1#E_WP_IO_03_1,E_AR_CL_03_1,E_EN_NO_03_1", nGx, nGy, 0, 0);
			if(k==5)	uUnit = m_pED.CreateObject("E_CH_GJ_03_1#E_WP_CR_03_1,E_AR_CL_03_1,E_EN_SP_03_1", nGx, nGy, 0, 0);
		
			if(k==6)	uUnit = m_pED.CreateObject("E_CH_GT_04_1#E_WP_CA_04_1,E_AR_CH_04_1,E_EN_SP_04_1", nGx, nGy, 0, 0);
			if(k==7)	uUnit = m_pED.CreateObject("E_CH_GT_04_1#E_WP_HL_04_1,E_AR_CL_04_1,E_EN_NO_04_1", nGx, nGy, 0, 0);
			if(k==8)	uUnit = m_pED.CreateObject("E_CH_GT_04_1#E_WP_CB_04_1,E_AR_RL_04_1,E_EN_PR_04_1", nGx, nGy, 0, 0);
		
			if(k==9)	uUnit = m_pED.CreateObject("U_CH_GT_05_1#U_WP_AR_05_1,U_WP_AR2_05_1,U_AR_CL_05_1,U_EN_NO_05_1", nGx, nGy, 0, 0); 
			if(k==10)	uUnit = m_pED.CreateObject("E_CH_GT_05_1#E_WP_HL_05_1,E_AR_CL_05_1,E_EN_NO_05_1", nGx, nGy, 0, 0); 
			if(k==11)	uUnit = m_pED.CreateObject("E_CH_GT_05_1#E_WP_CB_05_1,E_AR_RL_05_1,E_EN_PR_05_1", nGx, nGy, 0, 0); 

			if(k==12)	uUnit = m_pED.CreateObject("E_CH_GT_06_1#E_WP_CA_06_1,E_WP_CA2_06_1,E_AR_CH_06_1,E_EN_SP_06_1", nGx, nGy, 0, 0); 
			if(k==13)	uUnit = m_pED.CreateObject("E_CH_GT_06_1#E_WP_HL_06_1,E_WP_HL2_06_1,E_AR_CL_06_1,E_EN_NO_06_1", nGx, nGy, 0, 0); 
			if(k==14)	uUnit = m_pED.CreateObject("E_CH_GT_06_1#E_WP_CB_06_1,E_WP_CB2_06_1,E_AR_RL_06_1,E_EN_PR_06_1", nGx, nGy, 0, 0); 

			uUnit.CommandMove(G2AMID(nTx), G2AMID(nTy));
		}
	}
}

function void InitializeLC()
{
	int nGx, nGy, i, k;
	int nTx, nTy;
	unit uUnit;

	if(m_pLC.GetNumberOfUnits()==0)
	{
		for(i=1;i<=5;i=i+1)
		{
			GetMarker(i+10, nTx, nTy);
			GetMarker(i, nGx, nGy);
			
			k=Rand(21);

			if(k<5) uUnit = m_pLC.CreateObject("L_CH_GJ_02_1#L_WP_EL_02_1,L_AR_CH_02_1,L_EN_NO_02_1", nGx, nGy, 0, 0);
			if(k>=5 && k<10) uUnit = m_pLC.CreateObject("L_CH_GJ_02_1#L_WP_PG_02_1,L_AR_CL_02_1,L_EN_SP_02_1", nGx, nGy, 0, 0);
			if(k>=10 && k<15) uUnit = m_pLC.CreateObject("L_CH_GJ_02_1#L_WP_SG_02_1,L_AR_RL_02_1,L_EN_NO_02_1", nGx, nGy, 0, 0);

			if(k==15) uUnit = m_pLC.CreateObject("L_CH_GT_04_1#L_WP_PB_04_1,L_AR_CH_04_1,L_EN_NO_04_1", nGx, nGy, 0, 0);
			if(k==16) uUnit = m_pLC.CreateObject("L_CH_GT_04_1#L_WP_PB_04_1,L_AR_CL_04_1,L_EN_SP_04_1", nGx, nGy, 0, 0);
			if(k==17) uUnit = m_pLC.CreateObject("L_CH_GT_04_1#L_WP_PB_04_1,L_AR_RL_04_1,L_EN_PR_04_1", nGx, nGy, 0, 0);
			
			if(k==18) uUnit = m_pLC.CreateObject("L_CH_GT_05_1#L_WP_PB_05_1#L_WP_PB2_05_1,L_AR_CH_05_1,L_EN_NO_05_1", nGx, nGy, 0, 0);
			if(k==19) uUnit = m_pLC.CreateObject("L_CH_GT_05_1#L_WP_PB_05_1#L_WP_PB2_05_1,L_AR_CL_05_1,L_EN_SP_05_1", nGx, nGy, 0, 0);
			if(k==20) uUnit = m_pLC.CreateObject("L_CH_GT_05_1#L_WP_PB_05_1#L_WP_PB2_05_1,L_AR_RL_05_1,L_EN_PR_05_1", nGx, nGy, 0, 0);
			
			uUnit.CommandMove(G2AMID(nTx), G2AMID(nTy));
		}
	}
}

int nTicks, nUCS, nLC;

state Initialize
{

	m_pLC = GetPlayer(3);

	nRace = Rand(1);
	if(nRace)
	{
		m_pUCS = GetPlayer(1);
		m_pUCS.SetEnemy(m_pLC);
		m_pLC.SetEnemy(m_pUCS);
		InitializeUCS();
	}
	else
	{
		m_pED = GetPlayer(2);
		m_pED.SetEnemy(m_pLC);
		m_pLC.SetEnemy(m_pED);
		InitializeED();
	}

    return StartCamera,1;
}


state StartCamera
{
	SetWind(30,100);//strenght[0-100],Direction[0-255]
	nTicks = PlayCutscene("Main_02.trc", false, false, false);
	return CreateObjects, nTicks/2 - 1;
}

state CreateObjects
{
	InitializeLC();
	
	if(nRace)
	{
		InitializeUCS();
	}
	else
	{
		InitializeED();
	}
	return StartCamera,nTicks/2 - 1;
}

}
