#include "..\..\defines.ech"

#define MISSION_NAME "translateA_M7"

#define WAVE_MISSION_PREFIX "AL\\M7\\A_M7_Brief_"


/*
Misja 7

Atak na sily 3 korporacji. 





po rozkazie zabicia cywilow - przemiana igora. 

przeniesienie jego jednostek do wroga. 

Zniszczenie obcych


  +neutral ED
  +Flota Alienow latajaca z igorem - 1 Destroyer i 2 light crusery. 

  +flota wraca do bazy

  +wstawic Rochlina
  +Wstawic goal o rochlinie


  +Wstawic replikatorusa i przepiac go na gracza.

  +wstawic sprawdzanie rochlina

  

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
		playerPlayer	  = 4;
		playerLC     = 3;
		playerED     = 2;
		playerUCS     = 1;
		playerALIEN = 7;
				
		goalAHero1MustSurvive = 0;
		goalDestroyAllHumans = 1;
		goalDestroyTroffForces = 2;
		goalKillTroff = 3;
		goalKillRochlin = 4;
		
		markerAHero1 = 1;
		markerCivilians = 2;
		markerAHero2 = 3;
		markerRep = 4;
		markerEHero3 = 5;
		markerFleet1 = 6;
		markerFleet2 = 7;
		markerFleet3 = 8;
	}

	player m_pPlayer;
	player m_pLC;
	player m_pED;
	player m_pUCS;
	player m_pALIEN;
	
	unit m_uAHero1, m_uAHero2, m_uEHero3, m_uFleet1,m_uFleet2,m_uFleet3, m_uRep;
	
	
	int nFleetCounter;	
	int m_nState;
	int m_nAttackCounter;
	int m_bBuildingDestroyed;
	int m_bUCSBuildingDestroyed;
	state Start;
	state MissionFlow;
	state XXX;
 
	function void CreateFleet()
	{
		CREATE_UNIT(ALIEN, Fleet1, "A_CH_LC_13_1");		
		CREATE_UNIT(ALIEN, Fleet2, "A_CH_LC_13_1");		
		CREATE_UNIT(ALIEN, Fleet3, "A_CH_HC_14_1");		
	}

	function void MoveFleet(unit uDestination, int nNow)
	{
		++nFleetCounter;
		if(nFleetCounter<15 && !nNow) return;
		nFleetCounter=0;
		if(m_uFleet1.IsLive())CommandMoveUnitToUnit(m_uFleet1, uDestination);
		if(m_uFleet2.IsLive())CommandMoveUnitToUnit(m_uFleet2, uDestination);
		if(m_uFleet3.IsLive())CommandMoveUnitToUnit(m_uFleet3, uDestination);
	}

	state Initialize
	{
		int i;
		unit uVehicle;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(LC );
		INITIALIZE_PLAYER(ED );
		INITIALIZE_PLAYER(UCS );
		INITIALIZE_PLAYER(ALIEN );

		
				
			
		ActivateAI(m_pLC);
		ActivateAI(m_pED);
		ActivateAI(m_pUCS);
		ActivateAI(m_pALIEN);

		SetPlayerTemplateseLCCampaign(m_pLC, 7);
		SetPlayerResearchesLCCampaign(m_pLC, 7);
		AddPlayerResearchesLCCampaign(m_pLC, 7);

		SetPlayerTemplateseEDCampaign(m_pED, 7);
		SetPlayerResearchesEDCampaign(m_pED, 7);
		AddPlayerResearchesEdCampaign(m_pED, 7);

		SetPlayerTemplateseUCSCampaign(m_pUCS, 7);
		SetPlayerResearchesUCSCampaign(m_pUCS, 7);
		AddPlayerResearchesUCSCampaign(m_pUCS, 7);

		m_pLC.AddResource(eCrystal, 5000);
		m_pLC.AddResource(eWater, 5000);

		m_pED.AddResource(eMetal, 5000);
		m_pED.AddResource(eWater, 5000);

		m_pUCS.AddResource(eCrystal, 5000);
		m_pUCS.AddResource(eMetal, 5000);

		SetNeutrals(m_pLC,m_pUCS,m_pED);
		SetNeutrals(m_pPlayer,m_pALIEN,m_pED);

		SetAlly(m_pPlayer, m_pALIEN);

		SetEnemies(m_pALIEN, m_pLC);
		SetEnemies(m_pALIEN, m_pUCS);

		SetEnemies(m_pPlayer, m_pLC);
		SetEnemies(m_pPlayer, m_pUCS);
		
		m_pUCS.SetAIControlOptions(eAIControlBuildBase,false);

		REGISTER_GOAL(AHero1MustSurvive);
		REGISTER_GOAL(DestroyAllHumans);
		REGISTER_GOAL(DestroyTroffForces);
		REGISTER_GOAL(KillTroff);
		REGISTER_GOAL(KillRochlin);
		
		RESTORE_SAVED_UNIT(Player, AHero1, eBufferAHero1);	
				
		CreateFleet();
		LookAtMarker(markerAHero1);
		SetWind(20, 20);
		return Start;
	}

	

	state Start
	{
		m_nState=0;
		//m_nState=30;//XXXMD
		m_nAttackCounter = 0;
		FadeOutCutscene(60, 0, 0, 0);
		return MissionFlow, 160;


		
	}
	int m_nKillCounter;
	state MissionFlow
	{
		int i,nGx, nGy, nFound;

		if(m_nState==0)
		{
			m_nState = 1;
			ENABLE_GOAL(AHero1MustSurvive);
			ENABLE_GOAL(DestroyAllHumans);
			ADD_BRIEFINGS(Start,BAD_TROFF_HEAD,BAD_IGOR_HEAD,10);
			START_BRIEFING(eInterfaceEnabled);
			WaitToEndBriefing(state, 10*30);
			return state;
		}

		if(m_nState==1)//
		{
			MoveFleet(m_uAHero1,false);
			if(m_bUCSBuildingDestroyed>5)
			{
					m_nState = 2;
					m_bUCSBuildingDestroyed = 0;
					CREATE_UNIT(ALIEN, AHero2, "A_HERO_02");	
					CREATE_UNIT(ED, EHero3, "A_HERO_03");	
					MoveFleet(m_uAHero2, true);
			
					ShowInterface(false);
					EnableInterface(false);
					
					VERIFY(GetMarker(markerCivilians, nGx, nGy));
					LookAt(G2AMID(nGx),G2AMID(nGy), 15, 64, 50);
		//			DelayedLookAt(int nX, int nY, int nZ, int nAngle, int nViewAngle, int nDelay, int bClockWise)
					DelayedLookAt(G2AMID(nGx),G2AMID(nGy),35,128, 45, 30*30, 1);    //zoom out  //xxxmd
					SetAlly(m_pPlayer, m_pUCS);
					SetGoalState(goalDestroyAllHumans, goalFailed);
					ENABLE_GOAL(DestroyTroffForces);
					ENABLE_GOAL(KillTroff);
					ENABLE_GOAL(KillRochlin);
					ADD_BRIEFINGS(Civilians1,BAD_TROFF_HEAD,BAD_IGOR_HEAD,3);
					ADD_BRIEFINGS(Civilians2,ARIA_HEAD,BAD_IGOR_HEAD,5);
					ADD_BRIEFINGS(Civilians3,ROCHLIN_HEAD,BAD_IGOR_HEAD,3);
					ADD_BRIEFINGS(Civilians4,ARIA_HEAD,ROCHLIN_HEAD,3);
					ADD_BRIEFINGS(Civilians5,BAD_TROFF_HEAD,ROCHLIN_HEAD,3);
					ADD_BRIEFINGS(Civilians6,IGOR_HEAD,BAD_TROFF_HEAD,5);
					START_BRIEFING(eInterfaceDisabled);
					WaitToEndBriefing(state, 30);
					return state;
			}
			return state,30;
		}	
		
		if(m_nState==2)
		{	

			m_nState = 35;
			ShowInterface(true);
			EnableInterface(true);
			if(GET_DIFFICULTY_LEVEL()>1) GiveAllUnitsNotAroundHeroToPlayer(m_pPlayer, m_pALIEN, m_uAHero1, 15);//xxxmd	
			
			SetAlly(m_pPlayer, m_pLC);
			SetAlly(m_pPlayer, m_pUCS);

			SetEnemies(m_pPlayer, m_pED);
			SetEnemies(m_pPlayer, m_pALIEN);

			SetEnemies(m_pUCS, m_pED);
			SetEnemies(m_pUCS, m_pALIEN);

			SetEnemies(m_pLC, m_pED);
			SetEnemies(m_pLC, m_pALIEN);

			m_pUCS.EnableAI(true);
			ActivateAIControlAllUnits(m_pUCS);
			return state, 5*30;
		}

		if(m_nState==35)
		{	

			m_nState = 3;
			CREATE_UNIT(Player, Rep, "A_CH_NU_10_1");		
			ADD_BRIEFINGS(NewStrogov,ARIA_HEAD,IGOR_HEAD,9);
			START_BRIEFING(eInterfaceEnabled);
			WaitToEndBriefing(state, 30);
			return state, 5*30;
		}

		if(m_nState==3)
		{
			if(!m_uAHero2.IsLive() && GetGoalState(goalKillTroff)!=goalAchieved)
			{
				MoveFleet(m_uAHero1,true);
				ACHIEVE_GOAL(KillTroff);
			}
			
			if(!m_uEHero3.IsLive() && GetGoalState(goalKillRochlin)!=goalAchieved)
			{
				MoveFleet(m_uAHero1,true);
				ACHIEVE_GOAL(KillRochlin);
				ADD_BRIEFINGS(EDNeutral,ED_SOLDIER_HEAD,IGOR_HEAD,7);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 30);
				SetNeutrals(m_pPlayer, m_pLC, m_pUCS, m_pED);
			}
			
			if (m_bBuildingDestroyed==true && 
				m_pALIEN.GetNumberOfBuildings() < 3 &&
				m_pALIEN.GetNumberOfUnits() < 3)
			{
			 	ACHIEVE_GOAL(DestroyTroffForces);
			}

			if(!m_uAHero2.IsLive() && !m_uEHero3.IsLive() && GetGoalState(goalDestroyTroffForces)==goalAchieved)
			{
				m_nState=15;
				ADD_BRIEFINGS(Victory,IGOR_HEAD,ARIA_HEAD,3);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 30);
				return state;
			}
			m_bBuildingDestroyed = false;
			return state, 30;
		}
		if(m_nState==15)
		{
			SaveEndMissionGame(407,null);
			EnableInterface(false);
			ShowInterface(false);
			m_nState=18;
			return state,0;
		}
		if(m_nState==18)
		{       
			SetWind(0, 0);SetTimer(2,0);
			EnableMessages(false);
			i = PlayCutscene("A_M7_C2.trc", true, true, true);
			return XXX, i-eFadeTime;
		
		
		}
		
		return state, 30;
	}

	state XXX
	{
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

		m_bBuildingDestroyed=true;

		if ( uKilled == m_uAHero1 )
		{
			bIgnoreEvent=true;
			SetGoalState(goalAHero1MustSurvive, goalFailed);

			LookatUnit(m_uAHero1);
			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state YYY;

			SetStateDelay(120);
		}
	}

	event RemovedBuilding(unit uKilled, unit uAttacker, int nNotifyType)
	{
		m_bBuildingDestroyed=true;
		if(uAttacker!=null &&
			(uAttacker.GetIFF() == m_pPlayer.GetIFF()||uAttacker.GetIFF() == m_pALIEN.GetIFF())&& 
			 uKilled.GetIFF() == m_pUCS.GetIFF() )
		{
			++m_bUCSBuildingDestroyed;
		}
	}

	
    event EscapeCutscene(int nIFFNum)
    {
		if(state==XXX)
		{
		}
		else
		{
			return;
		}


		SetLowConsoleText("");
        RemoveDelayedWaves();
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
