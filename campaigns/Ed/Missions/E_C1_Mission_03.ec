#include "..\..\defines.ech"


#define MISSION_NAME "translateE_M3"

#define WAVE_MISSION_PREFIX "ED\\M3\\E_M3_Brief_"

	
#define	CLEAR_TUTORIAL() SetConsoleText("")

#define PLAY_BRIEFING_TUTORIAL(BriefingName, AnimMesh, Time, Modal) \
	SetConsoleText(MISSION_NAME "_Tutorial_" # BriefingName); 

#define PLAY_TIMED_BRIEFING_TUTORIAL(BriefingName, AnimMesh, Time, Modal) \
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
		
		rangeAlex = 4;
		rangeBase = 16;

		playerPlayer      = 2;
		playerEnemy       = 3;
		playerEnemyRes    = 7;
		playerNeutral     = 5;
		

		goalHeroMustSurvive = 0;
		goalBuildUpTheBase = 1;
		goalFindAlex = 2;
		goalHealAlex = 3;
		
		goalFindLCBase = 5;
		goalAttackLCBase = 6;
		goalDestroyLCBase = 7;
		

		markerEHero1 = 1;
		markerAlex = 3;
		markerMedkit = 4;
		markerLCBase1 = 5;
		markerLCBase2 = 6;
		markerQueen = 7;
		markerLandingZone = 8;
		markerEnemyAttackStart = 9;
		markerRestriction1 = 10;
		markerRestriction2 = 11;
		markerRestriction3 = 12;

		markerClearEnemyEasy = 40; //20 markerów
		markerClearEnemyMedium = 20;//20 markerów

	}

	player m_pPlayer;
	player m_pEnemy;
	player m_pEnemyRes;
	player m_pNeutral;
	

	unit m_uEHero1;
	unit m_uAlex;
	unit m_uQueen;

	int m_bLCBaseAttacked;
	int nState;
	int bShowFoundUs;
	int m_bNoWind;

	state Start;
	state MissionFlow;
	state XXX;

	int m_bBaseAttack;
	int m_nBaseAttackX;
	int m_nBaseAttackY;
	int m_bHealAlex;


	state Initialize
	{
		int i;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player     );
		INITIALIZE_PLAYER(Enemy      );
		INITIALIZE_PLAYER(EnemyRes );
		INITIALIZE_PLAYER(Neutral    );
		

		bShowFoundUs = false;

		SetNeutrals(m_pEnemy, m_pEnemyRes, m_pNeutral);
		SetNeutrals(m_pPlayer, m_pEnemyRes);
		m_pPlayer.SetAlly(m_pNeutral);
		m_pNeutral.SetAlly(m_pPlayer);

		SetEnemies(m_pPlayer, m_pEnemy);
		SetEnemies(m_pPlayer, m_pEnemyRes);
		
		REGISTER_GOAL(HeroMustSurvive);
		REGISTER_GOAL(BuildUpTheBase);
		REGISTER_GOAL(FindAlex);
		REGISTER_GOAL(HealAlex);
		
		REGISTER_GOAL(FindLCBase);
		REGISTER_GOAL(AttackLCBase);
		REGISTER_GOAL(DestroyLCBase);
		
		RESTORE_SAVED_UNIT(Player, EHero1, eBufferEHero1);
		RestoreBestInfantryAtMarker(m_pPlayer, markerEHero1);
        FinishRestoreUnits(m_pPlayer);

		m_pEnemyRes.EnableAI(false);
		m_pEnemy.EnableAI(true);
		DEACTIVATE_AI(m_pEnemy);

		LookAtUnit(m_uEHero1);


		if(GET_DIFFICULTY_LEVEL() == 0)
		{
			for(i=markerClearEnemyEasy; i<markerClearEnemyEasy+40;i=i+1)
			{
				KillUnitAtMarker(i);
			}
			RemoveUnitAtPoint(81,126);
		}
		if(GET_DIFFICULTY_LEVEL() == 1)
		{
			for(i=markerClearEnemyMedium; i<markerClearEnemyMedium+20;i=i+1)
			{
				KillUnitAtMarker(i);
			}
		}

		SetPlayerTemplateseEDCampaign(m_pPlayer, 3);
		SetPlayerResearchesEDCampaign(m_pPlayer, 3);
		SetEnemyResearchesEDCampaign(m_pEnemy, 3);
		//AddPlayerResearchesEDCampaign(m_pPlayer, 3);
		if(GET_DIFFICULTY_LEVEL() == 2)
		{
			AddEnemyResearchesEDCampaign(m_pEnemy, 3);
		}


		m_pPlayer.EnableBuilding("E_BL_CC_01"   , false);
		m_pPlayer.EnableBuilding("E_BL_EG_02"   , true);
		m_pPlayer.EnableBuilding("E_BL_EX_03"   , true);
		m_pPlayer.EnableBuilding("E_BL_CA_04_1" , true);
		m_pPlayer.EnableBuilding("E_BL_CA_04_2" , true);
		m_pPlayer.EnableBuilding("E_BL_CA_04_3" , true);
		m_pPlayer.EnableBuilding("E_BL_ST_05"   , true);
		m_pPlayer.EnableBuilding("E_BL_IF_06"   , true);
		m_pPlayer.EnableBuilding("E_BL_UF_07"   , true);
		m_pPlayer.EnableBuilding("E_BL_AC_08"   , true);
		m_pPlayer.EnableBuilding("E_BL_TC_09"   , true);
		m_pPlayer.EnableBuilding("E_BL_RL_10"   , false);
		m_pPlayer.EnableBuilding("E_BL_AR_11"   , true);
		m_pPlayer.EnableBuilding("E_BL_WA_12"   , true);
		m_pPlayer.EnableBuilding("E_BL_WA_12_Q" , true);
		m_pPlayer.EnableBuilding("E_BL_WA_12_I" , true);
		m_pPlayer.EnableBuilding("E_BL_WA_12_L" , true);
		m_pPlayer.EnableBuilding("E_BL_WA_12_T" , true);
		m_pPlayer.EnableBuilding("E_BL_WA_12_X" , true);
		m_pPlayer.EnableBuilding("E_BL_GA_13"   , true);
		m_pPlayer.EnableBuilding("E_BL_CO_15"   , true);
		m_pPlayer.EnableBuilding("E_BL_CO_15_2" , true);
		m_pPlayer.EnableBuilding("E_BL_CO_15_3" , true);
		m_pPlayer.EnableBuilding("E_BL_CO_15_4" , true);
		m_pPlayer.EnableBuilding("E_BL_CO_15_5" , true);
		m_pPlayer.EnableBuilding("E_BL_CO_15_6" , true);
		m_pPlayer.EnableBuilding("E_BL_CO_15_7" , true);
		m_pPlayer.EnableBuilding("E_BL_CO_15_8" , true);
		m_pPlayer.EnableBuilding("E_BL_CO_15_9" , true);
		m_pPlayer.EnableBuilding("E_BL_CO_15_10", true);
		m_pPlayer.EnableBuilding("E_BL_CO_16"   , true);
		m_pPlayer.EnableBuilding("E_BL_DR_17"   , true);
		m_pPlayer.EnableBuilding("E_BL_SG_18"   , true);
		m_pPlayer.EnableBuilding("E_BL_WC_14_1" , true);
		m_pPlayer.EnableBuilding("E_BL_WC_14_2" , true);
		m_pPlayer.EnableBuilding("E_BL_WC_14_3" , true);
		m_pPlayer.EnableBuilding("E_BL_WC_14_4" , true);

		SetTimer(1, 500);//alex - 3 sekundy
		SetWind(30, 100);
		SetTimer(2, 2*60*30); // wind change
	
		return Start,1;
	}

	

	state Start
	{
		EnableInterface(true);
		ShowInterface(true);

		FadeOutCutscene(100, 0, 0, 0);
		nState=1;
		m_bHealAlex = false;
		SetLimitedGameRect(markerRestriction1,markerRestriction2);
		m_pPlayer.SetBuildBuildingsTimeMultiplyPercent(20);
		return MissionFlow, 160;
		
	}

/*	
nState = 0; start zablokowana mapa kwadrat
nState = 1; briefing build up a base 
nState = 2; budowa bazy -  kilka budynków lub zblizenie sie do markera x
		    briefing o sygnale SOS - zablokowana mapa - dolna po³owa
nState = 3; szukanie alex -  briefing po jej znalezieniu -  w³aczenie timera dla alex alexstate = 1
nState = 4; briefing o potrzebie znalezienia bazy wroga - cala mapa odkryta
nState = 5;   
			gdy mapa odkryta - briefing od Timura
  
nState = 7; briefing od królowej, goal ¿eby zaatakowaæ bazê LC, LC aktywowane - ataki na gracza.
nState = 8; gdy jakis budynek LC zniszczony TargetReached - królowa zaczyna  akcjê

nState = 9; 1 minute pozniej(timerek sobie tyka) briefing ze królowa zosta³a schwytana goal - zniszczenie bazy  
nState = 9; - czekamy na zniszczenie beazy
nState = 10; -  briefing koncowy cutscena itp. 
*/
	state MissionFlow
	{
		int nGx1, nGy1, nGx2, nGy2;
		int nTicks;
		if(nState==1)
		{
			nState = 25;
			m_pPlayer.AddResource(1, 5000);
			m_pPlayer.AddResource(2, 5000);

			ENABLE_GOAL(HeroMustSurvive);
			ENABLE_GOAL(BuildUpTheBase);
			ADD_BRIEFINGS(BuildUpTheBase, TIMUR_HEAD, IGOR_HEAD, 11);
	        START_BRIEFING(false);
			WaitToEndBriefing(state, 30);
			return state;
		}

		if(nState==25)
		{
			bShowFoundUs = true;
			nState=2;
			return state;
		}
		
		if(nState==2)
		{
		
		
			if(m_pPlayer.GetNumberOfBuildings()>12)
			{
				nState = 3;
				SetGoalState(goalBuildUpTheBase,goalAchieved,false);
				ENABLE_GOAL(FindAlex);
				AddMapSignAtMarker(markerAlex, signMoveTo, -1);
				SetLimitedGameRect(markerRestriction3,markerRestriction2);
				ADD_BRIEFINGS(SOS, TIMUR_HEAD, IGOR_HEAD, 6);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 30);
				return state;
			}
			return state;
		}
		if(nState==3)
		{
			if ( IsUnitNearMarker(m_uEHero1, markerAlex, rangeAlex) )
			{
				nState = 4;
				CREATE_UNIT(Neutral, Alex, "N_IN_VA_01");
				LookAtUnit(m_uAlex);
				SetGoalState(goalFindAlex,goalAchieved,false);
				ENABLE_GOAL(HealAlex);
				AddMapSignAtMarker(markerMedkit, signMoveTo, -1);
				ADD_BRIEFINGS(Alex, IGOR_HEAD, ALEX_HEAD, 19);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30);
				return state;
			}
			return state;
		}
		if(nState==4)
		{
			if ( IsUnitNearMarker(m_uEHero1, markerMedkit, rangeAlex) )
			{
				nState = 5;
				m_bHealAlex = true;
				ENABLE_GOAL(FindLCBase);
				ClearLimitedGameRect();
				SetTimer(1, 90);
				RemoveMapSignAtMarker(markerMedkit);
				ADD_BRIEFINGS(FindLCBase, TIMUR_HEAD, IGOR_HEAD, 14);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30);
				return state;
			}
			return state;
		}
		if(nState==5)
		{
			
			VERIFY(GetMarker(markerLCBase1, nGx1, nGy1));
			VERIFY(GetMarker(markerLCBase2, nGx2, nGy2));

			if ( !m_pPlayer.IsFogInPoint(nGx1, nGy1) ||  !m_pPlayer.IsFogInPoint(nGx2, nGy2)
				|| GetGoalState(goalHealAlex) == goalAchieved)
			{
				nState = 6;
				
				m_pPlayer.SetBuildBuildingsTimeMultiplyPercent(100);
				SetGoalState(goalFindLCBase,goalAchieved,false);
				ADD_BRIEFINGS(NewOrders,  IGOR_HEAD, TIMUR_HEAD,5);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 300);
				return state;
			}
			return state;
		}

		if(nState==6)
		{
			nState = 7;
			m_bLCBaseAttacked = false;
			if(GET_DIFFICULTY_LEVEL()>0)
			{
				ActivateAI(m_pEnemy);
				m_pEnemy.SetAIControlOptions(eAIRebuildAllBuildings, true);
				m_pEnemy.SetAIControlOptions(eAIControlBuildBase, false);
			}
			ENABLE_GOAL(AttackLCBase);
			AddMapSignAtMarker(markerLCBase1, signAttack, -1);
			ADD_BRIEFINGS(EscortAgent, QUEEN_HEAD, IGOR_HEAD, 10);
			CREATE_UNIT(Neutral, Queen, "N_IN_VA_06");
			START_BRIEFING(false);
			WaitToEndBriefing(state, 30);
			return state;
		
		}

		if(nState==7 && m_bLCBaseAttacked)
		{
			nState = 71;
			
			if(GET_DIFFICULTY_LEVEL()==0)
			{
				ActivateAI(m_pEnemy);
				m_pEnemy.SetAIControlOptions(eAIControlBuildBase, false);
				m_pEnemy.AddResource(eCrystal, -5000);
				m_pEnemy.AddResource(eWater, -5000);
				m_pEnemy.AddResource(eMetal, -5000);
				m_pEnemy.SetAIControlOptions(eAIControlBuildBase, false);
			}
			SetGoalState(goalAttackLCBase,goalAchieved,false);
			ENABLE_GOAL(DestroyLCBase);
			ADD_BRIEFING(Trap_01, QUEEN_HEAD);
			ADD_BRIEFING(Trap_02, IGOR_HEAD);
			ADD_BRIEFING(Trap_03, ALEX_HEAD);
			ADD_BRIEFING(Trap_04, QUEEN_HEAD);
			START_BRIEFING(false);
			WaitToEndBriefing(state, 10*30);
			return state;
		}

		if(nState==71)
		{
			nState = 8;
			AddAgent(12); //Noire
			return state,30;
		}
		if(nState==8 && m_bLCBaseAttacked)
		{


			if ( m_pEnemy.GetNumberOfBuildings(eBuildingPowerPlant) <1 )
			{
				SetGoalState(goalDestroyLCBase, goalAchieved);
				RemoveMapSignAtMarker(markerLCBase1);
				nState = 9;
				//XXX zrobic cutscenke ladujacego transportera i  wysiadajacego szatmara.
				return state;
			}
		}
		
		if(nState==9 && m_bLCBaseAttacked)
		{
			nState = 15;
			
			ADD_BRIEFING(Visit_01, SZATMAR_HEAD);
			ADD_BRIEFING(Visit_02, IGOR_HEAD);
			ADD_BRIEFING(Visit_03, ALEX_HEAD);
			ADD_BRIEFING(Visit_04, SZATMAR_HEAD);
			START_BRIEFING(true);
			WaitToEndBriefing(state, 30);
			return state;
		}

		if(nState==15)
		{
			nState=16;
			SaveEndMissionGame(103,null);
			return state,1;
		}
		if(nState==16)
		{
			
			PrepareSaveUnits(m_pPlayer);
            SAVE_UNIT(Player, EHero1, eBufferEHero1);
            SaveBestInfantry(m_pPlayer, 12-(GET_DIFFICULTY_LEVEL()*3));
			SetWind(0,0);
			m_bNoWind=true;
			EnableMessages(false);
			nTicks = PlayCutscene("E_M3_C2.trc", true, true, true);
			return XXX, nTicks-eFadeTime;
		}
		return MissionFlow, 160;
	}

	state XXX
	{
		EndMission(true);
	}
	state YYY
	{
		MissionDefeat();
	}

	
	event Timer1() // Alex
	{
		int nGx, nGy;

		if (m_bHealAlex &&
			IsGoalEnabled(goalHealAlex) && 
			GetGoalState(goalHealAlex)!= goalAchieved && 
			IsUnitNearMarker(m_uEHero1, markerAlex, rangeAlex) &&
			m_uEHero1.GetObjectCountInHeroInventory("ART_HEAL",false))
			{
				SetTimer(1, 500);
				SetGoalState(goalHealAlex,goalAchieved);
				RemoveMapSignAtMarker(markerAlex);

				
	
				VERIFY(GetMarker(markerLCBase1, nGx, nGy));
				ResetFogInArea(nGx, nGy, 10, m_pPlayer.GetIFF());
				ShowObjectsInArea(nGx, nGy, 10, m_pPlayer.GetIFF(),m_pEnemy.GetIFF(), eShowObjectsAll);

				VERIFY(GetMarker(markerLCBase2, nGx, nGy));
				ResetFogInArea(nGx, nGy, 10, m_pPlayer.GetIFF());
				ShowObjectsInArea(nGx, nGy, 10, m_pPlayer.GetIFF(),m_pEnemy.GetIFF(), eShowObjectsAll);

				m_uEHero1.CommandDropObjectFromInventory("ART_HEAL");
				m_uAlex.SetPlayer(m_pPlayer);
				ADD_BRIEFINGS(Medkit, IGOR_HEAD, ALEX_HEAD, 15);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30);
				return;
			}
	}

	event Timer2() // Wind
	{
		if(m_bNoWind)SetWind(0,0);
		else
			SetWind(Rand(100),Rand(255));
	}

	event EndMission(int nResult)
	{
	}
	
	event RemovedUnit(unit uKilled, unit uAttacker, int nNotifyType)
	{
		// mission failed gdy zabijemy swojego lub wieznia

		if(uKilled.GetIFF()==m_pEnemy.GetIFF() && bShowFoundUs)
		{
			bShowFoundUs = false;
			ADD_BRIEFING(FoundUs, IGOR_HEAD);
			START_BRIEFING(true);
			WaitToEndBriefing(state, 30);
			return;
		}


		if ( uKilled == m_uEHero1 )
		{
			CLEAR_TUTORIAL();
			SetGoalState(goalHeroMustSurvive, goalFailed);

			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state YYY;

			SetStateDelay(120);
		}
	}

	int m_bBrief;

	event RemovedBuilding(unit uKilled, unit uAttacker, int nNotifyType)
	{
		int bPlayBrief;

		if ( uKilled.GetIFFNum() == m_pEnemy.GetIFFNum() )
		{
			m_bLCBaseAttacked = true;
		}
		if ( uKilled.GetIFFNum() == m_pEnemyRes.GetIFFNum() )
		{
			SetGoalState(goalAttackLCBase,goalFailed,true);
			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state YYY;

			SetStateDelay(120);
		}


			
	}

	event AddedBuilding(unit uCreated, int nNotifyType)
	{

		
	}

    event EscapeCutscene(int nIFFNum)
    {
		int nTicks;//czas potrzebny na fadeOut
        if ((state == XXX))
        {
        }
        else
        {
            return;
        }
		nTicks = StopCutscene();
		SetStateDelay(nTicks);
    }

	event DebugEndMission()
	{
		nState = 15;
		state MissionFlow;
        SetStateDelay(30);
	}

    event DebugCommand(string pszCommand)
    {
        string strCommand;
        strCommand = pszCommand;
        if (!strCommand.CompareNoCase("x1"))
        {
            state MissionFlow;
        }
	}
}
