/*
First Part
1 - ladowanie i transmisja  [goal idz do bazy neva]  Alien zaczyna rozbudowe.
2 - odnaleziebnie bazy neva - transmisja [goal idz do kanionu] [na strogovie]
3 - kanion - atak LC [na dowolnym unicie]
4 - transmisja odwrót 3 sek
5 - transmisja wracamy do bazy neva 15 sek
6 - przejecie bazy neva [wynalazki, budynki itp) LC zaczyna rozbudowe. [na strogovie]

Second part
	1 technik 
	2 technik
	Znisczenie bazy LC
	Zniszczenie obcych



*/
#include "..\..\defines.ech"
#define MISSION_NAME "translateE_M7"

#define WAVE_MISSION_PREFIX "ED\\M7\\E_M7_Brief_"


#define TIME1_AFTER_TRAP 3
#define TIME2_AFTER_TRAP 15

#define	CLEAR_TUTORIAL() SetConsoleText("")

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
		playerLC		= 3; // pulapka
		playerAlien     = 4; 
		playerED		= 5; //neva base
				
		goalHeroMustSurvive = 0;
		goalGoToNeva = 1;
		goalDestroyAliens = 2;
		goalValley = 3;
		goalDestroyLC = 4;
		goalCaptureNeva = 5;
		goalSabotage = 6;

		
		markerEHero1 = 1;
		markerEDBase = 2;
		markerValley = 3;
		markerSaboteur = 4;
		markerHero2 = 5;
		markerRochlin = 6;
		markerCommando1 = 60;
		markerCommando2 = 61;
		markerCommando3 = 62;
		markerCommando4 = 63;

		markerTransporter =7;
		markerTrap = 10; //do 19 
		markerAttack = 40; // ataki parami z losowych pozycji.40-41 42-43 44-45 46-47 48-49  54-55
		
	}

	player m_pPlayer;
	player m_pLC;
	player m_pAlien;
	player m_pED;
	
	
	unit m_uEHero1;
	unit m_uSaboteur;
	unit m_uRochlin;
	unit m_uTransporter;
	unit m_uCommando1;
	unit m_uCommando2;
	unit m_uCommando3;
	unit m_uCommando4;
	int m_nState;
	int m_bCheckVictory;    
	int m_nAttackCounter;
	int m_nAttackMarker;	
	int m_bNoWind;

	state Start;
	state FirstPart;
	state Agents;
	state SecondPart;
	state Finish;
	state XXX;

	state Initialize
	{
		int i;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(LC);
		INITIALIZE_PLAYER(Alien);
		INITIALIZE_PLAYER(ED );
		
		SetNeutrals(m_pAlien, m_pLC, m_pED);
		m_pPlayer.SetAlly(m_pED);
		m_pED.SetAlly(m_pPlayer);
		SetEnemies(m_pPlayer,m_pLC);
		SetEnemies(m_pPlayer,m_pAlien);

		m_pLC.EnableAI(false);
		m_pAlien.EnableAI(true);
		m_pED.EnableAI(false);
		ActivateAI(m_pAlien);

		REGISTER_GOAL(HeroMustSurvive);
		REGISTER_GOAL(GoToNeva);
		REGISTER_GOAL(DestroyAliens);
		REGISTER_GOAL(Valley);
		REGISTER_GOAL(DestroyLC);
		REGISTER_GOAL(CaptureNeva);
		REGISTER_GOAL(Sabotage);

				
		RESTORE_SAVED_UNIT(Player, EHero1, eBufferEHero1);
		RestoreBestInfantryAtMarker(m_pPlayer, markerEHero1);
        FinishRestoreUnits(m_pPlayer);

		LookAtUnit(m_uEHero1);
		if(!GET_DIFFICULTY_LEVEL())
		{
			for(i=20;i<22;i=i+1)
				RemoveUnitAtMarker(i);
				
			RemoveUnitAtPoint(66,95);
			RemoveUnitAtPoint(56,151);
			RemoveUnitAtPoint(65,144);
			RemoveUnitAtPoint(84,134);
			RemoveUnitAtPoint(49,113);
			RemoveUnitAtPoint(45,107);
			RemoveUnitAtPoint(25,124);
			RemoveUnitAtPoint(27,123);
			RemoveUnitAtPoint(72,166);
			RemoveUnitAtPoint(72,160);
			RemoveUnitAtPoint(68,164);
		}

		SetPlayerTemplateseEDCampaign(m_pPlayer, 7);
		SetPlayerResearchesEDCampaign(m_pPlayer, 7);
		//AddPlayerResearchesEDCampaign(m_pPlayer, 7);
		SetEnemyResearchesEDCampaign(m_pLC, 7);
		if(GET_DIFFICULTY_LEVEL())AddEnemyResearchesEDCampaign(m_pLC, 7);
		
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

		SetTimer(1, 10*30); // licznik ataku 10sekund
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
				eNoMoneyDisplay |
				//eNoMenuButton |
				0
				);
		ShowInterface(false);
		return Start;
	}

	

	state Start
	{
		m_nState = 0;
		FadeOutCutscene(100, 0, 0, 0);
				//m_nState = 7;//XXXMD usunac
				//return Finish;//XXXMD usunac
		return FirstPart, 160; //XXXMD przywrocic
		
	}
/*
First Part
0 - ladowanie i transmisja  [goal idz do bazy neva]  Alien zaczyna rozbudowe.
2 - odnaleziebnie bazy neva - transmisja [goal idz do kanionu] [na strogovie]
3 - kanion - atak LC [na dowolnym unicie]
4 - transmisja odwrót 3 sek
5 - transmisja wracamy do bazy neva 15 sek
6 - przejecie bazy neva [wynalazki, budynki itp) LC zaczyna rozbudowe. [na strogovie]
*/
	state FirstPart
	{
		int i;
		if(m_nState==0)//ladowanie i transmisja od rochlina
		{
			m_nState = 1;
			EnableInterface(true);
			ShowInterface(true);
			ENABLE_GOAL(HeroMustSurvive);
			ENABLE_GOAL(GoToNeva);
			AddMapSignAtMarker(markerEDBase, signMoveTo, -1);
			ADD_BRIEFING(Briefing_01, IGOR_HEAD);
			ADD_BRIEFING(Briefing_02, ROCHLIN_HEAD);
			ADD_BRIEFING(Briefing_03, IGOR_HEAD);
			ADD_BRIEFING(Briefing_04, ROCHLIN_HEAD);
	        ADD_BRIEFING(Briefing_05, IGOR_HEAD);
			ADD_BRIEFING(Briefing_06, ROCHLIN_HEAD);
	        ADD_BRIEFING(Briefing_07, IGOR_HEAD);
			ADD_BRIEFING(Briefing_08, ROCHLIN_HEAD);
	        ADD_BRIEFING(Briefing_09, ROCHLIN_HEAD);
	        ADD_BRIEFING(Briefing_10, IGOR_HEAD);
			ADD_BRIEFING(Briefing_11, ROCHLIN_HEAD);
	        ADD_BRIEFING(Briefing_12, IGOR_HEAD);
			
	        START_BRIEFING(true);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(m_nState==1)// dotarcie do bazy neva i transmisja
		{
			if(IsUnitNearMarker(m_uEHero1, markerEDBase, 15))
			{
				m_nState = 2;
				RemoveMapSignAtMarker(markerEDBase);
				ACHIEVE_GOAL(GoToNeva);
				ENABLE_GOAL(DestroyAliens);
				ENABLE_GOAL(Valley);
				AddMapSignAtMarker(markerValley, signMoveTo, -1);
				ADD_BRIEFINGS(Trans1,ED_OFFICER_HEAD, IGOR_HEAD, 10);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30);
				return state;
			}
		}

		if(m_nState==2)//dotarcie do doliny i pu³pka 
		{
			if(IsAnyObjectNearMarker(m_pPlayer, markerValley, 4))
			{
				//wstawic pojazdy LC
				for(i=0;i<10;i=i+1)
				{
					CreatePlayerObjectsAtMarker(m_pLC, "L_CH_GJ_02_1#L_WP_PG_02_3,L_AR_CL_02_3,L_EN_SP_02_3", 1, markerTrap+i);
				}
				m_nState = 3;
				return state, TIME1_AFTER_TRAP *30;
			}
			return state;

		}

		if(m_nState==3)// briefing  trap 
		{
			m_nState = 4;
			RemoveMapSignAtMarker(markerValley);
			ACHIEVE_GOAL(Valley);
			ADD_BRIEFING(Trap_01,IGOR_HEAD);
			START_BRIEFING(false);
			WaitToEndBriefing(state, TIME2_AFTER_TRAP*30);
			return state;
		}
		if(m_nState==4) //briefing go back to neva 
		{
			m_nState = 5;
			ENABLE_GOAL(CaptureNeva);
			ADD_BRIEFING(Betrayal_01,IGOR_HEAD);
			START_BRIEFING(false);
			WaitToEndBriefing(state, 5*30);
			return state;
		}
		if(m_nState==5)//dotarcie do novej
		{
			if(IsUnitNearMarker(m_uEHero1, markerEDBase, 15))
			{
				ACHIEVE_GOAL(CaptureNeva);
				m_nState = 6;
				ENABLE_GOAL(DestroyLC);
				ADD_BRIEFINGS(Trans2,ED_OFFICER_HEAD, IGOR_HEAD, 9);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30*15);
				return state;
			}
		}
		if(m_nState==6)//przejecie novej
		{
				m_pPlayer.AddResource(eMetal, 5000 - (GET_DIFFICULTY_LEVEL()*1000));
				m_pPlayer.AddResource(eWater, 5000 - (GET_DIFFICULTY_LEVEL()*1000));
				GiveAllBuildingsToPlayer(m_pED,m_pPlayer);
				GiveAllUnitsToPlayer(m_pED,m_pPlayer);
				m_nState = 1;

				m_pPlayer.AddBlockShootingMissile("E_MI_CA_04_1", true);
				m_pPlayer.AddBlockShootingMissile("E_MI_CA_04_2", true);
				m_pPlayer.AddBlockShootingMissile("E_MI_CA_04_3", true);

				m_pPlayer.AddBlockShootingMissile("E_MI_HL_04_1", true);
				m_pPlayer.AddBlockShootingMissile("E_MI_HL_04_2", true);
				m_pPlayer.AddBlockShootingMissile("E_MI_HL_04_3", true);
				
				m_pPlayer.AddBlockShootingMissile("E_MI_CB_04_1", true);
				m_pPlayer.AddBlockShootingMissile("E_MI_CB_04_2", true);
				m_pPlayer.AddBlockShootingMissile("E_MI_CB_04_3", true);

				SetEnemies(m_pPlayer,m_pLC);
				m_pLC.AddResource(eMetal, 3000 + (GET_DIFFICULTY_LEVEL()*1000));
				m_pLC.AddResource(eWater, 3000 + (GET_DIFFICULTY_LEVEL()*1000));
				

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
				m_nAttackCounter = 1;
				return Agents,10*30;
		}
	}
	
	state Agents
	{
		
		if(m_nState==1)
		{
			m_nState = 2;
			AddAgent(10); //Sergant
			return state,30*20;
		}
		if(m_nState==2)
		{
			m_nState = 1;
			AddAgent(5); //Iceman
			return SecondPart,10*30;
		}
	}
	state SecondPart
	{
		int nGx, nGy;
		if(m_nState==1)//sprawdzenie czy wyprodukowano czolgi briefing i goal o sabotzazu
		{


				if(m_pPlayer.GetNumberOfUnitsWithChasis("E_CH_GT_04_1", true)>0 ||
					m_pPlayer.GetNumberOfUnitsWithChasis("E_CH_GT_05_1", true)>0 ||
					m_pPlayer.GetNumberOfUnitsWithChasis("E_CH_GT_06_1", true)>0)
				{
					m_nState=2;
					if(!GET_DIFFICULTY_LEVEL())AddMapSignAtMarker(markerSaboteur, signSpecial, -1);
					SetNeutrals(m_pPlayer, m_pED);
					CREATE_UNIT(ED, Saboteur, "ED_OFFICER");		
					ENABLE_GOAL(Sabotage);
					ADD_BRIEFINGS(Trans3,ED_SOLDIER_HEAD, IGOR_HEAD, 6);
					START_BRIEFING(true);
					WaitToEndBriefing(state, 30*15);
					return state;
				}

		}

		
		if(m_nState==2)//sprawdzenie czy ktos obok technika briefing i goal o techniku
		{
			if(IsAnyObjectNearMarker(m_pPlayer, markerSaboteur, 8))
			{
				m_nState=3;
				if(!GET_DIFFICULTY_LEVEL())RemoveMapSignAtMarker(markerSaboteur);
				ADD_BRIEFINGS(Trans4,ED_OFFICER_HEAD, ED_SOLDIER_HEAD,  4);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30*15);
				return state;
			}
		}
		if(m_nState==3)//technik strzela
		{
			m_pED.SetEnemy(m_pPlayer);
			m_nState = 4;
			return state, 30;
		}
		if(m_nState==4)//gracz strzela do technika czekac chwile
		{
			ACHIEVE_GOAL(Sabotage);
			m_pPlayer.SetEnemy(m_pED);
			m_nState = 45;
			return state, 30;
		}
		if(m_nState==45)//info ze komerndant zabity
		{
			if(!m_uSaboteur.IsLive())
			{
				m_nState = 5;
				ADD_BRIEFINGS(TraitorKilled,ED_SOLDIER_HEAD, IGOR_HEAD, 3);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30*30);
				return state;
			}
		}
		
		if(m_nState==5)//info ze juz naprawiono czolgi -od tej chwili moga strzelac
		{
			m_nState = 6;//nic nie znaczacy stan
			ActivateAI(m_pLC);
			m_pLC.SetAIControlOptions(eAIRebuildAllBuildings, true);
			m_pLC.SetAIControlOptions(eAIControlBuildBase, false);
				
			m_pPlayer.AddBlockShootingMissile("E_MI_CA_04_1", false);
			m_pPlayer.AddBlockShootingMissile("E_MI_CA_04_2", false);
			m_pPlayer.AddBlockShootingMissile("E_MI_CA_04_3", false);

			m_pPlayer.AddBlockShootingMissile("E_MI_HL_04_1", false);
			m_pPlayer.AddBlockShootingMissile("E_MI_HL_04_2", false);
			m_pPlayer.AddBlockShootingMissile("E_MI_HL_04_3", false);
			
			m_pPlayer.AddBlockShootingMissile("E_MI_CB_04_1", false);
			m_pPlayer.AddBlockShootingMissile("E_MI_CB_04_2", false);
			m_pPlayer.AddBlockShootingMissile("E_MI_CB_04_3", false);

			ADD_BRIEFING(GunsFixed_01,ED_SOLDIER_HEAD);
			START_BRIEFING(false);
			WaitToEndBriefing(state, 5*30);
			return state;
		}

		if(m_bCheckVictory)
		{
			m_bCheckVictory=false;
			if(GetGoalState(goalDestroyLC)!=goalAchieved)
			{
				if(m_pLC.GetNumberOfBuildings()==0 && m_pLC.GetNumberOfUnits()==0)
				{
					ACHIEVE_GOAL(DestroyLC);
				}
			}
			if(GetGoalState(goalDestroyAliens)!=goalAchieved)
			{
				if(m_pAlien.GetNumberOfBuildings()<3 && m_pAlien.GetNumberOfUnits()<6)
				{
					ACHIEVE_GOAL(DestroyAliens);
					m_pAlien.EnableAI(false);
				}

			}
			if(GetGoalState(goalDestroyLC)==goalAchieved && GetGoalState(goalDestroyAliens)==goalAchieved)
			{
				EnableInterface(false);
				ShowInterface(false);
				m_nState = 7;
				return Finish;
			}
			
		}


//ataki obcych
		if(m_nAttackCounter>10-(GET_DIFFICULTY_LEVEL()*2))
		{
			
			if(m_nAttackMarker<markerAttack || m_nAttackMarker>markerAttack+14)
			{
				m_nAttackMarker = markerAttack;
			}
			else
				m_nAttackMarker = m_nAttackMarker+2;

			TraceD("                     attack marker:");TraceD(m_nAttackMarker);TraceD("   \n");
			VERIFY(GetMarker(m_nAttackMarker, nGx, nGy));
			if (m_pPlayer.IsFogInPoint(nGx, nGy))  // sprawdzic czy nie zostal odkryty przez gracza.
			{
				m_nAttackCounter = 1;
				if(Rand(5)>0)CreateAndAttackFromMarkerToMarker(m_pAlien, "A_CH_GJ_02_1",3+GET_DIFFICULTY_LEVEL(),m_nAttackMarker, m_nAttackMarker+1);
				if(Rand(5)>0)CreateAndAttackFromMarkerToMarker(m_pAlien, "A_CH_GJ_02_2",2+GET_DIFFICULTY_LEVEL(),m_nAttackMarker, m_nAttackMarker+1);
				if(Rand(5)>0)CreateAndAttackFromMarkerToMarker(m_pAlien, "A_CH_GJ_03_2",2+GET_DIFFICULTY_LEVEL(),m_nAttackMarker, m_nAttackMarker+1);
				if(Rand(5)>0)CreateAndAttackFromMarkerToMarker(m_pAlien, "A_CH_GT_04_1",1+(GET_DIFFICULTY_LEVEL()*2),m_nAttackMarker, m_nAttackMarker+1);
			}
		}
		return state;
	}


	state Finish
	{
		int nTicks;
		if(m_nState==7)
		{
			m_nState = 8;
			return state,1;
		}
		if(m_nState==8)
		{
			m_nState = 10;
			SetLowConsoleText("");
			m_uEHero1 = null;
			RemoveAllPlayerUnits(m_pPlayer);//zeby nie porzeszkadzali w cutscenie
			//SetUnitAtMarker(m_uEHero1, markerHero2, 128);
			//CREATE_UNIT_ALPHA(Player,Rochlin,"N_ROCHLIN",0);
			//CREATE_UNIT_ALPHA(Player,Commando1,"E_IN_CO_03_1",32);
			//CREATE_UNIT_ALPHA(Player,Commando2,"E_IN_CO_03_1",224);
			//CREATE_UNIT_ALPHA(Player,Commando3,"E_IN_CO_03_1",96);
			//CREATE_UNIT_ALPHA(Player,Commando4,"E_IN_CO_03_1",160);
			//CREATE_UNIT_ALPHA(Player,Transporter,"E_CH_TR_09_1",32);
			
			//LookAtMarkerMedium(markerHero2,0);
			//DelayedLookAtMarkerMedium(markerHero2,128,30*120,1);
			return state,0;
			
		}
		/*if(m_nState==9)
		{
			m_nState=10;

			ADD_BRIEFINGS(E_M7_C1,IGOR_HEAD, ROCHLIN_HEAD, 14);
			START_BRIEFING(true);
			WaitToEndBriefing(state, 30);
			return state;
		}*/

		if(m_nState == 10)
		{
			m_nState = 11;
			SaveEndMissionGame(107,null);
			return state, 1;
		}
		if(m_nState == 11)
		{
			SetWind(0, 0);
			m_bNoWind=true;
			EnableMessages(false);
			nTicks = PlayCutscene("E_M7_C2.trc", true, true, true);
			return XXX, nTicks-eFadeTime;
		}
		return Finish, 60;
	}

	state XXX
	{
		EndMission(true);
	}
	state YYY
	{
		MissionDefeat();
	}
	event Timer1() // licznik co 10 sekund
	{
	if(m_nAttackCounter)
		++m_nAttackCounter;
	}

	event Timer2() // Wind
	{
		if(m_bNoWind)
			SetWind(0,0);
		else
			SetWind(Rand(100),Rand(255));
	}

	event EndMission(int nResult)
	{
	}
	
	event RemovedUnit(unit uKilled, unit uAttacker, int nNotifyType)
	{
		// mission failed gdy zabijemy swojego lub wieznia

		

		if ( uKilled!=null && uKilled == m_uEHero1 )
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
		if ( uKilled.GetIFFNum() != m_pPlayer.GetIFFNum() )
		{
			m_bCheckVictory = true;
		}
	}

	event EscapeCutscene(int nIFFNum)
    {
		int nTicks;//czas potrzebny na fadeOut
        if ((state == Start) || (state == XXX))
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
		m_nState = 7;
		state Finish;
        SetStateDelay(30);
	}

    event DebugCommand(string pszCommand)
    {
	}
}
