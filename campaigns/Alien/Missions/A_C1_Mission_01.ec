#include "..\..\defines.ech"

#define MISSION_NAME "translateA_M1"

#define WAVE_MISSION_PREFIX "AL\\M1\\A_M1_Brief_"


/*
Misja 1
Obudzenie Igora i nauka sterowania obcymi - zniszcenie osady Last hope.
1 igor
2- ataki ucs
3 -ataki ed
4 - ataki neutral
5-6 ograniczenie na starcie

player 4
Enemyucs =1
EnemyED =2
EnemyCivil =5

Zbuduj pojazdy
zbuduj  budynki 1 atak UCS

zciagniecie  ograniczen

zniszcz 3 bazy.

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
		playerEnemyUCS    = 1;
		playerEnemyED     = 2;
		playerEnemyCIVIL  = 5;
		
		
		
		goalAHero1MustSurvive = 0;
		goalCloneTheLady = 1;
		goalTransformToNest = 2;
		goalTransformToTrooper = 3;
		goalDestroyEDBase = 4;
		goalDestroyUCSBase = 5;
		goalDestroyNEWHOPE = 6;
		
		markerAHero1 = 1;
		markerAttackUCS = 2;
		markerAttackED = 3;
		markerAttackCIVIL = 4;
		markerRestriction1 = 5;
		markerRestriction2 = 6;
	}

	player m_pPlayer;
	player m_pEnemyUCS;
	player m_pEnemyED;
	player m_pEnemyCIVIL;
	
	unit m_uAHero1;
	
	int bCheckCopulas;		
	int m_nState;
	int m_nAttackCounter;
	int bIgnoreEvent;	
	
	state Start;
	state MissionFlow;
	state XXX;
	state YYY;

	function int SendAttackToPlayerBase()
	{
		int i, k, nGx, nGy, nMarker;

        
        i = Rand(3);
		nMarker = markerAttackUCS+i;
		
		VERIFY(GetMarker(nMarker, nGx, nGy));
		if (!m_pPlayer.IsFogInPoint(nGx, nGy))
		{
		
			return 0;
		}
		
		k = m_pPlayer.GetNumberOfVehicles()*(GET_DIFFICULTY_LEVEL()+1);

		k = k/5;
		if(k>15) k=15;
        if(!k)k=1;
		

		if(!i)//UCS
		{
			CreateAndAttackFromMarkerToUnit(m_pEnemyUCS, "U_CH_GJ_02_1#U_WP_CH_02_1,U_AR_CL_02_1,U_EN_SP_02_1", k, nMarker, m_uAHero1);
			if(GET_DIFFICULTY_LEVEL())CreateAndAttackFromMarkerToUnit(m_pEnemyUCS, "U_CH_AJ_01_1#U_WP_SH_01_3,U_AR_CL_01_2,U_EN_SP_01_1", k, nMarker, m_uAHero1);
		}
		if(i==1)//ED
		{
			CreateAndAttackFromMarkerToUnit(m_pEnemyED, "E_IN_MA_01_1", k, nMarker, m_uAHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemyED, "E_IN_BA_02_1", k/2, nMarker, m_uAHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemyED, "E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_CL_03_1,E_EN_SP_03_1", 2, nMarker, m_uAHero1);
			if(GET_DIFFICULTY_LEVEL())CreateAndAttackFromMarkerToUnit(m_pEnemyED, "E_CH_AJ_01_1#E_WP_SL_01_1,E_AR_CL_01_1,E_EN_PR_01_1", k, nMarker, m_uAHero1);
		}

		if(i==2)//CIVIL
		{
			CreateAndAttackFromMarkerToUnit(m_pEnemyCIVIL, "N_CH_GJ_03_1", k, nMarker, m_uAHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemyCIVIL, "N_CH_GJ_03_2", k/2, nMarker, m_uAHero1);
		}

		
		return 1;

	}


	state Initialize
	{
		int i;
		unit uVehicle;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(EnemyUCS );
		INITIALIZE_PLAYER(EnemyED );
		INITIALIZE_PLAYER(EnemyCIVIL );
		
		
		m_pEnemyUCS.EnableAI(false);
		m_pEnemyED.EnableAI(false);
		m_pEnemyCIVIL.EnableAI(false);
		

		
		SetNeutrals(m_pEnemyUCS,m_pEnemyED,m_pEnemyCIVIL);
		
		
		REGISTER_GOAL(AHero1MustSurvive);
		REGISTER_GOAL(CloneTheLady);
		REGISTER_GOAL(TransformToNest);
		REGISTER_GOAL(TransformToTrooper);
		REGISTER_GOAL(DestroyEDBase);
		REGISTER_GOAL(DestroyUCSBase);
		REGISTER_GOAL(DestroyNEWHOPE);

		
		
		CREATE_UNIT(Player, AHero1, "A_HERO_01");		
				
		
		SetWind(20, 100);
		i = PlayCutscene("A_M1_C1.trc", true, true, true);
		return Start, i-eFadeTime;
		
	}

	

	state Start
	{
		bCheckCopulas=false;
		m_nState=0;
		//m_nState=30;//XXXMD
		LookAtMarker(markerAHero1);
		SetLimitedGameRect(markerRestriction1,markerRestriction2);
		return MissionFlow, eFadeTime;


		
	}
	int m_nKillCounter;
	state MissionFlow
	{
		int i,nGx, nGy;

		if(bCheckCopulas)
		{
			bCheckCopulas = false;
			TraceD("=================check==============\n\n");
			if(!m_pPlayer.GetNumberOfUnitsWithChasis("A_CH_NU_01_1",1) && !IsTransformationCopula(m_pPlayer, "A_CH_NU_01_C"))
			{
				bIgnoreEvent=true;
				EnableInterface(false);
				ShowInterface(false);
				SetLowConsoleText("translateMissionFailed");
				FadeInCutscene(100, 0, 0, 0);
				return YYY,120;
			}
		}
		if(m_nState==0)
		{
			m_nState = 1;
			ENABLE_GOAL(AHero1MustSurvive);
			ENABLE_GOAL(CloneTheLady);
			ADD_BRIEFINGS(Start,BAD_TROFF_HEAD,BAD_IGOR_HEAD,12);
			START_BRIEFING(eInterfaceEnabled);
			WaitToEndBriefing(state, 10*30);
			return state;
		}
		if(m_nState==1)//
		{
			m_nState = 101;
			PLAY_TIMED_BRIEFING_TUTORIAL(CloneUnit,60*30);
			return state;
		}
		if(m_nState==101)//
		{
			if(m_pPlayer.GetNumberOfUnits()>4)
			{
				m_nState = 2;
				ACHIEVE_GOAL(CloneTheLady);
				ENABLE_GOAL(TransformToNest);
				ADD_BRIEFINGS(TransformToNest,BAD_IGOR_HEAD,BAD_TROFF_HEAD,4);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 5*30);
				return state;
			}
			return state;
		}
		if(m_nState==2)//
		{
			m_nState = 201;
			PLAY_TIMED_BRIEFING_TUTORIAL(CreateNest,60*30);
			return state;
		}
		
		if(m_nState==201)//
		{
			if(m_pPlayer.GetNumberOfNoCopulaBuildings()>0)
			{
				m_nState = 3;
				ACHIEVE_GOAL(TransformToNest);
				ENABLE_GOAL(TransformToTrooper);
				ADD_BRIEFINGS(TransformToTrooper,BAD_IGOR_HEAD,BAD_TROFF_HEAD,3);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 30);
				return state;
			}
			return state;
		}
		if(m_nState==3)//
		{
			m_nState = 301;
			PLAY_TIMED_BRIEFING_TUTORIAL(CreateTrooper,60*30);
			return state;
		}
		
		if(m_nState==301)//
		{
			if(m_pPlayer.GetNumberOfUnitsWithChasis("A_CH_GJ_02_1",1)>0)
			{
				m_nState = 4;
				m_nAttackCounter=(GET_DIFFICULTY_LEVEL()+1)*60;
				ClearLimitedGameRect();
				ACHIEVE_GOAL(TransformToTrooper);
				ENABLE_GOAL(DestroyEDBase);
				ENABLE_GOAL(DestroyUCSBase);
				ENABLE_GOAL(DestroyNEWHOPE);
				ADD_BRIEFINGS(DestroyAllHumans,BAD_IGOR_HEAD,BAD_TROFF_HEAD,9);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 30);
				return state;
			}
			return state;
		}
		if(m_nState==4)
		{	

			++m_nAttackCounter;
			if(m_nAttackCounter>60*(5 - GET_DIFFICULTY_LEVEL()))
			{
				if(SendAttackToPlayerBase())m_nAttackCounter=0;
			}

			if (GetGoalState(goalDestroyEDBase)!=goalAchieved && (m_pEnemyED.GetNumberOfBuildings()<=m_pEnemyED.GetNumberOfBuildings(eBuildingWall)))
			{
				ACHIEVE_GOAL(DestroyEDBase);
			}
			if (GetGoalState(goalDestroyUCSBase)!=goalAchieved && m_pEnemyUCS.GetNumberOfBuildings()==0)
			{
				ACHIEVE_GOAL(DestroyUCSBase);
			}
			if (GetGoalState(goalDestroyNEWHOPE)!=goalAchieved && m_pEnemyCIVIL.GetNumberOfBuildings()==0)
			{
				ACHIEVE_GOAL(DestroyNEWHOPE);
			}


			if (GetGoalState(goalDestroyEDBase)==goalAchieved && 
				GetGoalState(goalDestroyUCSBase)==goalAchieved && 
				GetGoalState(goalDestroyNEWHOPE)==goalAchieved)
			{
				m_nState = 15;
				ADD_BRIEFINGS(Victory,BAD_IGOR_HEAD,BAD_TROFF_HEAD,3);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 10);
				return state;
			}

			return state, 30;
		}

		if(m_nState==15)
		{
			SaveEndMissionGame(401,null);
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
		
		if(bIgnoreEvent) return;
		// mission failed gdy zabijemy swojego lub wieznia
		if(uKilled.IsLive()) return;

		

		if(uKilled.GetIFF()==m_pPlayer.GetIFF() && (m_nState<4 || m_nState>100))
		{
			TraceD("=================unit destroyed==============\n");
			bCheckCopulas = true;
		}

		if ( uKilled == m_uAHero1)
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
		if(bIgnoreEvent) return;
		
		if(uKilled.GetIFF()==m_pPlayer.GetIFF() && (m_nState<4 ||m_nState>100))	
		{
			TraceD("=================building destroyed==============\n");
			bCheckCopulas = true;
		}
	}

	
    event EscapeCutscene(int nIFFNum)
    {
		if(state==Start)
		{
		}
		else
		{
			return;
		}


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
