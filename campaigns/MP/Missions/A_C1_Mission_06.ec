#include "..\..\defines.ech"

#define MISSION_NAME "translateA_M6"

#define WAVE_MISSION_PREFIX "AL\\M6\\A_M6_Brief_"


/*
Misja 6
Proba schwytania arii
Aria jest na negocjacjach w bazie LC

  Restricted area

- walka z baza LC. Szybki atak i  okr¹zenie bazy.
Zniszczenie obrony. 
Gdy cala baza zniszczona - briefing z aria. 

  zniesienie restricted area i zmasowany atal LC na gracza - proba zlapania strogova

Potem rozkaz trofa zeby zniszczyc wszystkie sily LC skoro Aria uciekla to  niech zaplaca jej  zolnierze.

  Po zniszczeniu wszystkich budynkow LC koniec

ery nie odkryte.
*/

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
		playerEnemyLC     = 5;
		playerEnemyLC2     = 3;
		playerEnemyLC3     = 6;
				
		goalAHero1MustSurvive = 0;
		goalDestroyAriaDefences = 1;
		goalCaptureAria = 2;
		goalDestroyLCBase = 3;
		
		markerAHero1 = 1;
		markerLCBase = 2;
		markerAria = 3;
		markerRect1 = 4;
		markerRect2 = 5;
		markerAttackLC = 6; //- 11 - atak idzie do markera 2
		markerAttackLC2 = 11; //- 11 - atak idzie do markera 2
	}

	player m_pPlayer;
	player m_pEnemyLC;
	player m_pEnemyLC2;
	player m_pEnemyLC3;
	
	unit m_uAHero1;
	unit m_uAria;
	
		
	int m_nState;
	int m_nAttackCounter;
	int m_bBuildingDestroyed;
	
	state Start;
	state MissionFlow;
	state XXX;

	function void CreateAttack()
	{
		int i, size;
		size = 5+GET_DIFFICULTY_LEVEL()*2;

		for(i=markerAttackLC;i<=markerAttackLC2;i=i+1)
		{
			if(Rand(2))
			{
				CreatePatrol(m_pEnemyLC2, "L_CH_AT_03_1#L_WP_PB_03_1,L_AR_CH_03_1,L_EN_NO_03_1", 1+GET_DIFFICULTY_LEVEL(),i,markerLCBase);
				CreatePatrol(m_pEnemyLC2, "L_CH_GT_05_1#L_WP_PB_05_1#L_WP_PB2_05_1,L_AR_CH_05_1,L_EN_NO_05_1", 1+GET_DIFFICULTY_LEVEL(),i,markerLCBase);
				CreatePatrol(m_pEnemyLC2, "L_CH_AJ_01_1#L_WP_EL_01_1,L_AR_CH_01_1,L_EN_NO_01_1", 2+GET_DIFFICULTY_LEVEL(),i,markerLCBase);
			}
			else
			{
				CreatePatrol(m_pEnemyLC2, "L_CH_AT_03_1#L_WP_PB_03_1,L_AR_CH_03_1,L_EN_NO_03_1", 1+GET_DIFFICULTY_LEVEL(),i,markerLCBase);
				CreatePatrol(m_pEnemyLC2, "L_CH_GT_06_1#L_WP_PB_06_1#L_WP_EL_06_1,L_WP_PB2_06_1,L_WP_PB2_06_1,L_AR_CH_06_1,L_EN_NO_06_1", 1+GET_DIFFICULTY_LEVEL(),i,markerLCBase);
				CreatePatrol(m_pEnemyLC2, "L_CH_AJ_01_1#L_WP_SG_01_1,L_AR_RL_01_1,L_EN_NO_01_1", 1+GET_DIFFICULTY_LEVEL(),i,markerLCBase);
			}
		}
	}

	state Initialize
	{
		int i;
		unit uVehicle;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(EnemyLC3 );
		INITIALIZE_PLAYER(EnemyLC );
		INITIALIZE_PLAYER(EnemyLC2 );
		
		m_pEnemyLC3.EnableAI(false);
		m_pEnemyLC.EnableAI(true);
		m_pEnemyLC2.EnableAI(false);
		
		ActivateAI(m_pEnemyLC);
		m_pEnemyLC.SetAIControlOptions(eAIRebuildAllBuildings, true);
		m_pEnemyLC.SetAIControlOptions(eAIControlBuildBase, false);

		SetPlayerTemplateseLCCampaign(m_pEnemyLC, 6);
		SetPlayerResearchesLCCampaign(m_pEnemyLC, 6);
		AddPlayerResearchesLCCampaign(m_pEnemyLC, GET_DIFFICULTY_LEVEL()*3);

		SetPlayerTemplateseLCCampaign(m_pEnemyLC2, 6);
		SetPlayerResearchesLCCampaign(m_pEnemyLC2, 6);
		AddPlayerResearchesLCCampaign(m_pEnemyLC2, GET_DIFFICULTY_LEVEL()*3);

		SetPlayerTemplateseLCCampaign(m_pEnemyLC3, 6);
		SetPlayerResearchesLCCampaign(m_pEnemyLC3, 6);
		AddPlayerResearchesLCCampaign(m_pEnemyLC3, GET_DIFFICULTY_LEVEL()*3);

		m_pEnemyLC.AddResource(eCrystal, 5000);
		m_pEnemyLC.AddResource(eWater, 5000);

		m_pEnemyLC2.AddResource(eCrystal, 5000);
		m_pEnemyLC2.AddResource(eWater, 5000);

		m_pEnemyLC3.AddResource(eCrystal, 5000);
		m_pEnemyLC3.AddResource(eWater, 5000);

		SetNeutrals(m_pEnemyLC,m_pEnemyLC3,m_pEnemyLC2);


		if(!GET_DIFFICULTY_LEVEL())
		{
			for(i=20; i<41;i=i+1)RemoveUnitAtMarker(i);
			
			CreatePlayerObjectAtMarker(m_pPlayer, "A_CH_AF_12_1", 41);
			CreatePlayerObjectAtMarker(m_pPlayer, "A_CH_AF_12_1", 42);
		}
		
		REGISTER_GOAL(AHero1MustSurvive);
		REGISTER_GOAL(DestroyAriaDefences);
		REGISTER_GOAL(CaptureAria);
		REGISTER_GOAL(DestroyLCBase);
	
		RESTORE_SAVED_UNIT(Player, AHero1, eBufferAHero1);
				
		LookAtMarker(markerAHero1);
		SetWind(20, 20);
		return Start;
	}

	

	state Start
	{
		m_nState=0;
		//m_nState=30;//XXXMD
		m_nAttackCounter = 0;
		SetLimitedGameRect(markerRect1,markerRect2);
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
			AddMapSignAtMarker(markerLCBase, signAttack, -1);
			ENABLE_GOAL(AHero1MustSurvive);
			ENABLE_GOAL(CaptureAria);
			ENABLE_GOAL(DestroyAriaDefences);
			ADD_BRIEFINGS(Start,BAD_IGOR_HEAD,BAD_TROFF_HEAD,16);
			START_BRIEFING(eInterfaceEnabled);
			WaitToEndBriefing(state, 10*30);
			return state;
		}

		if(m_nState==1)//atak na sily arii
		{
			if(m_bBuildingDestroyed==true && m_pEnemyLC.GetNumberOfBuildings() < 15)
			{
				m_bBuildingDestroyed = false;
					m_nState = 2;
					SetNeutrals(m_pPlayer, m_pEnemyLC);
					ClearLimitedGameRect();
					RemoveMapSignAtMarker(markerLCBase);
					ACHIEVE_GOAL(DestroyAriaDefences);
					SetGoalState(goalCaptureAria, goalFailed);
					ENABLE_GOAL(DestroyLCBase);
					ADD_BRIEFINGS(Aria,BAD_IGOR_HEAD,ARIA_HEAD,18);
					START_BRIEFING(eInterfaceEnabled);
					WaitToEndBriefing(state, 0);
					return state;
			}
			return state;
		}	
		
		if(m_nState==2)
		{	

			m_nState = 3;
			CreateAttack();
			m_pEnemyLC2.EnableAI(true);
			ActivateAI(m_pEnemyLC2);
			m_pEnemyLC2.SetAIControlOptions(eAIRebuildAllBuildings, true);
			m_pEnemyLC2.SetAIControlOptions(eAIControlBuildBase, false);
			return state, 5*30;
		}

		if(m_nState==3)
		{
			m_nState = 4;
			SetEnemies(m_pPlayer, m_pEnemyLC);
			ADD_BRIEFINGS(Trap,BAD_TROFF_HEAD,BAD_IGOR_HEAD,4);
			START_BRIEFING(eInterfaceEnabled);
			WaitToEndBriefing(state, 10*30);
			return state;
		}


		if(m_nState==4 && m_bBuildingDestroyed==true)
		{
			m_bBuildingDestroyed = false;
		
			/*++m_nAttackCounter;
			if(m_nAttackCounter>60*(5 - GET_DIFFICULTY_LEVEL()))
			{
				if(SendAttackToPlayerIgor())m_nAttackCounter=0;
			}*/
			
			if (m_pEnemyLC2.GetNumberOfBuildings() < 10)
			{
				ACHIEVE_GOAL(DestroyLCBase);
				m_nState = 15;
				ADD_BRIEFINGS(Victory,BAD_IGOR_HEAD,BAD_TROFF_HEAD,4);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 30);
				return state;
			}
			return state, 30;
		}
		if(m_nState==15)
		{
			SaveEndMissionGame(406,null);
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

		if ( uKilled == m_uAHero1 )
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
