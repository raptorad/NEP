#include "..\..\defines.ech"

#define MISSION_NAME "translateL_M3"

#define MISSION_GOAL_PREFIX     MISSION_NAME "_Goal_"
#define MISSION_BRIEFING_PREFIX MISSION_NAME "_Brief_"

#define WAVE_MISSION_PREFIX "LC\\M3\\L_M3_Brief_"
#define WAVE_MISSION_SUFFIX ".ogg"

#define WAVE_MISSION_PREFIX "LC\\M3\\L_M3_Brief_"

#define TALK_TIME	150

#define REGISTER_GOAL(GoalName) RegisterGoal(goal ## GoalName, MISSION_GOAL_PREFIX # GoalName);
#define INITIALIZE_UNIT(UnitName) m_u ## UnitName = GetUnitAtMarker(marker ## UnitName);

#define GET_DIFFICULTY_LEVEL() SendCampaignEventGetDifficultyLevel()


#define TRACED(input) TraceD("                                               Ticks: ");TraceD(input);TraceD("          \n");

mission MISSION_NAME
{
	#include "..\..\common.ech"
	#include "..\..\dialog.ech"
	#include "..\..\Researches.ech"
	state Initialize; // musi byc z tutaj zeby od niego rozpoczal sie skrypt
	#include "..\..\dialog2.ech"

	function int SendAllOsUnitsToMarker(unit auUnit[], int nMarker)
	{
		int nGx, nGy;
		int i;

		unit uUnit;

		GetMarker(nMarker, nGx, nGy);

		for ( i = 0; i < auUnit.GetSize(); ++i )
		{
			uUnit = auUnit[i];
			uUnit.CommandMove(G2AMID(nGx), G2AMID(nGy));
		}

		return false;
	}
	function int IsAnyOsUnitsNearMarker(unit auUnit[], int nMarker, int nRange)
	{
		int nGx, nGy;
		int i;

		unit uUnit;

		GetMarker(nMarker, nGx, nGy);

		for ( i = 0; i < auUnit.GetSize(); ++i )
		{
			uUnit = auUnit[i];

			if ( uUnit.DistanceTo(G2AMID(nGx), G2AMID(nGy)) <= G2AMID(nRange) )
			{
				return true;
			}
		}

		return false;
	}

	function int IsAnyOsUnitsBetweenMarkers(unit auUnit[], int nM1, int nM2)
	{
		int i;

		unit uUnit;

		for ( i = 0; i < auUnit.GetSize(); ++i )
		{
			uUnit = auUnit[i];

			if ( IsUnitBetweenMarkers(uUnit, nM1, nM2)  )
			{
				return true;
			}
		}

		return false;
	}

	consts
	{
		
		goalLHeroMustSurvive = 0;
		goalLHero2MustSurvive = 1;
		goalFollowTheLeader = 2;
		goalGoToBase = 3;
		goalFindInformation = 4;
		goalBringPlansToBase = 5; 
		goalDestroyEnemies = 6;

		rangeNear = 2;
		range4 = 4;
		markerLHero1 = 1;
		markerLHero2 = 2;
		markerSelene = 4;
		markerCopy = 5;
		markerOctanBase = 6;

		markerSupport1 = 81;
		markerSupport2 = 82;
		markerSupport3 = 83;
		markerSupport4 = 84;
		markerSupport5 = 85;
		
		markerSupport6 = 68;
		markerSupport7 = 69;
		markerSupport8 = 70;
		markerPatrol = 100;
		markerAttack = 110;
		markerHeroAfterCutscene2 = 26;

		markerMech1 = 15;
		markerMech2 = 27;
		markerMech3 = 28;
		markerMech4 = 71;
		markerMech5 = 72;

		

		markerAnimal = 10;
	}

	player m_pPlayer;
	player m_pEnemy;
	player m_pLC;
	player m_pSeleneLC;
	
	unit m_uLHero1;
	unit m_uLHero2;

	unit m_auSupport[];

	unit m_uAnimal;

	int m_nFriendStep;
	int m_nHurryUpCounter;
    int m_nTargetType;
	int m_nPlantBriefing;
	int m_bUnitDestroyed;
	int m_bUnitDestroyed2;
	int m_bBuildingDestroyed;
	int n_PlaceMarker;
	int m_nMissionFailedCounter;
	int m_nSpiderShootCounter;
	int m_nOnLandCounter;

	
	state Initialize;
	state Start;
	state StartCutscene1;
	state EndCutscene1;
	state FollowTheLeader;
    state FadeInCutscene2;
	state StartCutscene2;
	state EndCutscene2;
    state FindInformation1;
    state StartCutscene3;
	state EndCutscene3;
    state FadeOutCutscene3;
	state SeleneDestruction;
	state RoadToOctan;
	state OctanBase;
	state XXX;
    
	
	state Initialize
	{
		SetWind(30,100);//strenght[0-100],Direction[0-255]
		EnableInterface(false);
		ShowInterface(false);

        FadeInCutscene(0, 0, 0, 0);
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
		return StartCutscene1, 5;
	}
	
	int nCutsceneStep;	
	int nTicks;
	state StartCutscene1
	{
		int i;
		m_pPlayer = GetPlayer(3);
		m_pEnemy = GetPlayer(1);
		m_pLC   = GetPlayer(7);
		m_pSeleneLC = GetPlayer(8);
		
		SetNeutrals(m_pPlayer, m_pLC);
		SetNeutrals(m_pPlayer, m_pSeleneLC);
		
		SetNeutrals(m_pEnemy, m_pLC, m_pSeleneLC);

		m_pPlayer.AddIgnoreNotifyAttackUnit("N_IN_AN_01_1",true);
		m_pPlayer.AddIgnoreNotifyAttackUnit("N_DE_PL_07",true);
		m_pPlayer.AddIgnoreNotifyAttackUnit("N_DE_PL_07_2",true);
		m_pPlayer.AddIgnoreNotifyAttackUnit("N_DE_PL_07_3",true);

		SetPlayerResearchesLCCampaign(m_pPlayer, 3);

		REGISTER_GOAL(LHeroMustSurvive) ;
		REGISTER_GOAL(LHero2MustSurvive) ;
		REGISTER_GOAL(FollowTheLeader) ;
		REGISTER_GOAL(GoToBase) ;
		REGISTER_GOAL(FindInformation) ;
		REGISTER_GOAL(BringPlansToBase) ; 
		REGISTER_GOAL(DestroyEnemies) ;

		
		CommandHoldPosUnitFromMarker(38);
		CommandHoldPosUnitFromMarker(39);
		CommandHoldPosUnitFromMarker(40);
		CommandHoldPosUnitFromMarker(41);

		INITIALIZE_UNIT(Animal);

		m_auSupport.Create(0);

		
		
		if(GET_DIFFICULTY_LEVEL() < 2)
		{
			for(i=53;i<68;i=i+1)
				KillUnitAtMarker(i);
		}
		if(GET_DIFFICULTY_LEVEL() == 0)
		{
			for(i=73;i<80;i=i+1)
				KillUnitAtMarker(i);
		}

      
		nTicks = PlayCutscene("L_M3_C1.trc", false, false, false);

		nCutsceneStep=0;
		return EndCutscene1, nTicks-eFadeTime;
		
	}
	

	state EndCutscene1
	{
		m_uLHero2 = CreatePlayerObjectAtMarker(m_pSeleneLC, "L_HERO_02", markerLHero2,128);
		RESTORE_SAVED_UNIT(Player, LHero1, eBufferLHero1);
		
		m_uLHero1.CommandSetMovementMode(eMovementModeHoldPosition);
		m_uLHero2.CommandSetMovementMode(eMovementModeHoldPosition); 

		LookAtUnitClose(m_uLHero2);
		m_nFriendStep = 0; 
		return Start, 0;
	}

	state Start
	{
	
		if ( m_nFriendStep == 0 ) 
		{
			m_nFriendStep = 1; 
			EnableInterface(true);
			ShowInterface(true);
			SetLimitedGameRect(20,20,30,30);
			ENABLE_GOAL(LHeroMustSurvive) ;
			ENABLE_GOAL(LHero2MustSurvive) ;
			ENABLE_GOAL(FollowTheLeader);
			ADD_BRIEFING(FollowMe, NATASHA_HEAD);
			START_BRIEFING(false);
			WaitToEndBriefing(state, 0);
			return state;
		}
		if ( m_nFriendStep == 1 )
		{
			m_nFriendStep = 0; 
			AddMapSignAtMarker(3, signMoveTo,-1);
			return FollowTheLeader, 0;
		}
	}
	
	state FollowTheLeader
	{
		
		++m_nSpiderShootCounter;
		if(m_bUnitDestroyed && m_nTargetType>0)
		{
			m_bUnitDestroyed = false;
			if(m_nSpiderShootCounter>40)
			{

				m_nSpiderShootCounter=0;
				if(m_nTargetType==1) ADD_BRIEFING(GoodShot1, NATASHA_HEAD); 
				if(m_nTargetType==2) ADD_BRIEFING(GoodShot2, NATASHA_HEAD); 
				if(m_nTargetType==3) ADD_BRIEFING(GoodShot3, NATASHA_HEAD); 
				if(m_nTargetType==4) ADD_BRIEFING(GoodShot4, NATASHA_HEAD); 
				++m_nTargetType;

				if(m_nTargetType>1 &&m_nTargetType<6)		
				{
					START_BRIEFING(false);
					WaitToEndBriefing(state, 30);
					return state;
				}
			}
		}

		if(m_nHurryUpCounter==6*20)
		{
			++m_nHurryUpCounter;
			ADD_BRIEFING(HurryUp1, NATASHA_HEAD);
			START_BRIEFING(false);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(m_nHurryUpCounter==6*50)
		{
			m_nHurryUpCounter=0;
			ADD_BRIEFING(HurryUp2, NATASHA_HEAD);
			START_BRIEFING(false);
			WaitToEndBriefing(state, 30);
			return state;
		}
		

		if ( m_nFriendStep == 0 ) // follow the leader
		{
			if ( IsUnitNearMarker(m_uLHero2, 3, rangeNear) )
			{
				
				++m_nHurryUpCounter;
				if ( IsUnitNearUnit(m_uLHero1, m_uLHero2, rangeNear) || IsUnitNorthOfMarker(m_uLHero1,3))
				{
					m_nFriendStep=4;
					m_nHurryUpCounter=0;
					RemoveMapSignAtMarker(3);
					AddMapSignAtMarker(7, signMoveTo,-1);
					SetLimitedGameRect(20,20,45,73);
				}
			}
			else if ( !m_uLHero2.IsMoving() )
			{
				CommandMoveUnitToMarker(m_uLHero2, 3);
			}
		}
		else if ( m_nFriendStep == 4 )
		{
			if ( IsUnitNearMarker(m_uLHero2, 7, rangeNear) )
			{
				++m_nHurryUpCounter;
				if ( IsUnitNearUnit(m_uLHero1, m_uLHero2, rangeNear) || IsUnitNorthOfMarker(m_uLHero1,7))
				{
					RemoveMapSignAtMarker(7);
					AddMapSignAtMarker(8, signMoveTo,-1);
					SetLimitedGameRect(20,20,45,97);
					m_nTargetType = 1;
					m_bUnitDestroyed = false;
					m_nFriendStep=101;
					m_nHurryUpCounter=0;
					ADD_BRIEFING(DestroyAnimals, NATASHA_HEAD);
					START_BRIEFING(false);
					WaitToEndBriefing(state, 0);
					return state;
				}
			}
			else if ( !m_uLHero2.IsMoving() )
			{
				m_nHurryUpCounter=0;;
				CommandMoveUnitToMarker(m_uLHero2, 7);
			}
		}
		else if ( m_nFriendStep == 101 )
		{
				m_nFriendStep=5;
				return FollowTheLeader, 0;
		}

		else if ( m_nFriendStep == 5 )//********************************************************************
		{
			if ( !m_uAnimal.IsLive() )
			{
				TraceD("Animal Killed\n");
				++m_nFriendStep;
			}
			else if ( IsUnitNearMarker(m_uLHero2, 36, 1) ) 
			{
				TraceD("Attack Animal\n");
				m_uLHero2.CommandAttack(m_uAnimal);
			}
			else if (!m_uLHero2.IsMoving() )
			{
				TraceD("Move to marker 36\n");
				CommandMoveUnitToMarker(m_uLHero2, 36);
			}
		}
		else if ( m_nFriendStep == 6 )//********************************************************************
		{
			if ( IsUnitNearMarker(m_uLHero2, 8, rangeNear) )
			{
				++m_nHurryUpCounter;
				if ( IsUnitNearUnit(m_uLHero1, m_uLHero2, rangeNear) || IsUnitNorthOfMarker(m_uLHero1,8))
				{
					m_nHurryUpCounter = 0;
					RemoveMapSignAtMarker(8);
					AddMapSignAtMarker(9, signMoveTo,-1);
					++m_nFriendStep;
				}
			}
			else if ( !m_uLHero2.IsMoving() )
			{
				CommandMoveUnitToMarker(m_uLHero2, 8);
			}
		}
		else if ( m_nFriendStep == 7 )//********************************************************************
		{
			if ( IsUnitNearMarker(m_uLHero2, 9, rangeNear) )
			{
				++m_nHurryUpCounter;
				if ( IsUnitNearUnit(m_uLHero1, m_uLHero2, range4) || IsUnitNorthOfMarker(m_uLHero1,9))
				{
					RemoveMapSignAtMarker(9);
					m_nHurryUpCounter = 0;
					++m_nFriendStep;
					m_nTargetType = 0;
					m_nPlantBriefing = 0;
					ClearLimitedGameRect();
					return FadeInCutscene2, 0;
				}
			}
			else if ( !m_uLHero2.IsMoving() )
			{
				CommandMoveUnitToMarker(m_uLHero2, 9);
			}
		}

		return FollowTheLeader, 5;
	}


    state FadeInCutscene2
    {
		EnableInterface(false);
		ShowInterface(false);

        FadeInCutscene(50, 0, 0, 0);
        return StartCutscene2, 50;
    }

	state StartCutscene2
	{
        /*
        
		PlayWave("LC\\M1D\\L_M1D_C2_1.ogg",volBriefing,442);

		PlayWave("LC\\M1D\\L_M1D_C2_2.ogg",volBriefing,853);
		PlayWave("LC\\M1D\\L_M1D_C2_3.ogg",volBriefing,983);
		PlayWave("LC\\M1D\\L_M1D_C2_4.ogg",volBriefing,1123);
		PlayWave("LC\\M1D\\L_M1D_C2_5.ogg",volBriefing,1397);
		
		PlayWave("LC\\M1D\\L_M1D_C2_6.ogg",volBriefing,1800);
		PlayWave("LC\\M1D\\L_M1D_C2_7.ogg",volBriefing,1938);
		*/
		
	
		nTicks = PlayCutscene("L_M3_C2.trc", false, false, false);
		
		return EndCutscene2, nTicks - eFadeTime;
	}

    state EndCutscene2
    {
		int i;
		int noOfUnits;
		unit uUnit;

		
		if(GET_DIFFICULTY_LEVEL() == 0)
		{
			noOfUnits=5;
			m_auSupport.Add(CreatePlayerObjectAtMarker(m_pPlayer, "L_IN_RG_01_1", markerSupport6));
			m_auSupport.Add(CreatePlayerObjectAtMarker(m_pPlayer, "L_IN_RG_01_1", markerSupport7));
			m_auSupport.Add(CreatePlayerObjectAtMarker(m_pPlayer, "L_IN_RG_01_1", markerSupport8));
		}
		else
			noOfUnits=3;



		for(i = markerSupport1; i < markerSupport1+noOfUnits; i = i+1)
		{
			uUnit = CreatePlayerObjectAtMarker(m_pPlayer, "L_CH_GT_04_1#L_WP_PB_04_2,L_AR_CL_04_3,L_EN_NO_04_1,E_IE_SG_04_1", i);
			m_auSupport.Add(uUnit);
			if(uUnit.HaveCrew())
			{
				uUnit = uUnit.GetCrew();
				m_auSupport.Add(uUnit);
			}
		}
		
		SetUnitAtMarker(m_uLHero1, markerHeroAfterCutscene2);
		m_auSupport.Add(m_uLHero1);
		SetUnitAtMarker(m_uLHero2, 80);
		m_uLHero2.SetPlayer(m_pPlayer);//XXX
		m_auSupport.Add(m_uLHero2);

		SetLimitedGameRect(18,50,60,143);
        LookAtMarker(markerHeroAfterCutscene2);
        nCutsceneStep=0;
        return FindInformation1, eFadeTime;
    }
	
	state FindInformation1
	{
		
		if(!nCutsceneStep)
		{
			EnableInterface(true);
			ShowInterface(true);
			nCutsceneStep=1;
			ACHIEVE_GOAL(FollowTheLeader);
			ENABLE_GOAL(FindInformation);
			ADD_BRIEFINGS(FindInformation, LC_OFFICER_HEAD,ARIA_HEAD,6);
			START_BRIEFING(true);
			WaitToEndBriefing(state, 3);
			return state;

		}
		if(nCutsceneStep==2)
		{
			nCutsceneStep=0;
			EnableInterface(false);
			ShowInterface(false);
			FadeInCutscene(50, 0, 0, 0);
			return StartCutscene3, 50;
		}
		
		if ( IsAnyOsUnitsNearMarker(m_auSupport, 12, 2) )
		{
			nCutsceneStep=2;
			ADD_BRIEFINGS(CaptureMechs, LC_OFFICER_HEAD,ARIA_HEAD,2);
			START_BRIEFING(true);
			WaitToEndBriefing(state, 3);
			return state;
		}
		

		return FindInformation1, 5;
	}



    state StartCutscene3
	{
				
		ClearLimitedGameRect();

        nTicks = PlayCutscene("L_M3_C3.trc", false, false, false);

		return EndCutscene3, nTicks - eFadeTime;
	}

	state EndCutscene3
    {
		m_auSupport.Add(CreatePlayerObjectAtMarker(m_pPlayer, "L_IN_HA_02_1", 14));
		m_auSupport.Add(CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_AR_03_3,U_AR_CL_03_3,U_EN_SP_03_3,U_IE_RD_01_3", markerMech1));
		m_auSupport.Add(CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_AR_03_3,U_AR_CL_03_3,U_EN_SP_03_3,U_IE_RD_01_3", markerMech2));
		m_auSupport.Add(CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_AR_03_3,U_AR_CL_03_3,U_EN_SP_03_3,U_IE_RD_01_3", markerMech3));

		if(GET_DIFFICULTY_LEVEL() == 0)
		{
			m_auSupport.Add(CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_CH_03_3,U_AR_CL_03_1,U_EN_SP_03_3,U_IE_RD_01_3", markerMech4));
			m_auSupport.Add(CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_CH_03_3,U_AR_CL_03_1,U_EN_SP_03_3,U_IE_RD_01_3", markerMech5));
		}
	
		LookAtMarker(markerMech2); // XXX to nie dziala
        return FadeOutCutscene3, eFadeTime;
    }

    state FadeOutCutscene3
	{
		EnableInterface(true);
		ShowInterface(true);
		nCutsceneStep=0;
		return SeleneDestruction, 15*30;
	}


	
	state SeleneDestruction
	{
		int i;
		if(!nCutsceneStep)
		{
				EnableInterface(false);
				ShowInterface(false);
				nCutsceneStep=1;
				ACHIEVE_GOAL(GoToBase);
				ENABLE_GOAL(BringPlansToBase);
				AddMapSignAtMarker(markerOctanBase,signMoveTo,-1);
				ADD_BRIEFINGS(Transmission, LC_OFFICER_HEAD,ARIA_HEAD,7);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 3);
				return state;
			
		}
		if(nCutsceneStep==1)// strzelanie
		{
			m_pPlayer.SetAlly(m_pSeleneLC);
			m_pSeleneLC.SetAlly(m_pPlayer);
			m_pEnemy.SetEnemy(m_pSeleneLC);
			FadeInCutscene(50, 0, 0, 0);
			nCutsceneStep=2;
			return state,50;
		}
		if(nCutsceneStep==2)
		{
			nCutsceneStep=3;
			FadeOutCutscene(50, 0, 0, 0);
			LookAtMarkerMedium(markerSelene,0);
			DelayedLookAtMarkerMedium(markerSelene,40,310,1);
			return state,50;
		}
		if(nCutsceneStep==3)
		{
			nCutsceneStep=4;
			KillUnitAtMarker(markerSelene);
			return state,210;
		}
		if(nCutsceneStep==4)
		{
			nCutsceneStep=5;
			FadeInCutscene(50, 0, 0, 0);
			return state,70;
		}
		if(nCutsceneStep==5)
		{
			nCutsceneStep=6;
			FadeOutCutscene(50, 0, 0, 0);
			LookAtUnit(m_uLHero1);
			return state,50;
		}
		if(nCutsceneStep==6)
		{
				EnableInterface(true);
				ShowInterface(true);
				nCutsceneStep=7;
				return state,30*30;
		}
		if(nCutsceneStep==7)
		{
				nCutsceneStep=8;
				ACHIEVE_GOAL(FindInformation);
				ADD_BRIEFINGS(Szatmar, SZATMAR_HEAD,ARIA_HEAD,14);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 3);
				return state;
			
		}
		if(nCutsceneStep==8)
		{
			TraceD("CreatePatrols              \n");
			for(i=0;i<10;i=i+2)
			{
				CreatePatrol(m_pEnemy, "U_CH_AJ_01_1#U_WP_CH_01_1,U_AR_CH_01_1,U_EN_PR_01_1", 3+(GET_DIFFICULTY_LEVEL()*2), markerPatrol+i, markerPatrol+1+i);		
				CreatePatrol(m_pEnemy, "U_CH_GJ_02_1#U_WP_NG_02_1,U_AR_RL_02_1,U_EN_PR_02_1", 3+(GET_DIFFICULTY_LEVEL()*2), markerPatrol+i, markerPatrol+1+i);		
				CreatePatrol(m_pEnemy, "U_CH_GT_03_1#U_WP_CH_03_2,U_AR_RL_03_1,U_EN_PR_03_1", 3+GET_DIFFICULTY_LEVEL()*2, markerPatrol+i, markerPatrol+1+i);		
			}
			nCutsceneStep=0;
			return RoadToOctan;
		}
		
		return state;
	}
// ewakuacja  reszty personelu do bazy 2
state RoadToOctan
{
	if(nCutsceneStep==0)
	{
		if ( IsAnyOsUnitsNearMarker(m_auSupport, markerCopy, 6) )
		{
			nCutsceneStep = 1;
			ADD_BRIEFINGS(Copy, ARIA_HEAD,NATASHA_HEAD, 3);
			START_BRIEFING(false);
			WaitToEndBriefing(state, 3);
			return state;
		}
	}
	if(nCutsceneStep==1)
	{
		nCutsceneStep = 2;
		return state, 60*30;
	}
	if(nCutsceneStep==2)
	{
			nCutsceneStep = 3;
			ADD_BRIEFINGS(Copy2, NATASHA_HEAD,ARIA_HEAD,4);
			START_BRIEFING(false);
			WaitToEndBriefing(state, 3);
			return state;
	}
	if(nCutsceneStep==3)
	{
		//if ( IsAnyOsUnitsNearMarker(m_auSupport, markerOctanBase, 8) )
		if ( IsUnitNearMarker(m_uLHero1, markerOctanBase, 8) )
		{
			nCutsceneStep = 4;
			ACHIEVE_GOAL(BringPlansToBase); 
			ENABLE_GOAL(DestroyEnemies);
			ADD_BRIEFINGS(OctanBase, LC_OFFICER_HEAD,ARIA_HEAD,6);
			START_BRIEFING(true);
			WaitToEndBriefing(state, 3);
			return state;
		}
	}
	if(nCutsceneStep==4)
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
		nCutsceneStep = 0;
		RemoveMapSignAtMarker(markerOctanBase);
		GiveAllUnitsToPlayer(m_pLC, m_pPlayer);
		GiveAllInfantryToPlayer(m_pLC, m_pPlayer);
		GiveAllBuildingsToPlayer(m_pLC, m_pPlayer);
		return OctanBase,30*30;
	}
	return state;
}
// obrona bazy2 i wykonczenie mechów. 
state OctanBase
{
	if(nCutsceneStep ==2000) // end game
	{
		EnableInterface(false);
		ShowInterface(false);
		SetLowConsoleText("translateMissionAccomplished");
		FadeInCutscene(90, 0, 0, 0);
		return XXX, 120;
	}

	if(nCutsceneStep ==0)
	{	
		nCutsceneStep = 1;
		KillAllPlayerUnits(m_pEnemy);
		m_bUnitDestroyed2 = false;
		TraceD("   Sending huge attack          \n");
		CreatePatrol(m_pEnemy, "U_CH_AJ_01_1#U_WP_SH_01_3,U_AR_RL_01_3,U_EN_NO_01_1", 3+(GET_DIFFICULTY_LEVEL()*3), markerAttack, markerAttack+1);		
		if(GET_DIFFICULTY_LEVEL())CreatePatrol(m_pEnemy, "U_CH_GT_04_1#U_WP_PB_04_2,U_AR_RL_04_3,U_EN_SP_04_1", 3+(GET_DIFFICULTY_LEVEL()*3), markerAttack, markerAttack+1);		
		else CreatePatrol(m_pEnemy, "U_CH_GT_03_1#U_WP_NG_03_2,U_AR_RL_03_3,U_EN_PR_03_1", 3+(GET_DIFFICULTY_LEVEL()*3), markerAttack, markerAttack+1);		
		CreatePatrol(m_pEnemy, "U_CH_GT_03_1#U_WP_NG_03_2,U_AR_RL_03_3,U_EN_PR_03_1", 3+(GET_DIFFICULTY_LEVEL()*3), markerAttack, markerAttack+1);		
		CreatePatrol(m_pEnemy, "U_CH_AS_09_1", 2+(GET_DIFFICULTY_LEVEL()*2), markerAttack, markerAttack+2);		
	}

	if(m_bUnitDestroyed2)
	{
		m_bUnitDestroyed2 = false;
		if(m_pEnemy.GetNumberOfUnits()==0)
		{
			SaveEndMissionGame(203, null);
			nCutsceneStep=2000;
			ACHIEVE_GOAL(DestroyEnemies);
			ADD_BRIEFINGS(TheEnd, LC_OFFICER_HEAD,ARIA_HEAD,7);
			START_BRIEFING(true);
			WaitToEndBriefing(state, 3);
			return state;
		}

	}
	return state,30;
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



// ewakuacja  reszty personelu do bazy 2


	
	
	event EndMission(int nResult)
	{
	}
	
	event RemovedUnit(unit uKilled, unit uAttacker, int nNotifyType)
	{

		if(uKilled.GetIFF() == m_pEnemy.GetIFF())
		{
			m_bUnitDestroyed2 = true;
			if(uAttacker == m_uLHero1)
			{
				m_bUnitDestroyed2 = true;
			}

		}
		else if(!uKilled.IsLive() && (uKilled==m_uLHero1 || uKilled==m_uLHero2))
		{

			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);
			SetStateDelay(120);
			state YYY;
		}
	}

	event RemovedBuilding(unit uKilled, unit uAttacker, int nNotifyType)
	{
	}

    event EscapeCutscene(int nIFFNum)
    {
        int nTicks;
        if ((state == EndCutscene1) || (state == EndCutscene2) || (state == EndCutscene3))
        {
			
        }
        else
        {
            return;
        }
		SetLowConsoleText("");
        nTicks = StopCutscene();
		SetStateDelay(nTicks);
    }

    event DebugEndMission()
	{
		nCutsceneStep = 2000;
		state OctanBase;
        SetStateDelay(30);
	}
    event DebugCommand(string pszCommand)
    {
        string strCommand;
        strCommand = pszCommand;
	} 
}
