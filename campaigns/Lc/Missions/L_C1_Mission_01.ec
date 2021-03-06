#include "..\..\defines.ech"

#define MISSION_NAME "translateL_M1"

#define WAVE_MISSION_PREFIX "LC\\M1\\L_M1_Brief_"


/*

   Ladowanie - briefing ze trzeba znalezc sonde - start patroli

   droga do sondy - znalezienie sondy - lookAt i briefing ze musieli ja zabrac nowy goal znajdz zloza

   droga do z³oz - jak znalezione male to briefing ze za male
                  jak duze to briefing o budowie bazy


   zrzut pierwszych czesci bazy

   Budowa bazy -  ataki co kilka minut.

   jak baza ma wiecej niz 6 budynkow - info ze trzeba znalezc sonde i ze jest w bazie przemytnikow 

    jak sonda znaleziona - to info zeby porwac ciezarowke. 

   jak ciezarowka nasza to goal  escort.

   droga do bazy -  ataki na ciezarowke. 

   Aria dociera do bazy - briefing i cutscena -mission accomplished
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
		
		playerPlayer     = 3;
		playerEnemy      = 6;// obcy na planszy
		playerNeutral    = 5;	
		
		goalLHero1MustSurvive = 0;
		goalFindPlace = 2;
		goalFindResource = 3;
		goalBuildBase = 4;
		goalFindProbe = 5;
		goalTakeProbe = 6;
		goalProtectTruck = 7;


		markerLHero1 = 1;
		markerProbe = 2;
		markerSmallResources = 3;
		markerResources= 4;
   		markerBase1 = 5;
		markerBase2 = 6;
		markerMine1 = 7;
		markerMine2 = 8;
		markerTruck = 9;
		markerTruckDefence = 10; //-14
		markerPatrol1 = 20;// -38 co 3
		eNoOfPatrols = 6;
		markerAttack = 20;

		markerPatrolDest1 = 40;
		markerPatrolDest2 = 41;
		markerPatrolDest3 = 42;
	}

	player m_pPlayer;
	player m_pEnemy;
	player m_pNeutral;

	unit m_uLHero1;
	unit m_uTruck;
	
	int m_nState;
	int nAttackCounter;	
	int bCivilBriefing;
    int m_noOfUnits;
	int m_bDontCheckKill;
	function void CreateStartPatrols()//XXXMD
	{
		int i;

		for(i=0;i<10;i=i+3)
		{
				CreatePatrol(m_pEnemy, "N_CH_GJ_03_2", GET_DIFFICULTY_LEVEL(), markerPatrol1+i, markerPatrol1+i+1, markerPatrol1+i+2, markerPatrol1+i);
				CreatePatrol(m_pEnemy, "N_IN_SM_01_1", 1+(GET_DIFFICULTY_LEVEL()*2), markerPatrol1+i, markerPatrol1+i+1, markerPatrol1+i+2, markerPatrol1+i);

		}
	}

	function void CreatePatrols()
	{
		int i, k;

		k=m_pPlayer.GetNumberOfVehicles()*(GET_DIFFICULTY_LEVEL()+1);

		k=k/6;
        if(!k)k=1;

		for(i=0;i<10;i=i+3)
		{
				CreatePatrol(m_pEnemy, "N_CH_GJ_03_2", k, markerPatrol1+i, markerPatrol1+i+1, markerPatrol1+i+2, markerPatrol1+i);
				CreatePatrol(m_pEnemy, "N_IN_SM_01_1", k, markerPatrol1+i, markerPatrol1+i+1, markerPatrol1+i+2, markerPatrol1+i);
				CreatePatrol(m_pEnemy, "N_IN_SM_02_1", k, markerPatrol1+i, markerPatrol1+i+1, markerPatrol1+i+2, markerPatrol1+i);
		}
		
	}
	
	function int SendAttackToPlayerBase()
	{
		int i, k, nGx, nGy,  bAirOnly, a,b,c;

		if(!GET_DIFFICULTY_LEVEL())
		{
			i = Rand(4); 
			if(i) return 1;
		}
		i = Rand(3); 
		if(!i)
		{
			a=markerPatrolDest1;
			b=markerPatrolDest2;
			c=markerPatrolDest3;
		}
		if(i==1)
		{
			a=markerPatrolDest2;
			b=markerPatrolDest1;
			c=markerPatrolDest3;
		}
		if(i==2)
		{
			a=markerPatrolDest3;
			b=markerPatrolDest2;
			c=markerPatrolDest1;
		}
        
        i = Rand(10);
		TraceD("                                       Create Attack: units:");TraceD(m_pEnemy.GetNumberOfUnits());TraceD("   marker:");TraceD(markerAttack+i);
		VERIFY(GetMarker(markerAttack+i, nGx, nGy));
		if (!m_pPlayer.IsFogInPoint(nGx, nGy))
		{
			TraceD("Failed              \n");
			return 0;
		}
		bAirOnly = false;
		if(m_pEnemy.GetNumberOfUnits()>=250) bAirOnly = true;//zeby nie bylo za duzo

		k=m_pPlayer.GetNumberOfVehicles()*(GET_DIFFICULTY_LEVEL()+1);

		k=k/5;
        if(!k)k=1;
		if(!bAirOnly)
		{
			TraceD("ground ");
			CreatePatrol(m_pEnemy, "N_CH_GJ_03_2", k, markerAttack+i, a,b,c);
			CreatePatrol(m_pEnemy, "N_IN_SM_01_1", k, markerAttack+i, a,b,c);
			CreatePatrol(m_pEnemy, "N_IN_SM_02_1", k, markerAttack+i, a,b,c);
		}
		CreatePatrol(m_pEnemy, "E_CH_AJ_01_1#E_WP_SL_01_1,E_AR_CH_01_1,E_EN_NO_01_1", k, markerAttack+i, a,b,c);

		TraceD(" air              \n");
		return 1;

	}

	function void CreateTruckAttack()
	{
	
		int nMarker,k;

		k=(GET_DIFFICULTY_LEVEL())*3 + 2;
		
		nMarker = markerPatrol1 + Rand(18);
		
		CreateAndAttackFromMarkerToUnit(m_pEnemy, "N_CH_GJ_03_2", k, nMarker, m_uTruck);
		CreateAndAttackFromMarkerToUnit(m_pEnemy, "N_CH_GJ_03_1", k, nMarker, m_uTruck);
		if(!GET_DIFFICULTY_LEVEL()) k=1;
		CreateAndAttackFromMarkerToUnit(m_pEnemy, "E_CH_AJ_01_1#E_WP_SL_01_1,E_AR_CH_01_1,E_EN_SP_01_1", k, nMarker, m_uTruck);
		
		
	}

	

	state Start;
	state MissionFlow;
	state XXX;

	state Initialize
	{
		int i;
		bCivilBriefing = true;
		
		INITIALIZE_PLAYER(Player);
		INITIALIZE_PLAYER(Enemy);
		INITIALIZE_PLAYER(Neutral);

		SetNeutrals(m_pPlayer, m_pNeutral);
		SetNeutrals(m_pEnemy, m_pNeutral);


		INITIALIZE_UNIT(Truck);
		m_uTruck.RemoveCrew();
		
		CREATE_UNIT(Player, LHero1, "L_HERO_01");		
		LookAtUnit(m_uLHero1);
		
		m_pEnemy.EnableAI(false);
		
		SetPlayerTemplateseLCCampaign(m_pPlayer, 1);
		SetPlayerResearchesLCCampaign(m_pPlayer, 1);
		

		if(!GET_DIFFICULTY_LEVEL())
		{
			for(i=50; i<=78;i=i+1)RemoveUnitAtMarker(i);
		}

		SetEnemies(m_pEnemy,m_pPlayer);
		
		REGISTER_GOAL(LHero1MustSurvive);
		REGISTER_GOAL(FindPlace);
		REGISTER_GOAL(FindResource);
		REGISTER_GOAL(BuildBase);
		REGISTER_GOAL(FindProbe);
		REGISTER_GOAL(TakeProbe);
		REGISTER_GOAL(ProtectTruck);
		
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
		i = PlayCutscene("L_M1_C1.trc", true, true, true);
		return Start, i-eFadeTime;
	}

	

	state Start
	{
		m_nState=0;
		
		return MissionFlow, eFadeTime;


		
	}
	int bSmallResources;
	int nTicks;
	state MissionFlow
	{
		int i,nGx, nGy;

		if(m_nState==0)
		{
			m_nState = 1;
			ENABLE_GOAL(LHero1MustSurvive);
			ENABLE_GOAL(FindPlace);
			AddMapSignAtMarker(markerProbe, signMoveTo, -1);
			ADD_BRIEFINGS(Start, NATASHA_HEAD,ARIA_HEAD,2);
			START_BRIEFING(false);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(m_nState==1)// uruchomic patrole obcych
		{
			m_nState = 2;
			CreateStartPatrols();
			bCivilBriefing = false;
			return state;
		}
		if(m_nState==2)// dotarcie do sondy
		{	
			if(IsUnitNearMarker(m_uLHero1, markerProbe, 6))
			{
				RemoveMapSignAtMarker(markerProbe);
				LookAtMarkerClose(markerProbe);
				m_nState = 3;
				bSmallResources = false;
				ACHIEVE_GOAL(FindPlace);
				ENABLE_GOAL(FindResource);
				ADD_BRIEFINGS(SearchProbe,ARIA_HEAD, NATASHA_HEAD, 10);
				START_BRIEFING(true);//zablokowany interface
				WaitToEndBriefing(state, 10*30);
				return state;
			}
			return state;
		}


		if(m_nState==3)// 
		{
			VERIFY(GetMarker(markerResources, nGx, nGy));
			if (!m_pPlayer.IsFogInPoint(nGx, nGy))
			{
				LookAtMarkerMedium(markerResources);
				m_nState = 4;
				ACHIEVE_GOAL(FindResource);
				ENABLE_GOAL(BuildBase);
				ADD_BRIEFINGS(BulidBase,ARIA_HEAD,NATASHA_HEAD, 2);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 30);
				return state;
			}
			if(!bSmallResources)
			{
				VERIFY(GetMarker(markerSmallResources, nGx, nGy));
				if (!m_pPlayer.IsFogInPoint(nGx, nGy))
				{
					bSmallResources=true;
					LookAtMarkerMedium(markerSmallResources);
					ADD_BRIEFINGS(SmallResources,LC_SOLDIER_HEAD, ARIA_HEAD, 2);
					START_BRIEFING(false);
					WaitToEndBriefing(state, 30);
					return state;
				}
			}
	
			return state;
		}
		if(m_nState==4)
		{
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
			m_pPlayer.AddResource(eCrystal, 5000);
			m_pPlayer.AddResource(eWater, 5000);

			GetMarker(markerBase1, nGx, nGy);
			m_pPlayer.CreateOrbitalBuildBuilding("L_BL_BA_01", nGx, nGy, 0);
			GetMarker(markerBase2, nGx, nGy);
			m_pPlayer.CreateOrbitalBuildBuilding("L_BL_BA_01", nGx, nGy, 0x40);
			GetMarker(markerMine1, nGx, nGy);
			m_pPlayer.CreateOrbitalBuildBuilding("L_BL_MI_10", nGx, nGy, 0x40);
			GetMarker(markerMine2, nGx, nGy);
			m_pPlayer.CreateOrbitalBuildBuilding("L_BL_MI_10", nGx, nGy, 0);

			CreatePatrols();
			m_noOfUnits = 1000;
			SendAttackToPlayerBase();
			nAttackCounter=0;
			m_nState = 45;
			return state, 20;
		}

		if(m_nState==45)
		{
			if ((m_pPlayer.GetNumberOfBuildings("L_BL_PP_02") >= 2) && 
			   (m_pPlayer.GetNumberOfBuildings("L_BL_UF_03") >= 1) && 
			   (m_pPlayer.GetNumberOfBuildings("L_BL_ST_09") >= 1) 
			   //&& (m_pPlayer.GetNumberOfBuildings("L_BL_IF_04") >= 1)
				)
        	{
				m_nState = 46;
				nAttackCounter = 900-(GET_DIFFICULTY_LEVEL()*300);
				ACHIEVE_GOAL(BuildBase);
				ENABLE_GOAL(FindProbe);
				ADD_BRIEFINGS(BaseCompleted,ARIA_HEAD,NATASHA_HEAD, 3);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 30);
			}
			return state,10*30;
		}
		if(m_nState==46)
		{
			m_nState = 5;
			AddAgent(2); //Demolisher
			return state,20*30;
		}		

		if(m_nState==5)// szukanie sondy walka z bandytami itp
		{

			++nAttackCounter;
			if(nAttackCounter > 900-(GET_DIFFICULTY_LEVEL()*300))
			{
				if(SendAttackToPlayerBase())
				{
					nAttackCounter=0;
				}
				else 
				{
					nAttackCounter = 900-(GET_DIFFICULTY_LEVEL()*300);
				}
			}
			
			VERIFY(GetMarker(markerTruck, nGx, nGy));
			if (!m_pPlayer.IsFogInPoint(nGx, nGy))
			{
				m_pPlayer.SetAlly(m_pNeutral);
				m_pNeutral.SetAlly(m_pPlayer);

				LookAtMarkerMedium(markerTruck);
				m_nState = 6;
				ACHIEVE_GOAL(FindProbe);
				ENABLE_GOAL(TakeProbe);
				AddMapSignAtMarker(markerTruck, signSpecial, -1);
				ADD_BRIEFING(TakeProbe, ARIA_HEAD);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 30);
			}
			return state,30;
		}
		if(m_nState==6)
		{
			if(m_uTruck.GetIFF() == m_pPlayer.GetIFF() )
			{
				m_nState = 7;
				nAttackCounter = 120-(GET_DIFFICULTY_LEVEL()*30);
				ACHIEVE_GOAL(TakeProbe);
				RemoveMapSignAtMarker(markerTruck);
				AddMapSignAtMarker(markerBase1,signMoveTo, -1);
				ENABLE_GOAL(ProtectTruck);
				ADD_BRIEFING(GetMove, ARIA_HEAD);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 30);
			}
			return state;
		}
		if(m_nState==7)// droga powrotna
		{
			++nAttackCounter;
			if(nAttackCounter>240-(GET_DIFFICULTY_LEVEL()*30))
			{
				CreateTruckAttack();				
				nAttackCounter=0;
			}
			
			if(IsUnitNearMarker(m_uTruck, markerBase1, 8))
			{
				m_nState = 15;
				ADD_BRIEFINGS(Finish,ARIA_HEAD,NATASHA_HEAD, 5);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 30);
			}
			return state;
		}
		if(m_nState==15)
		{
			m_nState=16;
			SaveEndMissionGame(201,null);
			return state,1;
		}
		if(m_nState==16)
		{
			EnableInterface(false);
			ShowInterface(false);
			m_nState=18;
			SetWind(0, 0);SetTimer(2,0);
			EnableMessages(false);
			nTicks = PlayCutscene("L_M1_C2.trc", true, true, true);
			return state,eFadeTime;
		}
		if(m_nState==18)
		{                      
			//SetLowConsoleText("translateMissionAccomplished");
			//FadeInCutscene(100, 0, 0, 0);
			PrepareSaveUnits(m_pPlayer);
		    SAVE_UNIT(Player, LHero1, eBufferLHero1);
			SaveBestInfantry(m_pPlayer, 12-GET_DIFFICULTY_LEVEL()*3);
			m_bDontCheckKill = true;
			RemoveAllPlayerUnits(m_pPlayer);
			return XXX, nTicks - (eFadeTime*2);
		
		}
		
		return state, 30;
	}

	state XXX
	{
		EnableInterface(true);
		ShowInterface(true);
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
		if(m_bDontCheckKill) return;
		if ( uKilled == m_uLHero1 )
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
		if (( uKilled == m_uTruck ) && (nNotifyType != eNotifyChangedPlayer))
		{
			SetGoalState(goalProtectTruck, goalFailed);

			LookatUnit(m_uLHero1);
			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state YYY;

			SetStateDelay(120);
		}
	}
	
	
	event RemovedBuilding(unit uKilled, unit uAttacker, int bChangedPlayer)
	{
		if(m_bDontCheckKill) return;
		if(uKilled.GetIFF()==m_pEnemy.GetIFF() &&!bCivilBriefing)
		{
			bCivilBriefing=true;
			ADD_BRIEFINGS(EnterBase,CIVIL_HEAD, ARIA_HEAD, 3);
			START_BRIEFING(false);
			WaitToEndBriefing(state, 30);
		}
	}
	
    event EscapeCutscene(int nIFFNum)
    {
        int nTicks;//czas potrzebny na fadeOut
        if ((state == Start) || (state==MissionFlow && m_nState==18) || (state==XXX))
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
		int nNum;
		int nGx, nGy;
		string strCommand;
		
		strCommand = pszCommand;
		if (!strCommand.CompareNoCase("state"))
		{
			TRACE5("state = ", state,"m_nState = ",m_nState,"    \n");
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

/*

Saveowanie unitow w kampanii:
        else if (!strCommand.CompareNoCase("testsave"))
        {
            PrepareSaveUnits(m_pPlayer);
            SAVE_UNIT(Player, LHero1);
            SaveBestInfantry(m_pPlayer, 10);
        }
        else if (!strCommand.CompareNoCase("testrestore"))
        {
            RESTORE_SAVED_UNIT(Player, LHero1);
            RestoreBestInfantryAtMarker(m_pPlayer, markerLHero1);
            FinishRestoreUnits(m_pPlayer);
        }

*/

/*

Cutsceny:
- to co sie da wrzucac do tracka w edytorze

//wywolanie:
int nTicks = PlayCutscene(pszTrackName, bFadeInOut, bDisableInterface, bHideInterface);
 (bFadeInOut/bDisableInterface/bHideInterface - wywolywac z true rowniez dla pierwszej cutsceny na poczatku misji gdy ekran juz jest zgaszony)

jesli do cutsceny beda wywolywane PlayWave ze skryptu i bFadeInOut == true to trzeba dodac czas fadeIn:
PlayWave("xxx.ogg",volBriefing,890 + GetPlayCutsceneFadeInDelay());
 (uwaga: GetPlayCutsceneFadeInDelay zawsze zwraca czas fadeIn bo moze zostac wywolany przed PlayCutscene - i nie wiadomo jaka bedzie wartosc bFadeOut)

jesli jest wywolane PlayCutsceneMusic("xxxx.ogg") to zacznie sie odgrywac w momencie startu cutsceny (po zrobieniu fadeIn)
PlayCutsceneMusic(null) powoduje wylaczenie muzyki w trakcie cutsceny 
 (jest wywolywane automatycznie jesli w cutscenie jest wpisany wave zaczynajacy sie w ticku 0 i trwajacy przez cala cutscene)

//przerywanie
event EscapeCutscene(int nIFFNum)
{
    int nTicks;//czas potrzebny na fadeOut
    nTicks = StopCutscene();
    SetStateDelay(nTicks);
}

*/
