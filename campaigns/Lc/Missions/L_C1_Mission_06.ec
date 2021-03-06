
#define MISSION_NAME "translateL_M6"

#define WAVE_MISSION_PREFIX "LC\\M6\\L_M6_Brief_"

mission MISSION_NAME
{
	state Initialize;

	#include "..\..\common.ech"
	#include "..\..\dialog.ech"
	#include "..\..\dialog2.ech"
	#include "..\..\weather.ech"
	#include "..\..\defines.ech"
	#include "..\..\researches.ech"

	#define PILOT_HEAD LC_GIRL_HEAD /* xxx */
	#define PILOT_HEAD_NAME LC_GIRL_HEAD_NAME /* xxx */

	consts
	{
		eMission = 6;

		playerPlayer    = 3;
		playerEnemyBase = 2;
		playerEnemy1    = 5;
		playerEnemy2    = 6;
		playerNeutral   = 7;

		goalLHeroMustSurvive  = 0;
		goalEHero1MustSurvive  = 1;
		goalEHero2MustSurvive  = 2;
		goalFreeIgor = 3;
		goalFreeLCPrisoners = 4;
		goalEvacuationPoint  = 5;

		markerStart = 1;
		markerLHero1  = 1;

		markerPrisonerFirst       = 10;
		markerPrisonerGuard1First = 11;
		markerPrisonerGuard2First = 12;

		stepPrisoners  = 10;
		countPrisoners =  6;

		expPrisoners = 6;
		expGuards    = 6;

		ePrisonersTick  = 30;

		markerEnemyPatrolAFirst = 80;
		markerEnemyPatrolALast  = 85;

		markerEnemyPatrolBFirst = 86;
		markerEnemyPatrolBLast  = 93;

		markerEHero1 = 2;
		markerEHero2 = 3;

		markerEvacuationPoint = 4;

		rangeNearIgor = 4;
		rangeNearEvacuationPoint = 7;
	}
	
	player m_pPlayer;
	player m_pEnemyBase;
	player m_pEnemy1;
	player m_pEnemy2;
	player m_pNeutral;
	
	unit m_uLHero1;
	unit m_uEHero1;
	unit m_uEHero2;
		
	state Start;
	state FindIgor;
	state FindEvacuationPoint;
	state End;
	state XXX;
	

	function void InitializeResearches()
	{
		SetPlayerTemplateseLCCampaign(m_pPlayer, eMission);
		SetPlayerResearchesLCCampaign(m_pPlayer, eMission);
		//AddPlayerResearchesLCCampaign(m_pPlayer, eMission);

		SetPlayerResearchesEDCampaign(m_pEnemyBase, eMission);
		AddPlayerResearchesEDCampaign(m_pEnemyBase, eMission);

		SetPlayerResearchesEDCampaign(m_pEnemy1, eMission);
		SetPlayerResearchesEDCampaign(m_pEnemy2, eMission);
		

		if(GET_DIFFICULTY_LEVEL()==1)
		{
			AddPlayerResearchesEDCampaign(m_pEnemy1, eMission-2);
			AddPlayerResearchesEDCampaign(m_pEnemy2, eMission-2);
		}
		if(GET_DIFFICULTY_LEVEL()==2)
		{
			AddPlayerResearchesEDCampaign(m_pEnemy1, eMission);
			AddPlayerResearchesEDCampaign(m_pEnemy2, eMission);
		}
	}
	

	int  m_anPrisoner[];
	unit m_auPrisoner[];
	unit m_auPrisonerGuard1[];
	unit m_auPrisonerGuard2[];

	function void CreatePrisoner(int nPrisoner)
	{
		int nMarkerPrisoner;
		int nMarkerPrisonerGuard1;
		int nMarkerPrisonerGuard2;

		unit uPrisoner;
		unit uPrisonerGuard1;
		unit uPrisonerGuard2;

		nMarkerPrisoner       = markerPrisonerFirst       + nPrisoner * stepPrisoners;
		nMarkerPrisonerGuard1 = markerPrisonerGuard1First + nPrisoner * stepPrisoners;
		nMarkerPrisonerGuard2 = markerPrisonerGuard2First + nPrisoner * stepPrisoners;

		uPrisoner = CreatePlayerObjectAtMarker(m_pNeutral, "L_IN_DR_03_1", nMarkerPrisoner);

		AddMapSignAtMarker(nMarkerPrisoner, signSpecial, -1);
		uPrisonerGuard1 = CreatePlayerObjectAtMarker(m_pEnemyBase, "E_CH_GT_04_1#E_WP_CA_04_1,E_AR_CL_04_1,E_EN_NO_04_1,E_IE_SG_04_1,E_IE_RD_01_1", nMarkerPrisonerGuard1);
		uPrisonerGuard2 = CreatePlayerObjectAtMarker(m_pEnemyBase, "E_CH_GT_05_1#E_WP_CA_05_1,E_AR_CL_05_1,E_EN_NO_05_1,E_IE_SG_04_1,E_IE_RD_01_1", nMarkerPrisonerGuard2);

		uPrisonerGuard1.CommandSetMovementMode(eMovementModeHoldPosition);
		uPrisonerGuard2.CommandSetMovementMode(eMovementModeHoldPosition);

		uPrisonerGuard1 = uPrisonerGuard1.GetCrew();
		uPrisonerGuard2 = uPrisonerGuard2.GetCrew();

		m_auPrisoner.Add(uPrisoner);
		m_anPrisoner.Add(nMarkerPrisoner);

		m_auPrisonerGuard1.Add(uPrisonerGuard1);
		m_auPrisonerGuard2.Add(uPrisonerGuard2);
	}

	function void InitializePrisoners()
	{
		int nPrisoner;

		m_auPrisoner.Create(0);
		m_anPrisoner.Create(0);
		m_auPrisonerGuard1.Create(0);
		m_auPrisonerGuard2.Create(0);

		for ( nPrisoner = 0; nPrisoner < countPrisoners; ++nPrisoner )
		{
			CreatePrisoner(nPrisoner);
		}

		SetExperienceLevel(m_auPrisoner, expPrisoners);

		SetExperienceLevel(m_auPrisonerGuard1, expGuards);
		SetExperienceLevel(m_auPrisonerGuard2, expGuards);

		SetTimer(1, ePrisonersTick);
	}

	function int CheckPrisoner(int nPrisoner)
	{
		unit uPrisoner;
		unit uPrisonerGuard1;
		unit uPrisonerGuard2;
		int nMarker;
		uPrisoner = m_auPrisoner[nPrisoner];
		nMarker = m_anPrisoner[nPrisoner];

		uPrisonerGuard1 = m_auPrisonerGuard1[nPrisoner];
		uPrisonerGuard2 = m_auPrisonerGuard2[nPrisoner];

		if ( uPrisoner.IsLive() && uPrisoner.GetIFFNum() != m_pPlayer.GetIFFNum() )
		{
			if ( !uPrisonerGuard1.IsLive() && !uPrisonerGuard2.IsLive() )
			{
				RemoveMapSignAtMarker(nMarker);
				uPrisoner.SetPlayer(m_pPlayer);
				return true;
			}
		}

		return false;
	}

	function void CheckPrisoners()
	{
		int i, nPrisoners;

		nPrisoners = m_auPrisoner.GetSize();

		if(!nPrisoners) return;

		for ( i = 0; i < nPrisoners; ++i )
		{
			if ( CheckPrisoner(i) )
			{
				m_auPrisoner.RemoveAt(i);
				m_anPrisoner.RemoveAt(i);
				m_auPrisonerGuard1.RemoveAt(i);
				m_auPrisonerGuard2.RemoveAt(i);

				--i; --nPrisoners;
			}
		}
		if(!nPrisoners)ACHIEVE_GOAL(FreeLCPrisoners);
	}

	event Timer1()
	{
		CheckPrisoners();
	}

	function void CreateEnemyPatrolA(int nMarker)
	{
		CreatePatrol(m_pEnemyBase, "E_CH_GJ_03_1#E_WP_CR_03_1,E_AR_CL_03_1,E_EN_SP_03_1"             , 1+(GET_DIFFICULTY_LEVEL()*1), nMarker, nMarker+1);
		CreatePatrol(m_pEnemyBase, "E_CH_AJ_01_1#E_WP_SL_01_3,E_AR_CL_01_3,E_EN_SP_01_1,E_IE_SG_01_3", 1+(GET_DIFFICULTY_LEVEL()*1), nMarker, nMarker+1);
		CreatePatrol(m_pEnemyBase, "E_CH_GT_04_1#E_WP_CA_04_1,E_AR_RL_04_3,E_EN_SP_04_1,E_IE_SG_04_3", (GET_DIFFICULTY_LEVEL()*1), nMarker, nMarker+1);
	}

	function void CreateEnemyPatrolB(int nMarker)
	{
		CreatePatrol(m_pEnemyBase, "E_CH_GJ_03_1#E_WP_CR_03_1,E_AR_CL_03_1,E_EN_SP_03_1"             , 3+(GET_DIFFICULTY_LEVEL()*2), nMarker, nMarker+1);
		CreatePatrol(m_pEnemyBase, "E_CH_AJ_01_1#E_WP_SL_01_3,E_AR_CL_01_3,E_EN_SP_01_1,E_IE_SG_01_3", 3+(GET_DIFFICULTY_LEVEL()*2), nMarker, nMarker+1);
		CreatePatrol(m_pEnemyBase, "E_CH_GT_04_1#E_WP_CA_04_1,E_AR_RL_04_3,E_EN_SP_04_1,E_IE_SG_04_3", 1+(GET_DIFFICULTY_LEVEL()*2), nMarker, nMarker+1);
		CreatePatrol(m_pEnemyBase, "E_CH_GA_08_1#E_WP_GR_08_1,E_AR_RL_08_3,E_EN_SP_08_1,E_IE_SG_01_3", (GET_DIFFICULTY_LEVEL()*1), nMarker, nMarker+1);
	}

	function void CreateEnemies()
	{
		int nMarker;

		for ( nMarker = markerEnemyPatrolAFirst; nMarker < markerEnemyPatrolALast; ++nMarker )
		{
			CreateEnemyPatrolA(nMarker);
		}

		for ( nMarker = markerEnemyPatrolBFirst; nMarker < markerEnemyPatrolBLast; ++nMarker )
		{
			CreateEnemyPatrolB(nMarker);
		}
	}

	state Initialize
	{
		int i;

		INITIALIZE_PLAYER(Player);
		INITIALIZE_PLAYER(EnemyBase);
		INITIALIZE_PLAYER(Enemy1);
		INITIALIZE_PLAYER(Enemy2);
		INITIALIZE_PLAYER(Neutral);

		SetNeutrals(m_pEnemyBase, m_pEnemy1, m_pEnemy2, m_pNeutral);

		SetNeutrals(m_pPlayer, m_pNeutral);
		SetEnemies(m_pPlayer, m_pEnemyBase);
		SetEnemies(m_pPlayer, m_pEnemy1);
		SetEnemies(m_pPlayer, m_pEnemy2);

		ActivateAI(m_pEnemy1);
		if(GET_DIFFICULTY_LEVEL()) ActivateAI(m_pEnemy2);
		

		REGISTER_GOAL(LHeroMustSurvive   );
		REGISTER_GOAL(EHero1MustSurvive   );
		REGISTER_GOAL(EHero2MustSurvive   );
		REGISTER_GOAL(FreeIgor  );
		REGISTER_GOAL(FreeLCPrisoners  );
		REGISTER_GOAL(EvacuationPoint   );


		InitializeResearches();
		InitializePrisoners();
		
		StartWeather();
		
		RESTORE_SAVED_UNIT(Player, LHero1, eBufferLHero1);
		RestoreBestInfantryAtMarker(m_pPlayer, markerStart);
		FinishRestoreUnits(m_pPlayer);

		m_pPlayer.AddResource(eCrystal, 5000);
		m_pPlayer.AddResource(eWater, 5000);


		i = PlayCutscene("L_M6_C1.trc", true, true, true);
		return Start, i-eFadeTime;
		
	}

	int m_nState;

	state Start
	{
		m_nState=0;
		LookAtUnit(m_uLHero1);
		EnableInterface(true);
		ShowInterface(true);
		ENABLE_GOAL(LHeroMustSurvive   );
		ENABLE_GOAL(FreeIgor  );
		ENABLE_GOAL(FreeLCPrisoners  );
		
		ADD_BRIEFINGS(Transmision1, ARIA_HEAD, NATASHA_HEAD, 9);
		START_BRIEFING(true);

		AddMapSignAtMarker(markerEHero1, signMoveTo, -1);

		WaitToEndBriefing(FindIgor, 10*30);
	}

	state FindIgor
	{
		if(m_nState==0)
		{
			m_nState=1;
			CreateEnemies();
			return state,20*30;
		}

		if(m_nState==1)
		{
			m_nState = 2;
			AddAgent(3); //Doc
			return state,20*30;
		}
		if(m_nState==2)
		{
			m_nState = 3;
			AddAgent(4); //Gabriel
			return state,20*30;
		}
		if(m_nState==3)
		{
			if ( IsUnitNearMarker(m_uLHero1, markerEHero1, rangeNearIgor) )
			{
				
				CREATE_UNIT_ALPHA(Player, EHero1, "E_HERO_01",128);
				RemoveMapSignAtMarker(markerEHero1);
				m_nState = 4;
				ACHIEVE_GOAL(FreeIgor);
				ENABLE_GOAL(EHero1MustSurvive);
				ADD_BRIEFINGS(Transmision2, IGOR_HEAD, ARIA_HEAD, 17);
				START_BRIEFING(true);
				WaitToEndBriefing(state, 0);
			}
		}
		
		if(m_nState==4)
		{
			m_nState = 0;
			CREATE_UNIT_ALPHA(Player, EHero2, "E_HERO_02",128);
			ENABLE_GOAL(EHero2MustSurvive);
			ENABLE_GOAL(EvacuationPoint);
			AddMapSignAtMarker(markerEvacuationPoint, signMoveTo, -1);
			ADD_BRIEFING(Transmision3_01, IGOR_HEAD);
			ADD_BRIEFING(Transmision4_01, ARIA_HEAD);
			ADD_BRIEFINGS(Transmision5, NATASHA_HEAD, ARIA_HEAD, 2);
			START_BRIEFING(true);
			WaitToEndBriefing(FindEvacuationPoint, 0);
		}
		return state,30;
	
	}

	state FindEvacuationPoint
	{

		if(m_nState==0)
		{
			m_nState=1;
			CreateEnemyPatrolB(100);
			CreateEnemyPatrolB(102);
			CreateEnemyPatrolA(100);
			CreateEnemyPatrolA(102);
			return state,60;
		}


		if ( IsUnitNearMarker(m_uLHero1, markerEvacuationPoint, rangeNearEvacuationPoint) && 
			IsUnitNearMarker(m_uEHero1, markerEvacuationPoint, rangeNearEvacuationPoint) &&
			IsUnitNearMarker(m_uEHero2, markerEvacuationPoint, rangeNearEvacuationPoint))
		{
			SaveEndMissionGame(206,null);
			ACHIEVE_GOAL(EvacuationPoint   );
			RemoveMapSignAtMarker(markerEvacuationPoint);
			ADD_BRIEFINGS(Transmision6,ARIA_HEAD,NATASHA_HEAD,2);
			START_BRIEFING(true);
			WaitToEndBriefing(End, 0);
		}
		return state,60;
	}

	state End
	{
		int i;
		EnableInterface(false);
		ShowInterface(false);
		m_pEnemy1.EnableAI(false);
		m_pEnemy2.EnableAI(false);
		m_pEnemyBase.EnableAI(false);
		SetNeutrals(m_pPlayer, m_pEnemy1, m_pEnemy2, m_pEnemyBase);
		SetWind(0, 0);SetTimer(2,0);
		EnableMessages(false);
		i = PlayCutscene("L_M6_C2.trc", true, true, true);
		return XXX, i-eFadeTime;
		
		
	}

	state XXX
	{
		PrepareSaveUnits(m_pPlayer);
        SAVE_UNIT(Player, LHero1, eBufferLHero1);
		SAVE_UNIT(Player, EHero1, eBufferEHero1);
		SAVE_UNIT(Player, EHero2, eBufferEHero2);
        SaveBestInfantry(m_pPlayer, 12-GET_DIFFICULTY_LEVEL()*3);
		EndMission(true);
	}
	state YYY
	{
		MissionDefeat();
	}


	event RemovedUnit(unit uKilled, unit uAttacker, int nNotifyType)
	{
		if ( state != YYY && state != XXX)
		{
			if ( uKilled == m_uLHero1 )
			{
				SetGoalState(goalLHeroMustSurvive, goalFailed, false);
				
				EnableInterface(false);
				ShowInterface(false);
				
				SetLowConsoleText("translateMissionFailed");
				
				FadeInCutscene(100, 0, 0, 0);
				
				state YYY;
				
				SetStateDelay(120);
			}
			if ( uKilled == m_uEHero2 && IsGoalEnabled(goalEHero2MustSurvive) )
			{
				SetGoalState(goalEHero2MustSurvive, goalFailed, false);
				
				EnableInterface(false);
				ShowInterface(false);
				
				SetLowConsoleText("translateMissionFailed");
				
				FadeInCutscene(100, 0, 0, 0);
				
				state YYY;
				
				SetStateDelay(120);
			}
			if ( uKilled == m_uEHero1 && IsGoalEnabled(goalEHero1MustSurvive) )
			{
				SetGoalState(goalEHero1MustSurvive, goalFailed, false);
				
				EnableInterface(false);
				ShowInterface(false);
				
				SetLowConsoleText("translateMissionFailed");
				
				FadeInCutscene(100, 0, 0, 0);
				
				state YYY;
				
				SetStateDelay(120);
			}
			
		}
	}

	event RemovedBuilding(unit uKilled, unit uAttacker, int nNotifyType)
	{
	}

	event EscapeCutscene(int nIFFNum)
	{
		int nTicks;//czas potrzebny na fadeOut
        if ((state == Start) ||(state == XXX))
        {
        }
        else
        {
            return;
        }
		nTicks = StopCutscene();
		SetStateDelay(nTicks);
	}

	event EndMission(int nResult)
	{
	}

	event DebugEndMission()
	{
		if(m_uEHero1 == null)CREATE_UNIT_ALPHA(Player, EHero1, "E_HERO_01",128);
		state End;
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
