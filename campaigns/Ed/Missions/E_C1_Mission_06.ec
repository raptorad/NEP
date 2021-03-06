#include "..\..\defines.ech"
/*
1 - ladowanie i transmisja
2 - odnaleziebnie bazy - transmisja z szalencami
3 - atak szalnców - transmisja do bazy.
4 - atak obcych
5 - transmisja Timura o zawieszeniu broni
6 - walka z obcymi o droga do bazy LC
7 - oczyszczanie bazy LC
8 - cutscena koñcz¹ca.





*/

#define MISSION_NAME "translateE_M6"

#define WAVE_MISSION_PREFIX "ED\\M6\\E_M6_Brief_"


#define	CLEAR_TUTORIAL() SetConsoleText("")

#define PLAY_BRIEFING_TUTORIAL(BriefingName, Time, Modal) \
	SetConsoleText(MISSION_NAME "_Tutorial_" # BriefingName); 

#define PLAY_TIMED_BRIEFING_TUTORIAL(BriefingName, Time, Modal) \
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

		playerPlayer    = 2;
		playerED		= 5;
		playerAlien1    = 6;
		playerAlien2    = 7;
		playerAlien3    = 8;
		playerLC		= 3;
		
		goalHeroMustSurvive = 0;
		goalGoToDon = 1;
		goalBuildBase = 2;
		goalNegotiate = 3;
		goalCleanup = 4;

		markerEHero1 = 1;
		markerEDBase = 2;
		markerLCBase = 3;
		markerBunker = 4;
		markerAttack = 10; //do 19 ataki parami 10->11 12->13 .. 18->19
		
	}

	player m_pPlayer;
	player m_pED; //5 ED w donie
	player m_pAlien1;//  ataki na baze ED
	player m_pAlien2;// na calej planszy - aktywny
	player m_pAlien3;// w bazie LC
	player m_pLC;
	

	unit m_uEHero1;
	unit m_uBunker;
	
	int m_nState;
	int m_bCheckVictory;    

	state Start;
	state MissionFlow;
	state XXX;

	state Initialize
	{
		int i;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(Alien1 );
		INITIALIZE_PLAYER(Alien2 );
		INITIALIZE_PLAYER(Alien3 );
		INITIALIZE_PLAYER(ED );
		INITIALIZE_PLAYER(LC);
		
		
		SetNeutrals(m_pAlien1, m_pAlien2, m_pAlien3, m_pLC, m_pED);
		m_pPlayer.SetAlly(m_pED);
		m_pED.SetAlly(m_pPlayer);

		m_pAlien1.EnableAI(false);
		m_pAlien2.EnableAI(false);
		m_pAlien3.EnableAI(false);
		m_pED.EnableAI(false);
		m_pLC.EnableAI(false);
		
		REGISTER_GOAL(HeroMustSurvive);
		REGISTER_GOAL(GoToDon);
		REGISTER_GOAL(BuildBase);
		REGISTER_GOAL(Negotiate);
		REGISTER_GOAL(Cleanup);

				
		INITIALIZE_UNIT(Bunker);

		RESTORE_SAVED_UNIT(Player, EHero1, eBufferEHero1);
		RestoreBestInfantryAtMarker(m_pPlayer, markerEHero1);
        FinishRestoreUnits(m_pPlayer);

		LookAtUnit(m_uEHero1);
		if(GET_DIFFICULTY_LEVEL())
		{
			RemoveUnitAtMarker(20);
			RemoveUnitAtMarker(21);
		}
		if(!GET_DIFFICULTY_LEVEL())
		{
			RemoveUnitAtPoint(60,162);
			RemoveUnitAtPoint(61,162);
			RemoveUnitAtPoint(88,196);
			RemoveUnitAtPoint(89,196);
			RemoveUnitAtPoint(85,197);
			RemoveUnitAtPoint(87,201);
			RemoveUnitAtPoint(154,205);
			RemoveUnitAtPoint(59,166);
			RemoveUnitAtPoint(60,162);
			RemoveUnitAtPoint(61,162);
		}


		SetPlayerTemplateseEDCampaign(m_pPlayer, 6);
		SetPlayerResearchesEDCampaign(m_pPlayer, 6);
		//AddPlayerResearchesEDCampaign(m_pPlayer, 6);
		SetEnemyResearchesEDCampaign(m_pLC, 6);
		
		
		m_pPlayer.EnableBuilding("E_BL_CC_01"   , true);
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
		m_pPlayer.EnableBuilding("E_BL_RL_10"   , true);
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

		SetTimer(2, 2*60*30); // wind change


		SetWind(30, 100);


		SetInterfaceOptions(
				eNoConstructorDialog |
				eNoResearchCenterDialog |
				eNoBuildingUpgradeDialog |
				eNoBuildPanelDialog |
				eNoMoneyConfigDialog |
				//eNoGoalsDialog |
				//eNoCommandsDialog |
				//eNoMapDialog |
				eNoAllianceDialog |
				//eForceAllianceDialog |
				//eForceAllianceDialog |
				//eNoMoneyDisplay |
				//eNoMenuButton |
				0
				);
		return Start;
	}

	

	state Start
	{

		m_nState = 0;
		EnableInterface(true);
		ShowInterface(true);

		FadeOutCutscene(100, 0, 0, 0);
		return MissionFlow, 160;
		
	}

	state MissionFlow
	{
		int i;
		if(m_nState==0)
		{
			m_nState = 1;
			
			ENABLE_GOAL(HeroMustSurvive);
			ENABLE_GOAL(GoToDon);
			AddMapSignAtMarker(markerEDBase, signMoveTo, -1);
			ADD_BRIEFINGS(Briefing, TIMUR_HEAD, IGOR_HEAD, 11);
	        START_BRIEFING(true);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(m_nState==1)
		{
			if(IsAnyObjectNearMarker(m_pPlayer, markerEDBase, 6))
			{
				m_nState = 2;
				RemoveMapSignAtMarker(markerEDBase);
				ACHIEVE_GOAL(GoToDon);
				ADD_BRIEFINGS(Madmen,ED_SOLDIER_HEAD, IGOR_HEAD, 6);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30);
				return state;
			}
		}

		if(m_nState==2)
		{
			m_pED.SetEnemy(m_pPlayer);
			m_nState = 3;
			return state;
		}

		if(m_nState==3)
		{
			m_pPlayer.SetEnemy(m_pED);
			GiveAllBuildingsToPlayer(m_pED,m_pPlayer);
			m_nState = 4;
			return state;
		}
		if(m_nState==4)
		{
			if(m_pED.GetNumberOfUnits()==0)
			{
				SetInterfaceOptions(
				//eNoConstructorDialog |
				//eNoResearchCenterDialog |
				//eNoBuildingUpgradeDialog |
				//eNoBuildPanelDialog |
				//eNoMoneyConfigDialog |
				//eNoGoalsDialog |
				//eNoCommandsDialog |
				//eNoMapDialog |
				eNoAllianceDialog |
				//eForceAllianceDialog |
				//eForceAllianceDialog |
				//eNoMoneyDisplay |
				//eNoMenuButton |
				0
				);
				m_pPlayer.AddResource(eMetal, 5000-GET_DIFFICULTY_LEVEL()*1000);
				m_pPlayer.AddResource(eWater, 5000-GET_DIFFICULTY_LEVEL()*1000);
				m_nState = 5;
				ENABLE_GOAL(BuildBase);
				ADD_BRIEFINGS(AfterAttack, IGOR_HEAD,ED_SOLDIER_HEAD, 7);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30*15);
				return state;
			}
		}
		if(m_nState==5)
		{
				m_nState = 6;
				ADD_BRIEFING(Contact_01, ED_SOLDIER_HEAD);
				ADD_BRIEFING(Contact_02, IGOR_HEAD);
				ADD_BRIEFING(Contact_03, TIMUR_HEAD);
				ADD_BRIEFING(Contact_04, IGOR_HEAD);
				ADD_BRIEFING(Contact_05, TIMUR_HEAD);
				ADD_BRIEFING(Contact_06, IGOR_HEAD);
				ADD_BRIEFING(Contact_07, TIMUR_HEAD);
				ADD_BRIEFING(Contact_08, IGOR_HEAD);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 120*30);
				return state;
		}
		if(m_nState==6)
		{
				m_nState = 7;
								
				// atak ai 1
				// aktywowanie alien 2
				if(GET_DIFFICULTY_LEVEL())ActivateAI(m_pAlien2);
				for(i=0; i<7+GET_DIFFICULTY_LEVEL();i=i+2)
				{
					CreateAndAttackFromMarkerToMarker(m_pAlien1, "A_CH_GJ_02_1",2+GET_DIFFICULTY_LEVEL(),markerAttack+i, markerAttack+i+1);
					CreateAndAttackFromMarkerToMarker(m_pAlien1, "A_CH_GJ_02_2",2+GET_DIFFICULTY_LEVEL(),markerAttack+i, markerAttack+i+1);
					CreateAndAttackFromMarkerToMarker(m_pAlien1, "A_CH_GJ_03_2",3+GET_DIFFICULTY_LEVEL(),markerAttack+i, markerAttack+i+1);
					CreateAndAttackFromMarkerToMarker(m_pAlien1, "A_CH_GT_04_1",GET_DIFFICULTY_LEVEL()*2,markerAttack+i, markerAttack+i+1);
				}
				return state;
		}
		if(m_nState==7)
		{
			if(m_pAlien1.GetNumberOfUnits()==0)
			{
				m_nState=8;
				if(!GET_DIFFICULTY_LEVEL())ActivateAI(m_pAlien2);
				SetNeutrals(m_pPlayer, m_pLC);
				ENABLE_GOAL(Negotiate);
				AddMapSignAtMarker(markerLCBase, signMoveTo, -1);
				ADD_BRIEFINGS(Aliens, TIMUR_HEAD,IGOR_HEAD, 12);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30*15);
			}
			return state;
		}
		if(m_nState==8)
		{
			if(IsAnyObjectNearMarker(m_pPlayer, markerLCBase, 16))
			{
				m_nState = 95;
				SetEnemies(m_pLC,m_pAlien2);
				SetEnemies(m_pLC,m_pAlien3);
				RemoveMapSignAtMarker(markerLCBase);
				ENABLE_GOAL(Cleanup);
				ADD_BRIEFING(LCBase_01, IGOR_HEAD);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30);
				return state;
			}
		}
		if(m_nState==95)
		{
			m_nState = 9;
			SetEnemies(m_pPlayer,m_pAlien2);
			SetEnemies(m_pPlayer,m_pAlien3);
			return state;
		}
		if(m_nState==9)
		{
			if(m_pAlien3.GetNumberOfUnits()==0)
			{
				m_nState=10;
				EnableMessages(false);
				ACHIEVE_GOAL(Negotiate);
				ACHIEVE_GOAL(Cleanup);
				ADD_BRIEFING(Takeover_01, ED_SOLDIER_HEAD);
				ADD_BRIEFING(Takeover_02, IGOR_HEAD);
				ADD_BRIEFING(Takeover_03, ARIA_HEAD);
				ADD_BRIEFING(Takeover_04, IGOR_HEAD);
				ADD_BRIEFING(Takeover_05, ARIA_HEAD);
				ADD_BRIEFING(Takeover_06, IGOR_HEAD);
				ADD_BRIEFING(Takeover_07, ARIA_HEAD);
				ADD_BRIEFING(Takeover_08, IGOR_HEAD);
				ADD_BRIEFING(Takeover_09, ARIA_HEAD);
				ADD_BRIEFING(Takeover_10, IGOR_HEAD);
				ADD_BRIEFING(Takeover_11, ARIA_HEAD);
				ADD_BRIEFING(Takeover_12, IGOR_HEAD);
				ADD_BRIEFING(Takeover_13, ARIA_HEAD);
				ADD_BRIEFING(Takeover_14, IGOR_HEAD);
				ADD_BRIEFING(Takeover_15, ED_SOLDIER_HEAD);
				ADD_BRIEFING(Takeover_16, IGOR_HEAD);
				ADD_BRIEFING(Takeover_17, ROCHLIN_HEAD);
				ADD_BRIEFING(Takeover_18, IGOR_HEAD);
				ADD_BRIEFING(Takeover_19, ROCHLIN_HEAD);
				ADD_BRIEFING(Takeover_20, IGOR_HEAD);
				ADD_BRIEFING(Takeover_21, ROCHLIN_HEAD);
				ADD_BRIEFING(Takeover_22, IGOR_HEAD);
				ADD_BRIEFING(Takeover_23, ROCHLIN_HEAD);
				ADD_BRIEFING(Takeover_24, IGOR_HEAD);
				ADD_BRIEFING(Takeover_25, ROCHLIN_HEAD);
				ADD_BRIEFING(Takeover_26, IGOR_HEAD);
				ADD_BRIEFING(Takeover_27, IGOR_HEAD);
				ADD_BRIEFING(Takeover_28, ARIA_HEAD);
				ADD_BRIEFING(Takeover_29, IGOR_HEAD);
				ADD_BRIEFING(Takeover_30, ARIA_HEAD);
				ADD_BRIEFING(Takeover_31, IGOR_HEAD);
				ADD_BRIEFING(Takeover_32, ARIA_HEAD);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30);
			}
			return state;
		}

		if(m_nState==10)
		{
			SaveEndMissionGame(106,null);
			m_nState = 15;
			return state;
		}
		
		if(m_nState == 15)
		{
				EnableInterface(false);
				ShowInterface(false);
				
				PrepareSaveUnits(m_pPlayer);
				SAVE_UNIT(Player, EHero1, eBufferEHero1);
				SaveBestInfantry(m_pPlayer, 12-(GET_DIFFICULTY_LEVEL()*3));

				SetLowConsoleText("translateMissionAccomplished");

				FadeInCutscene(100, 0, 0, 0);
				return XXX,150;
		
		}
		return MissionFlow, 60;
	}
	
	state XXX
	{
		EndMission(true);
	}
	state YYY
	{
		MissionDefeat();
	}


	
	

	event Timer2() // Wind
	{
		SetWind(Rand(100),Rand(255));
	}

	event EndMission(int nResult)
	{
	}
	
	event RemovedUnit(unit uKilled, unit uAttacker, int nNotifyType)
	{
		// mission failed gdy zabijemy swojego lub wieznia

		

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
		if ( uKilled.GetIFFNum() != m_pPlayer.GetIFFNum() )
		{
			m_bCheckVictory = true;
		}

	}

	

	event RemovedBuilding(unit uKilled, unit uAttacker, int nNotifyType)
	{
		if ( uKilled == m_uBunker)
		{
			
			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state YYY;

			SetStateDelay(120);
		}

		
		if ( uKilled.GetIFFNum() != m_pPlayer.GetIFFNum() )
		{
			m_bCheckVictory = true;
		}
	}

	event AddedBuilding(unit uCreated, int nNotifyType)
	{

		
	}

    event EscapeCutscene(int nIFFNum)
    {
		int nTicks;//czas potrzebny na fadeOut
        if ((state == Start))
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
		m_nState = 15;
		state MissionFlow;
        SetStateDelay(30);
	}

    event DebugCommand(string pszCommand)
    {
	}
}
