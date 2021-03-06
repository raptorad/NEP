#include "..\..\defines.ech"

#define MISSION_NAME "translateA_M2"

#define WAVE_MISSION_PREFIX "AL\\M2\\A_M2_Brief_"


/*
Misja 1
Walka o przejecie ksiezyca energetycznego z rak obcych
1 igor
2 - ataki ucs
3 - zrod³o energii

player 4

EnemyED =2
Neutral1 =6
Neutral2 =7

Znajdz zloza siloconu dla statku matki
Sklonuj statek matke
zbuduj transmutera
Znajdz zloza metalu dla transmutera
zbuduj light cruisera

zniszcz baze ed

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
		playerNeutral     = 7;
				
		goalAHero1MustSurvive = 0;
		goalFindSilicon = 1;
		goalCloneMothership = 2;
		goalTransform1 = 3;
		goalFindMetal = 4;
		goalTransform2 = 5;
		goalDestroyEDBase = 6;
		
		markerAHero1 = 1;
		markerAttackED = 12;//-18
		markerSource = 3;
		markerSilicon = 4;//-8
		markerMetal = 9;//-11
	}

	player m_pPlayer;
	player m_pEnemyED;
	player m_pNeutral;
	
	unit m_uAHero1;
	

	int bIgnoreEvent;
	int m_nState;
	int m_nAttackCounter;
	int m_bBuildingDestroyed;
	
	state Start;
	state MissionFlow;
	state XXX;
	state YYY;

	function int SendAttackToPlayerBase()
	{
		int i, k, nGx, nGy, nMarker;

        i=Rand(7);
        nMarker = markerAttackED+i;
		
		VERIFY(GetMarker(nMarker, nGx, nGy));
		if (!m_pPlayer.IsFogInPoint(nGx, nGy))
		{
			return 0;
		}
		
		k = m_pPlayer.GetNumberOfVehicles()*(GET_DIFFICULTY_LEVEL()+1);

		k = k/8;
		if(k>15) k=15;
        if(!k)k=1;
		

		CreateAndAttackFromMarkerToUnit(m_pEnemyED, "E_IN_MA_01_1", k, nMarker, m_uAHero1);
		CreateAndAttackFromMarkerToUnit(m_pEnemyED, "E_IN_BA_02_1", k/2, nMarker, m_uAHero1);
		CreateAndAttackFromMarkerToUnit(m_pEnemyED, "E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_CL_03_1,E_EN_SP_03_1", 2, nMarker, m_uAHero1);
		CreateAndAttackFromMarkerToUnit(m_pEnemyED, "E_CH_AJ_01_1#E_WP_SL_01_1,E_AR_CL_01_1,E_EN_PR_01_1", k, nMarker, m_uAHero1);
	
		
		return 1;

	}


	state Initialize
	{
		int i;
		unit uVehicle;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(EnemyED );
		INITIALIZE_PLAYER(Neutral );
		
		
		
		m_pEnemyED.EnableAI(false);
		m_pNeutral.EnableAI(false);
		

		
		SetNeutrals(m_pEnemyED,m_pNeutral);
		SetNeutrals(m_pPlayer,m_pNeutral);
		
		
		REGISTER_GOAL(AHero1MustSurvive);
		REGISTER_GOAL(FindSilicon  );
		REGISTER_GOAL(CloneMothership  );
		REGISTER_GOAL(Transform1  );
		REGISTER_GOAL(FindMetal  );
		REGISTER_GOAL(Transform2  );
		REGISTER_GOAL(DestroyEDBase  );
		
		
		
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
		FadeOutCutscene(60, 0, 0, 0);
		return MissionFlow, 160;


		
	}
	int m_nKillCounter;
	int bCheckCopulas;
	state MissionFlow
	{
		int i,j,nGx, nGy, nFound;

		if(bCheckCopulas)
		{
			bCheckCopulas=false;
			if(!m_pPlayer.GetNumberOfUnitsWithChasis("A_CH_NU_10_1",1)   &&
				!m_pPlayer.GetNumberOfUnitsWithChasis("A_CH_NU_11_1",1)  &&
				!IsTransformationCopula(m_pPlayer, "A_CH_NU_10_CLONE")   &&
				!IsTransformationCopula(m_pPlayer, "A_CH_NU_11_1_CREATE")&&
				!IsTransformationCopula(m_pPlayer, "A_CH_LC_13_1_CREATE"))
			{
				bIgnoreEvent=true;
				EnableInterface(false);
				ShowInterface(false);
				SetLowConsoleText("translateMissionFailed");
				FadeInCutscene(100, 0, 0, 0);
				return YYY,120;
			}
		}

		++m_nAttackCounter;
		if(m_nAttackCounter>60*(5 - GET_DIFFICULTY_LEVEL()))
		{
			if(SendAttackToPlayerBase())m_nAttackCounter=0;
		}

		if(m_nState==0)
		{
			if(!GET_DIFFICULTY_LEVEL())
			{
				AddMapSignAtMarker(markerSilicon, signSpecial, -1);
				AddMapSignAtMarker(markerSilicon+1, signSpecial, -1);
				AddMapSignAtMarker(markerSilicon+2, signSpecial, -1);
				AddMapSignAtMarker(markerSilicon+3, signSpecial, -1);
				AddMapSignAtMarker(markerSilicon+4, signSpecial, -1);
			}
			m_nState = 1;
			ENABLE_GOAL(AHero1MustSurvive);
			ENABLE_GOAL(FindSilicon);
			ADD_BRIEFINGS(Start,BAD_TROFF_HEAD,BAD_IGOR_HEAD,7);
			START_BRIEFING(eInterfaceEnabled);
			WaitToEndBriefing(state, 10*30);
			return state;
		}

		if(m_nState==1)//
		{
			for(i=markerSilicon;i<markerSilicon+5;i=i+1)
			{
				VERIFY(GetMarker(i, nGx, nGy));
				if (!m_pPlayer.IsFogInPoint(nGx, nGy))
				{
					m_nState = 2;
					if(!GET_DIFFICULTY_LEVEL())
					{
						RemoveMapSignAtMarker(markerSilicon); 
						RemoveMapSignAtMarker(markerSilicon+1); 
						RemoveMapSignAtMarker(markerSilicon+2); 
						RemoveMapSignAtMarker(markerSilicon+3); 
						RemoveMapSignAtMarker(markerSilicon+4); 
					}
					LookAtMarkerMedium(i);
					ACHIEVE_GOAL(FindSilicon);
					ENABLE_GOAL(CloneMothership);
					ADD_BRIEFINGS(CloneMothership,BAD_IGOR_HEAD,BAD_TROFF_HEAD,4);
					START_BRIEFING(eInterfaceEnabled);
					WaitToEndBriefing(state, 10*30);
					return state;
				}
			}
			return state;
		}	
			
		if(m_nState==2)//
		{
			m_nState = 3;
			PLAY_TIMED_BRIEFING_TUTORIAL(CloneMothership,60*30);
			return state;
		}
		if(m_nState==3)//
		{
			if(m_pPlayer.GetNumberOfUnitsWithChasis("A_CH_NU_10_1",1)>1)
			{
				m_nState = 4;
				ACHIEVE_GOAL(CloneMothership);
				ENABLE_GOAL(Transform1);
				ADD_BRIEFINGS(Transform1,BAD_TROFF_HEAD,BAD_IGOR_HEAD,3);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 5*30);
				return state;
			}
			return state;
		}
		if(m_nState==4)//
		{
			m_nState = 45;
			PLAY_TIMED_BRIEFING_TUTORIAL(Transform1_01,60*30);
			return state,60*30;
		}
		if(m_nState==45)//
		{
			m_nState = 5;
			PLAY_TIMED_BRIEFING_TUTORIAL(Transform1_02,60*30);
			return state;
		}
		
		if(m_nState==5)//
		{
			if(m_pPlayer.GetNumberOfUnitsWithChasis("A_CH_NU_11_1",1)>0)
			{
				m_nState = 6;
				if(!GET_DIFFICULTY_LEVEL())
				{
					AddMapSignAtMarker(markerMetal, signSpecial, -1);
					AddMapSignAtMarker(markerMetal+1, signSpecial, -1);
					AddMapSignAtMarker(markerMetal+2, signSpecial, -1);
				}
				ACHIEVE_GOAL(Transform1);
				ENABLE_GOAL(FindMetal);
				ADD_BRIEFINGS(FindMetal,BAD_TROFF_HEAD,BAD_IGOR_HEAD,3);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 30);
				return state;
			}
			return state;
		}
		if(m_nState==6)//
		{
			for(i=markerMetal;i<markerMetal+4;i=i+1)
			{
				VERIFY(GetMarker(i, nGx, nGy));
				if (!m_pPlayer.IsFogInPoint(nGx, nGy))
				{
					m_nState = 7;
					if(!GET_DIFFICULTY_LEVEL())
					{
						RemoveMapSignAtMarker(markerMetal); 
						RemoveMapSignAtMarker(markerMetal+1); 
						RemoveMapSignAtMarker(markerMetal+2); 
					}
					LookAtMarkerMedium(i);
					ACHIEVE_GOAL(FindMetal);
					ENABLE_GOAL(Transform2);
					ADD_BRIEFINGS(Transform2,BAD_IGOR_HEAD,BAD_TROFF_HEAD,3);
					START_BRIEFING(eInterfaceEnabled);
					WaitToEndBriefing(state, 10*30);
					return state;
				}
			}
			return state;
		}	
		
		if(m_nState==7)//
		{
			m_nState = 8;
			PLAY_TIMED_BRIEFING_TUTORIAL(Transform2,60*30);
		}
		
		if(m_nState==8)//
		{
			if(m_pPlayer.GetNumberOfUnitsWithChasis("A_CH_LC_13_1",1)>0)
			{
				m_nState = 9;
				ACHIEVE_GOAL(Transform2);
				ENABLE_GOAL(DestroyEDBase);
				ADD_BRIEFINGS(DestroyEDBase,BAD_TROFF_HEAD,BAD_IGOR_HEAD,4);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 30);
				return state;
			}
			return state;
		}
		

		if(m_nState==9)
		{	

			if(m_bBuildingDestroyed)
			{
				m_bBuildingDestroyed=false;
				if(m_pEnemyED.GetNumberOfBuildings()<=m_pEnemyED.GetNumberOfBuildings(eBuildingWall))
				{
					m_nState = 15;
					ACHIEVE_GOAL(DestroyEDBase);
					ADD_BRIEFINGS(Victory,BAD_TROFF_HEAD,BAD_IGOR_HEAD,5);
					START_BRIEFING(eInterfaceEnabled);
					WaitToEndBriefing(state, 0);
					return state;
				}
			}
			return state, 30;
		}

		if(m_nState==15)
		{
			SaveEndMissionGame(402,null);
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

		if((uKilled.GetIFF()==m_pPlayer.GetIFF()) && (m_nState<9 || m_nState>40))
		{
			bCheckCopulas=true;
		}
	}

	event RemovedBuilding(unit uKilled, unit uAttacker, int nNotifyType)
	{
		m_bBuildingDestroyed=true;
		if((uKilled.GetIFF()==m_pPlayer.GetIFF()) && (m_nState<9 || m_nState>40))
		{
			bCheckCopulas=true;
		}
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
