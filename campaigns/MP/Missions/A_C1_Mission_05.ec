#include "..\..\defines.ech"

#define MISSION_NAME "translateA_M5"

#define WAVE_MISSION_PREFIX "AL\\M5\\A_M5_Brief_"


/*
Misja 1
Walka o przejecie krateru na Marsie z rak ED i LC

1 igor
2 lady
 

player 4

EnemyED = 2
EnemyLC = 3
EnemyLC2 = 5 (patrole)

dotrzyj z krolowa do  krateru.
Zniszcz  baze Lc
Zniszcz bazeED

slabe Ataki co 3 minuty - po kolei jezeli markery nie odkryte.
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
		playerEnemyED     = 2;
		playerEnemyED2    = 8;
		playerEnemyLC     = 3;
		playerEnemyLC2    = 5;
				
		goalAHero1MustSurvive = 0;
		goalEscortLadyToCrater = 1;
		goalDestroyEDBase = 2;
		goalDestroyLCBase = 3;
		
		markerAHero1 = 1;
		markerLady = 2;
		markerCrater = 3;
		markerPatrol1 = 4;//-15 (16 to ostatni patrolowy punkt)
		markerAttackLC = 20; //22
		markerAttackED = 23; //26
	}

	player m_pPlayer;
	player m_pEnemyED;
	player m_pEnemyED2;
	player m_pEnemyLC;
	player m_pEnemyLC2;
	
	unit m_uAHero1;
	unit m_uLady;
	
		
	int m_nState;
	int m_nAttackCounter;
	int m_bBuildingDestroyed;
	
	state Start;
	state MissionFlow;
	state XXX;

	function int SendAttackToPlayerBase()
	{
		int i, k, nGx, nGy, nMarker;

        i=Rand(7);
        nMarker = markerAttackLC+i;
		
		VERIFY(GetMarker(nMarker, nGx, nGy));
		if (!m_pPlayer.IsFogInPoint(nGx, nGy))
		{
			return 0;
		}
		
		k = m_pPlayer.GetNumberOfVehicles()*(GET_DIFFICULTY_LEVEL()+1);

		k = k/5;
		if(k>15) k=15;
        if(!k)k=1;
		 if(i<3)//LC
		 {
			CreateAndAttackFromMarkerToUnit(m_pEnemyLC2, "L_CH_AJ_01_1#L_WP_EL_01_1,L_AR_CH_01_1,L_EN_NO_01_1", 2, nMarker, m_uAHero1);
			if(GET_DIFFICULTY_LEVEL())CreateAndAttackFromMarkerToUnit(m_pEnemyLC2, "L_CH_AT_03_1#L_WP_PB_03_1,L_AR_CH_03_1,L_EN_NO_03_1", k, nMarker, m_uAHero1);
		 }
		 else//ED
		 {
			CreateAndAttackFromMarkerToUnit(m_pEnemyED2, "E_IN_MA_01_1", k, nMarker, m_uAHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemyED2, "E_IN_BA_02_1", k/2, nMarker, m_uAHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemyED2, "E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_CL_03_1,E_EN_SP_03_1", 2, nMarker, m_uAHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemyED2, "E_CH_AJ_01_1#E_WP_SL_01_1,E_AR_CL_01_1,E_EN_PR_01_1", k, nMarker, m_uAHero1);
		 }
		
		return 1;

	}

	function void CreatePatrols()
	{
		int i, size;
		size = 3+GET_DIFFICULTY_LEVEL()*3;

		for(i=markerPatrol1;i<markerPatrol1+12;i=i+1)
		{
			if(Rand(2))
			{
				CreatePatrol(m_pEnemyLC2, "L_CH_AT_03_1#L_WP_PB_03_1,L_AR_CH_03_1,L_EN_NO_03_1", 1+GET_DIFFICULTY_LEVEL(),i,i+1);
				CreatePatrol(m_pEnemyLC2, "L_CH_GJ_02_1#L_WP_SG_02_1,L_AR_CL_02_1,L_EN_NO_02_1", 1+GET_DIFFICULTY_LEVEL(),i,i+1);
				CreatePatrol(m_pEnemyLC2, "L_CH_GJ_02_1#L_WP_AA_02_1,L_AR_CL_02_1,L_EN_NO_02_1", 1+GET_DIFFICULTY_LEVEL(),i,i+1);
			}
			else
			{
				if(GET_DIFFICULTY_LEVEL())CreatePatrol(m_pEnemyLC2, "L_CH_AT_03_1#L_WP_PB_03_1,L_AR_CH_03_1,L_EN_NO_03_1", 1+GET_DIFFICULTY_LEVEL(),i,i+1);
				CreatePatrol(m_pEnemyLC2, "L_CH_GJ_02_1#L_WP_PG_02_1,L_AR_RL_02_1,L_EN_SP_02_1", 1+GET_DIFFICULTY_LEVEL(),i,i+1);
				CreatePatrol(m_pEnemyLC2, "L_CH_GJ_02_1#L_WP_SG_02_1,L_AR_CL_02_1,L_EN_SP_02_1", 1+GET_DIFFICULTY_LEVEL(),i,i+1);
			}
		}
	}

	state Initialize
	{
		int i;
		unit uVehicle;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(EnemyED );
		INITIALIZE_PLAYER(EnemyED2 );
		INITIALIZE_PLAYER(EnemyLC );
		INITIALIZE_PLAYER(EnemyLC2 );
		
		
		
		
		m_pEnemyED.EnableAI(true);
		m_pEnemyED2.EnableAI(false);
		m_pEnemyLC.EnableAI(true);
		m_pEnemyLC2.EnableAI(false);
		
		SetPlayerTemplateseEDCampaign(m_pEnemyED, 5);
		SetPlayerResearchesEDCampaign(m_pEnemyED, 5);
		AddPlayerResearchesEDCampaign(m_pEnemyED, 5);

		SetPlayerResearchesEDCampaign(m_pEnemyED2, 5);
		AddPlayerResearchesEDCampaign(m_pEnemyED2, 5);

		SetPlayerResearchesLCCampaign(m_pEnemyLC, 5);
		SetPlayerResearchesLCCampaign(m_pEnemyLC2, 5);
		
		AddPlayerResearchesLCCampaign(m_pEnemyLC, 5);
		AddPlayerResearchesLCCampaign(m_pEnemyLC2, 5);
		
		
		SetNeutrals(m_pEnemyED,m_pEnemyED2,m_pEnemyLC,m_pEnemyLC2);
		
		
		ActivateAI(m_pEnemyED);
		m_pEnemyED.SetAIControlOptions(eAIRebuildAllBuildings, true);
		m_pEnemyED.SetAIControlOptions(eAIControlBuildBase, false);
		ActivateAI(m_pEnemyLC);
		m_pEnemyLC.SetAIControlOptions(eAIRebuildAllBuildings, true);
		m_pEnemyLC.SetAIControlOptions(eAIControlBuildBase, false);

		if(!GET_DIFFICULTY_LEVEL())
		{
			for(i=30; i<32;i=i+1)RemoveUnitAtMarker(i);
			
			CreatePlayerObjectAtMarker(m_pPlayer, "A_CH_AF_12_1", 32);
			CreatePlayerObjectAtMarker(m_pPlayer, "A_CH_LC_13_1", 33);
		}


		REGISTER_GOAL(AHero1MustSurvive);
		REGISTER_GOAL(EscortLadyToCrater);
		REGISTER_GOAL(DestroyEDBase);
		REGISTER_GOAL(DestroyLCBase);
	
		RESTORE_SAVED_UNIT(Player, AHero1, eBufferAHero1);		
		CREATE_UNIT(Player, Lady, "A_CH_NU_01_1");
				
		LookAtMarker(markerAHero1);
		SetWind(20, 20);
		return Start;
	}

	

	state Start
	{
		m_nState=0;
		//m_nState=30;//XXXMD
		m_nAttackCounter = 0;
		FadeOutCutscene(60, 0, 0, 0);
		return MissionFlow, 160;


		
	}
	int m_nKillCounter;
	state MissionFlow
	{
		int i,nGx, nGy, nFound;


		++m_nAttackCounter;
		if(m_nAttackCounter>60*(5 - GET_DIFFICULTY_LEVEL()))
		{
			if(SendAttackToPlayerBase())m_nAttackCounter=0;
		}



		if(m_nState==0)
		{
			m_nState = 1;
			CreatePatrols();
			AddMapSignAtMarker(markerCrater, signMoveTo, -1);
			ENABLE_GOAL(AHero1MustSurvive);
			ENABLE_GOAL(EscortLadyToCrater);
			ADD_BRIEFINGS(Start,BAD_IGOR_HEAD,BAD_TROFF_HEAD,12);
			START_BRIEFING(eInterfaceEnabled);
			WaitToEndBriefing(state, 10*30);
			return state;
		}

		if(m_nState==1)//droga do crateru
		{
			if(IsUnitNearMarker(m_uLady, markerCrater,8))
			{
					m_nState = 2;
					RemoveMapSignAtMarker(markerCrater);
					ACHIEVE_GOAL(EscortLadyToCrater);
					ENABLE_GOAL(DestroyEDBase);
					ENABLE_GOAL(DestroyLCBase);
					ADD_BRIEFINGS(Crater,BAD_IGOR_HEAD,BAD_TROFF_HEAD,6);
					START_BRIEFING(eInterfaceEnabled);
					WaitToEndBriefing(state, 10*30);
					return state;
			}
			return state;
		}	
		
		if(m_nState==2)
		{	

			++m_nAttackCounter;
			if(m_nAttackCounter>60*(5 - GET_DIFFICULTY_LEVEL()))
			{
				if(SendAttackToPlayerBase())m_nAttackCounter=0;
			}

			if (GetGoalState(goalDestroyEDBase)!=goalAchieved && m_pEnemyED.GetNumberOfBuildings()==0)
			{
				ACHIEVE_GOAL(DestroyEDBase);
			}
			if (GetGoalState(goalDestroyLCBase)!=goalAchieved && m_pEnemyLC.GetNumberOfBuildings()==0)
			{
				ACHIEVE_GOAL(DestroyLCBase);
			}
			

			if (GetGoalState(goalDestroyEDBase)==goalAchieved && 
				GetGoalState(goalDestroyLCBase)==goalAchieved )
			{
				m_nState = 15;
				ADD_BRIEFINGS(Victory,BAD_IGOR_HEAD,BAD_TROFF_HEAD,4);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 0);
				return state;
			}

			return state, 30;
		}
		if(m_nState==15)
		{
			SaveEndMissionGame(405,null);
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
		SAVE_UNIT(Player, AHero1, eBufferAHero1);
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

		if ( uKilled == m_uAHero1 || (uKilled == m_uLady && GetGoalState(goalEscortLadyToCrater)!=goalAchieved))
		{
			bIgnoreEvent=true;
			SetGoalState(goalAHero1MustSurvive, goalFailed);

			LookatUnit(m_uAHero1);
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
