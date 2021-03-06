#include "..\..\defines.ech"

#define MISSION_NAME "translateL_M2"

#define WAVE_MISSION_PREFIX "LC\\M2\\L_M2_Brief_"


/*
cutscena widok planetoidy z kosmos i ladowanie

briefing z profesorem

30 sekund spokoju

briefing z dowodztwa o zbilzniu sie floty ED - informacja ze po jej przybyciu nie da sie budowac budynkow

ataki ed przez 10 minut

briefing z prosba o pomoc  -  zniszczenie centrum orbitalnego - brak mozliwosci budowy budynków.

ataki przez 20 moinut przerywane briefingami z dowództwa. 

kolejny atak 1 1-2 minuty po zniszczeniu poprzedniego

sprawdzanie co gracz ma i na tej podstawie przygotowywanie atakow.
wysylanie atakow funkcja  create patrol - 3 punktow¹

 markerHero  = 1
 markerRestriction1 = 2
 markerRestriction2 = 3
 markerGenerator1 = 4 -6
 
 markerAttack = 10; 110-11-12, 13-14-15, 16-17-18, 19-20-21,  22-23-24,  25-26-27


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

		playerPlayer    = 3;
		playerEnemy     = 2;
		playerNeutral   = 5; // budynek bazy Sebastiana
		
		goalLHeroMustSurvive = 0;
		goalProtectResearchStation = 1;
		goalProtectGenerators = 2;

		markerLHero1 = 1;
		markerRestriction1 = 2;
		markerRestriction2 = 3;
		markerGenerator1 = 4; 
		markerGenerator2 = 5; 
		markerGenerator3 = 6; 
		markerAria2 = 7;
		markerSebastian = 8;
		markerGate = 9;
			
		markerCreate =  10;// -15
		markerAttack = 20;// -25
		
	}

	player m_pPlayer;
	player m_pEnemy;
	player m_pNeutral;
	

	unit m_uLHero1;
	unit m_uGenerator1;
	unit m_uGenerator2;
	unit m_uGenerator3;
	
	int m_nState;
	int m_nAttackCounter;
	int m_nAttackWaves;
	int m_bUnitDestroyed;    
	int m_nGenetarorsDestroyed;
	state Start;
	state MissionFlow;
	state XXX;

	state Initialize
	{
		int i;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(Enemy );
		INITIALIZE_PLAYER(Neutral);
		
		
		m_pPlayer.SetAlly(m_pNeutral);
		m_pNeutral.SetAlly(m_pPlayer);

		m_pEnemy.EnableAI(false);
		m_pNeutral.EnableAI(false);
		
		REGISTER_GOAL(LHeroMustSurvive);
		REGISTER_GOAL(ProtectResearchStation);
		REGISTER_GOAL(ProtectGenerators);
		
		INITIALIZE_UNIT(Generator1);
		INITIALIZE_UNIT(Generator2);
		INITIALIZE_UNIT(Generator3);


		RESTORE_SAVED_UNIT(Player, LHero1, eBufferLHero1);
		RestoreBestInfantryAtMarker(m_pPlayer, markerLHero1);
        FinishRestoreUnits(m_pPlayer);

		LookAtUnit(m_uLHero1);


		SetPlayerTemplateseLCCampaign(m_pPlayer, 2);
		SetPlayerResearchesLCCampaign(m_pPlayer, 2);
		//AddPlayerResearchesLCCampaign(m_pPlayer, 2);
		AddPlayerResearchesEDCampaign(m_pEnemy, 3);
		
		SetTimer(1, 300);//10 sekund - tutaj kreca sie liczniki
		SetTimer(2, 2*60*30); // wind change
		SetWind(30, 100);

		m_nAttackCounter=0;
		m_nGenetarorsDestroyed = 0;
		m_nAttackWaves = 4+GET_DIFFICULTY_LEVEL();
		EnableInterface(true);
		ShowInterface(true);

		i = PlayCutscene("L_M2_C1.trc", true, true, true);
		return Start, i-eFadeTime;
		
	}

	

	state Start
	{
		SetLimitedGameRect(	markerRestriction1,	markerRestriction2);
		m_nState=0;
		m_pPlayer.SetBuildBuildingsTimeMultiplyPercent(50+(GET_DIFFICULTY_LEVEL()*10));
		m_pPlayer.SetResearchTimeMultiplyPercent(30+(GET_DIFFICULTY_LEVEL()*10));
		return MissionFlow, 160;


		
	}

	state MissionFlow
	{
		int i,j,k, nType;


		if(m_nState==0)
		{
			m_nState = 1;
			m_pPlayer.AddResource(eCrystal, 5000);
			m_pPlayer.AddResource(eWater, 5000);

			ENABLE_GOAL(LHeroMustSurvive);
			ENABLE_GOAL(ProtectResearchStation);
			ENABLE_GOAL(ProtectGenerators);

			ADD_BRIEFINGS(Welcome, PROFFESOR_HEAD, ARIA_HEAD, 14);
	        START_BRIEFING(false);
			WaitToEndBriefing(state, 60*30);
			return state;
		}
		if(m_nState==1)// info o przybyciu floty i o barkach desantowych
		{
				m_nState = 2;
				ADD_BRIEFINGS(EnemyAproaching,LC_OFFICER_HEAD, ARIA_HEAD, 10);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 120*30);
				return state;
			
		}
		if(m_nState==2)// pierwszy atak
		{
				m_nState = 3;
				i = Rand(5);
				j = Rand(3);

				nType = Rand(5);
				
				if(nType==0)
				{
					CreatePatrol2(m_pEnemy, "E_CH_AJ_01_1#E_WP_SL_01_1,E_AR_RL_01_1,E_EN_SP_01_1", m_nAttackCounter+3+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
					CreatePatrol2(m_pEnemy, "E_CH_AJ_01_1#E_WP_CR_01_1,E_AR_CL_01_1,E_EN_SP_01_1", m_nAttackCounter+3+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
				}
				if(nType==1)
				{
					CreatePatrol2(m_pEnemy, "E_CH_GJ_02_1#E_WP_SL_02_1,E_AR_RL_02_1,E_EN_SP_02_1", m_nAttackCounter+3+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
					CreatePatrol2(m_pEnemy, "E_CH_GJ_02_1#E_WP_CR_02_1,E_AR_CL_02_1,E_EN_SP_02_1", m_nAttackCounter+3+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
				}
				if(nType==2)
				{
					CreatePatrol2(m_pEnemy, "E_CH_AJ_01_1#E_WP_SL_01_1,E_AR_CL_01_1,E_EN_SP_01_1", m_nAttackCounter+3+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
					CreatePatrol2(m_pEnemy, "E_CH_GJ_02_1#E_WP_CR_02_1,E_AR_RL_02_1,E_EN_PR_02_1", m_nAttackCounter+3+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
				}
				if(nType==3)
				{
					CreatePatrol2(m_pEnemy, "E_CH_AJ_01_1#E_WP_SL_01_1,E_AR_RL_01_1,E_EN_SP_01_1", m_nAttackCounter+1+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
					CreatePatrol2(m_pEnemy, "E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_CL_03_1,E_EN_SP_03_1", m_nAttackCounter+3+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
				}
				if(nType==4)
				{
					CreatePatrol2(m_pEnemy, "E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_RL_03_1,E_EN_SP_03_1", m_nAttackCounter+1+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
					CreatePatrol2(m_pEnemy, "E_CH_GJ_03_1#E_WP_CR_03_1,E_AR_CL_03_1,E_EN_SP_03_1", m_nAttackCounter+3+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
				}
				if(Rand(2))
					CreatePatrol2(m_pEnemy, "E_CH_GT_04_1#E_WP_CA_04_1,E_AR_CL_04_1,E_EN_SP_04_1", m_nAttackCounter+(GET_DIFFICULTY_LEVEL()), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
				else
					CreatePatrol2(m_pEnemy, "E_CH_GT_04_1#E_WP_HL_04_1,E_AR_CL_04_1,E_EN_NO_04_1", m_nAttackCounter+(GET_DIFFICULTY_LEVEL()), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
				
				if(GET_DIFFICULTY_LEVEL()>1)
					CreatePatrol2(m_pEnemy, "E_CH_GA_08_1#E_WP_GR_08_1,E_AR_CL_08_1,E_EN_SP_08_1",1, markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);
				++m_nAttackCounter;
				return state;
		}
		if(m_nState==3)
		{
			if(m_bUnitDestroyed)
			{
				m_bUnitDestroyed=false;
				if(m_pEnemy.GetNumberOfVehicles()==0)
				{
					if(m_nAttackCounter>=m_nAttackWaves)
						m_nState=4;
					else
						m_nState=2;
					return state, 60*30;
				}
			}
			return state;
		}
		if(m_nState==4)// info o przybyciu floty
		{
					m_pPlayer.EnableBuilding("L_BL_WA_11",false);
					m_pPlayer.EnableBuilding("L_BL_WC_12_2",false); 
					m_pPlayer.EnableBuilding("L_BL_WC_12_4",false); 
					m_pPlayer.EnableBuilding("L_BL_TW_13",false);
					m_pPlayer.EnableBuilding("L_BL_BA_01",false); 
					m_pPlayer.EnableBuilding("L_BL_PP_02",false); 
					m_pPlayer.EnableBuilding("L_BL_UF_03",false); 
					m_pPlayer.EnableBuilding("L_BL_MI_10",false); 
					m_pPlayer.EnableBuilding("L_BL_IF_04",false); 
					m_pPlayer.EnableBuilding("L_BL_RC_05",false); 
					m_pPlayer.EnableBuilding("L_BL_CA_06",false); 
					m_pPlayer.EnableBuilding("L_BL_UW_07",false); 
					m_pPlayer.EnableBuilding("L_BL_AR_08",false); 
					m_pPlayer.EnableBuilding("L_BL_ST_09",false); 


				m_nState = 5;
				m_nAttackCounter=0;
				ADD_BRIEFINGS(EnemyFleetArrived, LC_OFFICER_HEAD,ARIA_HEAD, 6);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 60*30);
				return state;
		}
		if(m_nState==5)// druga seria ataków
		{
				m_nState = 6; 
				i = Rand(5);
				j = Rand(3);
				k = m_pPlayer.GetNumberOfVehicles();

				k = k/5;
				
				nType = Rand(5);
				TraceD("                                 m_nState5 ntype:"); TraceD(nType);TraceD("     \n");
				if(nType==0)
				{
					CreatePatrol2(m_pEnemy, "E_CH_AJ_01_1#E_WP_SL_01_1,E_AR_CL_01_3,E_EN_SP_01_1", m_nAttackCounter+k+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
					CreatePatrol2(m_pEnemy, "E_CH_AJ_01_1#E_WP_CR_01_1,E_AR_CL_01_3,E_EN_SP_01_1", m_nAttackCounter+k+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
					CreatePatrol2(m_pEnemy, "E_CH_GJ_02_1#E_WP_SL_02_1,E_AR_RL_02_3,E_EN_SP_02_1", m_nAttackCounter+k+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
				}
				if(nType==1)
				{
					CreatePatrol2(m_pEnemy, "E_CH_GJ_02_1#E_WP_SL_02_1,E_AR_RL_02_3,E_EN_SP_02_1", m_nAttackCounter+k+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
					CreatePatrol2(m_pEnemy, "E_CH_GJ_02_1#E_WP_CR_02_1,E_AR_CL_02_3,E_EN_SP_02_1", m_nAttackCounter+k+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
				}
				if(nType==2)
				{
					CreatePatrol2(m_pEnemy, "E_CH_AJ_01_1#E_WP_SL_01_1,E_AR_CL_01_1,E_EN_SP_01_1", m_nAttackCounter+k+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
					CreatePatrol2(m_pEnemy, "E_CH_GJ_02_1#E_WP_SL_02_3,E_AR_CL_02_3,E_EN_SP_02_1", m_nAttackCounter+k+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
					CreatePatrol2(m_pEnemy, "E_CH_GJ_02_1#E_WP_CR_02_1,E_AR_RL_02_3,E_EN_PR_02_1", m_nAttackCounter+k+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
				}
				if(nType==3)
				{
					CreatePatrol2(m_pEnemy, "E_CH_AJ_01_1#E_WP_CR_01_1,E_AR_CL_01_1,E_EN_SP_01_1", m_nAttackCounter+k+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
					CreatePatrol2(m_pEnemy, "E_CH_GJ_03_1#E_WP_SL_03_3,E_AR_RL_03_3,E_EN_SP_03_1", m_nAttackCounter+k+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
				}
				if(nType==4)
				{
					CreatePatrol2(m_pEnemy, "E_CH_AJ_01_1#E_WP_CR_01_1,E_AR_CL_01_1,E_EN_SP_01_1", m_nAttackCounter+k+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
					CreatePatrol2(m_pEnemy, "E_CH_GJ_03_1#E_WP_CR_03_1,E_AR_CL_03_1,E_EN_SP_03_1", m_nAttackCounter+k+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
				}
				if(Rand(2))
					CreatePatrol2(m_pEnemy, "E_CH_GT_04_1#E_WP_CA_04_1,E_AR_CL_04_1,E_EN_SP_04_1,E_IE_SG_04_3", m_nAttackCounter+(GET_DIFFICULTY_LEVEL()), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
				else
					CreatePatrol2(m_pEnemy, "E_CH_GT_04_1#E_WP_HL_04_1,E_AR_CL_04_1,E_EN_NO_04_1,E_IE_SG_04_3", m_nAttackCounter+(GET_DIFFICULTY_LEVEL()), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
				
				if(GET_DIFFICULTY_LEVEL()>1)
					CreatePatrol2(m_pEnemy, "E_CH_GA_08_1#E_WP_GR_08_1,E_AR_CL_08_1,E_EN_SP_08_1,E_IE_SG_01_3",GET_DIFFICULTY_LEVEL(), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);
				if(m_nAttackCounter==6)
				{
					CreatePatrol2(m_pEnemy, "E_CH_GT_04_1#E_WP_CA_04_1,E_AR_RL_04_3,E_EN_SP_04_1,E_IE_SG_04_3", m_nAttackCounter+(GET_DIFFICULTY_LEVEL()), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
					CreatePatrol2(m_pEnemy, "E_CH_AJ_01_1#E_WP_SL_01_3,E_AR_CL_01_3,E_EN_SP_01_1,E_IE_SG_01_3", m_nAttackCounter+k+(GET_DIFFICULTY_LEVEL()*3), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);		
					CreatePatrol2(m_pEnemy, "E_CH_GA_08_1#E_WP_GR_08_1,E_AR_RL_08_3,E_EN_SP_08_1,E_IE_SG_01_3",1+GET_DIFFICULTY_LEVEL(), markerCreate+i, markerAttack+j, markerAttack+j+1, markerAttack+j+2);
				}

			++m_nAttackCounter;
			return state;
		}
		if(m_nState==6)
		{
			if(m_bUnitDestroyed)
			{
				m_bUnitDestroyed=false;
				if(m_pEnemy.GetNumberOfVehicles()==0)
				{
						m_nState=6+m_nAttackCounter;
						TraceD("                                 m_nState:"); TraceD(m_nState);TraceD("     \n");
					return state, 30;
				}
			}
			return state;
		}
		if(m_nState==7 || m_nState==9 || m_nState==11)
		{
				m_nState = 5;
				return state, 60*30;
		}
		if(m_nState==8)
		{
				m_nState = 5;
				ADD_BRIEFINGS(FleetOnTheWay1, ARIA_HEAD,LC_OFFICER_HEAD, 2);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 60*30);
				return state;
		}
		if(m_nState==10)
		{
				m_nState = 5;
				ADD_BRIEFINGS(FleetOnTheWay2, ARIA_HEAD, LC_OFFICER_HEAD, 2);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 60*30);
				return state;
		}
		if(m_nState==12)
		{
				m_nState = 5;
				ADD_BRIEFINGS(FleetOnTheWay3, LC_OFFICER_HEAD,ARIA_HEAD, 2);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 10*30);
				return state;
		}
		if(m_nState==13)
		{
				m_nState = 15;
				SaveEndMissionGame(202, null);
				ACHIEVE_GOAL(LHeroMustSurvive);
				ACHIEVE_GOAL(ProtectResearchStation);
				ACHIEVE_GOAL(ProtectGenerators);

				ADD_BRIEFING(FleetArrived_01, LC_OFFICER_HEAD);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 15*30);
				return state;
		}
		if(m_nState==15)
		{
			EnableInterface(false);
			ShowInterface(false);
			FadeInCutscene(60, 0, 0, 0);			
			m_nState=16;
			return state,60;
		}
		if(m_nState==16)
		{
			FadeOutCutscene(60, 0, 0, 0);
			m_nState=17;
			CreatePlayerObjectAtMarker(m_pPlayer,"L_HERO_01", markerAria2,192);
			CreatePlayerObjectAtMarker(m_pPlayer,"N_IN_VA_09", markerSebastian,64);
			LookAtMarkerMedium(markerGate, 0);
			DelayedLookAtMarkerMedium(markerGate,128, 30*60, 0);
			return state, 60;
		}
		if(m_nState==17)
		{
			ADD_BRIEFINGS(Outro, PROFFESOR_HEAD,ARIA_HEAD, 7);
			START_BRIEFING(true);
			WaitToEndBriefing(state, 30);
			m_nState = 18;
			return state;
		}
		
		if(m_nState==18)
		{                      
			SetLowConsoleText("translateMissionAccomplished");
			FadeInCutscene(100, 0, 0, 0);
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

			return XXX,150;
		
		}
		return state, 60;
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

	
	event Timer2() // Wind
	{
		SetWind(Rand(100),Rand(255));
	}

	event EndMission(int nResult)
	{
		EnableInterface(true);
		ShowInterface(true);
	}
	
	event RemovedUnit(unit uKilled, unit uAttacker, int nNotifyType)
	{
		// mission failed gdy zabijemy swojego lub wieznia

		

		if ( uKilled == m_uLHero1 )
		{
			SetGoalState(goalLHeroMustSurvive, goalFailed);

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
		if ( uKilled == m_uGenerator1 || uKilled == m_uGenerator2 || uKilled == m_uGenerator3)
		{
			++m_nGenetarorsDestroyed;

			if(m_nGenetarorsDestroyed>2)
			{
			
			SetGoalState(goalProtectGenerators, goalFailed);

			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state YYY;

			SetStateDelay(120);
			}
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
