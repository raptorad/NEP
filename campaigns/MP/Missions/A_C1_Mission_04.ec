#include "..\..\defines.ech"

#define MISSION_NAME "translateA_M4"

#define WAVE_MISSION_PREFIX "AL\\M4\\A_M4_Brief_"


/*
Misja 4
Zniszczenie placówki UCS na Gordanii
1 flota
Enemy1 = 1 - baza do zniszczenia  
Enemy2 = 6 - ataki na pozycje gracza.

*/

#define PLAY_TIMED_BRIEFING_TUTORIAL(BriefingName, Time) \
	SetConsoleText(MISSION_NAME "_Tutorial_" # BriefingName, Time); 

mission MISSION_NAME
{
	#include "..\..\common.ech"
	#include "..\..\dialog.ech"
	#include "..\..\Researches.ech"
	state Initialize; // musi byc z tutaj zeby od niego rozpoczal sie skrypt
	#include "..\..\dialog2.ech"

	consts
	{
		eModeLand = 1;

		playerPlayer	  = 4;
		playerEnemy1     = 1;
		playerEnemy2     = 6;
		playerEnemy3     = 7;//silicon patrols
		playerEnemy4     = 5;//metal patrol
			
		goalDestroyUCSPowerPlants = 0;
		
		markerStart = 1;

		markerPatrolStart = 2;
		markerPatrolSilicon = 3; // 4,5
		markerPatrolMetal = 6; // 7,8

		markerRandomPatrol = 10;//19
	}

	player m_pPlayer;
	player m_pEnemy1;
	player m_pEnemy2;
	player m_pEnemy3;
	player m_pEnemy4;
	
	
	int m_nState;
	int m_nAttackCounter;
	int m_nPatrolCounter;
	int m_bBuildingDestroyed;
	int m_bCrystalPatrol;
    int m_bMetalPatrol;
	int m_nWave;
	
	state Start;
	state MissionFlow;
	state XXX;

	function int CreatePatrols()
	{
		int i, k, nGx, nGy, nMarker;
//XXXMD
		for(i=markerRandomPatrol; i<markerRandomPatrol+7; i=i+1)
		{		
			CreatePatrol(m_pEnemy2, "U_CH_AS_09_1", 1, i, i+1);
			CreatePatrol(m_pEnemy2, "U_CH_AJ_01_1#U_WP_CH_01_3,U_AR_RL_01_3,U_EN_SP_01_1", 1+GET_DIFFICULTY_LEVEL(), i, i+1);
			CreatePatrol(m_pEnemy2, "U_CH_GJ_02_1#U_WP_CH_02_3,U_AR_RL_02_1,U_EN_SP_02_1", 2+GET_DIFFICULTY_LEVEL(), i, i+1);
			CreatePatrol(m_pEnemy2, "U_CH_GT_03_1#U_WP_AR_03_3,U_AR_RL_03_1,U_EN_SP_03_1", 1+GET_DIFFICULTY_LEVEL(), i, i+1);
		}
		return 1;
	}
	
	function int CreatePatrol(int i)
	{
		//eCrystal = 0;
	    //eMetal = 1;
		int nMarker, k;
		player pEnemy;


		if(i==eCrystal) 
		{
			if(m_bCrystalPatrol<10) return 0;
			m_bCrystalPatrol = 0;
			nMarker = markerPatrolSilicon; // 4,5
			pEnemy = m_pEnemy3;
		}
		else 
		{
			nMarker = markerPatrolMetal; // 7,8
			if(m_bMetalPatrol<10) return 0;
			m_bMetalPatrol = 0;
			pEnemy = m_pEnemy4;
		}

		if(pEnemy.GetNumberOfUnits()>8) return 0;


		++m_nWave;

		k = m_pPlayer.GetNumberOfVehicles();//*(GET_DIFFICULTY_LEVEL()+1);

		if(k>15) k=15;
		k = k-2;
		if(!GET_DIFFICULTY_LEVEL())k = k-2;
        if(k<1)k=1;
		

		
		if(GET_DIFFICULTY_LEVEL()>0)
		{
			k=k+3;
			CreatePatrol(pEnemy, "U_CH_AJ_01_1#U_WP_CH_01_1,U_AR_RL_01_1,U_EN_NO_01_1", k, markerPatrolStart, nMarker,nMarker+1,nMarker+2);
		}
		if(GET_DIFFICULTY_LEVEL()>1)
		{
			k=k+3;
			CreatePatrol(pEnemy, "U_CH_GT_03_1#U_WP_AR_03_3,U_AR_RL_03_1,U_EN_NO_03_1", k/2,markerPatrolStart, nMarker,nMarker+1,nMarker+2);
		}

		if(m_nWave<8)// pierwsze 4 ataki
		{
			TraceD("                                  maly atak                        \n");
			CreatePatrol(pEnemy, "U_CH_AJ_01_1#U_WP_CH_01_1,U_AR_CL_01_1,U_EN_NO_01_1", k, markerPatrolStart, nMarker,nMarker+1,nMarker+2);
			CreatePatrol(pEnemy, "U_CH_GT_03_1#U_WP_AR_03_1,U_AR_CL_03_1,U_EN_NO_03_1", k/2,markerPatrolStart, nMarker,nMarker+1,nMarker+2);
			if(GET_DIFFICULTY_LEVEL()>0)CreatePatrol(pEnemy, "U_CH_GT_03_1#U_WP_CH_03_1,U_AR_CL_03_1,U_EN_SP_03_1", k, markerPatrolStart, nMarker,nMarker+1,nMarker+2);
			CreatePatrol(pEnemy, "U_CH_GT_03_1#U_WP_AR_03_1,U_AR_CL_03_1,U_EN_SP_03_1", 3, markerPatrolStart, nMarker,nMarker+1,nMarker+2);
		}

		if((m_nWave>=8) && (m_nWave<16)) //drugie 4 atakow
		{
			TraceD("                                  sredni atak                        \n");
			if(GET_DIFFICULTY_LEVEL()>0)CreatePatrol(pEnemy, "U_CH_AJ_01_1#U_WP_CH_01_3,U_AR_RL_01_1,U_EN_NO_01_1,U_IE_SG_01_1", k, markerPatrolStart, nMarker,nMarker+1,nMarker+2);
			if(GET_DIFFICULTY_LEVEL()>0)CreatePatrol(pEnemy, "U_CH_GT_03_1#U_WP_AR_03_3,U_AR_RL_03_1,U_EN_NO_03_1,U_IE_SG_01_1", k/2,markerPatrolStart, nMarker,nMarker+1,nMarker+2);
			CreatePatrol(pEnemy, "U_CH_GT_03_1#U_WP_CH_03_3,U_AR_RL_03_1,U_EN_SP_03_1,U_IE_SG_01_1", k, markerPatrolStart, nMarker,nMarker+1,nMarker+2);
			CreatePatrol(pEnemy, "U_CH_GT_03_1#U_WP_AR_03_3,U_AR_RL_03_1,U_EN_SP_03_1,U_IE_SG_01_1", 3, markerPatrolStart, nMarker,nMarker+1,nMarker+2);
		}

		if(m_nWave>=16)// trzecie 4 atakow i reszta do konca.
		{
			TraceD("                                  duzy atak                        \n");
			if(GET_DIFFICULTY_LEVEL()>0)CreatePatrol(pEnemy, "U_CH_AJ_01_1#U_WP_SH_01_3,U_AR_RL_01_3,U_EN_PR_01_3,U_IE_SG_01_3", k+m_nWave-16, markerPatrolStart, nMarker,nMarker+1,nMarker+2);
			CreatePatrol(pEnemy, "U_CH_GT_03_1#U_WP_AR_03_3,U_AR_RL_03_3,U_EN_PR_03_1,U_IE_SG_01_3", k+m_nWave-16,markerPatrolStart, nMarker,nMarker+1,nMarker+2);
			CreatePatrol(pEnemy, "U_CH_GT_03_1#U_WP_CH_03_3,U_AR_RL_03_3,U_EN_PR_03_1,U_IE_SG_01_3", k+m_nWave-16, markerPatrolStart, nMarker,nMarker+1,nMarker+2);
		}

		


		return 1;

	}


	state Initialize
	{
		int i;
		unit uVehicle;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(Enemy1 );
		INITIALIZE_PLAYER(Enemy2 );
		INITIALIZE_PLAYER(Enemy3 );
		INITIALIZE_PLAYER(Enemy4 );
		
		m_pEnemy1.EnableAI(false);
		m_pEnemy2.EnableAI(false);
		
		ActivateAI(m_pEnemy1);
		m_pEnemy1.SetAIControlOptions(eAIRebuildAllBuildings, true);
		m_pEnemy1.SetAIControlOptions(eAIControlBuildBase, false);
		m_pEnemy1.SetAIControlOptions(eAIControlAttack, false);

		SetNeutrals(m_pEnemy1,m_pEnemy2,m_pEnemy3,m_pEnemy4);
		SetEnemies(m_pEnemy1, m_pPlayer);
		SetEnemies(m_pEnemy2, m_pPlayer);
		SetEnemies(m_pEnemy3, m_pPlayer);
		SetEnemies(m_pEnemy4, m_pPlayer);
		
		SetPlayerTemplateseUCSCampaign(m_pEnemy1, 6);
		SetPlayerResearchesUCSCampaign(m_pEnemy1, 6);
		AddPlayerResearchesUCSCampaign(m_pEnemy1, 6);
		SetPlayerResearchesUCSCampaign(m_pEnemy2, 6);
		AddPlayerResearchesUCSCampaign(m_pEnemy2, 6);
		SetPlayerResearchesUCSCampaign(m_pEnemy3, 6);
		AddPlayerResearchesUCSCampaign(m_pEnemy3, 6);
		SetPlayerResearchesUCSCampaign(m_pEnemy4, 6);
		AddPlayerResearchesUCSCampaign(m_pEnemy4, 6);

		
		REGISTER_GOAL(DestroyUCSPowerPlants);
	

		if(GET_DIFFICULTY_LEVEL()==1)
		{
			CreatePlayerObjectAtMarker(m_pPlayer, "A_CH_AF_12_1", 41);
			CreatePlayerObjectAtMarker(m_pPlayer, "A_CH_AF_12_1", 41);
		}
		
		if(!GET_DIFFICULTY_LEVEL())
		{
			for(i=20; i<42;i=i+1)RemoveUnitAtMarker(i);
			
			CreatePlayerObjectAtMarker(m_pPlayer, "A_CH_AF_12_1", 41);
			CreatePlayerObjectAtMarker(m_pPlayer, "A_CH_AF_12_1", 41);
			CreatePlayerObjectAtMarker(m_pPlayer, "A_CH_AF_12_1", 41);
			CreatePlayerObjectAtMarker(m_pPlayer, "A_CH_LC_13_1", 42);
			CreatePlayerObjectAtMarker(m_pPlayer, "A_CH_LC_13_1", 42);
			CreatePlayerObjectAtMarker(m_pPlayer, "A_CH_NU_10_1", 42);
		}

		

		LookAtMarker(markerStart);
		SetWind(20, 20);
		return Start;
	}

	

	state Start
	{
		m_nState=0;
		//m_nState=30;//XXXMD
		m_nAttackCounter = 0;
		m_bCrystalPatrol = 50;
		m_bMetalPatrol = 50;
		if(GET_DIFFICULTY_LEVEL()>0) CreatePatrols();
		FadeOutCutscene(60, 0, 0, 0);
		return MissionFlow, 160;


		
	}
	int m_nKillCounter;
	state MissionFlow
	{
		int i,nGx, nGy, nFound;
		if(m_nState==0)
		{
			m_nState = 1;
			ENABLE_GOAL(DestroyUCSPowerPlants);
			ADD_BRIEFINGS(Start,BAD_TROFF_HEAD,BAD_IGOR_HEAD,6);
			START_BRIEFING(eInterfaceEnabled);
			WaitToEndBriefing(state, 10*30);
			return state;
		}

		if(m_nState==1)//
		{
			++m_nAttackCounter;
			if(m_nAttackCounter>60*4)
			{
				m_nState = 2;
				CreatePatrol(eCrystal);
				CreatePatrol(eMetal);
				m_nAttackCounter=0;
			}
			return state, 30;
		}
		if(m_nState==2)//
		{
			if(m_pEnemy1.GetNumberOfBuildings(eBuildingPowerPlant)==0)
			{
				m_nState = 15;
				ACHIEVE_GOAL(DestroyUCSPowerPlants);
				ADD_BRIEFINGS(Victory,BAD_TROFF_HEAD,BAD_IGOR_HEAD,10);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 5);
				return state;
			}
			return state, 30;
		}

		if(m_nState==15)
		{
			SaveEndMissionGame(404,null);
			EnableInterface(false);
			ShowInterface(false);
			m_nState=18;
			return state,0;
		}
		if(m_nState==18)
		{                      
			SetLowConsoleText("translateMissionAccomplished");
			FadeInCutscene(100, 0, 0, 0);
			return XXX,150;
		}
		
		return state, 30;
	}

	state XXX
	{
		EndMission(true);
	}

	state YYY
	{
		MissionDefeat();
	}

	
	event EndMission(int nResult)
	{
	}
	
	int bIgnoreEvent;

	event RemovedUnit(unit uKilled, unit uAttacker, int nNotifyType)
	{
		// mission failed gdy zabijemy swojego lub wieznia
		if(uKilled.IsLive()) return;

		if ( uKilled.GetIFF() == m_pEnemy3.GetIFF()) 
		{
			++m_bCrystalPatrol;
		}
		if ( uKilled.GetIFF() == m_pEnemy4.GetIFF()) 
		{
			++m_bMetalPatrol;
		}
		
		if ( uKilled.GetIFF() == m_pPlayer.GetIFF()  && m_pPlayer.GetNumberOfUnits()==0 )
		{
			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state YYY;

			SetStateDelay(120);
		}
	}

	event RemovedBuilding(unit uKilled, unit uAttacker, int nNotifyType)
	{
		m_bBuildingDestroyed=true;
	}

	
    event EscapeCutscene(int nIFFNum)
    {
		return;

		SetLowConsoleText("");
        StopCutscene();
        SetStateDelay(0);
    }

	event DebugEndMission()
	{
		m_nState = 15;
		state MissionFlow;
        SetStateDelay(30);
	}

    event DebugCommand(string pszCommand)
    {
		int nNum;
		int nGx, nGy;
		string strCommand;
		
		strCommand = pszCommand;
		if (!strCommand.CompareNoCase("state"))
		{
			TRACE2("state = ", state);
		}
		else if (strCommand.sscanf("marker %d", nNum))
		{
			GetMarker(nNum, nGx, nGy);
			TRACE6("marker ", nNum, " = ", nGx, ", ", nGy);
			LookAtMarker(nNum);
		}
		else if (strCommand.sscanf("player %d", nNum))
		{
			GetStartingPoint(nNum, nGx, nGy);
			TRACE6("player ", nNum, " = ", nGx, ", ", nGy);
			LookAt(nGx, nGy, -1, -1, -1);
		}

	}
}
