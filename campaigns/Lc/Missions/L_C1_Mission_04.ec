#include "..\..\defines.ech"

#define MISSION_NAME "translateL_M4"

#define WAVE_MISSION_PREFIX "LC\\M4\\L_M4_Brief_"


/*
ladowanie w bazie. 
   Ladowanie - info od Sebastiana zeby szybko dotrzec do bazy bo w nocy znikaja patrole.

   droga do bazy - sciemnia sie  i pojawiaja sie obcy. Atakuja konwój arii. 

   Aria dociera do bazy
   
   Info od Sebastiana ze VanTroff Robi jakies dziwne ruchy. 
   
	Briefing z VanTroffem -  kaze nam spadac 

    pojawienie sie obcych -  i masakra zolnierzy LC

    ucieczka Arii do bunkra. 

    cutscena ze strogovem i jego odjazd.

    Briefing arrii do dowodztwa - rozkaz wytropienia i zniszczenia obcych (2 gracze obcych sa)

    Znalezienie bazy obcych - brieging z dowodztwa zeby ja zostawic i decyzja Arii zeby ja zniszczyc. 

    Zniszczenie obcych - odebranie Arii przywództwa. Wszystkie jednostki i budynki przechodza do dowodztwa.
	Czesc ludzi pozwala Arii uciec (ci na poludnie od mapy) a czesæ przechodzi na strone dowodztwa i sciga arie. 
	briefing od tych ktory pozostali (uciekaj Aria).

    Briefing od Sebastiana  i natashy  ze  wystarczy przebic sie do ladowiska i spadac. Sebastian pojawia sie na ladowisku.JEzeli natasha jest z aria  to z nia zostaje. JEzeli w bazie to pojawia sie na ladowisku razem z sebastianem.
	Pojawienie sie obrony ladowiska.

    Gdy Aria  i natasha znajda sie przy ladowisku - koniec.
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

		playerPlayer     = 3;
		playerBase       = 5; //
		playerEnemy1     = 7;// obcy na planszy
		playerEnemy2     = 4;// baza obcych do zniszczenia
		playerNeutral    = 2; // zolnierze Igora potem neutralni zolnierze LC
		
		goalLHero1MustSurvive = 0;
		goalLHero2MustSurvive = 1;
		goalReachTheBase = 2;
		goalDestroyAliens = 3;
		goalReachLandingZone = 4;
		

		markerLHero1 = 1;
		markerLHero2 = 2;
		markerSebastian = 3;
		markerLandingZone = 4;
   		markerBase = 5;
		markerBunker = 6;
		markerEnemyBase = 7;
		markerTank1 = 8;
		markerTank2 = 9;
		markerPatrol1 = 10;// - 21
		markerPatrolLandingZone = 30; //-31
		markerPatrolAlienStart = 32; // 32-33, 43-35
		markerAlienAttack = 50;
	}

	player m_pPlayer;
	player m_pEnemy1;
	player m_pEnemy2;
	player m_pBase;
	player m_pNeutral;
	
	unit m_uLHero1;
	unit m_uLHero2;
	unit m_uBunker;
	//unit m_uSebastian;
	//unit m_uVanTroff;
	
	int bIgnoreEvent;	
	int m_nState;
	int nAttackCounter;
	int m_bUnitDestroyed;    
	

	function void CreateAlienStartPatrols()//XXXMD
	{
		CreatePatrol(m_pEnemy1, "A_CH_GJ_02_1", 2+(GET_DIFFICULTY_LEVEL()*1), markerPatrolAlienStart, markerPatrolAlienStart+1);
		CreatePatrol(m_pEnemy1, "A_CH_GJ_02_1", 2+(GET_DIFFICULTY_LEVEL()*1), markerPatrolAlienStart+1, markerPatrolAlienStart+2);
		CreatePatrol(m_pEnemy1, "A_CH_GJ_02_1", 2+(GET_DIFFICULTY_LEVEL()*1), markerPatrolAlienStart+2, markerPatrolAlienStart+3);
		CreatePatrol(m_pEnemy1, "A_CH_GJ_02_1", 2+(GET_DIFFICULTY_LEVEL()*1), markerPatrolAlienStart+3, markerPatrolAlienStart+4);

		CreatePatrol(m_pEnemy1, "A_CH_GJ_02_2", 1+(GET_DIFFICULTY_LEVEL()*1), markerPatrolAlienStart, markerPatrolAlienStart+1);
		CreatePatrol(m_pEnemy1, "A_CH_GJ_02_2", 1+(GET_DIFFICULTY_LEVEL()*1), markerPatrolAlienStart+1, markerPatrolAlienStart+2);
		CreatePatrol(m_pEnemy1, "A_CH_GJ_02_2", 1+(GET_DIFFICULTY_LEVEL()*1), markerPatrolAlienStart+2, markerPatrolAlienStart+3);
		CreatePatrol(m_pEnemy1, "A_CH_GJ_02_2", 1+(GET_DIFFICULTY_LEVEL()*1), markerPatrolAlienStart+3, markerPatrolAlienStart+4);
	}

	function void CreateAlienPatrols()
	{
		int i;

		for(i=0;i<10;i=i+1)
		{
			if(!Rand(4))CreatePatrol(m_pEnemy1, "A_CH_GJ_02_1", 4+(GET_DIFFICULTY_LEVEL()*4), markerPatrol1+i, markerPatrol1+1+i);
			if(!Rand(4))CreatePatrol(m_pEnemy1, "A_CH_GJ_02_2", 3+(GET_DIFFICULTY_LEVEL()*3), markerPatrol1+i, markerPatrol1+1+i);
			if(!Rand(4))CreatePatrol(m_pEnemy1, "A_CH_GT_04_1", 2+(GET_DIFFICULTY_LEVEL()*2), markerPatrol1+i, markerPatrol1+1+i);
			if(!Rand(4))CreatePatrol(m_pEnemy1, "A_CH_GT_04_2", 2+(GET_DIFFICULTY_LEVEL()*1), markerPatrol1+i, markerPatrol1+1+i);
			if(!Rand(4))CreatePatrol(m_pEnemy1, "A_CH_GT_04_3", 2+(GET_DIFFICULTY_LEVEL()*1), markerPatrol1+i, markerPatrol1+1+i);
			if(!Rand(4))CreatePatrol(m_pEnemy1, "A_CH_GJ_03_1", 2+(GET_DIFFICULTY_LEVEL()*3), markerPatrol1+i, markerPatrol1+1+i);
		}
		
	}
	function int SendAttackToPlayerBase()
	{
		int i, k, nGx, nGy;

		i = Rand(2);

		VERIFY(GetMarker(markerAlienAttack+i, nGx, nGy));
		if (!m_pPlayer.IsFogInPoint(nGx, nGy)) return 0;
			
		k=m_pPlayer.GetNumberOfVehicles()*(GET_DIFFICULTY_LEVEL()+1);

		k=k/5;
        if(!k)k=1;
		
		CreatePatrol(m_pEnemy1, "A_CH_GJ_02_1", k, markerAlienAttack+i, markerBase);
		CreatePatrol(m_pEnemy1, "A_CH_GJ_02_2", k, markerAlienAttack+i, markerBase);
		CreatePatrol(m_pEnemy1, "A_CH_GT_04_1", k, markerAlienAttack+i, markerBase);
		CreatePatrol(m_pEnemy1, "A_CH_GJ_03_1", k, markerAlienAttack+i, markerBase);
		CreatePatrol(m_pEnemy1, "A_CH_GJ_03_2", k, markerAlienAttack+i, markerBase);
		return 1;
	}
	function void CreateLandingZonePatrol()
	{
		//CREATE_UNIT(Neutral, Sebastian, "N_IN_VA_09");		
		CreatePatrol(m_pBase, "L_CH_GT_04_1#L_WP_PB_04_1,L_AR_CL_04_1,L_EN_NO_04_1", 1+(GET_DIFFICULTY_LEVEL()*1), markerPatrolLandingZone,markerPatrolLandingZone+1);
		CreatePatrol(m_pBase, "L_IN_RG_01_1", 4+(GET_DIFFICULTY_LEVEL()*3), markerPatrolLandingZone,markerPatrolLandingZone+1);
	}

	unit m_uAliens[];
	unit m_uED[];
	
	function void CreateAliens()
	{
		int i;
		unit uVehicle;
		m_uAliens.Create(10);

		for(i=0;i<10;i=i+1)
			m_uAliens[i] = CreatePlayerObjectAtMarker(m_pEnemy1, "A_CH_GJ_02_2", 66+i);
	}
	function void ClearAliens()
	{
		int i, size;
		unit uVehicle;

		size = m_uAliens.GetSize();
		for(i=0;i<size;i=i+1)
		{
			uVehicle = m_uAliens[i];
			uVehicle.RemoveObject();
		}
	}
	function void CreateED()
	{
		int i;
		unit uVehicle;
		m_uED.Create(10);

		m_uED[0] = CreatePlayerObjectAtMarker(m_pNeutral, "E_HERO_01", 80, 64);
		for(i=1;i<10;i=i+1)
			m_uED[i] = CreatePlayerObjectAtMarker(m_pNeutral, "E_CH_GT_04_1#E_WP_CA_04_1,E_AR_CH_04_1,E_EN_SP_04_1", 80+i, Rand(256));
	}
	function void MoveOutED()
	{
		int i, size, nGx, nGy;
		unit uVehicle;

		VERIFY(GetMarker(90, nGx, nGy));
		size = m_uED.GetSize();
		for(i=0;i<size;i=i+1)
		{
			uVehicle = m_uED[i];
			uVehicle.CommandMove(G2AMID(nGx), G2AMID(nGy));
		}
	}
	function void ClearED()
	{
		int i, size;
		unit uVehicle;

		size = m_uED.GetSize();
		for(i=0;i<size;i=i+1)
		{
			uVehicle = m_uED[i];
			uVehicle.RemoveObject();
		}
	}

	state Start;
	state MissionFlow;
	state XXX;

	state Initialize
	{
		int i;
		unit uVehicle;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(Enemy1 );
		INITIALIZE_PLAYER(Enemy2);
		INITIALIZE_PLAYER(Base);
		INITIALIZE_PLAYER(Neutral);
		
		
		m_pEnemy1.EnableAI(false);
		m_pEnemy2.EnableAI(false);
		m_pBase.EnableAI(false);
		m_pNeutral.EnableAI(false);
		
		SetPlayerTemplateseLCCampaign(m_pPlayer, 4);
		SetPlayerResearchesLCCampaign(m_pPlayer, 4);
		//AddPlayerResearchesLCCampaign(m_pPlayer, 4);



		SetNeutrals(m_pPlayer,m_pNeutral, m_pBase);
		SetNeutrals(m_pEnemy1,m_pEnemy2,m_pBase,m_pNeutral);
		SetEnemies(m_pEnemy1,m_pPlayer);
		SetEnemies(m_pEnemy2,m_pPlayer);
		
		
		REGISTER_GOAL(LHero1MustSurvive);
		REGISTER_GOAL(LHero2MustSurvive);
		REGISTER_GOAL(ReachTheBase);
		REGISTER_GOAL(DestroyAliens);
		REGISTER_GOAL(ReachLandingZone);
		

		


		RESTORE_SAVED_UNIT(Player, LHero1, eBufferLHero1);
		RESTORE_SAVED_UNIT(Player, LHero2, eBufferLHero2);
		RestoreBestInfantryAtMarker(m_pPlayer, markerLHero1);
		FinishRestoreUnits(m_pPlayer);

		CreatePlayerObjectAtMarker(m_pPlayer, "L_CH_AJ_01_1#L_WP_EL_01_1,L_AR_CH_01_3,L_EN_NO_01_1", 100, 64);
		CreatePlayerObjectAtMarker(m_pPlayer, "L_CH_AJ_01_1#L_WP_EL_01_1,L_AR_CH_01_3,L_EN_NO_01_1", 100, 64);

		LookAtUnit(m_uLHero1);
		
		INITIALIZE_UNIT(Bunker);
		

		uVehicle = GetUnitAtMarker(markerTank1);
		uVehicle.CommandExitCrew();
		uVehicle = GetUnitAtMarker(markerTank2);
		uVehicle.CommandExitCrew();


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
		i = PlayCutscene("L_M4_C1.trc", true, true, true);
		return Start, i - eFadeTime;
	}

	

	state Start
	{
		EnableInterface(true);
		ShowInterface(true);
		m_nState=0;
		//m_nState=30;//XXXMD
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
			ENABLE_GOAL(LHero1MustSurvive);
			ENABLE_GOAL(LHero2MustSurvive);
			ENABLE_GOAL(ReachTheBase);
			AddMapSignAtMarker(markerBase, signMoveTo, -1);
			ADD_BRIEFINGS(Start, PROFFESOR_HEAD, ARIA_HEAD,6);
			START_BRIEFING(false);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(m_nState==1)// uruchomic patrole obcych
		{
			CreateAlienStartPatrols();//XXXMD
			m_nState = 2;
			return state;
		}
		if(m_nState==2)// dotarcie do bazy - rozmowa z VanTroffem
		{	
			if(IsUnitNearMarker(m_uLHero1, markerBase, 10))
			{
				RemoveMapSignAtMarker(markerBase);
				m_nState = 30;
				ACHIEVE_GOAL(ReachTheBase);
				ADD_BRIEFINGS(BaseTalk,PROFFESOR_HEAD,ARIA_HEAD,6);
				ADD_BRIEFINGS(VanTroff1,TROFF_HEAD,ARIA_HEAD,8);
				START_BRIEFING(true);//zablokowany interface
				WaitToEndBriefing(state, 10*30);
				return state;
			}
			return state;
		}


		if(m_nState==30)// 
		{
			//fade in, interface off
			EnableInterface(false);
			ShowInterface(false);
			FadeInCutscene(60, 0, 0, 0);//zciemnienie			
			++m_nState;
			return state;
		}
		if(m_nState==31)// 
		{
			++m_nState;
			FadeOutCutscene(60, 0, 0, 0);//rozjasnienie
			//move aria i natasha
			VERIFY(GetMarker(60, nGx, nGy));
			m_uLHero1.SetImmediatePosition(G2AMID(nGx), G2AMID(nGy), 0, 192, true);
			VERIFY(GetMarker(61, nGx, nGy));
			m_uLHero2.SetImmediatePosition(G2AMID(nGx), G2AMID(nGy), 0,192, true);
            
			//hold pos aria i natasha
			m_uLHero1.CommandSetMovementMode(1);
			m_uLHero2.CommandSetMovementMode(1);
			
			//lookat aria i natasha
			LookAtMarkerMedium(60,0);
			//delayed look at aria i natasha
			DelayedLookAtMarkerMedium(60,192,30*60, 0);
            //briefing z van troffem
			ADD_BRIEFINGS(VanTroff2,ARIA_HEAD,BAD_TROFF_HEAD,8);
			START_BRIEFING(true);//zablokowany interface
			WaitToEndBriefing(state, 0);
			return state;
		}
		if(m_nState==32)// 
		{
			//lookat 74
			LookAtMarker(74,20,192);
			//give all players base ->player
			GiveAllUnitsToPlayer(m_pBase, m_pPlayer);
			m_nKillCounter=61;
			++m_nState;
			return state,30;
		}
		if(m_nState==33) 
		{
			++m_nKillCounter;
			KillUnitAtMarker(m_nKillCounter);
			//create units
			if(m_nKillCounter==69)
			{
				CreateAliens();
				++m_nState;
				return state, 5*30;
			}
			//delay
			return state, 10;
		}
		if(m_nState==34)// 
		{
			//look at Aria 
			LookAtMarker(60,10,0);
			//aria  eneter object bunker
			m_uLHero1.CommandMoveCrewInsideObject(m_uBunker);
			//natasha enter object
			m_uLHero2.CommandMoveCrewInsideObject(m_uBunker);
            //wait
			++m_nState;
			ADD_BRIEFING(EnterBunker,ARIA_HEAD);
			START_BRIEFING(true);//zablokowany interface
			WaitToEndBriefing(state, 0);

			return state, 2*30;
		}
		if(m_nState==35)
		{
			//fade out
			FadeInCutscene(60, 0, 0, 0);//zciemnienie			
			++m_nState;
			return state,80;
		}
		if(m_nState==36) 
		{
			ClearAliens();
			//create strogoff i jego ludzie
			CreateED();
			//fade in
			LookAtMarker(60,10,0);
			FadeOutCutscene(60, 0, 0, 0);//rozjasnienie			
			//briefing wylazic. 
			ADD_BRIEFINGS(EDFirst,IGOR_HEAD,ARIA_HEAD,13);
			START_BRIEFING(true);//zablokowany interface
			WaitToEndBriefing(state, 0);
				
			++m_nState;
			return state;
		}
		if(m_nState==37) 
		{
			//aria out
			VERIFY(GetMarker(79, nGx, nGy));
			m_uLHero1.SetImmediatePosition(G2AMID(nGx), G2AMID(nGy), 0, 192, true);
			//briefing ze strogovem
			ADD_BRIEFINGS(EDSecond,IGOR_HEAD,ARIA_HEAD,6);
			START_BRIEFING(true);//zablokowany interface
			WaitToEndBriefing(state, 0);
			++m_nState;
			return state;
		}
		if(m_nState==38)// 
		{
			//strogov i jego ludzie odchodz¹
			MoveOutED();
			++m_nState;
			return state;
		}
		if(m_nState==39)// 
		{
			//39 interface wraca i ->4
			EnableInterface(true);
			ShowInterface(true);
			m_nState=4;
			return state, 60;
		}

		if(m_nState==4)// po odjezdzie igora - 
		{
			m_nState = 5;
			//GiveAllBuildingsToPlayer(m_pBase,m_pPlayer);
			m_pPlayer.AddResource(eCrystal, 5000);
			m_pPlayer.AddResource(eWater, 5000);
					
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
			m_pPlayer.EnableBuilding("L_BL_WA_11",true);
			m_pPlayer.EnableBuilding("L_BL_WC_12_2",true); 
			m_pPlayer.EnableBuilding("L_BL_WC_12_4",true); 
			m_pPlayer.EnableBuilding("L_BL_TW_13",true);
			m_pPlayer.EnableBuilding("L_BL_BA_01",true); 
			m_pPlayer.EnableBuilding("L_BL_PP_02",true); 
			m_pPlayer.EnableBuilding("L_BL_UF_03",true); 
			m_pPlayer.EnableBuilding("L_BL_MI_10",true); 
			m_pPlayer.EnableBuilding("L_BL_IF_04",true); 
			m_pPlayer.EnableBuilding("L_BL_RC_05",true); 
			m_pPlayer.EnableBuilding("L_BL_CA_06",true); 
			m_pPlayer.EnableBuilding("L_BL_UW_07",true); 
			m_pPlayer.EnableBuilding("L_BL_AR_08",true); 
			m_pPlayer.EnableBuilding("L_BL_ST_09",true); 
			return state, 5*30;
		}
		if(m_nState==5)// raport do dowodztwa
		{
			ClearED();
			CreateAlienPatrols();
			m_nState = 61;
			ENABLE_GOAL(DestroyAliens);
			ADD_BRIEFINGS(Transmision1,ARIA_HEAD, NATASHA_HEAD, 2);
			ADD_BRIEFINGS(Transmision2,ARIA_HEAD, LC_OFFICER_HEAD, 20);
			START_BRIEFING(false);
			nAttackCounter = (GET_DIFFICULTY_LEVEL()*30);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(m_nState==61)// aktywowanie ai
		{
			m_nState = 62;
			return state, 30*60*(6-GET_DIFFICULTY_LEVEL()*3);  //easy 6 minut, medium 3 minuty, hard 0minut
		}
		if(m_nState==62)// aktywowanie ai
		{
			ActivateAI(m_pEnemy1);
			m_nState = 6;
			return state;
		}
		if(m_nState==6)// znalezienie bazy obcych
		{
			++nAttackCounter;
			if(nAttackCounter>8*60-(GET_DIFFICULTY_LEVEL()*120))
			{
				if(SendAttackToPlayerBase()) nAttackCounter=0;
			}
			
			
			VERIFY(GetMarker(markerEnemyBase, nGx, nGy));
			if (!m_pPlayer.IsFogInPoint(nGx, nGy))
			{
				m_nState = 7;
				ADD_BRIEFINGS(Transmision3, ARIA_HEAD, LC_OFFICER_HEAD, 8);// briefing - nie zabijaj wszystkich
				START_BRIEFING(false);
				WaitToEndBriefing(state, 30);
			}
			return state,30;
		}
		if(m_nState==7)// znalezienie bazy obcych
		{
			if(m_pEnemy2.GetNumberOfBuildings()==0)
			{
				SaveEndMissionGame(204, null);
				bIgnoreEvent=true;
				m_nState = 8;
				return state,1;
			}
			return state;
		}
		if(m_nState==8)// znalezienie bazy obcych
		{
			m_nState = 9;
			ADD_BRIEFINGS(Transmision4,LC_OFFICER_HEAD,ARIA_HEAD,9);// zostajesz aresztowana
			START_BRIEFING(false);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(m_nState==9)// 
		{
			m_nState = 15;
			//XXXMD  Create sebastian na ladowisku
			ADD_BRIEFINGS(Transmision5,NATASHA_HEAD, ARIA_HEAD, 6);// uciekaj
			ADD_BRIEFINGS(Transmision6,PROFFESOR_HEAD, ARIA_HEAD, 3);// Sebastian, jestem z wami
			ADD_BRIEFINGS(Transmision7,PROFFESOR_HEAD, ARIA_HEAD, 2);// na ladowisku sie spotkamy
			START_BRIEFING(false);
			WaitToEndBriefing(state, 30);
			return state;
		}
		
		if(m_nState==15)
		{
			EnableInterface(false);
			ShowInterface(false);
			m_nState=18;
			return state,10;
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

        SAVE_UNIT(Player, LHero1, eBufferLHero1);
		SAVE_UNIT(Player, LHero2, eBufferLHero2);

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

		if(bIgnoreEvent) return;
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
		if ( (uKilled == m_uLHero2) && GetGoalState(goalLHero2MustSurvive)!=goalAchieved)
		{
			bIgnoreEvent=true;
			SetGoalState(goalLHero2MustSurvive, goalFailed);
			LookatUnit(m_uLHero2);
			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state YYY;

			SetStateDelay(120);
		}
		if ( uKilled.GetIFFNum() != m_pPlayer.GetIFFNum() )
		{
			m_bUnitDestroyed = true;
		}

	}

	event RemovedBuilding(unit uKilled, unit uAttacker, int nNotifyType)
	{
		m_bUnitDestroyed = true;
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
