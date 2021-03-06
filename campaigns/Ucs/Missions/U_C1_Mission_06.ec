#include "..\..\defines.ech"

#define MISSION_NAME "translateU_M6"

#define WAVE_MISSION_PREFIX "UCS\\M6\\U_M6_Brief_"


/*
ladowanie - briefing

podejscie do bazy lc - briefing - nikogo nie ma
za chwile briefing - tu jej ekscelencja -  zabierzcie mnie z tad. - co sie stalo.  - oni zaraz wroca.
baza LC jako ally
Alien jako wrog dla LC
wstawienie obcych na markerach wokol bazy

briefing od natashy - uciekajcie  ta sama droga ktora przysliscie - tylko ona jest wolna - zalieni zatrzymuja sie aby zniszczyc baze LC. 
Briefing od natashy - zrzucam wam drony i wysliwce do obrony. 
Rozbuduj baze - zabezpiecz teren.
po zniszczeniu wszystkich obcych koniec piesni. - jest ich bardzo duzo.



Nastepna misja. Zniszczyc miejsce skad nadchodza obcy. - swiatynia budowniczych - strogov znajduje tam zapiski i zmienia sie w obcego. 


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
		playerPlayer    = 1;
		playerEnemy     = 4;// Aliens
		playerNeutral = 3; //LC
		
		goalLHero1MustSurvive = 0;
		goalLookAround = 1;
		goalEvacuate = 2;
		goalDestroyAliens = 3;
		
		markerLHero1 = 1;
		markerLCBase = 2;
		markerDron = 5;
		markerAlienPatrol = 30; //-40 
		markerAlienAttack = 50; //-59 
		markerAlienDest = 60;
	}

	player m_pPlayer;
	player m_pEnemy;
	player m_pNeutral;

	unit m_uLHero1;
	unit m_uDron;
	
	int m_nState;
	int m_nAttackCounter;
	int m_nWave;

	state Start;
	state MissionFlow;
	state XXX;

	function void CreateAlienPatrols()
	{
		int i, k;

		k=3+(GET_DIFFICULTY_LEVEL()*2);

		for(i = 0; i<10;i=i+1)
		{
			CreatePatrol(m_pEnemy, "A_CH_GJ_02_2", k, markerAlienPatrol+i, markerAlienPatrol+i+1);
			CreatePatrol(m_pEnemy, "A_CH_GT_04_1", k/2,  markerAlienPatrol+i, markerAlienPatrol+i+1);
		}
	}

	
	function void CreateAlienAttack()
	{
		int i, k;

		k=3+(GET_DIFFICULTY_LEVEL()*2);

		for(i = 0; i<10;i=i+1)
		{
			CreatePatrol(m_pEnemy, "A_CH_GJ_02_2", k, markerAlienAttack+i, markerAlienDest);
			CreatePatrol(m_pEnemy, "A_CH_GT_04_1", k/2, markerAlienAttack+i, markerAlienDest);
		}
		
	}


	function int SendAttackToPlayerBase()
	{
		int i, k, nGx, nGy, nMarker;

        i=Rand(10);
        nMarker = markerAlienAttack+i;
		
		VERIFY(GetMarker(nMarker, nGx, nGy));
		if (!m_pPlayer.IsFogInPoint(nGx, nGy))
		{
			return 0;
		}
		
		k = m_pPlayer.GetNumberOfVehicles();

		k = k/5;
		if(GET_DIFFICULTY_LEVEL()<2) k=k-3;
		if(GET_DIFFICULTY_LEVEL()<1) k=k-3;

		
		if(k>15) k=15;
        if(k<1) k=1;
		
        ++m_nWave;
		CreateAndAttackFromMarkerToUnit(m_pEnemy, "A_CH_GJ_02_2", k, nMarker, m_uLHero1);
		CreateAndAttackFromMarkerToUnit(m_pEnemy, "A_CH_GJ_02_1", k, nMarker, m_uLHero1);
		if(m_nWave>3)CreateAndAttackFromMarkerToUnit(m_pEnemy, "A_CH_GJ_03_2", k, nMarker, m_uLHero1);
		if(m_nWave>6)CreateAndAttackFromMarkerToUnit(m_pEnemy, "A_CH_GT_04_1", k, nMarker, m_uLHero1);
		if(m_nWave>8 && k>1)CreateAndAttackFromMarkerToUnit(m_pEnemy, "A_CH_AF_12_1", k/2, nMarker, m_uLHero1);
		return 1;

	}


	state Initialize
	{
		int i;
		unit uVehicle;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player);
		INITIALIZE_PLAYER(Enemy);
		INITIALIZE_PLAYER(Neutral);
		
		m_pEnemy.EnableAI(false);
		m_pNeutral.EnableAI(false);

		SetPlayerTemplateseUCSCampaign(m_pPlayer, 6);
		SetPlayerResearchesUCSCampaign(m_pPlayer, 6);
		//AddPlayerResearchesUCSCampaign(m_pPlayer, 6);

		SetEnemies(m_pEnemy,m_pPlayer);
		SetNeutrals(m_pNeutral,m_pPlayer);
		SetNeutrals(m_pNeutral,m_pEnemy);

		// BY TZ
		if(GET_DIFFICULTY_LEVEL() ==0)// easy
		{
			for(i=90; i<=107;i=i+1) RemoveUnitAtMarker(i);

RemoveUnitAtPoint(174,155);
RemoveUnitAtPoint(199,167);
RemoveUnitAtPoint(157,184);

			m_pNeutral.CreateObject("L_BL_TW_13", 115,130, 0, 64);


			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_04_1#U_WP_PB_04_1#U_WP_SG_04_1,U_AR_CL_04_1,U_EN_PR_04_1", 70);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_04_1#U_WP_PB_04_1#U_WP_SG_04_1,U_AR_CL_04_1,U_EN_PR_04_1", 71);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_04_1#U_WP_PB_04_1#U_WP_SG_04_1,U_AR_CL_04_1,U_EN_PR_04_1", 72);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_04_1#U_WP_PB_04_1#U_WP_SG_04_1,U_AR_CL_04_1,U_EN_PR_04_1", 73);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_NG_03_2,U_AR_CL_03_2,U_EN_NO_03_1", 74);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_NG_03_2,U_AR_CL_03_2,U_EN_NO_03_1", 75);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_CH_03_1,U_AR_CH_03_1,U_EN_SP_03_1", 76);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_CH_03_1,U_AR_CH_03_1,U_EN_SP_03_1", 77);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_CH_03_1,U_AR_CH_03_1,U_EN_SP_03_1", 78);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_CH_03_1,U_AR_CH_03_1,U_EN_SP_03_1", 79);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_AS_09_1", 80);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_AS_09_1", 81);
		}

		if(GET_DIFFICULTY_LEVEL() == 1)// middle
		{
			for(i=103; i<=107;i=i+1) RemoveUnitAtMarker(i);
		}


		REGISTER_GOAL(LHero1MustSurvive);
		REGISTER_GOAL(LookAround);
		REGISTER_GOAL(Evacuate);
		REGISTER_GOAL(DestroyAliens);
		
		CREATE_UNIT(Player, LHero1, "L_HERO_01");		
		RestoreBestInfantryAtMarker(m_pPlayer, markerLHero1);
		FinishRestoreUnits(m_pPlayer);

		
		
		
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
		SetWind(20, 20);
		i = PlayCutscene("U_M6_C1.trc", true, true, true);
		return Start, i-eFadeTime;
		
	}

	

	state Start
	{
		//wysadzic zaloge z budynkow lc
		m_nState=0;
		//m_nState=30;//XXXMD
		LookAtUnit(m_uLHero1);
		m_pPlayer.AddResource(eCrystal, 5000);
		m_pPlayer.AddResource(eMetal, 5000);
		RemoveCrewFroAllBuildings(m_pNeutral);
		return MissionFlow, eFadeTime;


		
	}
	int m_nKillCounter;
	state MissionFlow
	{
		int i,nGx, nGy;

		if(m_nState==0)
		{
			m_nState = 11;
			ENABLE_GOAL(LHero1MustSurvive);
			ENABLE_GOAL(LookAround);
		
			ADD_BRIEFINGS(Start,IGOR_HEAD,ARIA_HEAD,7);
			EnableInterface(false);
			START_BRIEFING(eInterfaceDisabled);
			WaitToEndBriefing(state, 30);
			return state;
		}

		if(m_nState==11)
		{
			m_nState = 1;
			EnableInterface(true);
			return state;
		}
		if(m_nState==1)// doatarcie do bazy LC
		{
			VERIFY(GetMarker(markerLCBase, nGx, nGy));
			if (!m_pPlayer.IsFogInPoint(nGx, nGy))
			{
				m_nState = 2;
				ADD_BRIEFINGS(LCBase,ARIA_HEAD,IGOR_HEAD,7);// baza jest pusta, skad sie tu wzieli,  rozejzyj sie Igor
				START_BRIEFING(eInterfaceDisabled);
				WaitToEndBriefing(state, 5*30);
				return state;
			}
			return state;
		}
		if(m_nState==2)
		{
			m_nState = 3;
			SetAlly(m_pPlayer, m_pNeutral);
			ACHIEVE_GOAL(LookAround);
			ADD_BRIEFINGS(Survivor,CIVIL_HEAD, ARIA_HEAD,18);// dzieki za ratunek, uciekajmy, ktos ty, rzadze LC zbudowalem ta baze,  chcialem  miec bron z obcych ale sie rozlezli i zabli wszystkich, zaraz wroca,  zostan i gin.
			START_BRIEFING(eInterfaceDisabled);
			WaitToEndBriefing(state, 30);
			return state;
		}


		if(m_nState==3)
		{
			m_nState = 4;
			SetEnemies(m_pNeutral, m_pEnemy);
			if(GET_DIFFICULTY_LEVEL())CreateAlienPatrols();
			CreateAlienAttack();
			return state,30;
		}
		
		if(m_nState==4)// uciekaj Igor
		{
			m_nState = 5;
			ADD_BRIEFINGS(Evacuate,IGOR_HEAD,ARIA_HEAD,10);// uciekaj ta droga co przybyles - na skanerach  dizo ruchu., zrzucam drona
			START_BRIEFING(eInterfaceEnabled);
			WaitToEndBriefing(state, 5*30);
			return state;
		
		}
		
		if(m_nState==5)
		{	
			m_nState = 55;
			ENABLE_GOAL(DestroyAliens);
			
			m_nAttackCounter=60*(2 - GET_DIFFICULTY_LEVEL());

			SetEnemies(m_pPlayer, m_pEnemy);
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
			return state, 3*60;
		}
		if(m_nState==55)
		{
			m_nState = 6;
			ActivateAI(m_pEnemy);
			return state;
		}
		if(m_nState==6)
		{
			++m_nAttackCounter;
			if(m_nAttackCounter>60*(8 - GET_DIFFICULTY_LEVEL()*2))
			{
				if(SendAttackToPlayerBase())m_nAttackCounter=0;
			}
		
		
			if (!m_pEnemy.GetNumberOfBuildings() && !m_pEnemy.GetNumberOfUnits())
			{
				m_nState = 15;
				ACHIEVE_GOAL(DestroyAliens);
				ADD_BRIEFINGS(AliensDefeated,ARIA_HEAD,IGOR_HEAD,4);// wyspa czysta rozpoczynamy kolonizaje
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 10*30);
				return state;
			}
			return state;
		}

		if(m_nState==15)
		{
			SaveEndMissionGame(306,null);
			m_nState=18;
			EnableInterface(false);
			ShowInterface(false);
			return state,60;
		}
		if(m_nState==18)
		{     
			SetWind(0, 0);SetTimer(2,0);
			EnableMessages(false);
			i = PlayCutscene("U_M6_C2.trc", true, true, true);
			return XXX, i-eFadeTime;
		
		}
		
		return state, 30;
	}

state XXX
	{
		PrepareSaveUnits(m_pPlayer);
        SAVE_UNIT(Player, LHero1, eBufferLHero1);
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

		if ( uKilled == m_uLHero1 )
		{
			bIgnoreEvent=true;
			SetGoalState(goalLHero1MustSurvive, goalFailed);

			LookatUnit(m_uLHero1);
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
		if(state==Start || state==XXX)
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
