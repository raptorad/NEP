#include "..\..\defines.ech"

#define MISSION_NAME "translateU_M4"

#define WAVE_MISSION_PREFIX "UCS\\M4\\U_M4_Brief_"


/*
LastHope
ladowanie w bazie. 
   Ladowanie - strogov, kilka robotów 
     Briefing - witajcie jestesmy z LostSouls - statek Ed [przybyl tutaj, Czuja sie panami traktuja nas jak niewolnikow - pomozcie.
	 pewnie zaraz tu przybeda.
   
	rusza patrol ED do miejsca ladowania
   
	baza ED odkryta  - briefing z komendantem ED - 
	Zabicie zakladnikow - wkurzenie igora. 
	Drona
	Baza ED znisczona - koniec podziekowania  gosci z LostSouls - pokazanie swiatyni - Sebastian w swiatyni odczytuje wspolrzedne edenu
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

		playerPlayer    = 1;
		playerEnemy     = 2;// ED 
		playerNeutral   = 5;// Last hope
		playerNeutral2   = 6;// zakladnicy
		
		
		goalEHero1MustSurvive = 0;
		goalContactSurvivors = 1;
		goalNegotiate = 2;
		goalDestroyEDBase = 3;
		
		markerEHero1 = 1;
		markerEDBase = 2;
		markerTemple = 3;
		markerPatrol = 4;
		markerLastHope = 5;
		markerMassacre = 6;
		markerDron = 7;
		markerMainBase = 8;

		markerCreate = 9;
		markerDest1 = 10;
		markerDest2 = 11;
		markerDest3 = 12;
	}

	player m_pPlayer;
	player m_pEnemy;
	player m_pNeutral;
	player m_pNeutral2;

	unit m_uEHero1;
	unit m_uDron;
	unit m_uMainBase;

	int m_nState;
		
	state Start;
	state MissionFlow;
	state XXX;

	function void CreateEDPatrol()
	{
		int i, k;

		k=3+(GET_DIFFICULTY_LEVEL()*2);

		CreatePatrol(m_pEnemy, "E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_CL_03_2,E_EN_SP_03_3", k, markerPatrol, markerLastHope);
	}

	function void CreateEDHeavyPatrol()
	{
		int i, k;

		k=3+(GET_DIFFICULTY_LEVEL()*2);

		CreatePatrol(m_pEnemy, "E_CH_GT_04_1#E_WP_CA_04_1,E_AR_RL_04_1,E_EN_NO_04_1", k, markerCreate, markerDest1, markerDest2, markerDest3);
	}

	state Initialize
	{
		int i;
		unit uVehicle;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(Enemy );
		INITIALIZE_PLAYER(Neutral );
		INITIALIZE_PLAYER(Neutral2 );
		
		m_pEnemy.EnableAI(false);
		m_pNeutral.EnableAI(false);
		m_pNeutral2.EnableAI(false);

		SetPlayerTemplateseUCSCampaign(m_pPlayer, 3);
		SetPlayerResearchesUCSCampaign(m_pPlayer, 3);
		//AddPlayerResearchesUCSCampaign(m_pPlayer, 3);

		SetPlayerResearchesEDCampaign(m_pEnemy, 4);
		

		SetEnemies(m_pEnemy,m_pPlayer);
		SetNeutrals(m_pNeutral,m_pNeutral2,m_pPlayer);
		SetNeutrals(m_pNeutral2,m_pEnemy);

		INITIALIZE_UNIT(MainBase);

		// BY TZ
		if(GET_DIFFICULTY_LEVEL() ==0)// easy
		{
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_NG_03_3,U_AR_CH_03_3,U_EN_SP_03_3", 13);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_AR_03_3,U_AR_CL_03_3,U_EN_SP_03_3", 14);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_04_1#U_WP_PB_04_3#U_WP_XR_04_3,U_AR_CH_04_3,U_EN_SP_04_3", 15);
		}

		if(GET_DIFFICULTY_LEVEL() >0)// no easy
		{
			for(i=16; i<=17;i=i+1) RemoveUnitAtMarker(i);
		}
			
		
		REGISTER_GOAL(EHero1MustSurvive);
		REGISTER_GOAL(ContactSurvivors);
		REGISTER_GOAL(Negotiate);
		REGISTER_GOAL(DestroyEDBase);
		
		
		RESTORE_SAVED_UNIT(Player, EHero1, eBufferEHero1);
		RestoreBestInfantryAtMarker(m_pPlayer, markerEHero1);
		FinishRestoreUnits(m_pPlayer);

		
		LookAtUnit(m_uEHero1);
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
			eNoMoneyDisplay |
			//eNoMenuButton |
			0
			);
		SetWind(0, 0);
		return Start;
	}

	

	state Start
	{
		m_nState=0;
		//m_nState=30;//XXXMD

		m_pPlayer.AddResource(eCrystal, 5000);
		m_pPlayer.AddResource(eMetal, 5000);

		m_pEnemy.AddResource(eMetal, 5000);
		m_pEnemy.AddResource(eWater, 5000);

		FadeOutCutscene(60, 0, 0, 0);
		return MissionFlow, 160;


		
	}
	int m_nKillCounter;
	state MissionFlow
	{
		int i,nGx, nGy;

		if(m_nState==0)
		{
			m_nState = 1;
			ENABLE_GOAL(EHero1MustSurvive);
			ENABLE_GOAL(ContactSurvivors);
			ADD_BRIEFINGS(Start,IGOR_HEAD,ARIA_HEAD,5);
			START_BRIEFING(eInterfaceEnabled);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(m_nState==1)
		{
			if(IsUnitNearMarker(m_uEHero1, markerLastHope, 6)) // prosba o pomoc w negocjacjach z ED
			{
				m_nState = 2;
				ACHIEVE_GOAL(ContactSurvivors);
				LookAtMarkerMedium(markerLastHope);
				ENABLE_GOAL(Negotiate);
				EnableInterface(false);
				ADD_BRIEFINGS(Survivors,CIVIL_HEAD,IGOR_HEAD,16);
				START_BRIEFING(eInterfaceDisabled);
				WaitToEndBriefing(state, 30);
				return state;
			}
		}
		if(m_nState==2)// wyslac patrol ED
		{
			m_nState = 3;
			EnableInterface(true);
			CreateEDPatrol();
			ActivateAI(m_pEnemy);
			m_pEnemy.SetAIControlOptions(eAIRebuildAllBuildings, true);
			m_pEnemy.SetAIControlOptions(eAIControlBuildBase, false);

			return state;
		}
		if(m_nState==3)
		{	
			VERIFY(GetMarker(markerEDBase, nGx, nGy));
			if (!m_pPlayer.IsFogInPoint(nGx, nGy))
			{
				m_nState = 4;
				SetNeutrals(m_pPlayer, m_pEnemy);
				ADD_BRIEFINGS(Negotiations,ED_OFFICER_HEAD,IGOR_HEAD,10);// Negocjacje - jak nie odstapicie to zabijemy  niewolnikow.
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 1);
				return state;
			}
			return state;
		}

		if(m_nState==4)
		{
			m_nState = 5;
			SetEnemies(m_pNeutral2, m_pEnemy);
			SetAlly(m_pNeutral2, m_pPlayer);
			LookAtMarkerMedium(markerMassacre,0);
			DelayedLookAtMarkerMedium(markerMassacre,32, 5*30, 1);
			
			return state, 5*30;
		}

		if(m_nState==5)
		{
			m_nState = 6;
			
			SetEnemies(m_pPlayer, m_pEnemy);
			SetGoalState(goalNegotiate, goalFailed);
			ENABLE_GOAL(DestroyEDBase);
			ADD_BRIEFINGS(DestroyEDBase,IGOR_HEAD,ARIA_HEAD,11);
			START_BRIEFING(eInterfaceEnabled);
			WaitToEndBriefing(state, 5*30);
			return state, 5*30;
		}
		if(m_nState==6)
		{
			m_nState = 7;
			SetEnemies(m_pPlayer, m_pEnemy);
			CreateEDHeavyPatrol();
			CREATE_UNIT(Player, Dron, "U_CH_AR_08_1");		
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
		}
		if(m_nState==7)
		{
			
			if(!m_uMainBase.IsLive())
			{
				m_nState = 15;
				ACHIEVE_GOAL(DestroyEDBase);
				SetNeutrals(m_pEnemy,m_pPlayer,m_pNeutral);
				ADD_BRIEFINGS(EDBaseDestroyed1,ED_SOLDIER_HEAD,IGOR_HEAD,6); // poddajemy sie
				ADD_BRIEFINGS(EDBaseDestroyed2,IGOR_HEAD,ARIA_HEAD,4); // Igor do Arii, koniec walk
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 5*30);
			}
			return state, 5*30;
		}
		if(m_nState==15)
		{
			SaveEndMissionGame(304,null);
			m_nState=18;
			EnableInterface(false);
			ShowInterface(false);
			return state,60;
		}
		if(m_nState==18)
		{       
			SetWind(0, 0);SetTimer(2,0);
			EnableMessages(false);
			i = PlayCutscene("U_M4_C2.trc", true, true, true);
			return XXX, i-eFadeTime;
		
		}
		
		return state, 30;
	}

	state XXX
	{
		PrepareSaveUnits(m_pPlayer);
		SAVE_UNIT(Player, EHero1, eBufferEHero1);
        SaveBestInfantry(m_pPlayer, 12-GET_DIFFICULTY_LEVEL()*3);
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

		if ( uKilled == m_uEHero1 )
		{
			bIgnoreEvent=true;
			SetGoalState(goalEHero1MustSurvive, goalFailed);

			LookatUnit(m_uEHero1);
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
	}

	
    event EscapeCutscene(int nIFFNum)
    {
		if(state==XXX)
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
