#include "..\..\defines.ech"

#define MISSION_NAME "translateL_M5"

#define WAVE_MISSION_PREFIX "LC\\M5\\L_M5_Brief_"


/*

start  briefing i map sign na czolgach. goal: przejmij sprzêt
  zabicie  ochroniazy i uwolnienie wiezniow ED - briefing
  zniszczenie ochrony i czolgow briefing 
                    goal: zniszcz umocnienia portu kosmicznego
					
  zniszczenie budynkow obronnych portu 
                    briefing: natasha przejmij ten statek
					goal: natasza musi podejsc do statku
					rusza duzy atak na statek
natasha przy statku 
  mission over -  cutscena -  prom startuje. , kosmos prom dobija do  wielkiego statku. Po chwili statek odpala silniki i rusza. Koniec
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
		playerEnemy1     = 6;
		playerEnemy2     = 7;
		playerEnemy3     = 1;//guards1
		playerEnemy4     = 5;// guards2
		playerNeutral    = 2; // wiezniowie
		playerNeutral2    = 4; // wiezniowie
		playerNeutral3    = 8; //Pojazd Sebastiana
		
		goalLHero1MustSurvive = 0;
		goalLHero2MustSurvive = 1;
		goalSebastianMustSurvive = 2;
		goalCaptureVehicles = 3;
		goalDestroySpaceportDefence = 4;
		goalCaptureShuttle = 5;
		goalFreePrisoners = 6;
		goalCaptureNextVehicles =7; 

		markerLHero2 = 1;
		markerShuttle = 2;
		markerVehicleGuards = 5;
		markerPrizonersGuards = 6;
		markerPrizoners = 7;
		markerLHero1 = 8;
		markerSebastian = 9;

		markerWeakEnemy = 10;// - 19
		markerVehicle1 = 30;
		markerVehicle2 = 40;  // do przejecia pojazdy

		markerPrizoners2 = 39;	
		markerPrizonersGuards2 = 49;	

		markerLightPatrol = 50;
		markerHeavyPatrol = 60;
		markerFlightPatrol = 70;

		markerDefenceFirst = 80; // budynki obronne portu
		markerDefenceLast = 86;
	

		markerPursuit = 90;

	}

	player m_pPlayer;
	player m_pEnemy1;
	player m_pEnemy2;
	player m_pEnemy3;
	player m_pEnemy4;
	player m_pNeutral;
	player m_pNeutral2;
	player m_pNeutral3;	
	

	unit m_uLHero1;
	unit m_uLHero2;
	unit m_uSebastian;
	unit m_uShuttle;
	unit m_uVehicle1[];
	unit m_uVehicle2[];
	
	
	int m_nState;
	int bPrizoners1;
	int	bPrizoners2;
	int nPursuitCounter;
	int m_bUnitDestroyed;    
	

	function void CreateVehicles()//XXXMD
	{
		unit uVehicle;
		m_uVehicle1.Create(8);

		m_uVehicle1[0] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GA_08_1#L_WP_PC_08_1,L_AR_CL_08_1,L_EN_SP_08_1,L_IE_SG_01_2", markerVehicle1);
		m_uVehicle1[1] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GT_05_1#L_WP_MP_05_2#L_WP_MP2_05_2,L_AR_CL_05_2,L_EN_PR_05_1,L_IE_SG_04_2", markerVehicle1+1);
		m_uVehicle1[2] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GT_04_1#L_WP_MP_04_2,L_AR_CL_04_1,L_EN_NO_04_1,L_IE_SG_04_2", markerVehicle1+2);
		m_uVehicle1[3] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GT_04_1#L_WP_PB_04_2,L_AR_RL_04_1,L_EN_NO_04_1,L_IE_SG_04_2", markerVehicle1+3);
		m_uVehicle1[4] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GA_08_1#L_WP_PC_08_1,L_AR_CL_08_1,L_EN_SP_08_1,L_IE_SG_01_2", markerVehicle1+4);
		m_uVehicle1[5] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GJ_02_1#L_WP_SG_02_2,L_AR_RL_02_1,L_EN_NO_02_1,L_IE_SG_01_2", markerVehicle1+5);
		m_uVehicle1[6] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GJ_02_1#L_WP_AA_02_2,L_AR_RL_02_1,L_EN_PR_02_1,L_IE_SG_01_2", markerVehicle1+6);
		m_uVehicle1[7] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GT_05_1#L_WP_MP_05_2#L_WP_MP2_05_2,L_AR_CL_05_2,L_EN_PR_05_1,L_IE_SG_04_2", markerVehicle1+7);//XXXTZ
	
		uVehicle = m_uVehicle1[0];
		uVehicle.CommandSetLandAirMode(eModeLand);
		uVehicle = m_uVehicle1[4];
		uVehicle.CommandSetLandAirMode(eModeLand);

		m_uVehicle2.Create(8);

		m_uVehicle2[0] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GT_05_1#L_WP_PB_05_2#L_WP_PB2_05_2,L_AR_RL_05_2,L_EN_NO_05_1,L_IE_SG_04_2", markerVehicle2+0);
		m_uVehicle2[1] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GT_04_1#L_WP_SB_04_2,L_AR_CL_04_1,L_EN_NO_04_1,L_IE_SG_04_2", markerVehicle2+1);
		m_uVehicle2[2] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GT_04_1#L_WP_SB_04_2,L_AR_CL_04_1,L_EN_NO_04_1,L_IE_SG_04_2", markerVehicle2+2);
		m_uVehicle2[3] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GJ_02_1#L_WP_SG_02_2,L_AR_RL_02_1,L_EN_NO_02_1,L_IE_SG_01_2", markerVehicle2+3);
		m_uVehicle2[4] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GJ_02_1#L_WP_SG_02_2,L_AR_RL_02_1,L_EN_NO_02_1,L_IE_SG_01_2", markerVehicle2+4);
		m_uVehicle2[5] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GJ_02_1#L_WP_AA_02_2,L_AR_RL_02_1,L_EN_PR_02_1,L_IE_SG_01_2", markerVehicle2+5);
		m_uVehicle2[6] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GJ_02_1#L_WP_AA_02_2,L_AR_RL_02_1,L_EN_PR_02_1,L_IE_SG_01_2", markerVehicle2+6);
		m_uVehicle2[7] = CreatePlayerObjectAtMarker(m_pEnemy1, "L_CH_GT_05_1#L_WP_PB_05_2#L_WP_PB2_05_2,L_AR_RL_05_2,L_EN_NO_05_1,L_IE_SG_04_2", markerVehicle2+7);//XXXTZ
	}
	function void ClearVehiclesCrew()
	{
		int i, size;
		unit uVehicle;

		size = m_uVehicle1.GetSize();
		for(i=0;i<size;i=i+1)
		{
			uVehicle = m_uVehicle1[i];
			uVehicle.CommandExitCrew();
		}

		size = m_uVehicle2.GetSize();
		for(i=0;i<size;i=i+1)
		{
			uVehicle = m_uVehicle2[i];
			uVehicle.CommandExitCrew();
		}
			
	}
	function void CreateWeakEnemy()
	{
		int i;

		for(i=markerWeakEnemy;i<markerWeakEnemy+10;i=i+1) 
		{
			CreatePlayerObjectsAtMarker(m_pEnemy1, "L_IN_RG_01_1", 3+(GET_DIFFICULTY_LEVEL()*3), i);
			CreatePlayerObjectsAtMarker(m_pEnemy1, "L_CH_GJ_02_1#L_WP_PG_02_1,L_AR_CL_02_1,L_EN_PR_02_1", 1+(GET_DIFFICULTY_LEVEL()), i);
		}
	}

	function void CreateLightPatrols()//XXXMD
	{
		int i, size;
		size = 5+GET_DIFFICULTY_LEVEL()*2;

		for(i=0;i<size;i=i+1)
		{
			if(Rand(2))
			{
				CreatePatrol(m_pEnemy1, "L_CH_GJ_02_1#L_WP_EL_02_1,L_AR_CL_02_1,L_EN_NO_02_1", 1+GET_DIFFICULTY_LEVEL(),markerLightPatrol+i,markerLightPatrol+i+1);
				CreatePatrol(m_pEnemy1, "L_CH_GJ_02_1#L_WP_SG_02_1,L_AR_CL_02_1,L_EN_NO_02_1", 1+GET_DIFFICULTY_LEVEL(),markerLightPatrol+i,markerLightPatrol+i+1);
				CreatePatrol(m_pEnemy1, "L_CH_GJ_02_1#L_WP_AA_02_1,L_AR_CL_02_1,L_EN_NO_02_1", 1+GET_DIFFICULTY_LEVEL(),markerLightPatrol+i,markerLightPatrol+i+1);
			}
			else
			{
				CreatePatrol(m_pEnemy1, "L_CH_GJ_02_1#L_WP_PG_02_1,L_AR_RL_02_1,L_EN_SP_02_1", 1+GET_DIFFICULTY_LEVEL(),markerLightPatrol+i,markerLightPatrol+i+1);
				CreatePatrol(m_pEnemy1, "L_CH_GJ_02_1#L_WP_SG_02_1,L_AR_CL_02_1,L_EN_SP_02_1", 1+GET_DIFFICULTY_LEVEL(),markerLightPatrol+i,markerLightPatrol+i+1);
			}
		}
	}

	
	function void CreateHeavyPatrols()
	{
		int i, size;
		size = 5+GET_DIFFICULTY_LEVEL()*2;

		for(i=0;i<size;i=i+1)
		{
			if(Rand(2))
			{
//XXXTZ				CreatePatrol(m_pEnemy1, "L_CH_GT_04_1#L_WP_PB_04_1,L_AR_CL_04_1,L_EN_NO_04_1", 1+GET_DIFFICULTY_LEVEL(),markerHeavyPatrol+i,markerHeavyPatrol+i+1);
				CreatePatrol(m_pEnemy1, "L_CH_GT_04_1#L_WP_PB_04_1,L_AR_RL_04_1,L_EN_NO_04_1", GET_DIFFICULTY_LEVEL(),markerHeavyPatrol+i,markerHeavyPatrol+i+1);
				CreatePatrol(m_pEnemy1, "L_CH_GJ_02_1#L_WP_SG_02_1,L_AR_RL_02_1,L_EN_NO_02_1", GET_DIFFICULTY_LEVEL(),markerHeavyPatrol+i,markerHeavyPatrol+i+1);
				CreatePatrol(m_pEnemy1, "L_CH_GJ_02_1#L_WP_SG_02_1,L_AR_RL_02_1,L_EN_NO_02_1", 1+GET_DIFFICULTY_LEVEL(),markerHeavyPatrol+i,markerHeavyPatrol+i+1);
			}
			else
			{
//XXXTZ				CreatePatrol(m_pEnemy1, "L_CH_GT_04_1#L_WP_MP_04_1,L_AR_CL_04_1,L_EN_SP_04_1", 1+GET_DIFFICULTY_LEVEL(),markerHeavyPatrol+i,markerHeavyPatrol+i+1);
				CreatePatrol(m_pEnemy1, "L_CH_GT_04_1#L_WP_MP_04_1,L_AR_RL_04_1,L_EN_SP_04_1", GET_DIFFICULTY_LEVEL(),markerHeavyPatrol+i,markerHeavyPatrol+i+1);
				CreatePatrol(m_pEnemy1, "L_CH_GJ_02_1#L_WP_EL_02_1,L_AR_RL_02_1,L_EN_PR_02_1", 1+GET_DIFFICULTY_LEVEL(),markerHeavyPatrol+i,markerHeavyPatrol+i+1);
				CreatePatrol(m_pEnemy1, "L_CH_GJ_02_1#L_WP_EL_02_1,L_AR_RL_02_1,L_EN_PR_02_1", GET_DIFFICULTY_LEVEL(),markerHeavyPatrol+i,markerHeavyPatrol+i+1);

			}
		}
	}
	function void CreateFlightPatrols()
	{
		int i, size;
		size = 1+GET_DIFFICULTY_LEVEL()*4;

		for(i=0;i<size;i=i+1)
		{
			if(Rand(2))
			{
				CreatePatrol(m_pEnemy1, "L_CH_AJ_01_1#L_WP_EL_01_1,L_AR_CL_01_1,L_EN_SP_01_1", GET_DIFFICULTY_LEVEL(),markerFlightPatrol+i,markerFlightPatrol+i+1);
				CreatePatrol(m_pEnemy1, "L_CH_AJ_01_1#L_WP_SG_01_1,L_AR_CL_01_1,L_EN_NO_01_1", 1+GET_DIFFICULTY_LEVEL(),markerFlightPatrol+i,markerFlightPatrol+i+1);
			}
			else
			{
				CreatePatrol(m_pEnemy1, "L_CH_AJ_01_1#L_WP_SG_01_1,L_AR_CL_01_1,L_EN_SP_01_1", GET_DIFFICULTY_LEVEL(),markerFlightPatrol+i,markerFlightPatrol+i+1);
				CreatePatrol(m_pEnemy1, "L_CH_AJ_01_1#L_WP_SG_01_1,L_AR_CL_01_1,L_EN_NO_01_1", 1+GET_DIFFICULTY_LEVEL(),markerFlightPatrol+i,markerFlightPatrol+i+1);
	
			}
		}
	}
	function void CreatePursuitGroup()
	{
		
		if(Rand(2))
			{
				CreateAndAttackFromMarkerToUnit(m_pEnemy1, "L_CH_GJ_02_1#L_WP_EL_02_1,L_AR_CL_02_1,L_EN_NO_02_1", GET_DIFFICULTY_LEVEL(),markerPursuit,m_uLHero1);
				CreateAndAttackFromMarkerToUnit(m_pEnemy1, "L_CH_GJ_02_1#L_WP_SG_02_1,L_AR_CL_02_1,L_EN_NO_02_1", 1+GET_DIFFICULTY_LEVEL(),markerPursuit,m_uLHero1);
			}
			else
			{
				CreateAndAttackFromMarkerToUnit(m_pEnemy1, "L_CH_GJ_02_1#L_WP_PG_02_1,L_AR_CL_02_1,L_EN_SP_02_1", GET_DIFFICULTY_LEVEL(),markerPursuit,m_uLHero1);
				CreateAndAttackFromMarkerToUnit(m_pEnemy1, "L_CH_GJ_02_1#L_WP_PG_02_1,L_AR_CL_02_1,L_EN_SP_02_1", 1+GET_DIFFICULTY_LEVEL(),markerPursuit,m_uLHero1);
				CreateAndAttackFromMarkerToUnit(m_pEnemy1, "L_CH_GJ_02_1#L_WP_SG_02_1,L_AR_CL_02_1,L_EN_SP_02_1", 1+GET_DIFFICULTY_LEVEL(),markerPursuit,m_uLHero1);
			}
	}

	function void CreatePrisoners()
	{
		CreatePlayerObjectsAtMarker(m_pNeutral, "N_IN_SM_01_1", 8, markerPrizoners);//XXXTZ
		CreatePlayerObjectsAtMarker(m_pEnemy3, "L_IN_RG_01_1", 4+(GET_DIFFICULTY_LEVEL()*3), markerPrizonersGuards);

		CreatePlayerObjectsAtMarker(m_pNeutral2, "N_IN_SM_01_1", 8, markerPrizoners2);//XXXTZ
		CreatePlayerObjectsAtMarker(m_pEnemy4, "L_IN_RG_01_1", 6+(GET_DIFFICULTY_LEVEL()*3), markerPrizonersGuards2);
		CreatePlayerObjectsAtMarker(m_pEnemy4, "L_CH_GJ_02_1#L_WP_SG_02_1,L_AR_CL_02_1,L_EN_PR_02_1", 1+(GET_DIFFICULTY_LEVEL()), markerPrizonersGuards2);//XXXTZ

	}
	function void VehicleGuards()//XXXTZ
	{
		CreatePlayerObjectsAtMarker(m_pEnemy1, "L_IN_RG_01_1", 4+(GET_DIFFICULTY_LEVEL()*3), markerVehicleGuards);//XXXTZ
		CreatePlayerObjectsAtMarker(m_pEnemy1, "L_CH_GJ_02_1#L_WP_PG_02_1,L_AR_CL_02_1,L_EN_PR_02_1", 1+(GET_DIFFICULTY_LEVEL()), markerVehicleGuards);//XXXTZ
	}

	unit m_auDefence[];

	function void InitializeDefence()
	{
		unit uTmp;
		int i;	

		m_auDefence.Create(0);
		for ( i = markerDefenceFirst; i <= markerDefenceLast; i=i+1 )
		{
			uTmp = GetUnitAtMarker(i);
			if(uTmp)m_auDefence.Add(uTmp);
		}
	}

	function int CheckDefence()
	{
		int i, nDefence;
		unit uTmp;
		nDefence = m_auDefence.GetSize();

		if(!nDefence) return true;

		for ( i = 0; i < nDefence; ++i )
		{
			uTmp = m_auDefence[i];
			if (!uTmp.IsLive())
			{
				m_auDefence.RemoveAt(i);
				--i; --nDefence;
			}
		}
		if(!nDefence) return true;
		return false;
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
		INITIALIZE_PLAYER(Enemy2);
		INITIALIZE_PLAYER(Enemy3);
		INITIALIZE_PLAYER(Enemy4);
		INITIALIZE_PLAYER(Neutral);
		INITIALIZE_PLAYER(Neutral2);
		INITIALIZE_PLAYER(Neutral3);
		
		
		
		m_pEnemy1.EnableAI(false);
		m_pEnemy2.EnableAI(false);
		m_pEnemy3.EnableAI(false);
		m_pEnemy4.EnableAI(false);
		m_pNeutral.EnableAI(false);
		m_pNeutral2.EnableAI(false);
		m_pNeutral3.EnableAI(false);
		
		AddEnemyResearchesEDCampaign(m_pEnemy1, 5);
		AddEnemyResearchesEDCampaign(m_pEnemy2, 5);

		SetNeutrals(m_pPlayer,m_pNeutral,m_pNeutral2,m_pNeutral3);
		SetNeutrals(m_pEnemy1,m_pEnemy2,m_pEnemy3,m_pEnemy4,m_pNeutral,m_pNeutral2,m_pNeutral3);
		SetEnemies(m_pEnemy1,m_pPlayer);
		SetEnemies(m_pEnemy2,m_pPlayer);
		SetEnemies(m_pEnemy3,m_pPlayer);
		SetEnemies(m_pEnemy4,m_pPlayer);
		
		
		REGISTER_GOAL(LHero1MustSurvive);
		REGISTER_GOAL(LHero2MustSurvive);
		REGISTER_GOAL(SebastianMustSurvive);
		REGISTER_GOAL(CaptureVehicles  );
		REGISTER_GOAL(DestroySpaceportDefence);
		REGISTER_GOAL(CaptureShuttle  );
		REGISTER_GOAL(FreePrisoners);
		REGISTER_GOAL(CaptureNextVehicles); 
		
		CREATE_UNIT(Player, Sebastian, "N_IN_VA_09");
		
		RESTORE_SAVED_UNIT(Player, LHero1, eBufferLHero1);
		RESTORE_SAVED_UNIT(Player, LHero2, eBufferLHero2);
		
		LookAtUnit(m_uLHero1);
		
		INITIALIZE_UNIT(Shuttle);

		CreateVehicles();

		InitializeDefence();

		CreateWeakEnemy();
		CreatePrisoners();

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
		SetDrawAllObjects(true);
		i = PlayCutscene("L_M5_C1.trc", true, true, true);
		return Start, i-eFadeTime;
	}

	

	state Start
	{
		m_nState=0;
		SetDrawAllObjects(false);
		bPrizoners1 = false;
		bPrizoners2 = true; // nie sprawdzac prizonerow 2
		EnableInterface(true);
		ShowInterface(true);
		return MissionFlow, 160;
	}

	state MissionFlow
	{
		int i,k,nGx, nGy;
		unit uVehicle;

		
		if(m_nState==0) //=============================================================================================
		{
			m_nState = 1;
			ENABLE_GOAL(LHero1MustSurvive);
			ENABLE_GOAL(LHero2MustSurvive);
			ENABLE_GOAL(SebastianMustSurvive);
			
			ADD_BRIEFINGS(Transmision1,PROFFESOR_HEAD,ARIA_HEAD,6);
			ADD_BRIEFINGS(Transmision2,NATASHA_HEAD,ARIA_HEAD,,2);
			START_BRIEFING(false);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(m_nState==1)// zwolnic pojazdy
		{
			ClearVehiclesCrew();
			m_nState = 2;
			return state;
		}
		if(m_nState==2)// uwalnianie pierwszych wiezniow ==============================================================
		{
			if (!bPrizoners1 && !m_pEnemy3.GetNumberOfUnits())// uwolnieni wiezniowie
			{
					bPrizoners1 = true;
					bPrizoners2 = false;
					CreateLightPatrols();
					CreateHeavyPatrols();
					CreateFlightPatrols();
					LookAtMarkerClose(markerPrizoners);
					GiveAllUnitsToPlayer(m_pNeutral,m_pPlayer);//XXXTZ
					m_nState = 3;  
					KillUnitAtMarker(28); //wysadzenie murka   
					ENABLE_GOAL(FreePrisoners); //XXXMD
					ENABLE_GOAL(CaptureVehicles);
					AddMapSignAtMarker(markerVehicle1, signMoveTo, -1);
					ADD_BRIEFINGS(Transmision3,ARIA_HEAD, CIVIL_HEAD, 11);
					START_BRIEFING(false);
					WaitToEndBriefing(state, 10*30);
					return state;
			}
		}
		if(m_nState==3)// przejmowanie pojazdów ==============================================================
		{
			
			for(i=0; i<8;i=i+1)
			{
				uVehicle = m_uVehicle1[i];
				if (uVehicle.GetIFF()==m_pPlayer.GetIFF())
				{
					nPursuitCounter = (GET_DIFFICULTY_LEVEL()*30);
					m_nState = 4;
					RemoveMapSignAtMarker(markerVehicle1);
					AddMapSignAtMarker(markerDefenceFirst, signAttack,-1);
					ACHIEVE_GOAL(CaptureVehicles);
					ENABLE_GOAL(CaptureNextVehicles); 
					ENABLE_GOAL(DestroySpaceportDefence);
					ADD_BRIEFINGS(Transmision4,PROFFESOR_HEAD,ARIA_HEAD,3);
					ADD_BRIEFINGS(Transmision5,NATASHA_HEAD,ARIA_HEAD,4);
					START_BRIEFING(false);
					WaitToEndBriefing(state, 30);
					return state;
				}
			}
			return state;
		}
		
		if(m_nState==4 || m_nState==5)// ============================================================================================================================
		{
			// uwalnianie wiezniow2
			if (!bPrizoners2 && !m_pEnemy4.GetNumberOfUnits())// uwolnieni wiezniowie2
			{
					bPrizoners2 = true;
					ACHIEVE_GOAL(FreePrisoners);
					KillUnitAtMarker(29); //wysadzenie murka
					GiveAllUnitsToPlayer(m_pNeutral2,m_pPlayer);//XXXTZ
					ADD_BRIEFINGS(Transmision6,CIVIL_HEAD,ARIA_HEAD,4);
					START_BRIEFING(false);
					WaitToEndBriefing(state, 10*30);
					return state;
			}

			if(IsGoalEnabled(goalCaptureNextVehicles) && GetGoalState(goalCaptureNextVehicles)!=goalAchieved) // przejmowanie drugich pojazdow
			{
				for(i=0; i<8;i=i+1)
				{
					uVehicle = m_uVehicle2[i];
					if (uVehicle.GetIFF()==m_pPlayer.GetIFF())
					{
						ACHIEVE_GOAL(CaptureNextVehicles); 
						ADD_BRIEFINGS(Transmision9,ARIA_HEAD,PROFFESOR_HEAD,2);
						START_BRIEFING(false);
						WaitToEndBriefing(state, 30);
						return state;
					}
				}
			}
		}
		if(m_nState==4)// sprawdzanie czy obrona zniszczona ==============================================================
		{
			++nPursuitCounter;
			if(nPursuitCounter>((60*3) - (GET_DIFFICULTY_LEVEL()*30)))
			{
				nPursuitCounter=0;
				CreatePursuitGroup();
			}
			if(CheckDefence())
			{
				ACHIEVE_GOAL(DestroySpaceportDefence);
				ENABLE_GOAL(CaptureShuttle);
				RemoveMapSignAtMarker(markerDefenceFirst);
				AddMapSignAtMarker(markerShuttle, signMoveTo,-1);
				m_nState = 5;
				ADD_BRIEFINGS(Transmision7,ARIA_HEAD,NATASHA_HEAD,2);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 120*30);
			}
			return state,30;
		}		

		if(m_nState==5)// Natasha biegnie do wahadlowca==============================================================
		{
			if(IsUnitNearMarker(m_uLHero2, markerShuttle, 4))
			{
				m_nState = 15;
				ACHIEVE_GOAL(CaptureShuttle);
				ADD_BRIEFING(Transmision8_01,NATASHA_HEAD);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 30);
			}
			return state;
		}
		
		if(m_nState==15)//============================================================================================================================
		{
			SaveEndMissionGame(205,null);
			EnableInterface(false);
			ShowInterface(false);
			SetNeutrals(m_pPlayer, m_pEnemy1, m_pEnemy2, m_pEnemy3, m_pEnemy4);
			FadeInCutscene(60, 0, 0, 0);			
			m_nState=18;
			return state,60;
		}
		if(m_nState==18)
		{       
			SetWind(0, 0);SetTimer(2,0);
			EnableMessages(false);
			i = PlayCutscene("L_M5_C2.trc", true, true, true);
			return XXX, i-eFadeTime;
		}
		
		return state, 30;
	}

	state XXX
	{
		PrepareSaveUnits(m_pPlayer);
        SAVE_UNIT(Player, LHero1, eBufferLHero1);
		SAVE_UNIT(Player, LHero2, eBufferLHero2);
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
	
	event RemovedUnit(unit uKilled, unit uAttacker, int nNotifyType)
	{
		// mission failed gdy zabijemy swojego lub wieznia
		unit uTmp;

		uTmp = uKilled;
		if ( uTmp == m_uLHero1 )
		{
			SetGoalState(goalLHero1MustSurvive, goalFailed);

			LookatUnit(m_uLHero1);
			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state YYY;

			SetStateDelay(120);
		}
		if ( (uTmp == m_uLHero2) && GetGoalState(goalLHero2MustSurvive)!=goalAchieved)
		{
			SetGoalState(goalLHero2MustSurvive, goalFailed);
			LookatUnit(m_uLHero2);
			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state YYY;

			SetStateDelay(120);
		}
		if ( uTmp == m_uSebastian)
		{
			SetGoalState(goalSebastianMustSurvive, goalFailed);
			LookatUnit(m_uSebastian);
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
		if ( uKilled == m_uShuttle)
		{
			
			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state XXX;

			SetStateDelay(120);
			
		}
	}

	
    event EscapeCutscene(int nIFFNum)
    {
		int nTicks;//czas potrzebny na fadeOut
        if (state == Start || state== XXX)
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
