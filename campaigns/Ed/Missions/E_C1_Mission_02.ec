#include "..\..\defines.ech"


#define MISSION_NAME "translateE_M2"




#define MISSION_GOAL_PREFIX     MISSION_NAME "_Goal_"
#define MISSION_BRIEFING_PREFIX MISSION_NAME "_Brief_"

#define WAVE_MISSION_PREFIX "ED\\M2\\E_M2_Brief_"
#define WAVE_MISSION_SUFFIX ".ogg"

#define REGISTER_GOAL(GoalName) RegisterGoal(goal ## GoalName, MISSION_GOAL_PREFIX # GoalName);
#define INITIALIZE_UNIT(UnitName) m_u ## UnitName = GetUnitAtMarker(marker ## UnitName);





#define	CLEAR_TUTORIAL() SetConsoleText("")

#define PLAY_TIMED_BRIEFING_TUTORIAL(BriefingName, Time, Modal) \
	SetConsoleText(MISSION_NAME "_Tutorial_" # BriefingName, Time); 
	


mission MISSION_NAME
{
	#include "..\..\common.ech"
	#include "..\..\dialog.ech"
	state Initialize; // musi byc ztutaj zeby od niego rozpoczal sie skrypt
	#include "..\..\dialog2.ech"

	

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

	int m_nActRainIntensity;
	int m_nReqRainIntensity;

	function void InitializeRain(int nRainIntensity)
	{
		m_nReqRainIntensity = nRainIntensity;
		m_nActRainIntensity = nRainIntensity;

		SetRain(nRainIntensity);
	}

	function void Rain(int nRainIntensity)
	{
		m_nReqRainIntensity = nRainIntensity;

		if ( m_nActRainIntensity != m_nReqRainIntensity )
		{
			SetTimer(1, 3);
		}
	}
	unit m_auSupport[];
	function void StopAllUnits()
	{
		int i,size;
		unit uUnit;
		size = m_auSupport.GetSize();
		for(i=0;i<size;++i)
		{
			uUnit=m_auSupport[i];
			uUnit.CommandStop();
		}
	}
	consts
	{
		goalHeroMustSurvive  = 0;
		goalFindABase = 1;
		goalFindLandingZone = 2; 
		goalDestroyPlants = 3;
		goalSearchTheBase = 7;
		goalFindRadioStation = 4;
		goalFindExplosives = 5;
		goalDestroyStructures = 6;
		goalFindTroff = 7;

		
		rangeNear = 1;

		markerTransporter1 = 1;
		markerTransporter2 = 2;
		markerBase = 3;
		markerRadioStation = 4;
		markerEndMission = 100;		
		markerEHero1 = 6;
		markerSupport1 = 7;// do 13
		markerSupport2 = 20;//do 27
		markerEnemy = 30;
		markerPlant = 14;
		markerPlant1 = 50;// rosliny do zabicia
		markerMassacre = 28;
		markerBrokenWall = 29;
		markerExplosives = 31;
		markerExplosives1 = 80;		
		markerExplosives4 = 84;		
		markerAttack = 35;//do 39
		
			
	}

	player m_pPlayerED; //2
	player m_pPlants;  //3
	player m_pNeutralED; //8 - transporter
	player m_pEnemy; //5
	
	unit uLZoneLight;
	unit m_uEHero1;
	
	int nCutsceneStep;	
	int nTicks;
	int nState;
	int bMissionFailed;
	int bAlienBuildingDestroyed;
	
	state Start;
	state FirstHalf;
	state StartCutscene2;
	state FadeOutCutscene2;	
	state CreateTransporter;
    state EndCutscene2;
	state SecondHalf;	
	state Fight;
	
	state Cutscene3;
	state XXX;
	state MissionFailed;
//*********************************************************************************************
	state Initialize
	{
		bMissionFailed=false;
		SetWind(30,100);//strenght[0-100],Direction[0-255]

		SetTimer(2, 60); // 2s - sprawdzanie goali o zniszczeniu  roslin
		InitializeRain(0);
		EnableInterface(false);
		ShowInterface(false);
		//LookAtMarkerClose(markerEndMission);
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

		m_pPlayerED = GetPlayer(2);
		m_pPlants   = GetPlayer(1);
		m_pEnemy = GetPlayer(5);
		m_pNeutralED = GetPlayer(8);
	
		
		SetNeutrals(m_pPlants, m_pEnemy);
		SetNeutrals(m_pPlants, m_pNeutralED);
		SetNeutrals(m_pEnemy, m_pNeutralED);
		m_pPlayerED.SetAlly(m_pNeutralED);
		m_pNeutralED.SetAlly(m_pPlayerED);
		SetNeutrals(m_pPlayerED, m_pEnemy);
		
		REGISTER_GOAL(HeroMustSurvive);
		REGISTER_GOAL(FindABase);
		REGISTER_GOAL(FindLandingZone); 
		REGISTER_GOAL(DestroyPlants);
		REGISTER_GOAL(SearchTheBase);
		REGISTER_GOAL(FindRadioStation);
		REGISTER_GOAL(FindExplosives);
		REGISTER_GOAL(DestroyStructures);
		REGISTER_GOAL(FindTroff);
		m_auSupport.Create(0);

        nTicks = PlayCutscene("E_M2_C1.trc", true, true, true);

		return Start, nTicks-eFadeTime;
	}
//*********************************************************************************************

	state Start
	{
	
		unit uUnit;
		int noOfUnits;
		int i;
		int x;
		int y;
		int nKillPlants;

		PlayMusic("Music\\Earth_AL.ogg", true);

		
		if(GET_DIFFICULTY_LEVEL() == 0)	nKillPlants = 20;
		if(GET_DIFFICULTY_LEVEL() == 1)	nKillPlants = 10;
		if(GET_DIFFICULTY_LEVEL() == 2)	nKillPlants = 0;

		for(i=markerPlant1; i<markerPlant1 +nKillPlants;i=i+1)
		{
			KillUnitAtMarker(i);
		}
			
		CreatePlayerObjectAtMarker(m_pNeutralED, "E_CH_TR_09_1_FAKE", markerTransporter1,0);

		RESTORE_SAVED_UNIT_ALPHA(PlayerED, EHero1, eBufferEHero1,192);
		m_uEHero1.CommandSetMovementMode(1);
		LookAtMarkerMedium(markerEHero1);
		
		m_auSupport.Add(m_uEHero1);

		if(GET_DIFFICULTY_LEVEL() == 0) noOfUnits = 7;
		if(GET_DIFFICULTY_LEVEL() == 1) noOfUnits = 6;
		if(GET_DIFFICULTY_LEVEL() == 2) noOfUnits = 5;
		
		for(i=markerSupport1; i<markerSupport1+noOfUnits;i=i+1)
		{
			uUnit = CreatePlayerObjectAtMarker(m_pPlayerED, "E_IN_MA_01_1", i,192);
			uUnit.CommandSetMovementMode(1);
			m_auSupport.Add(uUnit);
		}	

		
		uLZoneLight = CreateObject("N_LZONE_LIGHT_OFF",40,61,0,0);


		m_pPlayerED.AddIgnoreNotifyAttackUnit("N_IN_AN_01_1",true);
		m_pPlayerED.AddIgnoreNotifyAttackUnit("N_DE_PL_18",true);
		m_pPlayerED.AddIgnoreNotifyAttackUnit("N_DE_PL_18_2",true);
		m_pPlayerED.AddIgnoreNotifyAttackUnit("N_DE_PL_18_3",true);
		
	
		nState = 0;
		
		Rain(80);
		
		
		SetLimitedGameRect(5, 46, 70,156);	
		
		return FirstHalf, eFadeTime;
		
	}
	
int bTutorialShowed;

//*********************************************************************************************
	state FirstHalf
	{
		int i,nGx1, nGy1;
		int nNumberOfEnemies;
		unit uUnit;
//       roslinki
		if(!IsGoalEnabled(goalDestroyPlants))
		{
			if (IsAnyOsUnitsNearMarker(m_auSupport, markerPlant, 5))
			{
				StopAllUnits();
				ENABLE_GOAL(DestroyPlants);
				ADD_BRIEFING(AlienPlants, IGOR_HEAD);
                START_BRIEFING(false);
				WaitToEndBriefing(FirstHalf, 150);
                return state;
			}
		}
		else
		{
			if(!bTutorialShowed)
			{
				bTutorialShowed=true;
				PLAY_TIMED_BRIEFING_TUTORIAL(AlienPlants, 900, false); //move fast
			}
			else
			{
				if(GetGoalState(goalDestroyPlants)==goalAchieved)	CLEAR_TUTORIAL();
			}
		}
			
			
		if(nState == 0)
		{
			nState = 1;
			StopAllUnits();
			EnableGoal(goalHeroMustSurvive,false);
			EnableGoal(goalFindTroff,false);
			ENABLE_GOAL(FindABase);
			ADD_BRIEFINGS(FindABase, TIMUR_HEAD, IGOR_HEAD, 6);
			START_BRIEFING(true);
			WaitToEndBriefing(state, 30);
			return state;
		}

		if(nState == 1)
		{
			VERIFY(GetMarker(markerTransporter2, nGx1, nGy1));// znaleziona baza
			if (!m_pPlayerED.IsFogInPoint(nGx1, nGy1))
			if ( IsAnyOsUnitsNearMarker(m_auSupport, markerTransporter2, 13) || IsAnyOsUnitsNearMarker(m_auSupport, markerBase, 3) )
			{
				nState = 2;
				StopAllUnits();
				ADD_BRIEFING(EmptyBase, IGOR_HEAD);
				START_BRIEFING(false);
				WaitToEndBriefing(FirstHalf, 30);
				return state;
			}
			return FirstHalf,30;
		}
		if(nState == 2)
		{
			nState = 3;
			SetGoalState(goalFindABase, goalAchieved);
			ENABLE_GOAL(FindLandingZone);
			return FirstHalf, 30;
		}
		
		if(nState == 3)
		{
			//VERIFY(GetMarker(markerTransporter2, nGx1, nGy1));
			//if (!m_pPlayerED.IsFogInPoint(nGx1, nGy1))
			if ( IsAnyOsUnitsNearMarker(m_auSupport, markerTransporter2, 5) )
			{
				nState = 4;
				StopAllUnits();
				Rain(0);
				LookAtMarkerMedium(markerTransporter2);
				EnableInterface(false);
				ADD_BRIEFING(CallingTransport, IGOR_HEAD);
				START_BRIEFING(true);
				return FirstHalf, 2*30;
			}
		}
		if(nState == 4)
		{
			uLZoneLight.KillObject();
			CreateObject("N_LZONE_LIGHT_ON",40,61,0,0);
			SetGoalState(goalFindLandingZone, goalAchieved, false);
			return StartCutscene2, 10*30;
		}
		return FirstHalf,50;
	}
	unit m_uTransporter;

//*********************************************************************************************
	state StartCutscene2
	{
        nTicks = PlayCutscene("E_M2_C2.trc", true, true, true);
		return EndCutscene2, nTicks-eFadeTime;
	}
//*********************************************************************************************
    state EndCutscene2
    {
		int i;
		int noOfUnits;
		unit uUnit;

		
		if(GET_DIFFICULTY_LEVEL() == 0) noOfUnits=8;
		if(GET_DIFFICULTY_LEVEL() == 1) noOfUnits=7;
		if(GET_DIFFICULTY_LEVEL() == 2) noOfUnits=5;
		


		for(i = markerSupport2; i < markerSupport2+noOfUnits; i = i+1)
		{
			uUnit = CreatePlayerObjectAtMarker(m_pPlayerED, "E_IN_MA_01_1", i, 64);
			uUnit.CommandSetMovementMode(1);
			m_auSupport.Add(uUnit);
		}

		SetLimitedGameRect(5, 16, 61,156);
		KillUnitAtMarker(markerTransporter1);

	
		
		return CreateTransporter, 1;
    }
//*********************************************************************************************	
	state CreateTransporter
	{
		m_uTransporter = CreatePlayerObjectAtMarker(m_pNeutralED, "E_CH_TR_09_1_FAKE", markerTransporter2,192);
		return FadeOutCutscene2, eFadeTime;
	}
//*********************************************************************************************	
	state FadeOutCutscene2
	{
		int nBriefingTicks;
		
		nState = 0;

		m_pPlayerED.AddIgnoreNotifyAttackUnit("E_IN_IM_01_1",true);
		m_pPlayerED.AddIgnoreNotifyAttackUnit("E_IN_IB_02_1",true);
		m_pPlayerED.AddIgnoreNotifyAttackUnit("E_IN_IC_03_1",true);
		
		
		m_pPlayerED.AddIgnoreNotifyAttackUnit("N_DE_PL_18",false);
		m_pPlayerED.AddIgnoreNotifyAttackUnit("N_DE_PL_18_2",false);
		m_pPlayerED.AddIgnoreNotifyAttackUnit("N_DE_PL_18_3",false);
		
		ENABLE_GOAL(SearchTheBase);
		return SecondHalf,nBriefingTicks+50;
	}

//*********************************************************************************************

	state SecondHalf	
	{
		int nBriefingTicks, nGx1, nGy1;

		if(nState == 0)
		{
			//VERIFY(GetMarker(markerMassacre, nGx1, nGy1));
			//if (!m_pPlayerED.IsFogInPoint(nGx1, nGy1))
			if ( IsAnyOsUnitsNearMarker(m_auSupport, markerMassacre, 9) )
			{
				nState = 1;
				StopAllUnits();
				LookAtMarkerClose(markerMassacre);
				EnableInterface(false);
				ADD_BRIEFING(Massacre, IGOR_HEAD);
				START_BRIEFING(false);
				WaitToEndBriefing(SecondHalf, 30);
				return state;
			}
		}

		if(nState == 1)
		{
			nState = 2;
			LookAtMarkerMedium(markerTransporter2);
			return SecondHalf, 60;
		}
		if(nState == 2)
		{
			nState = 3;
			m_uTransporter.KillObject();
			//KillUnitAtMarker(markerTransporter2);
			return SecondHalf, 90;
		}
		if(nState == 3)
		{
			nState = 4;
			EnableInterface(true);
			LookAtUnit(m_uEHero1);
			ADD_BRIEFING(TransporterExploded, IGOR_HEAD_SCREAM);
			START_BRIEFING(false);
			WaitToEndBriefing(SecondHalf, 150);
			return state;
			
		}
		if(nState == 4)
		{
				nState = 45;
				StopAllUnits();
				ENABLE_GOAL(FindRadioStation);
				ADD_BRIEFING(FindRadioStation, IGOR_HEAD);

				START_BRIEFING(false);
				WaitToEndBriefing(SecondHalf, 10*30);
				return state;
		}
		
		if(nState == 45)
		{
				nState = 46;
				StopAllUnits();
				ACHIEVE_GOAL(FindTroff);
				EnableInterface(false);
				ADD_BRIEFINGS(VanTroff,TROFF_HEAD, IGOR_HEAD,6);
				START_BRIEFING(true);
				WaitToEndBriefing(SecondHalf, 30);
				return state;
		}

		if(nState == 46)
		{
			nState = 5;
			EnableInterface(true);
			return state;
		}
		if(nState == 5) // broken wall
		{
			VERIFY(GetMarker(markerBrokenWall, nGx1, nGy1));
			if (!m_pPlayerED.IsFogInPoint(nGx1, nGy1))
			{
				ClearLimitedGameRect();
				StopAllUnits();
				nState = 55;
				EnableInterface(false);
				LookAtMarkerMedium(markerBrokenWall);
				ADD_BRIEFING(BrokenWall, IGOR_HEAD);
				START_BRIEFING(false);
				WaitToEndBriefing(SecondHalf, 30);
				return state;
			}
		}

		if(nState == 55) // AlienBuildings
		{
			EnableInterface(true);
			nState=6;
		}
		if(nState == 6) // AlienBuildings
		{
		
			if ( IsAnyOsUnitsNearMarker(m_auSupport, markerEnemy, 7) ||
				IsAnyOsUnitsNearMarker(m_auSupport, 50, 8))
			{
				StopAllUnits();
				nState = 65;
				EnableInterface(false);
				LookAtMarkerMedium(markerEnemy);
				ADD_BRIEFING(AlienBuildings, IGOR_HEAD);
				START_BRIEFING(false);
				WaitToEndBriefing(SecondHalf, 30);
				return state;
			}
		}

		if(nState == 65) // alien attack - start
		{
			EnableInterface(true);
			nState = 7;
		}
		if(nState == 7) // alien attack - start
		{
		
			if ( IsAnyOsUnitsNearMarker(m_auSupport, markerEnemy, 3) || 
				 IsAnyOsUnitsNearMarker(m_auSupport, 50, 6) || 
				 IsAnyOsUnitsNearMarker(m_auSupport, 69, 3) || 
				bAlienBuildingDestroyed)
			{
				nState = 8;
				StopAllUnits();
				m_pEnemy.SetEnemy(m_pPlayerED);
				return SecondHalf, 90;
			}
		}
		if(nState == 8) // alien attack
		{
			nState = 0;
			m_pPlayerED.SetEnemy(m_pEnemy);
			ADD_BRIEFING(AlienAttack, IGOR_HEAD_SCREAM);
			START_BRIEFING(false);
			WaitToEndBriefing(Fight, 150);
			return state;
		}
	}
int bMarkerActive;
int bFirstAttack;
int bFirstKilled;
int nAttackTimer;
	state Fight
	{
		int i;
		int noOfUnits;
		unit uUnit;
		if(nState == 0) // find explosives
		{
			nState = 1;
			bFirstAttack = true;
			nAttackTimer = 80;
			bMarkerActive = true;
			AddMapSignAtMarker(markerExplosives, signMoveTo, -1);
			for(i=markerExplosives1; i<= markerExplosives4; i=i+1) CreateObjectAtMArker("N_AE_BOMB_01",i);	
			ENABLE_GOAL(FindExplosives);
			ENABLE_GOAL(DestroyStructures);
			ADD_BRIEFING(Explosives, IGOR_HEAD);
			START_BRIEFING(false);
			WaitToEndBriefing(Fight, 30);
			return state;

		}
		if(nState == 1) // find explosives
		{

			

			// wysylac wrogow na igora		
			if(bMarkerActive && IsAnyOsUnitsNearMarker(m_auSupport, markerAttack, 4)) bMarkerActive = false;

			if(bMarkerActive)
			{
				if(GET_DIFFICULTY_LEVEL() == 0) { noOfUnits=2; nAttackTimer=nAttackTimer+2;}
				if(GET_DIFFICULTY_LEVEL() == 1) { noOfUnits=2; nAttackTimer=nAttackTimer+2;}
				if(GET_DIFFICULTY_LEVEL() == 2) { noOfUnits=3; nAttackTimer=nAttackTimer+3;}
				
				if(nAttackTimer>80)
				{
					TraceD("               Atak:"); 
					nAttackTimer=1;
					if(GET_DIFFICULTY_LEVEL() == 0) noOfUnits = 2; 
					if(GET_DIFFICULTY_LEVEL() == 1) noOfUnits = 4;
					if(GET_DIFFICULTY_LEVEL() == 2) noOfUnits = 5;

					for(i=0; i<noOfUnits+1;i=i+1)
					{
						if(Rand(4)==0)uUnit = CreatePlayerObjectAtMarker(m_pEnemy, "E_IN_IB_02_1", markerAttack+i,0);
						else uUnit = CreatePlayerObjectAtMarker(m_pEnemy, "E_IN_IM_01_1", markerAttack+i,0);
						CommandMoveAttackUnitToUnit(uUnit,m_uEHero1);
					}
					TraceD("\n");
					if(bFirstAttack) 
					{
						nState = 15;
						return state, 8*30;
					}

					return state, 2*30;
				}
			}				
			// sprawdzac czy nie zniszczyl wszystkich roslin - w timerze sie robi
			
			
			if ( IsGoalEnabled(goalFindExplosives) && GetGoalState(goalFindExplosives) == goalNotAchieved )
			{
				// sprawdzac czy znalazl ladunki
				if ( IsAnyOsUnitsNearMarker(m_auSupport, markerExplosives, 3))
				{
						RemoveMapSignAtMarker(markerExplosives);
						AddMapSignAtMarker(markerRadioStation, signMoveTo, -1);
						SetGoalState(goalFindExplosives,goalAchieved,false);
						ADD_BRIEFING(DestroyStructures, IGOR_HEAD);
						START_BRIEFING(false);
						WaitToEndBriefing(Fight, 30);
						return state;
				}
		
			}
			if ( IsAnyOsUnitsNearMarker(m_auSupport, markerRadioStation, 5) )
			{
				nState = 3;
				ADD_BRIEFINGS(CallingHelp, IGOR_HEAD, TIMUR_HEAD, 8);
				START_BRIEFING(false);
				WaitToEndBriefing(Fight, 30);
				return state;
			}
			
		}
		if ( nState==15 )
		{
			nState = 16;
			bFirstAttack = false;
			
			ADD_BRIEFING(SoldiersApproaching, ED_SOLDIER_HEAD);
			START_BRIEFING(false);
			WaitToEndBriefing(Fight, 30);
			return state;
		}

		if ( nState==16 )
		{
			if(bFirstKilled)
			{
				nState = 1;
				nAttackTimer = 80;
				SetGoalState(goalSearchTheBase, goalAchieved);
				ADD_BRIEFING(AttackedBySoldiers, IGOR_HEAD);
				START_BRIEFING(false);
				WaitToEndBriefing(Fight, 30);
				return state;
			}
		}


		if(nState == 3)
		{
			nState = 4;
			SaveEndMissionGame(102,null);
			return Fight, 1;			
		}

		if(nState == 4)
		{
			RemoveMapSignAtMarker(markerRadioStation);
			SetGoalState(goalFindRadioStation, goalAchieved);
			EnableMessages(false);
			nTicks = PlayCutscene("E_M2_C3.trc", true, true, true);
			return Cutscene3, eFadeTime;			
		}

		return Fight, 60;
	}

	
//*********************************************************************************************

	state Cutscene3
	{
		SAVE_UNIT(PlayerED, EHero1, eBufferEHero1);       
		RemoveAllPlayerUnits(m_pPlayerED);
		return XXX, nTicks-eFadeTime*2;
	}
	
//*********************************************************************************************
    state XXX
    {
		EndMission(true);
	}
//*********************************************************************************************	
	
//*********************************************************************************************
	state MissionFailed2
    {
		MissionDefeat();
	}
//*********************************************************************************************
	state MissionFailed
    {
		EnableInterface(false);
		ShowInterface(false);
		SetLowConsoleText("translateMissionFailed");
        FadeInCutscene(100, 0, 0, 0);
        return MissionFailed2, 120;
    }
//*********************************************************************************************
	event EndMission(int nResult)
	{
	}
	
	event RemovedUnit(unit uKilled, unit uAttacker, int nNotifyType)
	{

		if(!bFirstKilled && uKilled.GetIFF()==m_pEnemy.GetIFF()) bFirstKilled = true;
		if(bMissionFailed)return;

		if(state==Cutscene3)return;

		if(uKilled == m_uEHero1)
		{
			bMissionFailed = true;
			state MissionFailed;
		}
	}
	int bCheckBuildings;
	
	event RemovedBuilding(unit uKilled, unit uAttacker, int nNotifyType)
	{
		bCheckBuildings=true;
		if(nState==7) bAlienBuildingDestroyed=true;
	}

    event EscapeCutscene(int nIFFNum)
    {
        int nTicks;
        if ((state == Start) || (state == EndCutscene2) || (state == XXX))
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
		nState = 3;
		state Fight;
        SetStateDelay(30);
	}
    event DebugCommand(string pszCommand)
    {
        string strCommand;
        strCommand = pszCommand;
        if (!strCommand.CompareNoCase("C2"))
        {
            SetStateDelay(60);
        }
	}

	event Timer1()
	{
		if ( m_nActRainIntensity < m_nReqRainIntensity )
		{
			++m_nActRainIntensity;
		}
		else if ( m_nActRainIntensity > m_nReqRainIntensity )
		{
			--m_nActRainIntensity;
		}
		else
		{
			SetTimer(1, -1);

			return;
		}

		SetRain(m_nActRainIntensity);
	}
	event Timer2()
	{
		if(bCheckBuildings)
		{
			if ( IsGoalEnabled(goalDestroyPlants) && GetGoalState(goalDestroyPlants) == goalNotAchieved )
			{
				if(m_pPlants.GetNumberOfBuildings() == 0)
				{
					SetGoalState(goalDestroyPlants, goalAchieved);
					CLEAR_TUTORIAL();
				}
			}
			if ( IsGoalEnabled(goalDestroyStructures) && GetGoalState(goalDestroyStructures) == goalNotAchieved )
			{
				if(m_pEnemy.GetNumberOfBuildings() == 0)
				{
					SetGoalState(goalDestroyStructures, goalAchieved);
				}
			}
			bCheckBuildings=false;
		}
	}
}
