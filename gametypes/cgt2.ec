// +ogolne wyswietlanie goali na starcie  i w goalach
// +zrobic peace - wylaczyc aja chooseai controlAttack chooseenemy



// +uncle sam ustawianie kasy, dodawanie kasy, wylaczenie harvesterow i rafinerii.
// hero - sprawdzanie, wyswietlanie


mission MISSION_NAME
{

#include "..\Campaigns\common.ech"
#include "AgentsDialogs.ech"

state Initialize;
state Start;
#ifdef PEACE
state Peace;
#endif
state Nothing;

consts
{
	eRaceUCS = 1;
	eRaceED = 2;
	eRaceLC = 3;
	eRaceAlien = 4;
	eEnemy = 0;
	eNeutral = 1;
}

enum comboAlliedVictory
{
    "translateGameMenuAlliedVictoryNo",
    "translateGameMenuAlliedVictoryYes",
		multi:
    "translateGameMenuAlliedVictory"
}

enum comboStartingUnits
{
    "translateGameMenuStartingUnitsDefault",
    "translateGameMenuStartingUnitsBuilderOnly",
multi:
    "translateGameMenuStartingUnits"
}

#ifdef PEACE
enum comboPeace
{
    "translateGameMenuPeace3min",
    "translateGameMenuPeace5min",
	"translateGameMenuPeace7min",
	"translateGameMenuPeace10min",
	"translateGameMenuPeace15min",
		multi:
    "translateGameMenuPeaceTime"
}
#endif

#ifdef UNCLE_SAM
enum comboCash
{
    "translateGameMenuCash1k",
	"translateGameMenuCash2k",
	"translateGameMenuCash3k",
		multi:
    "translateGameMenuCash"
}
#endif


#ifdef PEACE
int nPeaceTimer;
#endif



function void InitPlayerUCS(player pPlayer, int bDynamicConn, int nX, int nY)
{
	pPlayer.AddResource(0, 5000);
	pPlayer.AddResource(1, 5000);

	#ifndef UNCLE_SAM
	pPlayer.AddObjectTemplate("U_CH_AH_10_1#U_EN_NO_10_1,U_IE_SG_01_1");
	#else
	
	pPlayer.EnableBuilding("U_BL_RE_13"   , false);
	pPlayer.EnableBuilding("U_BL_SI_14"   , false);
	pPlayer.EnableBuilding("U_BL_LZ_20"   , false);
    pPlayer.EnableUnit("U_CH_AH_10_1"     , false);

	#endif
	pPlayer.AddObjectTemplate("U_CH_AR_08_1#U_IE_SG_01_1");
	pPlayer.AddObjectTemplate("U_CH_AS_09_1#U_IE_SG_01_1");

//Air Jeep 
    pPlayer.AddObjectTemplate("U_CH_AJ_01_1#U_WP_CH_01_1,U_AR_CL_01_1,U_EN_NO_01_1,U_IE_SG_01_1");		

//Light Jeep
    pPlayer.AddObjectTemplate("U_CH_GJ_02_1#U_WP_CH_02_1,U_AR_CL_02_1,U_EN_NO_02_1,U_IE_SG_01_1");		

//Heavy Jeep-Tank
    pPlayer.AddObjectTemplate("U_CH_GT_03_1#U_WP_CH_03_1,U_AR_CL_03_1,U_EN_NO_03_1,U_IE_SG_01_1,U_IE_RD_01_1");

//Heavy Tank - 1
    pPlayer.AddObjectTemplate("U_CH_GT_04_1#U_WP_AR_04_1,U_AR_CL_04_1,U_EN_NO_04_1,U_IE_SG_04_1,U_IE_RD_01_1");

//Heavy Tank - 2
    pPlayer.AddObjectTemplate("U_CH_GT_05_1#U_WP_PB_05_1,U_WP_PB2_05_1,U_AR_CL_05_1,U_EN_NO_05_1,U_IE_SG_04_1,U_IE_RD_01_1");

//Air Artyllery
    pPlayer.AddObjectTemplate("U_CH_AA_06_1#U_WP_PL_06_1,U_AR_CL_06_1,U_EN_NO_06_1,U_IE_SG_04_1");

//Ground Artillery		

    pPlayer.AddObjectTemplate("U_CH_GA_07_1#U_WP_PL_07_1,U_AR_CL_07_1,U_EN_NO_07_1,U_IE_SG_01_1");		

//Air Bomber
	pPlayer.AddObjectTemplate("U_CH_AB_12_1#U_WP_PB_12_1,U_AR_CL_12_1,U_EN_PR_12_1,U_IE_SG_01_1");


	pPlayer.CreateObject("U_IN_TE_01_1", nX, nY, 0, 0);
	pPlayer.CreateObject("U_IN_TE_01_1", nX, nY+1, 0, 0);
	pPlayer.CreateObject("U_IN_TE_01_1", nX, nY-1, 0, 0);
	pPlayer.CreateObject("U_CH_AR_08_1", nX+1, nY, 0, 0);
	pPlayer.CreateObject("U_CH_AR_08_1", nX-1, nY, 0, 0);
#ifndef UNCLE_SAM
    //pPlayer.CreateObject("U_CH_AH_10_1#U_EN_NO_10_1", nX-1, nY, 0, 0);
#endif
}

function void InitPlayerED(player pPlayer, int bDynamicConn, int nX, int nY)
{
	pPlayer.AddResource(1, 5000);
	pPlayer.AddResource(2, 5000);

	#ifndef UNCLE_SAM
		pPlayer.AddObjectTemplate("E_CH_AH_12#E_IE_SG_01_1");
    #else
        pPlayer.EnableUnit("E_CH_AH_12", false);
	#endif



//Air Jeep 
    pPlayer.AddObjectTemplate("E_CH_AJ_01_1#E_WP_SL_01_1,E_AR_CL_01_1,E_EN_NO_01_1,E_IE_SG_01_1");		

//Light Jeep
    pPlayer.AddObjectTemplate("E_CH_GJ_02_1#E_WP_SL_02_1,E_AR_CL_02_1,E_EN_NO_02_1,E_IE_SG_01_1");

//Heavy Jeep
    pPlayer.AddObjectTemplate("E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_CL_03_1,E_EN_NO_03_1,E_IE_SG_01_1");

//Light Tank
    pPlayer.AddObjectTemplate("E_CH_GT_04_1#E_WP_CA_04_1,E_AR_CL_04_1,E_EN_NO_04_1,E_IE_SG_04_1,E_IE_RD_01_1");

//Medium Tank		
    pPlayer.AddObjectTemplate("E_CH_GT_05_1#E_WP_CA_05_1,E_AR_CL_05_1,E_EN_NO_05_1,E_IE_SG_04_1,E_IE_RD_01_1");

//Heavy Tank
    pPlayer.AddObjectTemplate("E_CH_GT_06_1#E_WP_CA_06_1,E_WP_CA2_06_1,E_AR_CL_06_1,E_EN_NO_06_1,E_IE_SG_04_1,E_IE_RD_01_1");

//Air Artyllery
    pPlayer.AddObjectTemplate("E_CH_AA_07_1#E_WP_GR_07_1,E_AR_CL_07_1,E_EN_NO_07_1,E_IE_SG_01_1");

//Ground Artillery		
    pPlayer.AddObjectTemplate("E_CH_GA_08_1#E_WP_EQ_08_1,E_AR_CL_08_1,E_EN_NO_08_1,E_IE_SG_01_1");

//Air Fighter
    pPlayer.AddObjectTemplate("E_CH_AF_11_1#E_WP_GB_11_1,E_AR_CL_11_1,E_EN_NO_11_1,E_IE_SG_01_1");

//Transport
    pPlayer.AddObjectTemplate("E_CH_TR_09_2#E_IE_SG_01_1");

//Repairer
    pPlayer.AddObjectTemplate("E_CH_AR_13_1#E_IE_SG_01_1");


	pPlayer.CreateObject("E_IN_MA_01_1", nX, nY-1, 0, 0);
	pPlayer.CreateObject("E_IN_MA_01_1", nX, nY+1, 0, 0);
#ifndef UNCLE_SAM
	pPlayer.CreateObject("E_CH_AH_12", nX+1, nY, 0, 0);
	pPlayer.CreateObject("E_CH_AH_12", nX, nY, 0, 0);
	pPlayer.CreateObject("E_CH_AH_12", nX-1, nY, 0, 0);
#endif
}

function void InitPlayerLC(player pPlayer, int bDynamicConn, int nX, int nY)
{
	pPlayer.AddResource(0, 9000);
	pPlayer.AddResource(2, 9000);

	#ifdef UNCLE_SAM
	pPlayer.EnableBuilding("L_BL_MI_10"   , false);
	#endif
	
//Air Jeep
	pPlayer.AddObjectTemplate("L_CH_AJ_01_1#L_WP_EL_01_1,L_AR_CL_01_1,L_EN_NO_01_1,L_IE_SG_01_1");

//Ground Jeep
	pPlayer.AddObjectTemplate("L_CH_GJ_02_1#L_WP_SG_02_1,L_AR_CL_02_1,L_EN_NO_02_1,L_IE_SG_01_1");

//Air Tank
	pPlayer.AddObjectTemplate("L_CH_AT_03_1#L_WP_SB_03_1,L_AR_CL_03_1,L_EN_NO_03_1,L_IE_SG_01_1");

//Ground Tank - 1
	pPlayer.AddObjectTemplate("L_CH_GT_04_1#L_WP_MP_04_1,L_AR_CL_04_1,L_EN_NO_04_1,L_IE_SG_04_1,L_IE_SG_04_1");

//Ground Tank - 2
	pPlayer.AddObjectTemplate("L_CH_GT_05_1#L_WP_PS_05_1#L_WP_PS2_05_1,L_AR_CL_05_1,L_EN_NO_05_1,L_IE_SG_04_1,L_IE_SG_04_1");

//Ground Tank - 3
	pPlayer.AddObjectTemplate("L_CH_GT_06_1#L_WP_MP_06_1#L_WP_EL_06_1,L_WP_MP2_06_1,L_WP_MP2_06_1,L_AR_CL_06_1,L_EN_NO_06_1,L_IE_SG_04_1,L_IE_SG_04_1");

//Air Artillery
	pPlayer.AddObjectTemplate("L_CH_AA_07_1#L_WP_PC_07_1,L_AR_CL_07_1,L_EN_NO_07_1,L_IE_SG_01_1");

//Ground Artillery
	pPlayer.AddObjectTemplate("L_CH_GA_08_1#L_WP_PC_08_1,L_AR_CL_08_1,L_EN_NO_08_1,L_IE_SG_01_1");

//Air Fighter
	pPlayer.AddObjectTemplate("L_CH_AF_11_1#L_WP_AA_11_1,L_AR_CL_11_1,L_EN_NO_11_1,L_IE_SG_01_1");

//Air Bomber
	pPlayer.AddObjectTemplate("L_CH_AB_12_1#L_WP_PB_12_1,L_AR_CL_12_1,L_EN_NO_12_1,L_IE_SG_01_1");


	pPlayer.CreateObject("L_IN_RG_01_1", nX, nY, 0, 0);
	pPlayer.CreateObject("L_IN_RG_01_1", nX-1, nY, 0, 0);
	pPlayer.CreateObject("L_IN_RG_01_1", nX+1, nY, 0, 0);
}

function void InitPlayerAlien(player pPlayer, int bDynamicConn, int nX, int nY)
{
	pPlayer.CreateObject("A_CH_NU_01_1", nX-1, nY, 0, 0);
	pPlayer.CreateObject("A_CH_NU_01_1", nX+1, nY, 0, 0);
	pPlayer.CreateObject("A_CH_NU_01_1", nX, nY-1, 0, 0);
	pPlayer.CreateObject("A_CH_NU_10_1", nX-2, nY, 0, 0);
	
}

#ifdef KILL_HERO
unit m_uHero[];
function void InitializeHeroes()
{
	int i;
	m_uHero.Create(9);
	for(i=0;i<9;++i) m_uHero[i] = null;
}

function void CheckHeroes(unit uKilled)
{
	int i;
	player pPlayer;
	if(uKilled == null) return;
	for(i=1;i<9;++i)
	{
		if(m_uHero[i] == uKilled)
		{
			
			pPlayer=GetPlayer(uKilled.GetIFFNum());
			LookAtUnit(m_uHero[i]);
			m_uHero[i]=null;
			pPlayer.GameDefeat(true);
			return;
		}
	}
}
	
#endif

function void InitPlayer(player pPlayer, int bDynamicConn, int nNo)
{
    int nX, nY;
    int nLimit;

    GetStartingPoint(pPlayer.GetIFFNum(), nX, nY);
    
    pPlayer.LookAt(nX, nY, 6,0,20);
	
    /*
    //zwiekszenie poczatkowego maksymalnego limitu gdy na starcie sa unity
    if (comboStartingUnits == 0)
    {
        nLimit = pPlayer.GetCurrUnitLimitSize();
        pPlayer.SetPlayerMaxUnitLimitSize(nLimit);
    }
    */

	if(pPlayer.GetRace()==eRaceUCS) //UCS
	{
        InitPlayerUCS(pPlayer, bDynamicConn, nX, nY);
		#ifdef KILL_HERO
		m_uHero[nNo] = pPlayer.CreateObject(UCS_HERO, nX,nY, 0, 0);//XXXMD wstawic 
		#endif
	}
	if(pPlayer.GetRace()==eRaceED) //ED
	{
        InitPlayerED(pPlayer, bDynamicConn, nX, nY);
		#ifdef KILL_HERO
		m_uHero[nNo] = pPlayer.CreateObject(ED_HERO, nX,nY, 0, 0);
		#endif
	}
	if(pPlayer.GetRace()==eRaceLC) //LC
	{
        InitPlayerLC(pPlayer, bDynamicConn, nX, nY);
		#ifdef KILL_HERO
		m_uHero[nNo] = pPlayer.CreateObject(LC_HERO, nX,nY, 0, 0);
		#endif
	}
	if(pPlayer.GetRace()==eRaceAlien)
	{
        InitPlayerAlien(pPlayer, bDynamicConn, nX, nY);
		#ifdef KILL_HERO
		m_uHero[nNo] = pPlayer.CreateObject(AL_HERO, nX,nY, 0, 0);
		#endif
	}
	pPlayer.SetMaxAgentsInPlayerCount(3);
}

#ifdef UNCLE_SAM
int m_nCash,m_nCashTimer;

function void AddMoneyToAllPlayers(int nCash)
{
	int nP;
    player pP;

	for (nP = 1; nP <= 8; ++nP)
    {
        pP = GetPlayer(nP);
        if ((pP != null) && pP.IsAlive() && HaveStartingPoint(nP))
        {
			if(pP.GetRace()!=eRaceAlien)
			{
    			pP.AddResource(0, nCash);
				pP.AddResource(1, nCash);
				pP.AddResource(2, nCash);
			}
		}
	}
}
#endif


int nAgentsCounter;
//int bCheckVictory;

#ifdef PEACE
function void SetAliances(int bType)
{
	int nP1, nP2;
    player pP1, pP2;

	for (nP1 = 1; nP1 <= 8; ++nP1)
    {
        pP1 = GetPlayer(nP1);
        if ((pP1 != null) && pP1.IsAlive() && HaveStartingPoint(nP1))
        {
			
			for (nP2 = nP1+1; nP2 <= 8; ++nP2)
			{
				pP2 = GetPlayer(nP2);
				if ((pP2 != null) && pP2.IsAlive() && HaveStartingPoint(nP2))
				{
					if(bType==eEnemy)
					{
						//pP1.SetAIControlOptions(eAIControlAttack,true);
						//pP1.SetAIControlOptions(eAIControlChooseEnemies,true);
						pP1.SetAIControlOptions(eAIPeaceTime,false);
						pP1.SetEnemy(pP2);
						pP2.SetEnemy(pP1);
					}
					if(bType==eNeutral)
					{
						//pP1.SetAIControlOptions(eAIControlAttack,false);
						//pP1.SetAIControlOptions(eAIControlChooseEnemies,false);
						pP1.SetAIControlOptions(eAIPeaceTime,true);
						pP1.SetNeutral(pP2);
						pP2.SetNeutral(pP1);
					}
				}
			}
        }
    }
}
#endif

int bAllowVictory;

int aHaveBuildings[];
//================================================================================================
state Initialize
{
    int nPlayer;
    player pPlayer;

	//bCheckVictory=false;

	SetWind(30,100);//strenght[0-100],Direction[0-255]
	SetTimer(0,3*30);//sprawdzanie victory
	InitializeAgents();
    
	aHaveBuildings.Create(17);
	#ifdef KILL_HERO
	InitializeHeroes();
	#endif

	for (nPlayer = 1; nPlayer <= 8; ++nPlayer)
    {
        pPlayer = GetPlayer(nPlayer);
        if ((pPlayer != null) && pPlayer.IsAlive() && HaveStartingPoint(nPlayer))
        {
            InitPlayer(pPlayer, false, nPlayer);
			aHaveBuildings[nPlayer]=0;
			if(comboAlliedVictory) pPlayer.SetSendENResults(false);
			else pPlayer.SetSendENResults(true);
            //if(comboAlliedVictory) pPlayer.SetAIControlOptions(eAIControlAINeutralAI, false);
            //else pPlayer.SetAIControlOptions(eAIControlAINeutralAI, true);
        }
    }
	bAllowVictory = false;
	RegisterGoal(0, MISSION_GOAL);
	EnableGoal(0, true, false); 

	SetInterfaceOptions(
			//eNoConstructorDialog |
		    //eNoResearchCenterDialog |
			//eNoBuildingUpgradeDialog |
			//eNoBuildPanelDialog |
			//eNoMoneyConfigDialog |
			//eNoGoalsDialog |
			//eNoCommandsDialog |
			//eNoMapDialog |
			//eNoAllianceDialog |
			//eForceAllianceDialog |
			//eForceAllianceDialog |
			//eNoMoneyDisplay |
			//eNoMenuButton |
            eShowStatisticsOnExitSkirmish |
			0
			);
		
	
	
	#ifdef UNCLE_SAM
	if(comboCash==0) m_nCash=2000;
	if(comboCash==1) m_nCash=4000;
	if(comboCash==2) m_nCash=6000;
	#endif
	
	return Start;
}

//==================================================================================================
state Start
{

	SetConsoleText(MISSION_GOAL, 10*30);
	
#ifdef PEACE
	
	SetAliances(eNeutral);
	
	if(comboPeace==0) nPeaceTimer=60*3;
	if(comboPeace==1) nPeaceTimer=60*5;
	if(comboPeace==2) nPeaceTimer=60*7;
	if(comboPeace==3) nPeaceTimer=60*10;
	if(comboPeace==4) nPeaceTimer=60*15;
	return Peace,10 * 30;
	
#else
	return Nothing;
#endif
}
//==================================================================================================

#ifdef PEACE
state Peace
{
	string sConsole, sTrl1, sTrl2, sTrl3, sNum1, sNum2;

    --nPeaceTimer;
	if(nPeaceTimer<1)
	{
		RegisterGoal(1, MISSION_GOAL2);
		SetGoalState(0,goalAchieved,false);
		EnableGoal(1, true, false); 

		SetAliances(eEnemy);
		SetConsoleText("translateGameTypeWAR", 10*30,true);		
		return Nothing;
	}
	
	sTrl1.Translate("translateGameTypePeaceCounter");
	sTrl2.Translate("translateGameTypePeaceCounterSec");
        
	if(nPeaceTimer<60)
    {
        sNum1.Format(" %d", nPeaceTimer);
		sConsole.Append(sTrl1);
        sConsole.Append(sNum1);
        sConsole.Append(sTrl2);
    }
	else
	{
		sTrl3.Translate("translateGameTypePeaceCounterMin");
		sNum1.Format(" %d", nPeaceTimer/60);
		sNum2.Format(" %d", nPeaceTimer%60);
		sConsole.Append(sTrl1);
		sConsole.Append(sNum1);
		sConsole.Append(sTrl3);
		sConsole.Append(sNum2);
		sConsole.Append(sTrl2);
	}
	SetConsoleText(sConsole, 60, false);
	return Peace, 30;
}
#endif

state Nothing
{
	#ifdef UNCLE_SAM
	
	++m_nCashTimer;
	if(m_nCashTimer>60)
	{
		m_nCashTimer=0;
		AddMoneyToAllPlayers(m_nCash);
	}
	#endif
	
    return Nothing,30;
}
//==================================================================================================
int bDontCheckVictory;

event Timer0()
{
#ifndef NO_VICTORYDEFEAT

	player pPlayer, pPlayer2;
	int nPlayer, nPlayer2, bLiveEnemy;
    int bKilled;

	if(bDontCheckVictory) return;
#ifndef KILL_HERO
	//if (!bCheckVictory) return;
	//bCheckVictory=false;
	
    //defeat?
	for (nPlayer = 1; nPlayer <= 8; ++nPlayer)
    {
        pPlayer = GetPlayer(nPlayer);
        if ((pPlayer != null) && pPlayer.IsAlive())
		{
            bKilled = false;

			if(aHaveBuildings[nPlayer])
			{
			   if ((pPlayer.GetNumberOfBuildings() == 0) && (pPlayer.GetNumberOfTransformationCopulas() == 0))
               {
                    bKilled = true;
               }
			}
			else
			{
				if (pPlayer.GetNumberOfUnits() == 0)
                {
                    bKilled = true;
                }
				if ((pPlayer.GetNumberOfBuildings()>0) || (pPlayer.GetNumberOfTransformationCopulas() >0))
				{
					bKilled = false;
				}
				if (pPlayer.GetNumberOfBuildings()>2)
				{
					aHaveBuildings[nPlayer] = 1;
				}
			}
			if (bKilled)
			{
				bAllowVictory = true;
				pPlayer.GameDefeat(true);//bShowStatistic
			}
		}
    }
#endif
#ifdef KILL_HERO
bAllowVictory=true;
#endif
    //victory?
	if(bAllowVictory)
	{
		for (nPlayer = 1; nPlayer <= 8; ++nPlayer)
		{
			pPlayer = GetPlayer(nPlayer);
			if ((pPlayer != null) && pPlayer.IsAlive())
			{
				bLiveEnemy = false;
				for (nPlayer2 = 1; nPlayer2 <= 8; ++nPlayer2)
				{
					pPlayer2 = GetPlayer(nPlayer2);
					if ((nPlayer2 != nPlayer) && (pPlayer2 != null) && pPlayer2.IsAlive())
					{
						if ((comboAlliedVictory == 0) || !pPlayer.IsAlly(pPlayer2))
						{
							bLiveEnemy = true;
						}
					}
				}
				if (!bLiveEnemy)
				{
					bDontCheckVictory = true;
					pPlayer.GameVictory(true, true);//bAddAgentsReputationOnVictory, bShowStatistic
				}
			}
		}
	}

#endif
}

event KilledNetworkPlayer(int nIFFNum)
{
	bAllowVictory = true;
}

event RemovedUnit(unit uKilled, unit uAttacker, int nNotifyType)
{
#ifdef PEACE
	player pPlayer;
	if(nPeaceTimer>0 && uAttacker.GetIFFNum()>0 && uAttacker.GetIFFNum()<9 && uKilled.GetIFF()!= uAttacker.GetIFF())
	{
		pPlayer = GetPlayer(uAttacker.GetIFFNum());
		if(pPlayer!=null && pPlayer.IsAlive())
		{
			//XXXMD wyswietlic przegrywajacemu komunikat "
			pPlayer.SetConsoleText("translateGameTypePeaceDefeat");
			pPlayer.GameDefeat(true);
		}
	}
#endif
#ifdef KILL_HERO
	CheckHeroes(uKilled);
#endif
	//bCheckVictory=true;
}

event RemovedBuilding(unit uKilled, unit uAttacker, int nNotifyType)
{
	
	#ifdef PEACE
	player pPlayer;
	if(nPeaceTimer>0 && uAttacker.GetIFFNum()>0 && uAttacker.GetIFFNum()<9 && uKilled.GetIFF()!= uAttacker.GetIFF())
	{
		pPlayer = GetPlayer(uAttacker.GetIFFNum());
		if(pPlayer!=null && pPlayer.IsAlive())
		{
			//XXXMD wyswietlic przegrywajacemu komunikat "
			pPlayer.SetConsoleText("translateGameTypePeaceDefeat");
			pPlayer.GameDefeat(true);
		}
	}
	#endif
	//bCheckVictory=true;
}


event NewDynamicConnectionPlayer(int nIFFNum)
{
	player pPlayer;
	pPlayer = GetPlayer(nIFFNum);
    InitPlayer(pPlayer, true, nIFFNum);
	pPlayer.RegisterGoal(0, MISSION_GOAL);
	pPlayer.EnableGoal(0, true, false); 
	pPlayer.SetConsoleText(MISSION_GOAL, 10*30);
	aHaveBuildings[nIFFNum]=0;
	bDontCheckVictory = false;
	if(comboAlliedVictory) pPlayer.SetSendENResults(false);
	else pPlayer.SetSendENResults(true);
    //if(comboAlliedVictory) pPlayer.SetAIControlOptions(eAIControlAINeutralAI, false);
    //else pPlayer.SetAIControlOptions(eAIControlAINeutralAI, true);
#ifdef PEACE
	if(nPeaceTimer<1)
	{
		pPlayer.RegisterGoal(1, MISSION_GOAL2);
		pPlayer.SetGoalState(0,goalAchieved,false);
		pPlayer.EnableGoal(1, true, true); 
		pPlayer.SetConsoleText(MISSION_GOAL2, 10*30);
		SetAliances(eEnemy);
	}
	else
	{
		SetAliances(eNeutral);
	}
#endif
}

event RemoveUnits()
{
    if (comboStartingUnits) 
    {
        return true;
    }
    return false;
}

event NotUseAgents()
{
    return !comboAgents;
}

event UseExtraSkirmishPlayers()
{
    return true;
}

event SpecialLevelFlags()
{
    return 0x01;
}

event AIPlayerFlags()
{
    return 0x0F;
}

command Initialize()
{
	comboAlliedVictory=1;
    comboStartingUnits=1;
    comboAgents=1;
    return true;
}

command Uninitialize()
{
    return true;
}
    
command Combo1(int nMode) button comboStartingUnits 
{
    comboStartingUnits = nMode;
	return true;
}

command Combo2(int nMode) button comboAlliedVictory
{
    comboAlliedVictory = nMode;
    return true;
}

#ifdef PEACE
command Combo3(int nMode) button comboPeace
{
    comboPeace = nMode;
    return true;
}
#endif

#ifdef UNCLE_SAM
command Combo3(int nMode) button comboCash
{
    comboCash = nMode;
    return true;
}
#endif

}

