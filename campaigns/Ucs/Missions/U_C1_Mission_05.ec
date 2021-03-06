#include "..\..\defines.ech"

#define MISSION_NAME "translateU_M5"

#define WAVE_MISSION_PREFIX "UCS\\M5\\U_M5_Brief_"


/*
ladowanie w bazie. 
   Ladowanie - strogov, kilka robotów
       Briefing - wykrylam dzialajace zrodlo zasilania na polnocy - ale  sa tez  sygnatury ED
   
	 Droga  do bazy ED - spotkania z obcymi  - ale prostymi do zabicia
	
	Gdy w poblizu bazy ED - briefing z komendantem - oddaj zrod³óó, nic z tego mam rozkazy od GPU - zabezpieczyc teren i czekac na przybycie posilków. 
	Briefing do Arii -  przyslij drony 

	pojawiaja sie drony i termity
   
	Jak baza zniszczona - goal - uruchomic transmitter.
	          stworzyc obce patrole. - naziemne.
  
	jak  brak obcych wokol transmitera - uruchomienie transmisji. Goal - zniszczyc reszte obcych zeby nie zniszczyli transmitera. 

    koniec. Cutscena - na wrotach zapalaja sie swiatla - sa gotowe do startu. 
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
		playerEnemy1    = 2;// ED 
		playerEnemy2    = 4;// Aliens
		playerNeutral = 6; //sebastian i source
		playerNeutral2 = 7; //transmiter

		goalEHero1MustSurvive = 0;
		goalFindSource = 1;
		goalDestroyEDBase = 2;
		goalFindTransmitter = 3;
		goalProtectSebastian = 4;
		goalDestroyAliens = 5;
		
		markerEHero1 = 1;
		markerEDBase = 2;
		markerSource = 3;
		markerTransmiter = 4;
		markerDron = 5;
		markerSebastian = 6;
		markerPatrol = 10;
		markerAlienFinalAttack = 50; // - 52 (random(2))
	}

	player m_pPlayer;
	player m_pEnemy1;
	player m_pEnemy2;
	player m_pNeutral;
	player m_pNeutral2;

	unit m_uEHero1;
	unit m_uDron;
	unit m_uSource;
	unit m_uTransmiter;
	unit m_uSebastian;

	int m_nState;
		
	state Start;
	state MissionFlow;
	state XXX;

	function void CreateAlienPatrols()
	{
		int i, k;

		k=3+(GET_DIFFICULTY_LEVEL()*2);

		for(i = 0; i<10;i=i+1)
		{
			CreatePatrol(m_pEnemy2, "A_CH_GJ_02_1", k/2, markerPatrol, markerPatrol+i);
			CreatePatrol(m_pEnemy2, "A_CH_GJ_02_2", k/2, markerPatrol, markerPatrol+i);
			if(GET_DIFFICULTY_LEVEL()>0 && i>5) CreatePatrol(m_pEnemy2, "A_CH_GT_04_1", k/2, markerPatrol, markerPatrol+i);
			if(GET_DIFFICULTY_LEVEL()==2) CreatePatrol(m_pEnemy2, "A_CH_GJ_03_1", k/2, markerPatrol, markerPatrol+i);
		}
	}

	
	function void CreateAlienAttack()
	{
		int i, k;

		i = Rand(3);
		k=3+(GET_DIFFICULTY_LEVEL()*2);

		CreatePatrol(m_pEnemy2, "A_CH_GT_04_1", k, markerAlienFinalAttack+i, markerSebastian);
		CreatePatrol(m_pEnemy2, "A_CH_GJ_02_1", k, markerAlienFinalAttack+i, markerSebastian);
		CreatePatrol(m_pEnemy2, "A_CH_GJ_02_2", k, markerAlienFinalAttack+i, markerSebastian);
		CreatePatrol(m_pEnemy2, "A_CH_GT_04_1", k, markerAlienFinalAttack+i, markerSebastian);
		
	}

	state Initialize
	{
		int i;
		unit uVehicle;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player);
		INITIALIZE_PLAYER(Enemy1);
		INITIALIZE_PLAYER(Enemy2);
		INITIALIZE_PLAYER(Neutral);
		INITIALIZE_PLAYER(Neutral2);
		
		m_pEnemy1.EnableAI(false);
		m_pEnemy2.EnableAI(false);// xxxmd WLACZYC JAK JUZ BEDZIE DZIALAL
		m_pNeutral.EnableAI(false);
		m_pNeutral2.EnableAI(false);

		SetPlayerTemplateseUCSCampaign(m_pPlayer, 3);
		SetPlayerResearchesUCSCampaign(m_pPlayer, 3);
		//AddPlayerResearchesUCSCampaign(m_pPlayer, 3);

		SetPlayerResearchesEDCampaign(m_pEnemy1, 4);
		

		SetEnemies(m_pEnemy2,m_pPlayer);
		SetNeutrals(m_pNeutral,m_pNeutral2,m_pPlayer, m_pEnemy1);
		SetNeutrals(m_pNeutral,m_pNeutral2,m_pEnemy2, m_pEnemy1);

		INITIALIZE_UNIT(Transmiter);
		INITIALIZE_UNIT(Source);

		// BY TZ
		if(GET_DIFFICULTY_LEVEL() ==0)// easy
		{
			for(i=80; i<=84;i=i+1) RemoveUnitAtMarker(i);
			for(i=90; i<=97;i=i+1) RemoveUnitAtMarker(i);
			
			RemoveUnitAtPoint(63,94);
			RemoveUnitAtPoint(44,95);

			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_NG_03_1,U_AR_CH_03_1,U_EN_NO_03_1", 65);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_NG_03_1,U_AR_CH_03_1,U_EN_NO_03_1", 66);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_NG_03_1,U_AR_CH_03_1,U_EN_NO_03_1", 67);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_CH_03_3,U_AR_CL_03_1,U_EN_SP_03_1", 62);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_CH_03_3,U_AR_CL_03_1,U_EN_SP_03_1", 63);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_CH_03_3,U_AR_CL_03_1,U_EN_SP_03_1", 64);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_04_1#U_WP_PB_04_1#U_WP_XR_04_1,U_AR_CH_04_1,U_EN_SP_04_1", 60);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_04_1#U_WP_PB_04_1#U_WP_XR_04_1,U_AR_CH_04_1,U_EN_SP_04_1", 61);

			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_AS_09_1", 68);
		}

		if(GET_DIFFICULTY_LEVEL() == 1)// middle
		{
			RemoveUnitAtMarker(81);
			RemoveUnitAtMarker(84);
			RemoveUnitAtMarker(90);
			RemoveUnitAtMarker(91);
			RemoveUnitAtMarker(94);
			RemoveUnitAtMarker(96);
		}


		REGISTER_GOAL(EHero1MustSurvive);
		REGISTER_GOAL(FindSource);
		REGISTER_GOAL(DestroyEDBase);
		REGISTER_GOAL(FindTransmitter);
		REGISTER_GOAL(ProtectSebastian);
		REGISTER_GOAL(DestroyAliens);
				
		
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

		FadeOutCutscene(60, 0, 0, 0);
		return MissionFlow, 160;


		
	}
	int m_nKillCounter;
	int m_nAttackCounter;
	int m_nNoOfAttacks;
	state MissionFlow
	{
		int i,nGx, nGy;

		if(m_nState==0)
		{
			m_nState = 1;
			ENABLE_GOAL(EHero1MustSurvive);
			ENABLE_GOAL(FindSource);
			EnableInterface(false);
			ADD_BRIEFINGS(FindSource,SZATMAR_HEAD,IGOR_HEAD,6);
			START_BRIEFING(eInterfaceDisabled);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(m_nState==1)
		{
			m_nState = 2;
			EnableInterface(true);
			CreateAlienPatrols();
			return state;
		}
		
		if(m_nState==2)
		{
			VERIFY(GetMarker(markerSource, nGx, nGy));
			if (!m_pPlayer.IsFogInPoint(nGx, nGy))
			{
				m_nState = 3;
				ACHIEVE_GOAL(FindSource);
				SetAlly(m_pPlayer, m_pNeutral);
				LookAtMarkerMedium(markerSource);
				ADD_BRIEFINGS(AtSource,ED_OFFICER_HEAD,IGOR_HEAD,11);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 30);
				return state;
			}
			return state;
		}

		if(m_nState==3)
		{	
			m_nState = 35;
			ENABLE_GOAL(DestroyEDBase);
			ADD_BRIEFINGS(GiveDrone,IGOR_HEAD,ARIA_HEAD,4);//XXXTZ
			START_BRIEFING(eInterfaceEnabled);
			WaitToEndBriefing(state, 1);
			return state;
		}

		if(m_nState==35)
		{	
			m_nState = 4;
			SetEnemies(m_pPlayer, m_pEnemy1);
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
			return state;
		}

		if(m_nState==4)
		{
		
		
			if (!m_pEnemy1.GetNumberOfBuildings() && !m_pEnemy1.GetNumberOfUnits())
			{
				m_nState = 5;
				CreateAlienPatrols();
				ACHIEVE_GOAL(DestroyEDBase);
				ENABLE_GOAL(FindTransmitter);
				ADD_BRIEFINGS(FindTransmiter,SZATMAR_HEAD,IGOR_HEAD,8);// poszukaj transmitera.
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 10*30);
				return state;
			}
			return state;
		}

		if(m_nState==5)
		{

			VERIFY(GetMarker(markerTransmiter, nGx, nGy));
			if (!m_pPlayer.IsFogInPoint(nGx, nGy))
			
			{
				m_nState = 6;
				ACHIEVE_GOAL(FindTransmitter);
				ENABLE_GOAL(ProtectSebastian);
				ENABLE_GOAL(DestroyAliens);
				LookAtMarkerMedium(markerTransmiter);
				SetAlly(m_pNeutral2, m_pPlayer);
				ADD_BRIEFINGS(Transmiter1,IGOR_HEAD,SZATMAR_HEAD,10);// bron sebastiana i usun  alienow
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 30);
				return state;
			}
			return state, 5*30;
		}

		if(m_nState==6)
		{
			m_nState = 7;
			CREATE_UNIT(Player, Sebastian, "N_IN_VA_09");
			SetEnemies(m_pNeutral, m_pEnemy2);
			SetEnemies(m_pNeutral2, m_pEnemy2);
			CreateAlienAttack();
			return state;
		}
		if(m_nState==7)
		{
			++m_nAttackCounter;
			if(m_nNoOfAttacks<4 && m_nAttackCounter> 60*(4-GET_DIFFICULTY_LEVEL()))
			{
				++m_nNoOfAttacks;
				m_nAttackCounter=0;
				CreateAlienAttack();
			}
			if (!m_pEnemy2.GetNumberOfBuildings() && !m_pEnemy2.GetNumberOfUnits())
			{
				m_nState = 15;
				ACHIEVE_GOAL(ProtectSebastian);
				ACHIEVE_GOAL(DestroyAliens);
				ADD_BRIEFINGS(TheEnd,IGOR_HEAD,ARIA_HEAD,3);// obcy zniszczeni
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 10*30);
				return state;
			}
			return state;
		
		}
		if(m_nState==15)
		{
			SaveEndMissionGame(305,null);
			m_nState=18;
			EnableInterface(false);
			ShowInterface(false);
			return state,60;
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
		
		if(uKilled.IsLive()) return;

		if ( uKilled == m_uEHero1 || uKilled==m_uSebastian)
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
