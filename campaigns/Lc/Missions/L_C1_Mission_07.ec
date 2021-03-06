#include "..\..\defines.ech"

#define MISSION_NAME "translateL_M7"

#define WAVE_MISSION_PREFIX "LC\\M7\\L_M7_Brief_"


/*
kometa widok planetoidy z kosmos i ladowanie

briefing z szatmarem -  nikt nie podejrzewal ze tutaj siedza.zaznaczylem wam centrum sterowania. Jak zniszczycie jego obrone to sie poddadza to tchurze.

czas na baze itp rusza AI.


jezeli ktos wokol markera 4 - roboty. To natasha sie wlacza i mowi ze musi tam sie dostac. 
Jak natasza  przy robotach to mówi ¿e  zaraz je przejmie. zmienia gracza na 8.
1 minute pozniej roboty sa przejete a natasha znika.  Inforo ¿e leci szkoloc hackerów.
1 minute pozniej dac research Hacker i briefing od natashy ze mozna robic hackerow. 




 markerLHero1  = 1
 markerLHero2  = 2
 markerEHero1  = 3
 markerRobots = 4
 markerUCSCenter = 5
 
 
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
		playerEnemy     = 1;
		playerNeutral1   = 6; // budynek bazy Przemytnikow
		playerNeutral2   = 8; // mechy do przejecia
		playerNeutral3   = 5; // natasha podczas hackowania
		
		goalLHero1MustSurvive = 0;
		goalLHero2MustSurvive = 1;
		goalEHeroMustSurvive = 2;
		goalCaptureControlCenter = 3;
		goalDestroyDefenders = 4;
		goalCaptureMechs = 5;

		markerLHero1 = 1;
		markerLHero2 = 2;
		markerEHero1 = 3;
		markerMechs = 4;
		markerControlCenter = 5;
		markerPatrol = 6;
	}

	player m_pPlayer;
	player m_pEnemy;
	player m_pNeutral1;
	player m_pNeutral2;
	player m_pNeutral3;
	

	unit m_uLHero1;
	unit m_uLHero2;
	unit m_uEHero1;
	unit m_uControlCenter;
	
	int m_nState;
	int m_bUnitDestroyed;    
	
	
	
	state Start;
	state MissionFlow;
	state XXX;

	state Initialize
	{
		int i;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(Enemy );
		INITIALIZE_PLAYER(Neutral1);
		INITIALIZE_PLAYER(Neutral2);
		INITIALIZE_PLAYER(Neutral3);
		
		RESTORE_SAVED_UNIT(Player, LHero1, eBufferLHero1);
		RESTORE_SAVED_UNIT(Player, LHero2, eBufferLHero2);
		RESTORE_SAVED_UNIT(Player, EHero1, eBufferEHero1);
		RestoreBestInfantryAtMarker(m_pPlayer, markerLHero1);
		FinishRestoreUnits(m_pPlayer);


		LookAtUnit(m_uLHero1);
		
		m_pEnemy.EnableAI(true);
		m_pNeutral1.EnableAI(false);
		m_pNeutral2.EnableAI(false);
		m_pNeutral3.EnableAI(false);
		AddUCSEnemyResearchesLCCampaign(m_pEnemy, 7);
		ActivateAI(m_pEnemy);
		m_pEnemy.SetAIControlOptions(eAIRebuildAllBuildings, true);
		m_pEnemy.SetAIControlOptions(eAIControlBuildBase, false);

		SetNeutrals(m_pPlayer,m_pNeutral1,m_pNeutral2,m_pNeutral3);
		SetNeutrals(m_pEnemy,m_pNeutral1,m_pNeutral2);
		m_pEnemy.SetEnemy(m_pPlayer);
		m_pPlayer.SetEnemy(m_pEnemy);
		
		


		m_pEnemy.AddResource(eCrystal, 4000+(GET_DIFFICULTY_LEVEL()*500));
		m_pEnemy.AddResource(eMetal, 4000+(GET_DIFFICULTY_LEVEL()*500));
		m_pPlayer.AddResource(eCrystal, 5000-(GET_DIFFICULTY_LEVEL()*500));
		m_pPlayer.AddResource(eWater, 5000-(GET_DIFFICULTY_LEVEL()*500));

					

		REGISTER_GOAL(LHero1MustSurvive);
		REGISTER_GOAL(LHero2MustSurvive);
		REGISTER_GOAL(EHeroMustSurvive);
		REGISTER_GOAL(CaptureControlCenter);
		REGISTER_GOAL(DestroyDefenders);
		REGISTER_GOAL(CaptureMechs);

		
		INITIALIZE_UNIT(ControlCenter);
		
		

		SetPlayerTemplateseLCCampaign(m_pPlayer, 7);
		SetPlayerResearchesLCCampaign(m_pPlayer, 7);
		//AddPlayerResearchesLCCampaign(m_pPlayer, 7);
		m_pPlayer.EnableResearch("RES_L_IN_HA_02_1"   , false);
		m_pPlayer.EnableResearch("RES_L_IN_HA_02_2"   , false);
		m_pPlayer.EnableResearch("RES_L_IN_HA_02_3"   , false);
			
		//XXXMD - wynalazki dodac do  ai ucs
		
			
		SetWind(0, 0);
		i = PlayCutscene("L_M7_C1.trc", true, true, true);
		return Start, i - eFadeTime;
	}

	

	state Start
	{
		m_nState=0;
		//m_nState=13;//XXXMD
		LookAtUnit(m_uLHero1);
		m_pPlayer.SetBuildBuildingsTimeMultiplyPercent(80+(GET_DIFFICULTY_LEVEL()*10));
		m_pPlayer.SetResearchTimeMultiplyPercent(80+(GET_DIFFICULTY_LEVEL()*10));
		FadeOutCutscene(60, 0, 0, 0);
		EnableInterface(true);
		ShowInterface(true);
		return MissionFlow, 160;


		
	}

	state MissionFlow
	{
		int i,nGx, nGy;

		if(m_nState==0)
		{
			m_nState = 100;
			LookAtUnit(m_uLHero1);
			ENABLE_GOAL(LHero1MustSurvive);
			ENABLE_GOAL(LHero2MustSurvive);
			ENABLE_GOAL(EHeroMustSurvive);
			ENABLE_GOAL(CaptureControlCenter);
			ENABLE_GOAL(DestroyDefenders);
			

			ADD_BRIEFING(Start_01, SZATMAR_HEAD);
			ADD_BRIEFING(Start_02, ARIA_HEAD);
			ADD_BRIEFING(Start_03, SZATMAR_HEAD);
			ADD_BRIEFING(Start_04, IGOR_HEAD);
			ADD_BRIEFING(Start_05, ARIA_HEAD);
			ADD_BRIEFING(Start_06, SZATMAR_HEAD);
			ADD_BRIEFING(Start_07, ARIA_HEAD);
			ADD_BRIEFING(Start_08, SZATMAR_HEAD);
			ADD_BRIEFING(Start_09, IGOR_HEAD);
			START_BRIEFING(false);
			WaitToEndBriefing(state, 60*30);
			return state;
		}
		if(m_nState==100)
		{
			m_nState = 1;
			AddAgent(8); //Predator
			return state,20*30;
		}
		if(m_nState==1)// szyukanie nieaktywnych mechow
		{
			VERIFY(GetMarker(markerMechs, nGx, nGy));
			if (!m_pPlayer.IsFogInPoint(nGx, nGy))
			{
				m_nState = 2;
				ENABLE_GOAL(CaptureMechs);
				ADD_BRIEFING(DisabledMechs_01,LC_SOLDIER_HEAD);
				ADD_BRIEFING(DisabledMechs_02,NATASHA_HEAD);
				ADD_BRIEFING(DisabledMechs_03,ARIA_HEAD);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 10*30);
				return state;
			}
		}
		if(m_nState==2)// mechy znalezione - porzystepujemy do hackowania
		{
			if (IsUnitNearMarker(m_uLHero2, markerMechs, 8))
			{
				m_uLHero2.SetPlayer(m_pNeutral3);
				m_pNeutral3.SetAlly(m_pPlayer);
				m_pPlayer.SetAlly(m_pNeutral3);
				m_nState = 25;
				ADD_BRIEFING(Hacking_01,NATASHA_HEAD);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 30);
				return state;
			}
		}
		if(m_nState==25)// mechy znalezione - porzystepujemy do hackowania
		{
			m_nState = 3;
			CreatePatrol(m_pEnemy, "U_CH_GT_03_1#U_WP_CH_03_2,U_AR_RL_03_1,U_EN_PR_03_1", 3+GET_DIFFICULTY_LEVEL()*3, markerPatrol, markerPatrol+1);		
			return state, 120*30;
		}
		if(m_nState==3)// mechy zhackowane
		{
				ACHIEVE_GOAL(CaptureMechs);
				ACHIEVE_GOAL(LHero2MustSurvive);
				m_uLHero2.RemoveObject();
				GiveAllUnitsToPlayer(m_pNeutral2, m_pPlayer);
				m_nState = 4;
				ADD_BRIEFINGS(CapturedMechs,NATASHA_HEAD, ARIA_HEAD, 7);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 120*30);
				return state;
		}		
		if(m_nState==4)// mechy zhackowane
		{
				m_nState = 5;
				m_pPlayer.EnableResearch("RES_L_IN_HA_02_1"  , true);
				m_pPlayer.EnableResearch("RES_L_IN_HA_02_2"   , true);
				m_pPlayer.EnableResearch("RES_L_IN_HA_02_3"   , true);
				m_pPlayer.AddResearch("RES_L_IN_HA_02_1");
				
				ADD_BRIEFINGS(Hackers,NATASHA_HEAD, ARIA_HEAD, 2);
				START_BRIEFING(false);
				WaitToEndBriefing(state, 30);
				return state;
		}
		
		if(m_nState==15)
		{
//Setally
			SetAlly(m_pPlayer,m_pNeutral1);
			EnableInterface(false);
			ShowInterface(false);
			FadeInCutscene(60, 0, 0, 0);			
			m_nState=16;
			return state,60;
		}
		if(m_nState==16)
		{
			SaveEndMissionGame(207,null);
			FadeOutCutscene(60, 0, 0, 0);
			m_nState=17;
			LookAtMarkerMedium(markerControlCenter, 0);
			DelayedLookAtMarkerMedium(markerControlCenter,128, 30*60, 0);
			return state, 60;
		}
		if(m_nState==17)
		{

			ADD_BRIEFINGS(Victory, CIVIL_HEAD, IGOR_HEAD, 21);
			START_BRIEFING(true);
			WaitToEndBriefing(state, 30);
			m_nState = 18;
			return state;
		}
		
		if(m_nState==18)
		{                      
			//SetLowConsoleText("translateL_M7_CampaignCompleted");
			SetWind(0, 0);SetTimer(2,0);
			EnableMessages(false);
			i = PlayCutscene("L_M7_C2.trc", true, true, true);
			return XXX,i-eFadeTime;
		
		}
		
		if(m_nState<15 && m_pEnemy.GetNumberOfBuildings()==0)//koniec
		{
			//XXXMD;
			m_nState=15;

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
	
	event RemovedUnit(unit uKilled, unit uAttacker, int nNotifyType)
	{
		// mission failed gdy zabijemy swojego lub wieznia

		
		if(m_nState>15) return;

		if ( uKilled == m_uLHero1 )
		{
			SetGoalState(goalLHero1MustSurvive, goalFailed);

			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state YYY;

			SetStateDelay(120);
		}
		if ( uKilled == m_uEHero1 )
		{
			SetGoalState(goalEHeroMustSurvive, goalFailed);

			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state YYY;

			SetStateDelay(120);
		}
		if ( uKilled == m_uLHero2 && m_uLHero2.GetHP()<=0 && GetGoalState(goalLHero2MustSurvive)!=goalAchieved)
		{
			SetGoalState(goalLHero2MustSurvive, goalFailed);

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
		if ( uKilled == m_uControlCenter)
		{
			
			SetGoalState(goalCaptureControlCenter, goalFailed);

			EnableInterface(false);
			ShowInterface(false);

			SetLowConsoleText("translateMissionFailed");

			FadeInCutscene(100, 0, 0, 0);

			state YYY;

			SetStateDelay(120);
			
		}
	}

	event AddedBuilding(unit uCreated, int nNotifyType)
	{

		
	}

    event EscapeCutscene(int nIFFNum)
    {
		int nTicks;//czas potrzebny na fadeOut
        if (state == Start || state==XXX)
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
