#include "..\..\defines.ech"

#define MISSION_NAME "translateE_M5"

#define WAVE_MISSION_PREFIX "ED\\M5\\E_M5_Brief_"


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
		playerEnemy1    = 3;
		playerEnemy2    = 6;
		playerEnemy3    = 7;
		playerEnemy4    = 8;
		playerNeutral   = 5;
		

		goalHeroMustSurvive = 0;
		goalRate1 = 1;
		goalRate2 = 2;
		goalRate3 = 3;
		goalRate4 = 4;
		goalDestroyLCForces = 5;
		goalProtectCannons = 6;

		markerGuns = 2;
		markerLCBase1 = 11; //do 19
		markerEHero1 = 1;
	}

	player m_pPlayer;
	player m_pEnemy1;
	player m_pEnemy2;
	player m_pEnemy3;
	player m_pEnemy4;
	player m_pNeutral;
	

	unit m_uEHero1;
	unit m_uGuns;
	int m_bNoWind;
	int m_nLCCounter;
	int m_nLCState;
	int m_nGunCounter;
	int m_nGunState;
	int m_bCheckVictory;    
	

	function void CreateAttack(player pPlayer, int i)
	{
		
		CreatePatrol(pPlayer, "L_CH_AJ_01_1#L_WP_EL_01_1,L_AR_CH_01_1,L_EN_NO_01_1", 3+GET_DIFFICULTY_LEVEL()*2,i,markerGuns);
		CreatePatrol(pPlayer, "L_CH_AJ_01_1#L_WP_SG_01_1,L_AR_RL_01_1,L_EN_NO_01_1", 3+GET_DIFFICULTY_LEVEL()*3,i,markerGuns);
		
		CreateDefenders(pPlayer, "L_CH_GT_04_1#L_WP_PB_04_1,L_AR_CL_04_1,L_EN_NO_04_1", 3+GET_DIFFICULTY_LEVEL(),i);
		CreateDefenders(pPlayer, "L_CH_GJ_02_1#L_WP_AA_02_1,L_AR_CL_02_3,L_EN_SP_02_3", 4+GET_DIFFICULTY_LEVEL(),i);
	}

	function void ActivateAI(player pPlayer,int nMarker)
	{
		int nGx, nGy;

		CreateAttack(pPlayer,nMarker);

		//VERIFY(GetMarker(nMarker, nGx, nGy));
		//SetStartingPointPosition(pPlayer.GetIFFNum(), nGx, nGy); //XXXMD

		ActivateAI(pPlayer);
	}

	function void DisableAIBuildings(player pPlayer)
	{
		pPlayer.SetAIControlOptions(eAIControlTurnOn, false);
	}

	

	state Start;
	state MissionFlow;
	state XXX;

	state Initialize
	{
		int i;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(Enemy1 );
		INITIALIZE_PLAYER(Enemy2 );
		INITIALIZE_PLAYER(Enemy3 );
		INITIALIZE_PLAYER(Enemy4 );
		INITIALIZE_PLAYER(Neutral);
		
		
		SetNeutrals(m_pEnemy1, m_pEnemy2, m_pEnemy3, m_pEnemy4);
		m_pPlayer.SetAlly(m_pNeutral);
		m_pNeutral.SetAlly(m_pPlayer);

		m_pEnemy1.EnableAI(true);
		m_pEnemy2.EnableAI(true);
		m_pEnemy3.EnableAI(true);
		m_pEnemy4.EnableAI(true);

		DEACTIVATE_AI(m_pEnemy1);
		DEACTIVATE_AI(m_pEnemy2);
		DEACTIVATE_AI(m_pEnemy3);
		DEACTIVATE_AI(m_pEnemy4);
		
		REGISTER_GOAL(HeroMustSurvive);
		REGISTER_GOAL(Rate1);
		REGISTER_GOAL(Rate2);
		REGISTER_GOAL(Rate3);
		REGISTER_GOAL(Rate4);
		REGISTER_GOAL(DestroyLCForces);
		REGISTER_GOAL(ProtectCannons);

		

		m_pNeutral.SetCommandBuildBuilding("E_BL_PC_20",140,128,0,null);//XXXMD <- budowa dzial orbitalnych

		INITIALIZE_UNIT(Guns);

		SetPlayerTemplateseEDCampaign(m_pPlayer, 5);
		SetPlayerResearchesEDCampaign(m_pPlayer, 5);
		SetEnemyResearchesEDCampaign(m_pEnemy1, 5);
		SetEnemyResearchesEDCampaign(m_pEnemy2, 5);
		SetEnemyResearchesEDCampaign(m_pEnemy3, 5);
		SetEnemyResearchesEDCampaign(m_pEnemy4, 5);
		//AddPlayerResearchesEDCampaign(m_pPlayer, 5);
		AddEnemyResearchesEDCampaign(m_pEnemy1, 5);
		AddEnemyResearchesEDCampaign(m_pEnemy2, 5);
		AddEnemyResearchesEDCampaign(m_pEnemy3, 5);
		AddEnemyResearchesEDCampaign(m_pEnemy4, 5);

		
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

		SetTimer(1, 300);//10 sekund - tutaj kreca sie liczniki
		SetTimer(2, 2*60*30); // wind change
		SetWind(30, 100);

		i = PlayCutscene("E_M5_C1.trc", true, true, true);

		return Start,i-eFadeTime;

		return Start;
	}

int bIgnoreEvent;		

	state Start
	{
		bIgnoreEvent=false;
		m_nLCState=0;
		
		
		RESTORE_SAVED_UNIT(Player, EHero1, eBufferEHero1);
		RestoreBestInfantryAtMarker(m_pPlayer, markerEHero1);
        FinishRestoreUnits(m_pPlayer);

		LookAtUnit(m_uEHero1);


		return MissionFlow, eFadeTime;
		
	}

state StartCutscene;


	state MissionFlow
	{
		int nGx1, nGy1, nGx2, nGy2, nTicks;


		if(m_nGunState==0)
		{
			m_nGunState = 1;
			m_pPlayer.AddResource(eMetal, 4000);
			m_pPlayer.AddResource(eWater, 4000);

			ENABLE_GOAL(HeroMustSurvive);
			ENABLE_GOAL(Rate1);
			ADD_BRIEFINGS(Briefing, TIMUR_HEAD, IGOR_HEAD, 14);
	        START_BRIEFING(true);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(m_nGunState==1)
		{
			if(m_pPlayer.GetResource(eMetal,true,true)>=5000)
			{
				m_nGunState = 21;
				ADD_BRIEFINGS(5000,TROFF_HEAD, IGOR_HEAD, 11);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30);
				return state;
			}
		}
		if(m_nGunState==21)
		{
			m_nGunState = 2;
			AddAgent(11); //Szajba
			return state,30*10;
		}
		if(m_nGunState==2)
		{
			if(m_pPlayer.GetResource(eMetal,true,true)>=10000)
			{
				m_pPlayer.AddResource(eMetal, -10000);
				m_pNeutral.AddResource(eMetal, 5000);
				m_nGunState = 3;
				ACHIEVE_GOAL(Rate1);
				ENABLE_GOAL(Rate2);
				ADD_BRIEFINGS(10K, IGOR_HEAD,TROFF_HEAD, 2);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30);
				return state;
			}
		}
		if(m_nGunState==3)
		{
			if(m_pPlayer.GetResource(eMetal,true,true)>=10000)
			{
				m_pPlayer.AddResource(eMetal, -10000);
				m_pNeutral.AddResource(eMetal, 5000);
				m_nGunState = 4;
				ACHIEVE_GOAL(Rate2);
				ENABLE_GOAL(Rate3);
				ADD_BRIEFINGS(20K, IGOR_HEAD,TROFF_HEAD, 2);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30);
				return state;
			}
		}
		if(m_nGunState==4)
		{
			if(m_pPlayer.GetResource(eMetal,true,true)>=10000)
			{
				m_pPlayer.AddResource(eMetal, -10000);
				m_pNeutral.AddResource(eMetal, 5000);
				m_nGunState = 5;
				ACHIEVE_GOAL(Rate3);
				ENABLE_GOAL(Rate4);
				ADD_BRIEFINGS(30K, IGOR_HEAD,TROFF_HEAD, 2);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30);
				return state;
			}
		}
		if(m_nGunState==5)
		{
			if(m_pPlayer.GetResource(eMetal,true,true)>=10000)
			{
				m_pPlayer.AddResource(eMetal, -10000);
				m_pNeutral.AddResource(eMetal, 5000);
				m_nGunState = 6;
				m_nGunCounter = 0;
				ACHIEVE_GOAL(Rate4);
				ADD_BRIEFINGS(40K, IGOR_HEAD,TROFF_HEAD, 2);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30);
				return state;
			}
		}
		if(m_nGunState==6)
		{
			if(m_nGunCounter>6)
			{
				m_nGunState = 7;
				
				DisableAIBuildings(m_pEnemy1);
				DisableAIBuildings(m_pEnemy2);
				DisableAIBuildings(m_pEnemy3);
				DisableAIBuildings(m_pEnemy4);
				m_nLCState = 5;
				ENABLE_GOAL(DestroyLCForces);
				m_bCheckVictory = true;
				ADD_BRIEFINGS(Guns, IGOR_HEAD,TROFF_HEAD, 2);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30);
				return state;
			}
		}

		if(m_nLCState==0)
		{
			if(m_nLCCounter>(6*3))
			{
				m_nLCCounter=0;
				m_nLCState = 1; 
		
				ActivateAI(m_pEnemy1,markerLCBase1);

				
				ENABLE_GOAL(ProtectCannons);
				ADD_BRIEFINGS(LCLanding, TIMUR_HEAD, IGOR_HEAD, 6);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 30);
				return state;
			}
		}

		if(m_nLCState==1 ) //2 ladowanie
		{
			if(m_nLCCounter>(8-GET_DIFFICULTY_LEVEL())*3)
			{

				m_pEnemy1.AddResource(eCrystal, 5000);
				m_pEnemy1.AddResource(eWater, 5000);

				ActivateAI(m_pEnemy2,markerLCBase1+1);
				m_nLCCounter = 0;
				if(GET_DIFFICULTY_LEVEL() == 0) 
					m_nLCState = 5;
				else
					m_nLCState = 2;
				return state;
			}
		}
		if(m_nLCState==2 ) //3 ladowanie
		{
			if(m_nLCCounter>(8-GET_DIFFICULTY_LEVEL())*3)
			{
				m_pEnemy1.AddResource(eCrystal, 5000);
				m_pEnemy1.AddResource(eWater, 5000);
				m_pEnemy2.AddResource(eCrystal, 5000);
				m_pEnemy2.AddResource(eWater, 5000);

				
				
				ActivateAI(m_pEnemy3,markerLCBase1+2);
				m_nLCCounter = 0;
				if(GET_DIFFICULTY_LEVEL() == 1) 
					m_nLCState = 5;
				else
					m_nLCState = 3;
				return state;
			}
		}
		if(m_nLCState==3 ) //4 ladowanie
		{
			if(m_nLCCounter>6*3)
			{
				m_pEnemy1.AddResource(eCrystal, 5000);
				m_pEnemy1.AddResource(eWater, 5000);
				m_pEnemy2.AddResource(eCrystal, 5000);
				m_pEnemy2.AddResource(eWater, 5000);
				m_pEnemy3.AddResource(eCrystal, 5000);
				m_pEnemy3.AddResource(eWater, 5000);

				
				
				ActivateAI(m_pEnemy4,markerLCBase1+3);
				m_nLCCounter = 0;
				m_nLCState = 5;
				return state;
			}
		}
		
		if(m_bCheckVictory && IsGoalEnabled(goalDestroyLCForces) && GetGoalState(goalDestroyLCForces)!=goalAchieved)
		{
			m_bCheckVictory = false;
			if(m_pEnemy1.GetNumberOfBuildings(eBuildingPowerPlant)==0 &&
				m_pEnemy2.GetNumberOfBuildings(eBuildingPowerPlant)==0 &&
				m_pEnemy3.GetNumberOfBuildings(eBuildingPowerPlant)==0 &&
				m_pEnemy4.GetNumberOfBuildings(eBuildingPowerPlant)==0)
			{
				ACHIEVE_GOAL(DestroyLCForces);
			}
		}

		if(m_nGunState == 7 && GetGoalState(goalDestroyLCForces)==goalAchieved)
		{
			SaveEndMissionGame(105,null);
			return StartCutscene,1;
		}
		return MissionFlow, 60;
	}
	state StartCutscene
	{
		int nTicks;
		bIgnoreEvent=true;
			PrepareSaveUnits(m_pPlayer);
            SAVE_UNIT(Player, EHero1, eBufferEHero1);
            SaveBestInfantry(m_pPlayer, 12-(GET_DIFFICULTY_LEVEL()*3));
			RemoveUnitAtMarker(markerGuns);
			m_bNoWind = true;
			SetWind(0,0);
			EnableMessages(false);
			nTicks = PlayCutscene("E_M5_C2.trc", true, true, true);
			return XXX, nTicks-eFadeTime;
	}
	state XXX
	{
		EndMission(true);
	}
	state YYY
	{
		MissionDefeat();
	}

	
	
	event Timer1() // clock
	{
		++m_nGunCounter;
		++m_nLCCounter;
		TraceD("                    Lc Counter = ");TraceD(m_nLCCounter);TraceD("    \n");
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
		if(bIgnoreEvent)return;
		

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
		if(bIgnoreEvent)return;
		if ( uKilled == m_uGuns && uAttacker != null)
		{
			CLEAR_TUTORIAL();
			SetGoalState(goalProtectCannons, goalFailed);

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
		m_nGunState = 7;
		ACHIEVE_GOAL(DestroyLCForces);
		state MissionFlow;
        SetStateDelay(30);
	}

    event DebugCommand(string pszCommand)
    {
	}
}
