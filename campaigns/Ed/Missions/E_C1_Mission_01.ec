#include "..\..\defines.ech"

#define MISSION_NAME "translateE_M1"

#define WAVE_MISSION_PREFIX "ED\\M1\\E_M1_Brief_"


#define IS_TUTORIAL true
#define IS_CAMERA_LOCKED IsUserSettingsLockedCameraAngle()
#define TIME_TIP 900	
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


	consts
	{
		rangeNear       =  1;
		rangeNearUnits  = 10;
		rangeNearCrater = 16;
		rangeNearBase   = 10;
		rangeLimitRect  =  4;
		rangeNearDst    =  3;

		playerPlayer      = 2;
		playerEnemy       = 3;
		playerEnemyAlien  = 4;
		playerEnemyPatrol = 6;
		playerEnemyEscort = 7;
		playerNeutral     = 5;
		playerEnemySmall  = 8;

		goalHeroMustSurvive  = 1;
		goalFindYourSoldiers = 2;
		goalFindOasis        = 3;
		goalBuildUpABase     = 4;
		goalHarvestWater     = 5;
		goalHarvestMetal     = 6;
		goalFreePrizoners    = 7;
		goalDestroyLCBase    = 8;
		goalFindTransporter  = 9;

		briefNoWay              = 1;
		briefHandsUp            = 2;
		briefMeeting1           = 3;
		briefFindWater          = 4;
		briefPrepareYourself    = 5;
		briefPrizoners          = 6;
		briefDestroyLCBase      = 7;
		briefDestroyCrystals    = 8;
		briefDestroyTransporter = 9;

		markerEHero1             =  1;
		markerStart              =  1;
		markerMedkit			 = 10;
		markerCrater             =  2;
		markerNoWay              =  3;
		markerEnemyBaseMain      =  4;
		markerEnemyHandsUp1      =  5;
//		markerEnemyHandsUp2      =  6;
		markerMeeting1           =  7;
//		markerMeeting2           =  8;
//		markerEnemyPatrolFirst   =  9;
//		markerEnemyPatrolLast    = 21;
//		markerEnemyBase1         = 22;
//		markerEnemyBase2         = 23;
//		markerEnemyBase1Support  = 24;
//		markerEnemyBase2Support  = 25;
		markerPrisoners          = 26;
		markerPrisonersEscort    = 27;
//		markerPrisonersPathFirst = 28;
//		markerPrisonersPathLast  = 43;
//		markerCrystals1          = 44;
//		markerCrystals2          = 45;
		markerRollingStones1     = 50;
//		markerRollingStones2     = 51;
		markerCrystals1          = 52;
//		markerCrystals2          = 53;
		markerHeroGun            = 46;
		markerMetal              = 46;
		markerLaserWallFirst     = 60;
		markerLaserWallLast      = 63;
//		markerWaterStorage1      = 70;
//		markerWaterStorage2      = 71;
		markerPrisonersInfo      =  8;
		markerPrisonersInfoDst   =  9;

		markerTransporter        = 47;

		markerHarvesters         =  6;
		markerHarvestersDst      =  2;

		markerEnemyBaseAttack    =  4;
		markerEnemyBaseAttackDst =  2;

		markerLaserTower1        = 64;
		markerLaserTower2        = 65;
	}



	

    function void CustomEndPlayBriefing(int nIFFNum, int nBriefingScriptNum, int bFromEscapeClick);
    #define CUSTOM_ENDPLAYBRIEFING CustomEndPlayBriefing

	state Initialize; // musi byc ztutaj zeby od niego rozpoczal sie skrypt
	#include "..\..\dialog2.ech"

	player m_pPlayer;
	player m_pEnemy;
	player m_pEnemyAlien;
	player m_pEnemyPatrol;
	player m_pEnemyEscort;
	player m_pNeutral;
	player m_pEnemySmall;

	unit m_uEHero1;

	unit m_auMeeting1[];
	unit m_auPrisoners[];
	unit m_auPrisonersEscort[];

	unit m_auEnemyBase1Support[];
	unit m_auEnemyBase2Support[];

	unit m_auHarvesters[];

	unit m_auEnemyBaseAttack[];

	// unit m_uCrystals1;

	unit m_uTransporter;

	unit m_uGirl1;
	unit m_uGirl2;

	unit m_uLaserTower1;
	unit m_uLaserTower2;

	int m_bNoWind;
	int m_bTutorial;
	int m_bActiveF2;
	int m_nShowTips;

	state Start;
	state Tutorial_00;
	state Tutorial_01;
	state Tutorial_04;
	state Tutorial_05;
	state Tutorial_06;
	state Tutorial_07;
	state EndTutorials;
	
	state FindSoldiers;
	state HandsUp;
	state Tutorial_09;
	state Tutorial_10a;
	state Tutorial_10b;
	state Tutorial_11;
	state Tutorial_12;
	state Tutorial_13;
	state Tutorial_14;
	state Tutorial_15;

	state Tutorial_16;
	state Tutorial_17;
	state Tutorial_18;
	state Tutorial_19;
	state Tutorial_20;
	state Tutorial_21;

	state FindOasis;
	state BuildUpABase;
	state TakeOutLCWater;
	state FreePrizoners0;
	state FreePrizoners;
	state DestroyLCBase0;
	state DestroyLCBase;

	state XXX;

	int m_bBaseAttack;

	int m_nBaseAttackX;
	int m_nBaseAttackY;

	state Initialize
	{
		int i;

		INITIALIZE_PLAYER(Player     );
		INITIALIZE_PLAYER(Enemy      );
		INITIALIZE_PLAYER(EnemyAlien );
		INITIALIZE_PLAYER(EnemyPatrol);
		INITIALIZE_PLAYER(EnemyEscort);
		INITIALIZE_PLAYER(Neutral    );
		INITIALIZE_PLAYER(EnemySmall );

		m_pPlayer     .EnableAI(false);
		m_pEnemy      .EnableAI(true);		
		m_pEnemyAlien .EnableAI(false);
		m_pEnemyPatrol.EnableAI(false);
		m_pEnemyEscort.EnableAI(false);
		m_pNeutral    .EnableAI(false);
		m_pEnemySmall .EnableAI(false);
		DEACTIVATE_AI(m_pEnemy);

		SetNeutrals(m_pEnemy, m_pEnemyAlien, m_pEnemyPatrol, m_pEnemyEscort, m_pNeutral, m_pEnemySmall);
		SetNeutrals(m_pPlayer, m_pNeutral);

		SetEnemies(m_pPlayer, m_pEnemy);
		SetEnemies(m_pPlayer, m_pEnemyAlien);
		// SetEnemies(m_pPlayer, m_pEnemyPatrol);
		SetEnemies(m_pPlayer, m_pEnemyEscort);
		SetEnemies(m_pPlayer, m_pEnemySmall);

		SetNeutrals(m_pPlayer, m_pEnemyPatrol);

		REGISTER_GOAL(HeroMustSurvive );
		REGISTER_GOAL(FindYourSoldiers);
		REGISTER_GOAL(FindOasis       );
		REGISTER_GOAL(BuildUpABase    );
		REGISTER_GOAL(HarvestWater    );
		REGISTER_GOAL(HarvestMetal    );
		REGISTER_GOAL(FreePrizoners   );
		REGISTER_GOAL(DestroyLCBase   );
		REGISTER_GOAL(FindTransporter );

		INITIALIZE_UNIT(Transporter);

		INITIALIZE_UNIT(LaserTower1);
		INITIALIZE_UNIT(LaserTower2);

		CREATE_UNIT(Player, EHero1, "E_HERO_01");

		CREATE_UNITS_ARR(Neutral, Meeting1, "E_IN_MA_01_1", 6);

		CREATE_UNITS_ARR(Neutral, Prisoners, "E_IN_MA_01_1", 6);

		SetExperienceLevel(m_auPrisoners, 6);

		CREATE_UNITS_ARR(EnemyEscort, PrisonersEscort, "L_IN_RG_01_1", 4);
		CREATE_UNITS_ARR(EnemyEscort, PrisonersEscort, "L_CH_GJ_02_1#L_WP_PG_02_1,L_AR_CL_02_1,L_EN_SP_02_1", 2);
		CREATE_UNITS_ARR(EnemyEscort, PrisonersEscort, "L_CH_GJ_02_1#L_WP_SG_02_1,L_AR_CL_02_1,L_EN_NO_02_1", 2);

		m_auEnemyBase1Support.Create(0);
		m_auEnemyBase2Support.Create(0);

		m_auHarvesters.Create(0);

		m_auEnemyBaseAttack.Create(0);

		for ( i = 100; i < 200; ++i )
		{
			if ( HaveMarker(i) )
			{
				CreatePlayerObjectAtMarker(m_pEnemyPatrol, "L_IN_RG_01_1", i);
				CreatePlayerObjectAtMarker(m_pEnemyPatrol, "L_IN_RG_01_1", i);
				CreatePlayerObjectAtMarker(m_pEnemyPatrol, "L_IN_RG_01_1", i);

				if ( SendCampaignEventGetDifficultyLevel() > 0 ) 
				{
					CreatePlayerObjectAtMarker(m_pEnemyPatrol, "L_IN_RG_01_1", i);
					CreatePlayerObjectAtMarker(m_pEnemyPatrol, "L_IN_RG_01_1", i);
				}
				if ( SendCampaignEventGetDifficultyLevel() > 1 ) 
				{
					CreatePlayerObjectAtMarker(m_pEnemyPatrol, "L_IN_RG_01_1", i);
					CreatePlayerObjectAtMarker(m_pEnemyPatrol, "L_IN_RG_01_1", i);
				}
			}
		}

		if(!GET_DIFFICULTY_LEVEL())
		{
			RemoveUnitAtMarker(19);
			RemoveUnitAtPoint(79,45);
		}

		m_uGirl1 = CreatePlayerObjectAtMarker(m_pEnemyPatrol, "L_IN_RG_01_1", markerEnemyHandsUp1);
		m_uGirl2 = CreatePlayerObjectAtMarker(m_pEnemyPatrol, "L_IN_RG_01_1", markerEnemyHandsUp1);

//		CreatePlayerObjectAtMarker(m_pEnemyPatrol, "L_IN_RG_01_1", markerEnemyHandsUp2);
//		CreatePlayerObjectAtMarker(m_pEnemyPatrol, "L_IN_RG_01_1", markerEnemyHandsUp2);

		LookAtUnit(m_uEHero1);

		
		SetPlayerTemplateseEDCampaign(m_pPlayer, 1);
		SetPlayerResearchesEDCampaign(m_pPlayer, 1);
		SetEnemyResearchesEDCampaign(m_pEnemy, 1);
				
		SetTimer(1, 90);//transporter - 3 sekundy

		SetWind(30, 100);
		SetTimer(2, 2*60*30);

		SetTimer(3, 2*60*30);
		SetTimer(4, 30*30);

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
		
		i = PlayCutscene("E_M1_C1.trc", true, true, true)-5;

		return Start,i;
	}

		

int nStart;
	state Start
	{
		int nGx, nGy;
		nStart=1;
		ADD_BRIEFING(Start, IGOR_HEAD)
		START_BRIEFING(true);
		
		if(IS_TUTORIAL)
		{
			GetMarker(markerStart, nGx, nGy);
			SetLimitedGameRect(nGx-rangeLimitRect, nGy-rangeLimitRect, nGx+rangeLimitRect+4, nGy+rangeLimitRect);
            WaitToEndBriefing(Tutorial_00, 100);
            return state;
		}
		else
		{
			SetLimitedGameRect(12, 13);
			EnableGoal(goalHeroMustSurvive, true, false);
			ENABLE_GOAL(FindYourSoldiers);
			AddMapSignAtMarker(markerMeeting1, signMoveTo, -1);
            WaitToEndBriefing(FindSoldiers, 100);
            return state;
		}
	}
	
	state Tutorial_00
	{
		if (  !m_uEHero1.IsSelected() )
		{
			PLAY_BRIEFING_TUTORIAL(01,  600, false); //select hero

			return Tutorial_01, 0;
		}
		else
		{
			PLAY_BRIEFING_TUTORIAL(04,  600, false); // move to the medkit

			return Tutorial_04, 0;
		}
	}

	state Tutorial_01
	{	
		if ( m_uEHero1.IsSelected() )
		{
			PLAY_BRIEFING_TUTORIAL(04,  600, false);//move to the medkit

			return Tutorial_04, 0;
		}

		return Tutorial_01, 1;
	}

	int m_nCameraZ;

	state Tutorial_04
	{
		if (IsUnitNearMarker(m_uEHero1, markerMedkit, 1))
		{
			PLAY_BRIEFING_TUTORIAL(05,  300, false);

			m_nCameraZ = -1;

			return Tutorial_05, 0;
		}

		return Tutorial_04, 1;
	}

	int m_nCameraX;
	int m_nCameraY;

	state Tutorial_05
	{
		int x, y, z, a, va;

		GetCameraPos(x, y, true, z, a, va);

		if ( m_nCameraZ == -1 )
		{
			m_nCameraZ = z;
		}
		else if ( z != m_nCameraZ )
		{
			PLAY_BRIEFING_TUTORIAL(06,  300, false);

			m_nCameraX = -1;
			m_nCameraY = -1;

			return Tutorial_06, 0;
		}

		return Tutorial_05, 1;
	}

	int m_nCameraAlpha;

	state Tutorial_06
	{
		int x, y, z, a, va;

		GetCameraPos(x, y, true, z, a, va);

		if ( m_nCameraX == -1 || m_nCameraY == -1 )
		{
			m_nCameraX = x;
			m_nCameraY = y;
		}
		else if ( x != m_nCameraX || y != m_nCameraY )
		{

			if(IS_CAMERA_LOCKED)
			{
				return EndTutorials, 30;
			}
			else
			{
			PLAY_BRIEFING_TUTORIAL(07,  300, false);

			m_nCameraAlpha = -1;

			return Tutorial_07, 0;
			}
		}

		return Tutorial_06, 1;
	}

	state Tutorial_07
	{
		int x, y, z, a, va;

		GetCameraPos(x, y, true, z, a, va);

		if ( m_nCameraAlpha == -1 )
		{
			m_nCameraAlpha = a;
		}
		else if ( a != m_nCameraAlpha )
		{
			m_nCameraAlpha = 0;
			return EndTutorials, 30;
		}

		return Tutorial_07, 1;
	}

	
	state EndTutorials
	{
		if(m_nCameraAlpha==0)
		{
			SetBlinkScreenButtonsDialogButton(1, true);
			SetLimitedGameRect(12, 13);
			EnableGoal(goalHeroMustSurvive,true,false);
			EnableGoal(goalFindYourSoldiers,true,false);
			AddMapSignAtMarker(markerMeeting1, signMoveTo, -1);
			m_nCameraAlpha = 1;
			return EndTutorials, 10;
		}
		else
		{
			PLAY_BRIEFING_TUTORIAL(08,  300, false);
			return FindSoldiers, 300;
		}
	}
	
	int m_bTutorial_09;

	
	int m_bHandsUp;

	int m_bTutorial_30;

	state FindSoldiers
	{
		unit uUnit;
		if ( !m_bHandsUp )
		{
			if ( IsUnitNearMarker(m_uEHero1, markerEnemyHandsUp1, rangeNearUnits) )
			{
				CLEAR_TUTORIAL();
				SetBlinkScreenButtonsDialogButton(1, false);
				m_bHandsUp = true;
				PLAY_BRIEFING(HandsUp, LC_GIRL_HEAD, false);

				m_pPlayer.SetEnemy(m_pEnemyPatrol);
				m_uEHero1.CommandStop();
                WaitToEndBriefing(HandsUp, 0);
				return state;
			}
		}
		else if ( !m_uGirl1.IsLive() && !m_uGirl2.IsLive() )
		{
			if ( IsUnitNearMarker(m_uEHero1, markerEnemyHandsUp1, rangeNearDst) )
			{
				if ( !m_bTutorial_30 )
				{
					PLAY_BRIEFING_TUTORIAL(30,  300, false);
					m_bTutorial_30 = true;
					return FindSoldiers;
				}
			}
		}
		if ( IsUnitNearMarker(m_uEHero1, markerMeeting1, 18) )
		{
			CLEAR_TUTORIAL();
		}
		if ( IsUnitNearMarker(m_uEHero1, markerMeeting1, rangeNearUnits) )
		{
			CLEAR_TUTORIAL();
			uUnit = m_auMeeting1[0];

			CommandMoveUnitToUnit(uUnit, m_uEHero1);

			m_uEHero1.CommandStop();

			RemoveMapSignAtMarker(markerMeeting1);


			ADD_BRIEFING(Meeting1_1, ED_SOLDIER_HEAD);
			ADD_BRIEFING(Meeting1_2, IGOR_HEAD);
			ADD_BRIEFING(Meeting1_3, ED_SOLDIER_HEAD);
			ADD_BRIEFING(Meeting1_4, IGOR_HEAD);
			START_BRIEFING(true);

			SetPlayer(m_auMeeting1, m_pPlayer);

			m_auMeeting1.Add(m_uEHero1);


			return Tutorial_10a, 1050;
		}

		return FindSoldiers;
	}

	state HandsUp
	{
		if ( !m_bTutorial_09 )
		{
			PLAY_BRIEFING_TUTORIAL(09,  300, false);
			m_bTutorial_09 = true;
		}

		if ( m_uGirl1.GetHP() < m_uGirl1.GetMaxHP() || m_uGirl2.GetHP() < m_uGirl2.GetMaxHP() || IsUnitNearMarker(m_uEHero1, markerEnemyHandsUp1, 4) )
		{
			SetEnemies(m_pPlayer, m_pEnemyPatrol);

			m_uGirl1.CommandAttack(m_uEHero1);
			m_uGirl2.CommandAttack(m_uEHero1);

			return FindSoldiers;
		}

		return HandsUp, 5;
	}

	state Tutorial_09
	{
	}

	function void SetLimitedGameRect(unit auUnit[])
	{
		int i, nGx, nGy;

		unit uUnit;

		int nGxMin, nGxMax;
		int nGyMin, nGyMax;

		uUnit = auUnit[0];

		uUnit.GetLocationG(nGxMin, nGyMin);
		uUnit.GetLocationG(nGxMax, nGyMax);

		for ( i=1; i<auUnit.GetSize(); ++i )
		{
			uUnit = auUnit[i];

			uUnit.GetLocationG(nGx, nGy);

			if ( nGx < nGxMin ) nGxMin = nGx;
			if ( nGy < nGyMin ) nGyMin = nGy;

			if ( nGx > nGxMax ) nGxMax = nGx;
			if ( nGy > nGyMax ) nGyMax = nGy;
		}

		SetLimitedGameRect(nGxMin-rangeLimitRect, nGyMin-rangeLimitRect, nGxMax+rangeLimitRect, nGyMax+rangeLimitRect);
	}

	state Tutorial_10a
	{
		PLAY_BRIEFING_TUTORIAL(10,  300, false); //select units

		SetLimitedGameRect(m_auMeeting1);

		return Tutorial_10b, 0;
	}

	state Tutorial_10b
	{
		if ( GetSelectedObjectsCount() > 1 )
		{
			PLAY_BRIEFING_TUTORIAL(11,  300, false); // move selected units

			return Tutorial_11, 0;
		}

		return Tutorial_10b, 1;
	}

	// int m_nSelectedUnits;
	// int m_nSelectedSince;

	state Tutorial_11  
	{
		int i;

		unit uUnit;

		if ( GetSelectedObjectsCount() <= 1 )
		{
			PLAY_BRIEFING_TUTORIAL(10,  300, false);

			return Tutorial_10b, 0;
		}

		for ( i=0; i<m_pPlayer.GetNumberOfUnits(); ++i )
		{
			uUnit = m_pPlayer.GetUnit(i);

			if ( uUnit.IsSelected() && !uUnit.IsMoving() )
			{
				return Tutorial_11, 1;
			}
		}

		

		// ClearSelection();

		// m_nSelectedUnits = -1;

		if ( GetSelectedObjectsCount() < 2 )
			PLAY_BRIEFING_TUTORIAL(12,  300, false);
			
		return Tutorial_12, 0;
	}

	state Tutorial_12
	{
		int i;

		unit uUnit;

		if ( GetSelectedObjectsCount() > 1 )
		{
			PLAY_BRIEFING_TUTORIAL(13,  300, false); // ctrl +1

			for ( i=0; i<m_pPlayer.GetNumberOfUnits(); ++i )
			{
				uUnit = m_pPlayer.GetUnit(i);

				uUnit.SetGroupNum(-1);
			}

			return Tutorial_13, 0;
		}

		return Tutorial_12, 1;
	}

	int m_nGroupNum;

	state Tutorial_13
	{
		int i;

		unit uUnit;

		if ( GetSelectedObjectsCount() < 2 )
		{
			PLAY_BRIEFING_TUTORIAL(12,  300, false);

			return Tutorial_12, 1;
		}

		for ( i=0; i<m_pPlayer.GetNumberOfUnits(); ++i )
		{
			uUnit = m_pPlayer.GetUnit(i);

			if ( uUnit.IsSelected() && uUnit.GetGroupNum() != -1 )
			{
				PLAY_BRIEFING_TUTORIAL(14,  300, false);// press 1

				m_nGroupNum = uUnit.GetGroupNum();

				ClearSelection();

				return Tutorial_14, 0;
			}
		}

		return Tutorial_13, 1;
	}

	state Tutorial_14
	{
		int i;

		unit uUnit;

		if ( GetSelectedObjectsCount() > 0 )
		{
			for ( i=0; i<m_pPlayer.GetNumberOfUnits(); ++i )
			{
				uUnit = m_pPlayer.GetUnit(i);

				if ( uUnit.IsSelected() && uUnit.GetGroupNum() == m_nGroupNum )
				{
					PLAY_BRIEFING_TUTORIAL(15,  300, false); // move

					// ClearLimitedGameRect();

					SetLimitedGameRect(14, 15);
					
					SetGoalState(goalFindYourSoldiers, goalAchieved, false);
					ENABLE_GOAL(FindOasis);
					AddMapSignAtMarker(markerCrater, signMoveTo, -1);

					return Tutorial_15, 450;
				}
			}
		}
		return Tutorial_14, 1;
	}

	state Tutorial_15
	{
		
		CLEAR_TUTORIAL();
		nStart = 0;
		return Tutorial_16, 0;
	}

	int m_bCrystals;

	state Tutorial_16
	{
		int i;
		unit uUnit;
		if ( !m_bCrystals && IsAnyOfUnitsNearMarker(m_auMeeting1, markerRollingStones1, rangeNearDst) )
		{
			CLEAR_TUTORIAL();

			ADD_BRIEFING(Avalanche_1, IGOR_HEAD)
			START_BRIEFING(false);

			m_bCrystals = true;
		}

		if ( IsAnyOfUnitsNearMarker(m_auMeeting1, 16, rangeNearDst) )
		{
			PLAY_BRIEFING_TUTORIAL(17,  300, false);

			for ( i=0; i<m_pPlayer.GetNumberOfUnits(); ++i )
			{
				uUnit = m_pPlayer.GetUnit(i);
				uUnit.CommandStop();
			}
			SetLimitedGameRect(m_auMeeting1);
			ADD_BRIEFING(Beware_1, IGOR_HEAD);
			START_BRIEFING(false);
            WaitToEndBriefing(Tutorial_17, 0);
            return state;
		}

		return Tutorial_16;
	}


	state Tutorial_17
	{
		
		if ( GetSelectedObjectsCount() > 0 && IsCommandsDialogOpen() )
		{
			PLAY_BRIEFING_TUTORIAL(18,  300, false);

			SetBlinkCommandsDialogButton(eCommandSetCrawlMode, true);

			return Tutorial_18, 30000;
		}
	}

	state Tutorial_18
	{
		SetBlinkCommandsDialogButton(eCommandSetCrawlMode, false);

		PLAY_BRIEFING_TUTORIAL(19,  300, false);

		SetBlinkCommandsDialogButton(eCommandSetMovementMode, true);

		return Tutorial_19, 30000;
	}

	state Tutorial_19
	{
		SetBlinkCommandsDialogButton(eCommandSetMovementMode, false);

		PLAY_BRIEFING_TUTORIAL(20,  300, false);

		SetBlinkCommandsDialogButton(eCommandSetAttackMode, true);

		return Tutorial_20, 30000;
	}

	state Tutorial_20
	{
		SetBlinkCommandsDialogButton(eCommandSetAttackMode, false);

		PLAY_BRIEFING_TUTORIAL(21,  300, false);

		SetBlinkCommandsDialogButton(eCommandSetAccuracyMode, true);

		return Tutorial_21, 30000;
	}

	state Tutorial_21
	{
		SetConsoleText("");

		SetBlinkCommandsDialogButton(eCommandSetAccuracyMode, false);

		SetLimitedGameRect(14, 15);

		return FindOasis;
	}

//	int m_bCrystals;

	int m_nLastWater;
	int m_nLastMetal;

	state FindOasis
	{
		if ( IsAnyOfUnitsNearMarker(m_auMeeting1, markerCrater, rangeNearCrater) )
		{

			m_pPlayer.EnableBuilding("E_BL_CC_01"   , true);
		
			RemoveMapSignAtMarker(markerCrater);
			SetGoalState(goalFindOasis, goalAchieved, false);
			EnableGoal(goalBuildUpABase,true,false);

			m_nLastMetal = 5000;
			m_nLastWater = 1700;

			m_pPlayer.AddResource(1, m_nLastMetal);
			m_pPlayer.AddResource(2, m_nLastWater);

			m_pPlayer.SetBuildBuildingsTimeMultiplyPercent(50);
			m_pPlayer.SetResearchTimeMultiplyPercent(50);

			ClearLimitedGameRect();

			SetInterfaceOptions(
				eNoConstructorDialog |
				eNoResearchCenterDialog |
				eNoBuildingUpgradeDialog |
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
			ADD_BRIEFING(BuildTheBase_1, TIMUR_HEAD);
            START_BRIEFING(false);
            WaitToEndBriefing(BuildUpABase, 0);
			return state;
		}

		return FindOasis;
	}

	int m_nHarvestersStep;

	function int IsHarvestingWater()
	{
		int nWater;

		nWater = m_pPlayer.GetResource(2, true, true);
		
		if ( nWater > m_nLastWater )
		{
			m_nLastWater = nWater;

			return true;
		}

		m_nLastWater = nWater;

		return false;
	}

	function int IsHarvestingMetal()
	{
		int nMetal;

		nMetal = m_pPlayer.GetResource(1, true, true);

		if ( nMetal > m_nLastMetal )
		{
			m_nLastMetal = nMetal;

			return true;
		}

		m_nLastMetal = nMetal;

		return false;
	}

	int buildStep;
	
	state BuildUpABase
	{
		
		
		if(!buildStep)
		{
			PLAY_BRIEFING_TUTORIAL(22,  300, false);
			buildStep=1;
		}
		if(buildStep==1 && m_pPlayer.GetNumberOfBuildings()>0)
		{
			m_pPlayer.EnableBuilding("E_BL_EG_02"   , true);
			PLAY_BRIEFING_TUTORIAL(23,  300, false);
			buildStep=2;
		}
		if(buildStep==2 && m_pPlayer.GetNumberOfBuildings("E_BL_EG_02")>1)
		{
			m_pPlayer.EnableBuilding("E_BL_ST_05"   , true);
			PLAY_BRIEFING_TUTORIAL(24,  300, false);
			buildStep=3;
		}
		if(buildStep==3 && m_pPlayer.GetNumberOfBuildings("E_BL_ST_05")>0)
		{
			m_pPlayer.EnableBuilding("E_BL_EX_03"   , true);
			PLAY_BRIEFING_TUTORIAL(25,  300, false);
			buildStep=4;
		}
		
		if(buildStep==4 && m_pPlayer.GetNumberOfBuildings("E_BL_EX_03")>0)
		{
			m_pPlayer.EnableBuilding("E_BL_IF_06"   , true);
			PLAY_BRIEFING_TUTORIAL(26,  300, false);
			buildStep=5;
		}
		if(buildStep==5 && m_pPlayer.GetNumberOfBuildings("E_BL_IF_06")>0)
		{
			m_pPlayer.EnableBuilding("E_BL_UF_07"   , true);
			PLAY_BRIEFING_TUTORIAL(27,  300, false);
			buildStep=6;
		}
		if(buildStep==6 && m_pPlayer.GetNumberOfBuildings("E_BL_UF_07")>0)
		{
			CLEAR_TUTORIAL();
			m_pPlayer.SetBuildBuildingsTimeMultiplyPercent(100);
			m_pPlayer.EnableBuilding("E_BL_AC_08"   , true);
			m_pPlayer.EnableBuilding("E_BL_TC_09"   , true);



			m_pPlayer.EnableBuilding("E_BL_CA_04_1" , true);
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
			m_pPlayer.EnableBuilding("E_BL_WC_14_1" , true);
		
			SetGoalState(goalBuildUpABase, goalAchieved, false);
			buildStep=7;
			return state;
		}
		if((buildStep==7) && (GetGoalState(goalHarvestWater) == goalAchieved) && (GetGoalState(goalHarvestMetal) == goalAchieved))
		{
			return TakeOutLCWater, 300;
		}

		if ( m_nHarvestersStep == 0 && m_pPlayer.GetNumberOfBuildings() >= 1 )
		{
			if ( m_auHarvesters.GetSize() == 0 )
			{
				CREATE_UNITS_ARR(Player, Harvesters, "E_CH_AH_12", 2);

				CommandMoveUnitsToMarker(m_auHarvesters, markerHarvestersDst);
			}
			else if ( IsAnyOfUnitsNearMarker(m_auHarvesters, markerHarvestersDst, rangeNearCrater) )
			{
				ADD_BRIEFING(HarvestWater_1, TIMUR_HEAD);
				ADD_BRIEFING(HarvestWater_2, IGOR_HEAD);
				START_BRIEFING(false);

				EnableGoal(goalHarvestWater, true);

				++m_nHarvestersStep;
			}
		}

		if ( IsGoalEnabled(goalHarvestWater) && GetGoalState(goalHarvestWater) == goalNotAchieved )
		{
			if ( IsHarvestingWater() )
			{
				SetGoalState(goalHarvestWater, goalAchieved, false);

				ADD_BRIEFING(PrepareDefence_1, TIMUR_HEAD);
				START_BRIEFING(false);

				m_uEHero1.GetLocation(m_nBaseAttackX, m_nBaseAttackY);

				m_bBaseAttack = true;
			}
		}

		if ( IsGoalEnabled(goalHarvestMetal) && GetGoalState(goalHarvestMetal) == goalNotAchieved )
		{
			if ( IsHarvestingMetal() )
			{
				SetGoalState(goalHarvestMetal, goalAchieved, false);
				RemoveMapSignAtMarker(markerMetal);
			}
		}

		if ( !IsGoalEnabled(goalHarvestMetal) && m_pPlayer.GetResource(1, true, true) < 200 )
		{
			ADD_BRIEFING(HarvestMetal_1, TIMUR_HEAD);
			ADD_BRIEFING(HarvestMetal_2, IGOR_HEAD);
			START_BRIEFING(false);

			AddMapSignAtMarker(markerMetal, signMoveTo, -1);

			EnableGoal(goalHarvestMetal, true);
		}

		if ( IsUnitNearMarker(m_uEHero1, markerEnemyBaseAttackDst, rangeNearBase) )
		{
			m_uEHero1.GetLocation(m_nBaseAttackX, m_nBaseAttackY);
		}

		return BuildUpABase;
	}

	int m_nTimer1;
	int m_nTimer2;

	state TakeOutLCWater
	{
		unit uUnit;
			ENABLE_GOAL(FreePrizoners);

			ADD_BRIEFING(Prizoners_1, ED_SOLDIER_HEAD);
			ADD_BRIEFING(Prizoners_2, IGOR_HEAD);
			ADD_BRIEFING(Prizoners_3, ED_SOLDIER_HEAD);
			ADD_BRIEFING(Prizoners_4, IGOR_HEAD);
			START_BRIEFING(false);

			AddMapSignAtMarker(markerPrisoners, signMoveTo, -1);

			uUnit = CreatePlayerObjectAtMarker(m_pPlayer, "E_IN_MA_01_1", markerPrisonersInfo);

			CommandMoveUnitToMarker(uUnit, markerPrisonersInfoDst);

			SetAlly(m_pPlayer, m_pNeutral);

			return FreePrizoners0, 90*30;
	}

	state FreePrizoners0
	{
		if ( m_uTransporter.IsLive() )
		{
			ADD_BRIEFING(DestroyTransporter_1, TIMUR_HEAD);
			START_BRIEFING(false);

			ENABLE_GOAL(FindTransporter);

			AddMapSignAtMarker(markerTransporter, signAttack, -1);
			
		}
		m_nShowTips = 1;
		return FreePrizoners, 400;
	}
	
	state FreePrizoners
	{
		int i;

		
		if ( m_pEnemyEscort.GetNumberOfUnits() == 0 && !m_uLaserTower1.IsLive() && !m_uLaserTower2.IsLive() )
		{
			for ( i=markerLaserWallFirst; i<=markerLaserWallLast; ++i )
			{
				if ( GetUnitAtMarker(i) == null )
				{
					SetGoalState(goalFreePrizoners, goalAchieved);

					RemoveMapSignAtMarker(markerPrisoners);

					SetPlayer(m_auPrisoners, m_pPlayer);

					ADD_BRIEFING(Prizoners2_1, ED_SOLDIER_HEAD);
					ADD_BRIEFING(Prizoners2_2, IGOR_HEAD);
					ADD_BRIEFING(Prizoners2_3, TIMUR_HEAD);
					ADD_BRIEFING(Prizoners2_4, IGOR_HEAD);
					START_BRIEFING(false);

					return DestroyLCBase0, 2000;
				}
			}
		}

		/*
		if ( m_pEnemyEscort.GetNumberOfUnits() == 0 )
		{
		}
		*/

		return FreePrizoners;
	}

	state DestroyLCBase0
	{
		ADD_BRIEFING(DestroyLCBase_1, TIMUR_HEAD);
		ADD_BRIEFING(DestroyLCBase_2, IGOR_HEAD);
		START_BRIEFING(false);

		ENABLE_GOAL(DestroyLCBase);

		AddMapSignAtMarker(markerEnemyBaseMain, signAttack, -1);

		m_nShowTips=10;

		m_bBaseAttack = false;
		ActivateAI(m_pEnemy);
		m_pEnemy.SetAIControlOptions(eAIControlBuildBase, false);
		return DestroyLCBase, 300;
	}
state StartCutscene;
	state DestroyLCBase
	{

		if ( m_pEnemy.GetNumberOfBuildings() <= m_pEnemy.GetNumberOfBuildings(eBuildingLaserWall)+2 )
		{
			SetGoalState(goalDestroyLCBase, goalAchieved);
			RemoveMapSignAtMarker(markerEnemyBaseMain);
			SetWind(0,0);
			m_bNoWind=true;
			SaveEndMissionGame(101,null);
			return StartCutscene, 1;

		}

		return DestroyLCBase;
	}

	state StartCutscene
	{
		int nTicks;
		EnableMessages(false);
		nTicks = PlayCutscene("E_M1_C2.trc", true, true, true);
		return XXX, nTicks-eFadeTime;
	}
	state XXX
	{
        PrepareSaveUnits(m_pPlayer);
        SAVE_UNIT(Player, EHero1, eBufferEHero1);
        SaveBestInfantry(m_pPlayer, 12-(GET_DIFFICULTY_LEVEL()*3));
		EndMission(true);
	}
	state YYY
	{
		MissionDefeat();
	}
	// int m_bHeroGun;
int bResTutorial;
int bBombTutorial;
	event Timer1()
	{

		if(!bResTutorial && m_pPlayer.IsResearchResearched("RES_E_TCH_AR_01_1"))
		{
			SetInterfaceOptions(
				//eNoConstructorDialog |
				//eNoResearchCenterDialog |
				eNoBuildingUpgradeDialog |
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

			bResTutorial = true;
			m_nShowTips = 30;
		}
		if ( IsGoalEnabled(goalFindTransporter) && GetGoalState(goalFindTransporter) == goalNotAchieved )
		{
			if ( !m_uTransporter.IsLive() )
			{
				SetGoalState(goalFindTransporter, goalAchieved);
				RemoveMapSignAtMarker(markerTransporter);
			}
			else
			if(!bBombTutorial)
			{
				if (IsUnitNearMarker(m_uEHero1, 47, 8))  //XXX
				{
					m_nShowTips = 20; //- tip o bombach
					bBombTutorial = true;
				}
			}
		}
	}

	event Timer2()
	{
		if(m_bNoWind)SetWind(0,0);
		else
			SetWind(Rand(100),Rand(255));
	}

	event Timer3()
	{
		int i;

		unit uUnit;

		if ( m_bBaseAttack )
		{
			for ( i = 0; i < m_auEnemyBaseAttack.GetSize(); ++i )
			{
				uUnit = m_auEnemyBaseAttack[i];

				if ( uUnit == null || !uUnit.IsLive() )
				{
					m_auEnemyBaseAttack.RemoveAt(i);

					--i;
				}
			}

			if ( m_auEnemyBaseAttack.GetSize() < 32 )
			{
				CREATE_UNITS_ARR(Enemy, EnemyBaseAttack, "L_IN_RG_01_1", 6);

				CommandMoveAttackUnitsToPoint(m_auEnemyBaseAttack, m_nBaseAttackX, m_nBaseAttackY);
				//CommandMoveUnitsToMarker(m_auEnemyBaseAttack, markerEnemyBaseAttackDst);
			}
		}
	}
	event Timer4()
	{
		if(!m_nShowTips) return;

		++m_nShowTips;
		CLEAR_TUTORIAL();
		if(m_nShowTips==2)
			PLAY_TIMED_BRIEFING_TUTORIAL(35,  TIME_TIP, false);// train soldiers

		if(m_nShowTips==4)
			PLAY_TIMED_BRIEFING_TUTORIAL(36,  TIME_TIP, false);// build vehicles

		if(m_nShowTips==8 && m_pPlayer.GetNumberOfBuildings("E_BL_TC_09")==0)
			PLAY_TIMED_BRIEFING_TUTORIAL(28,  TIME_TIP, false);// build res center

		if(m_nShowTips==9)
		{
			if(m_pPlayer.GetNumberOfBuildings("E_BL_TC_09")>0)
			{
				SetInterfaceOptions(
				eNoConstructorDialog |
				//eNoResearchCenterDialog |
				eNoBuildingUpgradeDialog |
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

				PLAY_TIMED_BRIEFING_TUTORIAL(29,  300, false);
			}
			else
			{
				m_nShowTips=8; // czekamy na zbudowanie Res Centra
			}
		}
		if(m_nShowTips==10)m_nShowTips=0;// koniec  tipw
		
		if(m_nShowTips==15)
		{
			PLAY_TIMED_BRIEFING_TUTORIAL(34,  TIME_TIP, false);// build res center
			m_nShowTips=0;// koniec  tipw
		}


		if(m_nShowTips==21)
		{
			PLAY_TIMED_BRIEFING_TUTORIAL(33,  TIME_TIP, false);// use bombs
			m_nShowTips=0;// koniec  tipw
		}

		if(m_nShowTips==31)
			PLAY_TIMED_BRIEFING_TUTORIAL(31,  TIME_TIP, false);// rocket technology invented
		if(m_nShowTips==33  && m_pPlayer.GetNumberOfBuildings("E_BL_AC_08")==0)
		{
			PLAY_TIMED_BRIEFING_TUTORIAL(32,  TIME_TIP, false);// build ammo supply
			m_nShowTips=0;// koniec  tipw
		}


	}

	event EndMission(int nResult)
	{
	}
	
	event RemovedUnit(unit uKilled, unit uAttacker, int nNotifyType)
	{
		// mission failed gdy zabijemy swojego lub wieznia
		if((nStart==1 && uKilled.GetIFF()== uAttacker.GetIFF()) ||
			(nStart==0 && uKilled.GetIFF()==m_pNeutral.GetIFF() && uAttacker.GetIFF() == m_pPlayer.GetIFF())) 
		{
			CLEAR_TUTORIAL();
			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state YYY;

			SetStateDelay(120);
		}
		
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
	}

	int m_bBrief;

	event RemovedBuilding(unit uKilled, unit uAttacker, int nNotifyType)
	{
		int bPlayBrief;

		if ( uKilled.GetIFFNum() == m_pEnemy.GetIFFNum() )
		{
			m_bBaseAttack = false;
		}

		/*
		if ( IsUnitNearMarker(uKilled, markerEnemyBase1, rangeNearBase) && m_auEnemyBase1Support.GetSize() == 0 )
		{
			CREATE_UNITS_ARR(Enemy, EnemyBase1Support, "L_IN_RG_01_1", 8);
			CREATE_UNITS_ARR(Enemy, EnemyBase1Support, "L_CH_GJ_02_1#L_WP_SG_02_1,L_AR_CL_02_1,L_EN_NO_02_1", 2);
			CREATE_UNITS_ARR(Enemy, EnemyBase1Support, "L_CH_GJ_02_1#L_WP_PG_02_1,L_AR_CL_02_1,L_EN_SP_02_1", 1);

			m_nTimer1 = 0;

			if ( !m_bBrief ) bPlayBrief = true;
		}

		if ( IsUnitNearMarker(uKilled, markerEnemyBase2, rangeNearBase) && m_auEnemyBase2Support.GetSize() == 0 )
		{
			CREATE_UNITS_ARR(Enemy, EnemyBase2Support, "L_IN_RG_01_1", 8);
			CREATE_UNITS_ARR(Enemy, EnemyBase2Support, "L_CH_GJ_02_1#L_WP_SG_02_1,L_AR_CL_02_1,L_EN_NO_02_1", 2);
			CREATE_UNITS_ARR(Enemy, EnemyBase2Support, "L_CH_GJ_02_1#L_WP_PG_02_1,L_AR_CL_02_1,L_EN_SP_02_1", 1);

			m_nTimer2 = 0;

			if ( !m_bBrief ) bPlayBrief = true;
		}

		if ( bPlayBrief )
		{
			ADD_BRIEFING(PrepareYourself_1, TIMUR_HEAD);
			ADD_BRIEFING(PrepareYourself_2, IGOR_HEAD);
			ADD_BRIEFING(PrepareYourself_3, IGOR_HEAD);
			START_BRIEFING(false);

			m_bBrief = true;
		}

		if ( IsGoalEnabled(goalTakeOutLCWater) && GetGoalState(goalTakeOutLCWater) == goalNotAchieved )
		{
			if ( m_pEnemySmall.GetNumberOfBuildings() < 4 )
			{
				SetGoalState(goalTakeOutLCWater, goalAchieved);

				RemoveMapSignAtMarker(markerWaterStorage1);
				RemoveMapSignAtMarker(markerWaterStorage2);
			}
		}
		*/
	}

	event AddedBuilding(unit uCreated, int nNotifyType)
	{
			if(!m_bActiveF2 && m_pPlayer.GetNumberOfBuildings("E_BL_TC_09")>0)
			{
			m_bActiveF2=true;
			SetInterfaceOptions(
				eNoConstructorDialog |
				//eNoResearchCenterDialog |
				eNoBuildingUpgradeDialog |
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
			}

//		if ( IsGoalEnabled(goalBuildUpABase) && GetGoalState(goalBuildUpABase) == goalNotAchieved )
//		{
//			if ( m_pPlayer.GetNumberOfBuildings(eBuildingPowerPlant) >= 2 && m_pPlayer.GetNumberOfBuildings(eBuildingUnitsExit) >= 1 && m_pPlayer.GetNumberOfBuildings(eBuildingObjectsFactory) >= 2 )
//			{
//				SetGoalState(goalBuildUpABase, goalAchieved, false);
//			}
//		}

		
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

	event DebugEndMission()
	{
		state XXX;
        SetStateDelay(30);
	}
    event DebugCommand(string pszCommand)
    {
        string strCommand;
        strCommand = pszCommand;
        if (!strCommand.CompareNoCase("x1"))
        {
            state Tutorial_17;
        }
	}

	event InterfaceClickBlinkCommandsDialogButton(int nCommand)
	{
		TRACE2("nCommand =", nCommand);

        SetStateDelay(30);
	}

	event InterfaceClickBlinkScreenButtonsDialogButton(int nButton)
	{
		if(nButton==1 && state==FindSoldiers)
		{
			SetBlinkScreenButtonsDialogButton(1, false);
			CLEAR_TUTORIAL();
		}
	}
	function void CustomEndPlayBriefing(int nIFFNum, int nBriefingScriptNum, int bFromEscapeClick)
	{
		if ( state != Tutorial_18 && state != Tutorial_19 && state != Tutorial_20 && state != Tutorial_21 && state != DestroyLCBase0 && state != FreePrizoners0 )
		{
			if ( bFromEscapeClick )
			{
				SetStateDelay(20);
			}
		}
	}
}
