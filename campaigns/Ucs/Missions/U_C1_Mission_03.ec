#include "..\..\defines.ech"

#define MISSION_NAME "translateU_M3"

#define WAVE_MISSION_PREFIX "UCS\\M3\\U_M3_Brief_"


/*
ladowanie w bazie. 
   Ladowanie - strogov, kilka robotów
                    Briefing - znalezc generator pola.
   
   jak generator odkryty
			Briefing - znisczyc generator pola. Tip znisczyc elektrownie - to wylaczy obrone

	generator zniszczony - koniec i film -mowiacy o przejeciu statku.	

		U_M1_Wreckage
			ADD_BRIEFINGS(Wreckage,IGOR_HEAD,ARIA_HEAD,2);

 
		U_M1_FirstAlien
			ADD_BRIEFING(FirstAlien,IGOR_HEAD);

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
		playerEnemy     = 4;// Alien -obrona
		playerEnemy2     = 7;// Alien -generator
		
		
		goalEHero1MustSurvive = 0;
		goalFindGenerator = 1;
		goalDestroyGenerator = 2;
		
		markerEHero1 = 1;
		markerGenerator = 2;
		markerCreatePatrol = 3;
		markerPatrol1 = 4;
		markerPatrol2 = 5;
		markerPatrol3 = 6;
		markerWreckFirst = 7;
		markerWreckLast =10;

		markerPatrolCreate = 11;
		markerPatrolDest1 = 12;
		markerPatrolDest2 = 13;
		markerPatrolDest3 = 14;
	}

	player m_pPlayer;
	player m_pEnemy;
	player m_pEnemy2;
	
	unit m_uEHero1;
	unit m_uGenerator;
		
	int m_nState;
	int nAttackCounter;
	int m_bUnitDestroyed;    
	int m_bShowWreckageBrief;    
	int m_bShowAlienBrief;    
	int m_bAttackActive;
    
	state Start;
	state MissionFlow;
	state XXX;

	function void CreateAlienPatrols()
	{
		int k;

		k=1+GET_DIFFICULTY_LEVEL()/2;
		CreatePatrol(m_pEnemy, "A_CH_LC_13_1", k, markerCreatePatrol, markerPatrol1, markerPatrol2, markerPatrol3);
	}

	function int SendAttackToPlayerBase()
	{
		int i, k, nGx, nGy,  bAirOnly, a,b,c;

		
		k=1+GET_DIFFICULTY_LEVEL(); 
        
		CreatePatrol(m_pEnemy, "A_CH_AF_12_1", k, markerPatrolCreate, markerEHero1);

		
		return 1;

	}

	

	state Initialize
	{
		int i;
		unit uVehicle;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(Enemy );
		INITIALIZE_PLAYER(Enemy2 );
		
		
		m_pEnemy.EnableAI(false);
		m_pEnemy2.EnableAI(false);
		
	
		SetPlayerTemplateseUCSCampaign(m_pPlayer, 3);
		SetPlayerResearchesUCSCampaign(m_pPlayer, 3);
		//AddPlayerResearchesUCSCampaign(m_pPlayer, 3);
		
		//SetEnemyResearchesUCSCampaign(m_pEnemy, 1);
		m_pPlayer.AddResource(eCrystal, 5000);
		m_pPlayer.AddResource(eMetal, 5000);


		SetEnemies(m_pEnemy,m_pPlayer);
		SetNeutrals(m_pEnemy,m_pEnemy2);
		
		REGISTER_GOAL(EHero1MustSurvive);
		REGISTER_GOAL(FindGenerator);
		REGISTER_GOAL(DestroyGenerator);
		
		
		RESTORE_SAVED_UNIT(Player, EHero1, eBufferEHero1);
		RestoreBestInfantryAtMarker(m_pPlayer, markerEHero1);
		FinishRestoreUnits(m_pPlayer);

		
		LookAtUnit(m_uEHero1);
		
		INITIALIZE_UNIT(Generator);

		// BY TZ
		if(GET_DIFFICULTY_LEVEL() == 0)// easy
		{
			for(i=15; i<=20;i=i+1) RemoveUnitAtMarker(i);
			
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_AR_03_1,U_AR_RL_03_1,U_EN_NO_03_1", 21);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_AR_03_1,U_AR_RL_03_1,U_EN_NO_03_1", 22);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_AR_03_1,U_AR_RL_03_1,U_EN_NO_03_1", 23);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_GT_03_1#U_WP_AR_03_1,U_AR_RL_03_1,U_EN_NO_03_1", 24);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_AS_09_1", 25);
			CreatePlayerObjectAtMarker(m_pPlayer, "U_CH_AS_09_1", 26);
		}
		

		m_bShowWreckageBrief = 1;    
		m_bShowAlienBrief = 1;    
		m_bAttackActive=false;
		SetTimer(1, 30*60*(4-GET_DIFFICULTY_LEVEL()));	
		SetWind(0, 0);
		return Start;
	}

	

	state Start
	{
		m_nState=0;
		FadeOutCutscene(60, 0, 0, 0);
		return MissionFlow, 160;


		
	}
	int m_nKillCounter;
	state MissionFlow
	{
		int i,nGx, nGy;


		if(m_bShowAlienBrief == 2)
		{
			m_bAttackActive = true;
			m_bShowAlienBrief = 0;    
			m_bShowWreckageBrief = 0;
			ADD_BRIEFING(FirstAlien_01,IGOR_HEAD);
			START_BRIEFING(false);
			WaitToEndBriefing(state, 30);
			return state;


		}
		if(m_bShowWreckageBrief == 1)
		{
			 for(i=markerWreckFirst; i<=markerWreckLast; i=i+1)
			 {
				VERIFY(GetMarker(i, nGx, nGy));
				if (!m_pPlayer.IsFogInPoint(nGx, nGy))
				{
					LookAtMarkerMedium(i);
					m_bShowWreckageBrief = 0;
			 		ADD_BRIEFINGS(Wreckage,IGOR_HEAD,ARIA_HEAD,2);
					START_BRIEFING(false);
					WaitToEndBriefing(state, 30);
					return state;
				}
			 }
		}






		if(m_nState==0)// find generator
		{
			m_nState = 1;
			ENABLE_GOAL(EHero1MustSurvive);
			ENABLE_GOAL(FindGenerator);
			ADD_BRIEFINGS(Start,IGOR_HEAD,ARIA_HEAD,5);
			EnableInterface(false);
			START_BRIEFING(eInterfaceDisabled);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(m_nState==1)// uruchomic patrole 
		{
			EnableInterface(true);
			CreateAlienPatrols();
			m_nState=2;
			return state, 60;
		}

		if(m_nState==2)// znaleziony, destroy generator
		{
			VERIFY(GetMarker(markerGenerator, nGx, nGy));
			if (!m_pPlayer.IsFogInPoint(nGx, nGy))
			{
				m_nState = 3;
				AddMapSignAtMarker(markerGenerator, signAttack,-1);
				LookAtMarkerMedium(markerGenerator,192);
				DelayedLookAtMarkerMedium(markerGenerator,0,1,30*30);
				ACHIEVE_GOAL(FindGenerator);
				ENABLE_GOAL(DestroyGenerator);
				SetAlly(m_pEnemy2,m_pPlayer);
				SetNeutrals(m_pEnemy,m_pPlayer);
				ADD_BRIEFINGS(DestroyGenerator,IGOR_HEAD,ARIA_HEAD,3);
				START_BRIEFING(false);//zablokowany interface
				WaitToEndBriefing(state, 10*30);
			}
			return state, 5*30;
		}
		if(m_nState==3)// 
		{
			m_nState=4;
			LookAtMarkerMedium(markerGenerator,0);
			SetEnemies(m_pEnemy2,m_pPlayer);
			SetEnemies(m_pEnemy,m_pPlayer);
		}

		if(m_nState==4)// 
		{
			if(!m_uGenerator.IsLive())
			{
				m_nState = 15;
				RemoveMapSignAtMarker(markerGenerator);
				ACHIEVE_GOAL(DestroyGenerator);
				SetNeutrals(m_pEnemy,m_pPlayer);
				return state, 60;
			}
			return state, 5*30;
		}
		
		if(m_nState==15)
		{
			SaveEndMissionGame(303,null);
			EnableInterface(false);
			ShowInterface(false);
			m_nState=18;
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

	
	event Timer1()
	{
		if(m_bAttackActive) SendAttackToPlayerBase();
	}
	
	event EndMission(int nResult)
	{
	}
	
	int bIgnoreEvent;

	event RemovedUnit(unit uKilled, unit uAttacker, int nNotifyType)
	{
		// mission failed gdy zabijemy swojego lub wieznia
		if(uKilled.IsLive()) return;

		if(m_bShowAlienBrief == 1)
		{
			if(uKilled.GetIFF()== m_pPlayer.GetIFF() && uAttacker.GetIFF() == m_pEnemy.GetIFF())
			{
				m_bShowAlienBrief = 2;    
			}
		}
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
