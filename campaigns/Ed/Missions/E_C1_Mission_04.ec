/*
jak cutscena z zabijaniem to dodac obrot kamery

- jak strogov pogada to fade out i zniknac transporter.

*/




#include "..\..\defines.ech"

#define MISSION_NAME "translateE_M4"

#define WAVE_MISSION_PREFIX "ED\\M4\\E_M4_Brief_"


#define PLAY_BRIEFING_TUTORIAL(BriefingName) \
	SetConsoleText(MISSION_NAME "_Tutorial_" # BriefingName);
#define	CLEAR_TUTORIAL() SetConsoleText("")
mission MISSION_NAME
{
	#include "..\..\common.ech"
	#include "..\..\dialog.ech"
	state Initialize; // musi byc z tutaj zeby od niego rozpoczal sie skrypt
	#include "..\..\dialog2.ech"

	consts
	{
		
		range4 = 4;
		
		playerEnemy       = 1;
		playerEnemy2      = 4;
		playerPlayer      = 2;
		playerNeutral     = 5;
		
		goalHeroMustSurvive = 0;
		goalGoToCenter = 1;
		goalGoToLadingZone = 2;
		goalBringTransporter = 3;
		goalDestroyAADefences = 4;
		goalEndRebellion = 5;
		goalKillAllPrizoners = 6;
		goalExplosives = 7;

		markerEHero1 = 1;
		markerOfficer = 2;
		markerSzatmar = 3;
		markerExplosives = 4;
		markerTransporter = 5;
		markerGate = 6;
		markerReinforcement = 7;
		markerEnemyJeep = 8;  // z tego markera ruszaja jeepy scigajace Igora.

		markerAATower1 = 10; // do 19
		markerBarricade1 = 20;//do 29  //N_BARR_01_5_A
			
		markerPatrol = 30;  //30-31  32-33  34-35 36-37 38-39  punkty tworzenia i trasy patroli. (nagrane)

		markerAttack = 40; // 40-41  42-43 44-45 46-47 48-49  punkty tworzenia i ataku. atak na glowna baze
		markerExecution = 50;		
		markerClearEnemyEasy = 60; //20 markerw
		markerClearEnemyMedium = 80;//20 markerw

		markerRestriction1 = 101;
		markerRestriction2 = 102;

	}

	player m_pPlayer;
	player m_pEnemy;
	player m_pEnemy2;
	player m_pNeutral;
	

	unit m_uEHero1;
	unit m_uSzatmar;
	unit m_uOfficer;
	unit m_uTransporter;
	unit m_auEnemyBaseAttack[];
    unit m_uJeep;
	unit m_uGate;
	unit m_auAA[];

	int m_bNoWind;
	int nState;
	int m_nTowers;
	int bExplosives, bAA, bUnitDestroyed, bBuildingDestroyed;


	state Start;
	state Meeting;
	state Preparation;
	state Road;
	state Rescue;
	state Massacre;
	state XXX;

	state Initialize
	{
		int i;
		

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(Enemy  );
		INITIALIZE_PLAYER(Enemy2  );
		INITIALIZE_PLAYER(Neutral);
		
		SetNeutrals(m_pEnemy, m_pNeutral,m_pPlayer, m_pEnemy2);
		
		SetNeutrals(m_pNeutral, m_pPlayer);
		

		REGISTER_GOAL(HeroMustSurvive);
		REGISTER_GOAL(GoToCenter);
		REGISTER_GOAL(GoToLadingZone);
		REGISTER_GOAL(BringTransporter);
		REGISTER_GOAL(DestroyAADefences);
		REGISTER_GOAL(EndRebellion);
		REGISTER_GOAL(KillAllPrizoners);
		REGISTER_GOAL(Explosives);
		
		
		
		CREATE_UNIT(Neutral, Szatmar, "E_HERO_02");
		CREATE_UNIT(Neutral, Officer, "ED_OFFICER");

		m_uSzatmar.CommandSetMovementMode(1);
		m_uOfficer.CommandSetMovementMode(1);

		KillUnitAtMarker(markerTransporter);
		
		

		INITIALIZE_UNIT(Gate);
		m_uGate.CommandSetGateMode(1);//mam nadzieje ze to znaczy open


		LookAtUnit(m_uEHero1);


		


		
		if(GET_DIFFICULTY_LEVEL() == 0)
		{
			m_nTowers = 4;
		}
		if(GET_DIFFICULTY_LEVEL() == 1)
		{
			m_nTowers = 7;
		}
		if(GET_DIFFICULTY_LEVEL() == 2)
		{
			m_nTowers = 10;
		}

		m_auAA.Create(m_nTowers);
		for(i=0;i<m_nTowers;i=i+1)
			m_auAA[i]=GetUnitAtMarker(i+markerAATower1);
		
		for(i=m_nTowers;i<10;i=i+1)
			RemoveUnitAtMarker(i+markerAATower1);
		
		m_pPlayer.EnableBuilding("E_BL_CC_01"   , false);
		m_pPlayer.EnableBuilding("E_BL_EG_02"   , false);
		m_pPlayer.EnableBuilding("E_BL_EX_03"   , false);
		m_pPlayer.EnableBuilding("E_BL_CA_04_1" , false);
		m_pPlayer.EnableBuilding("E_BL_CA_04_2" , false);
		m_pPlayer.EnableBuilding("E_BL_CA_04_3" , false);
		m_pPlayer.EnableBuilding("E_BL_ST_05"   , false);
		m_pPlayer.EnableBuilding("E_BL_IF_06"   , false);
		m_pPlayer.EnableBuilding("E_BL_UF_07"   , false);
		m_pPlayer.EnableBuilding("E_BL_AC_08"   , false);
		m_pPlayer.EnableBuilding("E_BL_TC_09"   , false);
		m_pPlayer.EnableBuilding("E_BL_RL_10"   , false);
		m_pPlayer.EnableBuilding("E_BL_AR_11"   , false);
		m_pPlayer.EnableBuilding("E_BL_WA_12"   , false);
		m_pPlayer.EnableBuilding("E_BL_WA_12_Q" , false);
		m_pPlayer.EnableBuilding("E_BL_WA_12_I" , false);
		m_pPlayer.EnableBuilding("E_BL_WA_12_L" , false);
		m_pPlayer.EnableBuilding("E_BL_WA_12_T" , false);
		m_pPlayer.EnableBuilding("E_BL_WA_12_X" , false);
		m_pPlayer.EnableBuilding("E_BL_GA_13"   , false);
		m_pPlayer.EnableBuilding("E_BL_CO_15"   , false);
		m_pPlayer.EnableBuilding("E_BL_CO_15_2" , false);
		m_pPlayer.EnableBuilding("E_BL_CO_15_3" , false);
		m_pPlayer.EnableBuilding("E_BL_CO_15_4" , false);
		m_pPlayer.EnableBuilding("E_BL_CO_15_5" , false);
		m_pPlayer.EnableBuilding("E_BL_CO_15_6" , false);
		m_pPlayer.EnableBuilding("E_BL_CO_15_7" , false);
		m_pPlayer.EnableBuilding("E_BL_CO_15_8" , false);
		m_pPlayer.EnableBuilding("E_BL_CO_15_9" , false);
		m_pPlayer.EnableBuilding("E_BL_CO_15_10", false);
		m_pPlayer.EnableBuilding("E_BL_CO_16"   , false);
		m_pPlayer.EnableBuilding("E_BL_DR_17"   , false);
		m_pPlayer.EnableBuilding("E_BL_SG_18"   , false);
		m_pPlayer.EnableBuilding("E_BL_WC_14_1" , false);
		m_pPlayer.EnableBuilding("E_BL_WC_14_2" , false);
		m_pPlayer.EnableBuilding("E_BL_WC_14_3" , false);
		m_pPlayer.EnableBuilding("E_BL_WC_14_4" , false);

		SetWind(30, 100);
		SetTimer(2, 2*60*30); // wind change


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

		i = PlayCutscene("E_M4_C1.trc", true, true, true);
		return Start,i-eFadeTime;
	}

	

	state Start
	{

		RESTORE_SAVED_UNIT(Player, EHero1, eBufferEHero1);
		nState = 1;
		SetLimitedGameRect(markerRestriction1,markerRestriction2);
		m_pPlayer.SetBuildBuildingsTimeMultiplyPercent(20);
		AddMapSignAtMarker(markerSzatmar, signMoveTo, -1);
		ENABLE_GOAL(HeroMustSurvive);
		ENABLE_GOAL(GoToCenter);
		LookAtUnit(m_uEHero1);
		return Meeting, eFadeTime;
		
	}

/*	
state start 
state meeting - konczy sie meetingiem
state preparation
state road
state fly
state rescue
state massacre

*/
	state Meeting
	{
		if(nState==1)
		{
			if ( IsUnitNearMarker(m_uEHero1, markerSzatmar, range4) )
			{
				nState = 2;
				LookAtUnit(m_uSzatmar);
				SetGoalState(goalGoToCenter,goalAchieved,false);
				RemoveMapSignAtMarker(markerSzatmar);

				ADD_BRIEFING(Meeting_01, IGOR_HEAD);
				ADD_BRIEFING(Meeting_02, ED_OFFICER_HEAD);
				ADD_BRIEFING(Meeting_03, IGOR_HEAD);
				ADD_BRIEFING(Meeting_04, SZATMAR_HEAD);
				ADD_BRIEFING(Meeting_05, IGOR_HEAD);
				ADD_BRIEFING(Meeting_06, SZATMAR_HEAD);
				ADD_BRIEFING(Meeting_07, ED_OFFICER_HEAD);

				ADD_BRIEFING(Meeting_08, SZATMAR_HEAD);
				ADD_BRIEFING(Meeting_09, IGOR_HEAD);
				ADD_BRIEFING(Meeting_10, SZATMAR_HEAD);
				ADD_BRIEFING(Meeting_11, ED_OFFICER_HEAD);

				ADD_BRIEFING(Meeting_12, IGOR_HEAD);
				ADD_BRIEFING(Meeting_13, SZATMAR_HEAD);
				
				START_BRIEFING(eInterfaceDisabled);
				WaitToEndBriefing(state, 30);
				return state;
			}
		}
		if(nState == 2)
		{
			nState = 1;
			return Preparation,30;
		}
		return state;
	}


	state Preparation
	{
		int i;
		if(nState==1)
		{
			ShowInterface(false);
			EnableInterface(false);
			FadeInCutscene(60, 0, 0, 0);
			nState = 2;
			return state, 60;
		}
		if(nState==2)// fade out - i odladamy scene walki
		{
			LookAtMarkerMedium(markerExecution,0);
			DelayedLookAtMarkerMedium(markerExecution,64,150+300,1);
			FadeOutCutscene(60, 0, 0, 0);
			m_pNeutral.SetAlly(m_pPlayer);
			m_pPlayer.SetAlly(m_pNeutral);
			SetEnemies(m_pPlayer, m_pEnemy);
			SetEnemies(m_pNeutral, m_pEnemy);
			SetEnemies(m_pPlayer, m_pEnemy2);
			SetEnemies(m_pNeutral, m_pEnemy2);
			nState = 3;
			return state, 60;
		}
		if(nState==3)// TIMUR briefing
		{
			nState = 4;
			m_uEHero1.CommandSetMovementMode(1);
			GiveAllBuildingsToPlayer(m_pNeutral,m_pPlayer);
			ADD_BRIEFINGS(Rebellion, TIMUR_HEAD, IGOR_HEAD, 2);
			START_BRIEFING(eInterfaceDisabled);
			WaitToEndBriefing(state, 0);
			return state;
		}
		if(nState==4)// atak na brame - barykady start
		{
			nState = 5;
			m_uGate.CommandSetGateMode(0);
			LookAtMarkerMedium(markerGate,0);
			for(i=0; i<9;i=i+2)
			{
				CreatePlayerObjectAtMarker(m_pEnemy, "N_IN_SM_01_1", markerAttack+i+1);
			}
			for(i=markerBarricade1; i<markerBarricade1+10;i=i+1)
				CreatePlayerObjectAtMarker(m_pEnemy,"N_BARR_01_5_A",i,192);
			return state, 90;
		}
		
		if(nState==5)// koniec ataku
		{
			PLAY_BRIEFING_TUTORIAL(UseCannons);
			nState = 6;
			ShowInterface(true);
			EnableInterface(true);	
			for(i=0; i<9;i=i+2)
			{
				CreateAndMoveFromMarkerToMarker(m_pEnemy2, "N_IN_SM_01_1",2+GET_DIFFICULTY_LEVEL()*2,markerAttack+i, markerAttack+i+1,1,0);
				CreateAndMoveFromMarkerToMarker(m_pEnemy2, "E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_CL_03_1,E_EN_PR_03_1",3+GET_DIFFICULTY_LEVEL(),markerAttack+i, markerAttack+i+1,0,1);
			}
			return state, 3*150; //15 s
		}
		if(nState==6)// plan briefing
		{
			if(m_pEnemy2.GetNumberOfUnits()<4)
			{
				KillAllPlayerUnits(m_pEnemy2);
				CLEAR_TUTORIAL();
				nState = 7;
				LookAtMarker(markerSzatmar);
				ADD_BRIEFINGS(Plan, ED_OFFICER_HEAD, IGOR_HEAD, 12);
				START_BRIEFING(eInterfaceDisabled);
				WaitToEndBriefing(state, 0);
				return state;
			}
			else
			{
				TraceD("              units: ");TraceD(m_pEnemy2.GetNumberOfUnits());TraceD("     \n");
			}
			return state;
		}
		if(nState==7)// 
		{
			nState = 8;
			AddMapSignAtMarker(markerTransporter, signMoveTo, -1);
			AddMapSignAtMarker(markerExplosives, signSpecial, -1);
			m_uTransporter = CreatePlayerObjectAtMarker(m_pEnemy, "E_CH_TR_09_3", markerTransporter);
			ENABLE_GOAL(Explosives);
			ENABLE_GOAL(GoToLadingZone);
			bExplosives = false;
			bAA =  false;
			return state;
		}
		if(nState==8)// Patrole start, barykady start
		{
			ClearLimitedGameRect();
			for(i=0;i<10;i=i+2)
			{
				CreatePatrol(m_pEnemy, "N_IN_SM_01_1", 4+(GET_DIFFICULTY_LEVEL()*2), markerPatrol+i, markerPatrol+1+i);		
				if(GET_DIFFICULTY_LEVEL())
					CreatePatrol(m_pEnemy, "E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_CL_03_1,E_EN_PR_03_1", GET_DIFFICULTY_LEVEL(), markerPatrol+i, markerPatrol+1+i);		
				else
				{
					if(i<5) CreatePatrol(m_pEnemy, "E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_CL_03_1,E_EN_PR_03_1", 1, markerPatrol+i, markerPatrol+1+i);		
				}
			}

			

			return Road;
		}
		
		return state;
	}


	int m_nJeepCounter;

	state Road
	{

		int i, nGx1, nGy1, nGx2, nGy2;


		if(nState==32)//end of this state
		{
			nState = 1;
			m_uJeep.KillObject();
			return Rescue,1;
		}

		if (!bExplosives && IsUnitNearMarker(m_uEHero1, markerExplosives, range4) )
		{
			bExplosives = true;
			SetGoalState(goalExplosives,goalAchieved);
			LookAtMarkerMedium(markerExplosives);
			RemoveMapSignAtMarker(markerExplosives);
			ADD_BRIEFING(Explosives_01, IGOR_HEAD);
			START_BRIEFING(eInterfaceEnabled);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(!bAA)
		{
			if(IsUnitNearMarkers(m_uEHero1, markerAATower1, markerAATower1+m_nTowers-1, 6))
			{
				bAA = true;
				ENABLE_GOAL(DestroyAADefences);
				ADD_BRIEFING(AA_01, IGOR_HEAD);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 30);
				for(i=markerAATower1;i<markerAATower1+m_nTowers;i=i+1)
				{
					AddMapSignAtMarker(i, signAttack,-1);
				}
				return state;
			}
		}
		if(GetGoalState(goalGoToLadingZone)!=goalAchieved)
		{
			if (IsUnitNearMarker(m_uEHero1, markerTransporter, 10) )
			{
				m_uTransporter.SetPlayer(m_pPlayer);
				ENABLE_GOAL(BringTransporter);
			}
			if (IsUnitNearMarker(m_uEHero1, markerTransporter, 6) )
			{
				m_nJeepCounter=0;
				m_uJeep.KillObject();
				LookAtMarkerMedium(markerTransporter);
				RemoveMapSignAtMarker(markerTransporter);
				AddMapSignAtMarker(markerSzatmar, signMoveTo, -1);
				SetGoalState(goalGoToLadingZone,goalAchieved);
				ADD_BRIEFING(Transporter_01, IGOR_HEAD);
				START_BRIEFING(eInterfaceDisabled);
				WaitToEndBriefing(state, 30);
				return state;
			}
		}
		if(IsGoalEnabled(goalBringTransporter) && GetGoalState(goalBringTransporter)!= goalAchieved)
		{
			if (IsUnitNearMarker(m_uTransporter, markerSzatmar, 6) && m_uTransporter.IsHelicopterOnLand())
			{
				nState=32;
				m_uTransporter.CommandExitCrew();
				EnableInterface(false);
				RemoveMapSignAtMarker(markerSzatmar);
				SetGoalState(goalBringTransporter,goalAchieved);
				ADD_BRIEFINGS(Meeting2, ED_OFFICER_HEAD, IGOR_HEAD, 3);
				START_BRIEFING(eInterfaceDisabled);
				WaitToEndBriefing(state, 30);
				return state;
			}
		}

		if(bBuildingDestroyed)
		{
			bBuildingDestroyed=false;
			if(GetGoalState(goalDestroyAADefences)!=goalAchieved  && m_pEnemy2.GetNumberOfBuildings()==0)
			{
				SetGoalState(goalDestroyAADefences, goalAchieved);
			}
		}

		if((!m_uJeep || !m_uJeep.IsLive()) && !IsUnitNearMarker(m_uEHero1, markerEnemyJeep, 15))
		{
			m_uJeep = CreatePlayerObjectAtMarker(m_pEnemy, "E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_CL_03_1,E_EN_PR_03_1", markerEnemyJeep);
		}
	
		++m_nJeepCounter;
		if(m_nJeepCounter>90-(GET_DIFFICULTY_LEVEL()*30))
		{
			m_nJeepCounter=0;
			m_uJeep.CommandMove(m_uEHero1.GetLocationX(),m_uEHero1.GetLocationY());
		}
		return state, 30;
	}

	state Rescue
	{
		int i, nGx, nGy;
		if(nState==1)//  briefing z szatmarem 
		{
			if(GetGoalState(goalDestroyAADefences)!=goalAchieved)
			{
				SetGoalState(goalDestroyAADefences, goalFailed);
			}
			TraceD("                Rozmowa z szatmarem\n");
			nState = 2;
			ADD_BRIEFINGS(Stariec, IGOR_HEAD, SZATMAR_HEAD, 9);
			START_BRIEFING(eInterfaceDisabled);
			WaitToEndBriefing(state, 0);
			return state;
		}
		
		if(nState==2)
		{
			FadeInCutscene(60,0,0,0);
			nState=3;
			return state, 60;
		}
		if(nState==3)
		{
			m_uTransporter.RemoveObject();
			m_uSzatmar.RemoveObject();
			m_uOfficer.RemoveObject();
			FadeOutCutscene(60,0,0,0);
			nState=4;
			return state, 60;
		}


	/*	if(nState==2)//  oficera zapakowac do transportera, szatmara usunac
		{
			TraceD("                Oficer do transportera, szatmar znika\n");
			m_uOfficer.CommandMoveCrewInsideObject(m_uTransporter);
			m_uSzatmar.RemoveObject();
			nState = 3;
			return state, 30;
		}
		if(nState==3 )
		{
			if(m_uTransporter.GetIFF()==m_pNeutral.GetIFF())//  transporter odlecie
			{
				TraceD("                Transporter odlatuje\n");
				m_uTransporter.CommandMove(20,20);
				nState = 5;
				return state, 60;
			}
			else
			{
				m_uOfficer.CommandMoveCrewInsideObject(m_uTransporter);
			}
		}*/
		
		if(nState==4)//  briefing z Timurem
		{
			nState = 5;
			TraceD("                Briefing z Timurem\n");
			ENABLE_GOAL(EndRebellion);
			ADD_BRIEFINGS(Reinforcements, TIMUR_HEAD, IGOR_HEAD, 4);
			START_BRIEFING(eInterfaceDisabled);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(nState==5)//  transporter znikna, posiki wstawic
		{
			TraceD("                Interface wraca\n");
			EnableInterface(true);
			
			LookAtMarkerMedium(markerReinforcement);
			CreatePlayerObjectsAtMarker(m_pPlayer, "E_CH_GT_04_1#E_WP_CA_04_2,E_AR_RL_04_1,E_EN_SP_04_1", 8, markerReinforcement, 128);
			CreatePlayerObjectsAtMarker(m_pPlayer, "E_CH_GJ_03_1#E_WP_SL_03_3,E_AR_RL_03_1,E_EN_SP_03_1", 8, markerReinforcement, 128);
			nState = 6;
			return state;
		}
		if(nState==6) //  czekamy 30 sekund
		{
			nState = 7;
			return state, 30*30;	
		}
		if(nState==7) //  briefing z Rochlinem
		{
			
			TraceD("                Briefing z Rochlinem\n");
			nState = 8;
			EnableGoal(goalEndRebellion,false);
			ENABLE_GOAL(KillAllPrizoners);
			ADD_BRIEFINGS(Escort, ROCHLIN_HEAD, IGOR_HEAD, 11);
			START_BRIEFING(eInterfaceEnabled);
			WaitToEndBriefing(state, 1);
			return state;
		}
		if(nState==8) // 
		{
			nState = 0;
			return Massacre;
		}
		return state, 30;
	}

	state Massacre
	{
		int i;
		if(nState == 0)
		{
			nState = 1;
			KillAllPlayerUnits(m_pEnemy);
			bUnitDestroyed = false;
			for(i=0; i<9;i=i+2)
			{
				CreateAndAttackFromMarkerToMarker(m_pEnemy, "E_CH_GJ_02_1#E_WP_SL_02_1,E_AR_CL_02_3,E_EN_SP_02_3",1,markerAttack+i, markerAttack+i+1);
			}
			return state, 10*30;
		}
		if(nState == 1)
		{
			nState = 2;
			
			bUnitDestroyed = false;
			for(i=0; i<9;i=i+2)
			{
				CreateAndAttackFromMarkerToMarker(m_pEnemy, "E_CH_GJ_02_1#E_WP_CR_02_4,E_AR_CL_02_3,E_EN_SP_02_3",1+GET_DIFFICULTY_LEVEL()*2,markerAttack+i, markerAttack+i+1);
				CreateAndAttackFromMarkerToMarker(m_pEnemy, "E_CH_GJ_03_1#E_WP_SL_03_3,E_AR_CL_03_3,E_EN_PR_03_3",1+GET_DIFFICULTY_LEVEL()*2,markerAttack+i, markerAttack+i+1);
			}
			return state, 60;
		}
		if(nState == 2)
		{
			if(bUnitDestroyed)
			{
				bUnitDestroyed = false;
				bBuildingDestroyed = false;
				if(m_pEnemy.GetNumberOfVehicles()<3)	
				{
					KillAllPlayerUnits(m_pEnemy);
					SetAlly(m_pPlayer,m_pEnemy);
					SetAlly(m_pPlayer,m_pEnemy2);
					SetGoalState(goalKillAllPrizoners,goalAchieved);
					nState = 4;
				}
			}
			return state;
		}
		
		if(nState==4)
		{
			nState=5;
			SaveEndMissionGame(104,null);
			return state,1;
		}
		if(nState==5) //  wstawic cutscene koncowa
		{
			m_bNoWind=true;
			SetWind(0,0);
			EnableMessages(false);
			i = PlayCutscene("E_M4_C2.trc", true, true, true);
			return XXX, i-eFadeTime;
		}
	}

	state XXX
	{
		SAVE_UNIT(Player, EHero1, eBufferEHero1);
		EndMission(true);
	}
	state YYY
	{
		MissionDefeat();
	}
	event Timer2()
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

		bUnitDestroyed = true;

		if( IsGoalEnabled(goalBringTransporter) && 
			(GetGoalState(goalBringTransporter)== goalNotAchieved)	&& 
			((uKilled==m_uTransporter) || (uKilled==m_uSzatmar) || (uKilled==m_uOfficer))
			)
		{
			SetGoalState(goalBringTransporter, goalFailed);

			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state YYY;

			SetStateDelay(120);
		}
		if ( uKilled == m_uEHero1 )
		{
			//CLEAR_TUTORIAL();
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
		int i,nGx,nGy;
		unit uUnit;
		bBuildingDestroyed = true;

		for(i=0;i<m_nTowers;i=i+1)
		{
			if(uKilled == m_auAA[i])
				RemoveMapSignAtMarker(markerAATower1+i);
		}
	}

	event AddedBuilding(unit uCreated, int nNotifyType)
	{

		
	}

    event EscapeCutscene(int nIFFNum)
    {
		int nTicks;//czas potrzebny na fadeOut
        if (state == Start || state==XXX)
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
		nState = 4;
		state Massacre;
        SetStateDelay(30);
	}
}
