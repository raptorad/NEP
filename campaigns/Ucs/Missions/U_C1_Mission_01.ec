#include "..\..\defines.ech"

#define MISSION_NAME "translateU_M1"

#define WAVE_MISSION_PREFIX "UCS\\M1\\U_M1_Brief_"


/*
ladowanie w bazie. 
   Ladowanie - strogov, kilka robotów i hackerek
                    Briefing - znalezc generator pola.
   
   jak generator odkryty
			Briefing - znisczyc generator pola. Tip znisczyc elektrownie - to wylaczy obrone

	generator zniszczony - koniec i film -mowiacy o przejeciu statku.	
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

		playerPlayer     = 1;
		playerEnemy     = 6;// UCS -obrona
		playerNeutral     = 7;// UCS -murki
		playerEnemy2     = 8;// UCS - generator
		
		
		goalEHero1MustSurvive = 0;
		goalFindGenerator = 1;
		goalDestroyGenerator = 2;
		
		markerEHero1 = 1;
		markerGenerator = 2;
		markerPatrolFirst = 3;
		markerPatrolLast = 12;
	}

	player m_pPlayer;
	player m_pEnemy;
	player m_pEnemy2;
	player m_pNeutral;
	
	unit m_uEHero1;
	unit m_uGenerator;
		
	int m_nState;
	int nAttackCounter;
	int m_bUnitDestroyed;    
		
	state Start;
	state MissionFlow;
	state XXX;

	function void CreateUCSPatrols()
	{
		int i, k;

		k=3 + GET_DIFFICULTY_LEVEL()*2;

		k=k/3;
        if(!k)k=1;

		CreatePatrol(m_pEnemy, "U_CH_GT_03_1#U_WP_NG_03_1,U_AR_CH_03_1,U_EN_NO_03_1", k, markerGenerator, markerEHero1);
		CreatePatrol(m_pEnemy, "U_CH_AJ_01_1#U_WP_SH_01_1,U_AR_CL_01_1,U_EN_SP_01_1", k, markerGenerator, markerEHero1);

		CreatePatrol(m_pEnemy, "U_IN_PT_02_1", 1+GET_DIFFICULTY_LEVEL(), markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		CreatePatrol(m_pEnemy, "U_IN_PT_02_1", 1+GET_DIFFICULTY_LEVEL(), markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		CreatePatrol(m_pEnemy, "U_IN_PT_02_1", 1+GET_DIFFICULTY_LEVEL(), markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		CreatePatrol(m_pEnemy, "U_IN_PT_02_1", 1+GET_DIFFICULTY_LEVEL(), markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		
		CreatePatrol(m_pEnemy, "U_IN_TE_01_1", 3+GET_DIFFICULTY_LEVEL()*3, markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		CreatePatrol(m_pEnemy, "U_IN_TE_01_1", 3+GET_DIFFICULTY_LEVEL()*3, markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		CreatePatrol(m_pEnemy, "U_IN_TE_01_1", 3+GET_DIFFICULTY_LEVEL()*3, markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		CreatePatrol(m_pEnemy, "U_IN_TE_01_1", 3+GET_DIFFICULTY_LEVEL()*3, markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		

		CreatePatrol(m_pEnemy, "U_CH_AJ_01_1#U_WP_SH_01_1,U_AR_CL_01_1,U_EN_SP_01_1", 1, markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		CreatePatrol(m_pEnemy, "U_CH_AJ_01_1#U_WP_SH_01_1,U_AR_CL_01_1,U_EN_SP_01_1", 1, markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		CreatePatrol(m_pEnemy, "U_CH_AJ_01_1#U_WP_SH_01_1,U_AR_CH_01_1,U_EN_SP_01_1", 1, markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		CreatePatrol(m_pEnemy, "U_CH_AJ_01_1#U_WP_SH_01_1,U_AR_CH_01_1,U_EN_SP_01_1", 1, markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		if(GET_DIFFICULTY_LEVEL())
		{
		CreatePatrol(m_pEnemy, "U_CH_AJ_01_1#U_WP_SH_01_1,U_AR_CH_01_1,U_EN_SP_01_1", 1, markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		CreatePatrol(m_pEnemy, "U_CH_AJ_01_1#U_WP_SH_01_1,U_AR_CH_01_1,U_EN_SP_01_1", 1, markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		CreatePatrol(m_pEnemy, "U_CH_AJ_01_1#U_WP_SH_01_1,U_AR_CH_01_1,U_EN_SP_01_1", 1, markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		}
		if(GET_DIFFICULTY_LEVEL()>1)
		{
		CreatePatrol(m_pEnemy, "U_CH_AJ_01_1#U_WP_SH_01_1,U_AR_CL_01_1,U_EN_SP_01_1", 1, markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		CreatePatrol(m_pEnemy, "U_CH_AJ_01_1#U_WP_SH_01_1,U_AR_CL_01_1,U_EN_SP_01_1", 1, markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		CreatePatrol(m_pEnemy, "U_CH_AJ_01_1#U_WP_SH_01_1,U_AR_CL_01_1,U_EN_SP_01_1", 1, markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8),markerPatrolFirst+Rand(8));
		}
		
	}



	state Initialize
	{
		int i;
		unit uVehicle;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(Enemy );
		INITIALIZE_PLAYER(Enemy2 );
		INITIALIZE_PLAYER(Neutral );
				
		
		m_pNeutral.EnableAI(false);
		m_pEnemy2.EnableAI(false);
		m_pEnemy.EnableAI(false);
		
		
		//SetPlayerTemplateseUCSCampaign(m_pPlayer, 1);
		//SetPlayerResearchesUCSCampaign(m_pPlayer, 1);
		
		//SetEnemyResearchesUCSCampaign(m_pEnemy, 1);
		

		SetEnemies(m_pEnemy,m_pPlayer);
		SetNeutrals(m_pEnemy, m_pNeutral, m_pEnemy2);
		SetNeutrals(m_pPlayer, m_pNeutral);
		
		
		REGISTER_GOAL(EHero1MustSurvive);
		REGISTER_GOAL(FindGenerator);
		REGISTER_GOAL(DestroyGenerator);
		
		
		CREATE_UNIT(Player, EHero1, "E_HERO_01");		
		
		
		
		INITIALIZE_UNIT(Generator);
		
		// ===========tu jest przyklad================
		if(GET_DIFFICULTY_LEVEL() ==0)// easy
		{
			for(i=17; i<=44;i=i+1) RemoveUnitAtMarker(i);
			
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_CH_03_1,U_AR_CL_03_1,U_EN_NO_03_1", 13);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_CH_03_1,U_AR_CL_03_1,U_EN_NO_03_1", 14);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_CH_03_1,U_AR_CL_03_1,U_EN_NO_03_1", 15);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_CH_03_1,U_AR_CL_03_1,U_EN_NO_03_1", 16);
			RemoveUnitAtPoint(62,18);
			RemoveUnitAtPoint(63,19);
			RemoveUnitAtPoint(61,19);
			RemoveUnitAtPoint(62,20);

			RemoveUnitAtPoint(33,65);
			RemoveUnitAtPoint(34,66);
			RemoveUnitAtPoint(32,66);
			RemoveUnitAtPoint(33,67);

			RemoveUnitAtPoint(106,122);
			RemoveUnitAtPoint(105,123);
			RemoveUnitAtPoint(107,123);
			RemoveUnitAtPoint(106,124);

			RemoveUnitAtPoint(138,118);
			RemoveUnitAtPoint(137,119);
			RemoveUnitAtPoint(138,120);
			RemoveUnitAtPoint(139,119);
		}

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
		i = PlayCutscene("U_M1_C1.trc", true, true, true);
		return Start, i-eFadeTime;
	
		
	}

	

	state Start
	{
		m_nState=0;
		LookAtUnit(m_uEHero1);
		return MissionFlow, 30;


		
	}
	int m_nKillCounter;
	state MissionFlow
	{
		int i,nGx, nGy;

		if(m_nState==0)
		{
			m_nState = 1;
			ENABLE_GOAL(EHero1MustSurvive);
			ENABLE_GOAL(FindGenerator);
			EnableInterface(false);
			ADD_BRIEFINGS(Start, ARIA_HEAD, IGOR_HEAD ,4);
			START_BRIEFING(eInterfaceDisabled);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(m_nState==1)// uruchomic patrole UCS
		{
			EnableInterface(true);
			CreateUCSPatrols();//XXXMD
			m_nState = 2;
			return state;
		}
		if(m_nState==2)// znalezienie generatora
		{	
			VERIFY(GetMarker(markerGenerator, nGx, nGy));
			if (!m_pPlayer.IsFogInPoint(nGx, nGy))
			{
				m_nState = 3;
				m_pEnemy.EnableAI(false);
				ActivateAI(m_pEnemy);
				LookAtMarkerMedium(markerGenerator,0);
				DelayedLookAtMarkerMedium(markerGenerator,192,30*30, 0);
				SetAlly(m_pPlayer, m_pEnemy2);
            	ACHIEVE_GOAL(FindGenerator);
				ENABLE_GOAL(DestroyGenerator);
				EnableInterface(false);
				ADD_BRIEFINGS(DestroyGenerator, IGOR_HEAD, ARIA_HEAD,3);
				START_BRIEFING(eInterfaceDisabled);
				WaitToEndBriefing(state, 0);
				return state;
			}
			return state;
		}

		if(m_nState==3)
		{
			LookAtMarkerMedium(markerGenerator,0);
			SetEnemies(m_pPlayer, m_pEnemy2);
			EnableInterface(true);
			m_nState=4;
			return state, 60;
		}

		if(m_nState==4)//
		{
			if(!m_uGenerator.IsLive())
			{
				m_nState = 15;
				ACHIEVE_GOAL(DestroyGenerator);
				SetNeutrals(m_pEnemy,m_pEnemy2,m_pPlayer);
				ADD_BRIEFINGS(GeneratorDestroyed,IGOR_HEAD,ARIA_HEAD,4);
				START_BRIEFING(false);//zablokowany interface
				WaitToEndBriefing(state, 3*30);
			}
			return state, 5*30;
		}
		
		if(m_nState==15)
		{
			SaveEndMissionGame(301,null);
			SetNeutrals(m_pEnemy,m_pEnemy2,m_pPlayer);
			EnableInterface(false);
			ShowInterface(false);
			FadeInCutscene(60, 0, 0, 0);			
			m_nState=18;
			return state,60;
		}
		if(m_nState==18)
		{       
			SetWind(0, 0);SetTimer(2,0);
			EnableMessages(false);
			i = PlayCutscene("U_M1_C2.trc", true, true, true);
			return XXX, i-eFadeTime;
		}
		
		return state, 30;
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
