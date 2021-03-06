#include "..\..\defines.ech"

#define MISSION_NAME "translateA_M3"

#define WAVE_MISSION_PREFIX "AL\\M3\\A_M3_Brief_"


/*
Misja 3
Atak arii na baze tyranosa
1 igor
2 - ataki ucs
3 - zrod³o energii

player 4
Enemy1 = 1
Enemy2 = 6 - pierwszy atak

obron baze przad atakiem,  zaliczony gdy pierwszy atak zniszczony calkowicie
utrzymaj baze do przybycia floty
usun ludzi z kontynentu.

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
		playerEnemy1     = 1;
		playerEnemy2     = 6;
				
		goalAHero1MustSurvive = 0;
		goalSurviveTheAttack = 1;
		goalProtectTheBaseUntilFleetArrive = 2;
		goalDestroyUCS = 3;
		
		markerAHero1 = 1;
		markerAttackStart = 2;//-8
		markerAttackDest = 9;//-11
		markerAttack = 12;//-14
		markerFleetCreate = 15;
		markerFleetMove = 16;
	}

	player m_pPlayer;
	player m_pEnemy1;
	player m_pEnemy2;
	
	
	unit m_uAHero1;
	
		
	int m_nState;
	int m_nAttackCounter;
	int m_nFleetCounter;
	int m_bBuildingDestroyed;
	
	state Start;
	state MissionFlow;
	state XXX;

	function void CreateFleet()
	{
		CreateAndAttackFromMarkerToMarker(m_pPlayer, "A_CH_AF_12_1", 6-(GET_DIFFICULTY_LEVEL()*2), markerFleetCreate, markerFleetMove);
		CreateAndAttackFromMarkerToMarker(m_pPlayer, "A_CH_LC_13_1", 4-(GET_DIFFICULTY_LEVEL()*2), markerFleetCreate, markerFleetMove);
		CreateAndAttackFromMarkerToMarker(m_pPlayer, "A_CH_HC_14_1", 1, markerFleetCreate, markerFleetMove);

		if(!GET_DIFFICULTY_LEVEL())CreateAndAttackFromMarkerToMarker(m_pPlayer, "A_CH_DE_15_1", 1, markerFleetCreate, markerFleetMove);
		return;
	}
	function int FirstAttack()
	{
		int i, k, nGx, nGy, nMarker;
		if(GET_DIFFICULTY_LEVEL()) k=0;
			else k=2;
        for(i=markerAttackStart; i<markerAttackStart+7-k; i=i+1)
		{		
			CreatePatrol(m_pEnemy2, "U_CH_AS_09_1", 1, i, markerAttackDest,markerAttackDest+1,markerAttackDest+2);
			CreatePatrol(m_pEnemy2, "U_CH_AJ_01_1#U_WP_CH_01_3,U_AR_CL_01_3,U_EN_NO_01_1", 3-k, i, markerAttackDest,markerAttackDest+1,markerAttackDest+2);
			CreatePatrol(m_pEnemy2, "U_CH_GJ_02_1#U_WP_NG_02_1,U_AR_RL_02_1,U_EN_PR_02_1", 3-k, i, markerAttackDest,markerAttackDest+1,markerAttackDest+2);
			CreatePatrol(m_pEnemy2, "U_CH_GT_03_1#U_WP_NG_03_1,U_AR_CL_03_1,U_EN_NO_03_1", 3-k, i, markerAttackDest,markerAttackDest+1,markerAttackDest+2);
			if(GET_DIFFICULTY_LEVEL())
				CreatePatrol(m_pEnemy2, "U_CH_GT_04_1#U_WP_GB_04_1#U_WP_FT_04_1,U_AR_RL_04_1,U_EN_PR_04_1", 2, i, markerAttackDest,markerAttackDest+1,markerAttackDest+2);
		}
	
		
		return 1;

	}
	function int SendAttackToPlayerBase()
	{
		int i, k, nGx, nGy, nMarker;

        i=Rand(3);
        nMarker = markerAttack+i;
		
		VERIFY(GetMarker(nMarker, nGx, nGy));
		if (!m_pPlayer.IsFogInPoint(nGx, nGy))
		{
			return 0;
		}
		
		if(m_pEnemy2.GetNumberOfVehicles() > 10) return 0;

		k = m_pPlayer.GetNumberOfVehicles()*(GET_DIFFICULTY_LEVEL()+1);

		k = k/7;
		if(k>15) k=15;
        if(!k)k=1;
		

		if(GET_DIFFICULTY_LEVEL())CreateAndAttackFromMarkerToUnit(m_pEnemy2, "U_CH_AJ_01_1#U_WP_CH_01_1,U_AR_CH_01_1,U_EN_NO_01_1", k, nMarker, m_uAHero1);
		CreateAndAttackFromMarkerToUnit(m_pEnemy2, "U_CH_GT_03_1#U_WP_NG_03_1,U_AR_CH_03_1,U_EN_NO_03_1", k/2, nMarker, m_uAHero1);
		CreateAndAttackFromMarkerToUnit(m_pEnemy2, "U_CH_GT_04_1#U_WP_GB_04_1#U_WP_FT_04_1,U_AR_RL_04_1,U_EN_PR_04_1", 2, nMarker, m_uAHero1);
		CreateAndAttackFromMarkerToUnit(m_pEnemy2, "U_CH_GT_03_1#U_WP_CH_03_3,U_AR_CH_03_1,U_EN_SP_03_1", k, nMarker, m_uAHero1);
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
		
		m_pEnemy1.EnableAI(true);
		m_pEnemy2.EnableAI(false);
		
		ActivateAI(m_pEnemy1);
		m_pEnemy1.SetAIControlOptions(eAIRebuildAllBuildings, true);
		m_pEnemy1.SetAIControlOptions(eAIControlBuildBase, false);

		SetNeutrals(m_pEnemy1,m_pEnemy2);
		
		SetPlayerTemplateseUCSCampaign(m_pEnemy1, 6);
		SetPlayerResearchesUCSCampaign(m_pEnemy1, 6);
		AddPlayerResearchesUCSCampaign(m_pEnemy1, 6);
		SetPlayerResearchesUCSCampaign(m_pEnemy2, 6);
		AddPlayerResearchesUCSCampaign(m_pEnemy2, 6);

		
		REGISTER_GOAL(AHero1MustSurvive);
		REGISTER_GOAL(SurviveTheAttack);
		REGISTER_GOAL(ProtectTheBaseUntilFleetArrive);
		REGISTER_GOAL(DestroyUCS);
	
		RESTORE_SAVED_UNIT(Player, AHero1, eBufferAHero1);
				
		if(!GET_DIFFICULTY_LEVEL())
		{
			for(i=20; i<42;i=i+1)RemoveUnitAtMarker(i);
		}
		LookAtMarker(markerAHero1);
		SetWind(20, 20);
		return Start;
	}

	

	state Start
	{
		m_nState=0;
		//m_nState=30;//XXXMD
		m_nAttackCounter = 0;
		FirstAttack();
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
			ENABLE_GOAL(AHero1MustSurvive);
			ENABLE_GOAL(SurviveTheAttack);
			ADD_BRIEFINGS(Start,BAD_TROFF_HEAD,BAD_IGOR_HEAD,6);
			START_BRIEFING(eInterfaceEnabled);
			WaitToEndBriefing(state, 10*30);
			return state;
		}

		if(m_nState==1)//
		{
			if(m_pEnemy2.GetNumberOfUnits()<7)
			{
				m_nState = 2;
				m_nFleetCounter = 0;		
				ACHIEVE_GOAL(SurviveTheAttack);
				ENABLE_GOAL(ProtectTheBaseUntilFleetArrive);
				ADD_BRIEFINGS(ProtectTheBase,BAD_IGOR_HEAD,BAD_TROFF_HEAD,5);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 10*30);
				return state;
			}
			return state;
		}	
			
		if(m_nState==2)//
		{
		/*	++m_nAttackCounter;
			if(m_nAttackCounter>60*5 - (GET_DIFFICULTY_LEVEL()*30))
			{
				if(SendAttackToPlayerBase())m_nAttackCounter=0;
			}*/
			++m_nFleetCounter;
			/*if(m_nFleetCounter==60*12 ||
			   m_nFleetCounter==60*13 ||
			   m_nFleetCounter==60*14 )
				SendAttackToPlayerBase();*/
				
			if(m_nFleetCounter>60*15)
			{
				m_nState=3;
				CreateFleet();
				ACHIEVE_GOAL(ProtectTheBaseUntilFleetArrive);
				ENABLE_GOAL(DestroyUCS);
				ADD_BRIEFINGS(DestroyUCS,BAD_TROFF_HEAD,BAD_IGOR_HEAD,4);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 10*30);
				return state;
			}
			return state,30;
		}
		if(m_nState==3)//
		{	
			if(m_bBuildingDestroyed)
			{
				m_bBuildingDestroyed=false;
				if(m_pEnemy1.GetNumberOfBuildings()<=m_pEnemy1.GetNumberOfBuildings(eBuildingWall))
				{
					m_nState = 15;
					ACHIEVE_GOAL(DestroyUCS);
					ADD_BRIEFINGS(Victory,BAD_IGOR_HEAD,BAD_TROFF_HEAD,3);
					START_BRIEFING(eInterfaceEnabled);
					WaitToEndBriefing(state, 0);
					return state;
				}
			}
			return state, 30;
		}

		if(m_nState==15)
		{
			SaveEndMissionGame(403,null);
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
