#include "..\..\defines.ech"

#define MISSION_NAME "translateU_M2"

#define WAVE_MISSION_PREFIX "UCS\\M2\\U_M2_Brief_"


/*
ladowanie w bazie. 
   Ladowanie - strogov, kilka robotów i hackerek
                    Briefing - uciekac z miejsc ladowania, 
   
	ruszaja patrole do miejsc ladowania
   
	dziala zniszczone w 50%  - briefing od Rochlina - posilki  dla ED - ida w strone strogova
	dziala zniszczone  - koniec i film -mowiacy o przejeciu statku.	
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

		playerPlayer    = 1;
		playerEnemy     = 2;// ED obrona dzial
		
		
		
		goalEHero1MustSurvive = 0;
		goalDestroyCannons = 1;
		
		markerEHero1 = 1;
		markerLandingSite1 = 2;
		markerLandingSite2 = 3;
		markerLandingSite3 = 4;
		markerCannons = 5;

		markerPatrol = 6;
		markerReinforcements = 7;

		markerAttack = 11; // do 19


	}

	player m_pPlayer;
	player m_pEnemy;
	
	unit m_uEHero1;
	unit m_uCannons;
		
	int m_nState;
	int nAttackCounter;
	int m_bUnitDestroyed;    
    int m_bBuildingCounter;
	int m_bDestroyedBuildingsCounter;
	
	state Start;
	state MissionFlow;
	state XXX;

	function int SendAttackToPlayerBase()
	{
		int i, k, nGx, nGy,  bAirOnly, a,b,c;

        
        i = Rand(9);
		TraceD("                                       Create Attack: units:");TraceD(m_pEnemy.GetNumberOfUnits());TraceD("   marker:");TraceD(markerAttack+i);
		VERIFY(GetMarker(markerAttack+i, nGx, nGy));
		if (!m_pPlayer.IsFogInPoint(nGx, nGy))
		{
			TraceD("Failed              \n");
			return 0;
		}
		
		k = m_pPlayer.GetNumberOfVehicles()*(GET_DIFFICULTY_LEVEL()+1);

		k = k/3;
		if(!GET_DIFFICULTY_LEVEL())k=k/2;
		if(k>15) k=15;
        if(k<1)k=1;
		
		
			CreateAndAttackFromMarkerToUnit(m_pEnemy, "E_IN_MA_01_1", k*2, markerAttack+i, m_uEHero1);
			
			CreateAndAttackFromMarkerToUnit(m_pEnemy, "E_IN_BA_02_1", k, markerAttack+i, m_uEHero1);
			if(m_bBuildingCounter>15+7+7+7) CreateAndAttackFromMarkerToUnit(m_pEnemy, "E_CH_GJ_02_1#E_WP_CR_02_1,E_AR_CL_02_3,E_EN_SP_02_1", 2, markerAttack+i, m_uEHero1);

			if(Rand(2)) CreateAndAttackFromMarkerToUnit(m_pEnemy, "E_IN_CO_03_1", 1, markerAttack+i, m_uEHero1);
			else CreateAndAttackFromMarkerToUnit(m_pEnemy, "E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_CL_03_1,E_EN_SP_03_1", 2, markerAttack+i, m_uEHero1);
		
		CreateAndAttackFromMarkerToUnit(m_pEnemy, "E_CH_AJ_01_1#E_WP_SL_01_1,E_AR_CH_01_1,E_EN_NO_01_1", k/2, markerAttack+i, m_uEHero1);

		TraceD(" poszlo             \n");
		return 1;

	}


	function void CreateEDPatrols()
	{
		int i, k;

		k=3+(GET_DIFFICULTY_LEVEL()*2);

		
		CreatePatrol(m_pEnemy, "E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_CH_03_1,E_EN_SP_03_1", k, markerPatrol, markerLandingSite1);
		CreatePatrol(m_pEnemy, "E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_CH_03_1,E_EN_SP_03_1", k, markerPatrol, markerLandingSite2);
		CreatePatrol(m_pEnemy, "E_CH_GJ_03_1#E_WP_SL_03_1,E_AR_CH_03_1,E_EN_SP_03_1", k, markerPatrol, markerLandingSite3);
			
	}

	function void CreateReinforcements()
	{
		CreateAndAttackFromMarkerToUnit(m_pEnemy, "E_CH_GT_04_1#E_WP_HL_04_1,E_AR_CL_04_1,E_EN_NO_04_1,E_IE_SG_04_3", 3+(GET_DIFFICULTY_LEVEL()), markerReinforcements, m_uEHero1);		
		CreateAndAttackFromMarkerToUnit(m_pEnemy, "E_CH_GT_04_1#E_WP_CA_04_1,E_AR_RL_04_3,E_EN_SP_04_1,E_IE_SG_04_3", 2+(GET_DIFFICULTY_LEVEL()), markerReinforcements, m_uEHero1);		
		CreateAndAttackFromMarkerToUnit(m_pEnemy, "E_CH_AJ_01_1#E_WP_SL_01_3,E_AR_CL_01_3,E_EN_SP_01_1,E_IE_SG_01_3", 3+(GET_DIFFICULTY_LEVEL()*3), markerReinforcements, m_uEHero1);		
		CreateAndAttackFromMarkerToUnit(m_pEnemy, "E_CH_GA_08_1#E_WP_GR_08_1,E_AR_RL_08_3,E_EN_SP_08_1,E_IE_SG_01_3",1+GET_DIFFICULTY_LEVEL(), markerReinforcements, m_uEHero1);		

		if(GET_DIFFICULTY_LEVEL()>1)
			CreateAndAttackFromMarkerToUnit(m_pEnemy, "E_CH_GA_08_1#E_WP_GR_08_1,E_AR_CL_08_1,E_EN_SP_08_1,E_IE_SG_01_3",GET_DIFFICULTY_LEVEL(), markerReinforcements, m_uEHero1);		

	}

	int m_bAIActive;
	int m_AgentAdded;
	
	state Initialize
	{
		int i;
		unit uVehicle;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player );
		INITIALIZE_PLAYER(Enemy );
		
		m_pEnemy.EnableAI(false);
		m_bAIActive = false;
		SetPlayerTemplateseUCSCampaign(m_pPlayer, 2);
		SetPlayerResearchesUCSCampaign(m_pPlayer, 2);
		
		SetPlayerResearchesEDCampaign(m_pEnemy, 3);
		
		
		SetEnemies(m_pEnemy,m_pPlayer);
		
		REGISTER_GOAL(EHero1MustSurvive);
		REGISTER_GOAL(DestroyCannons);
		
		
		RESTORE_SAVED_UNIT(Player, EHero1, eBufferEHero1);
		
		CreatePlayerObjectAtMarker(m_pPlayer,"U_CH_AR_08_1", markerLandingSite1);
		CreatePlayerObjectAtMarker(m_pPlayer,"U_CH_AH_10_1#U_EN_NO_10_1", markerLandingSite2);
		CreatePlayerObjectAtMarker(m_pPlayer,"U_CH_AH_10_1#U_EN_NO_10_1", markerLandingSite3);
		if(GET_DIFFICULTY_LEVEL()==0)
		{
			m_pEnemy.EnableResearch("RES_E_CH_GT_04_1"    , false);
			m_pPlayer.CreateObject("U_CH_AH_10_1#U_EN_NO_10_1", 33,221, 0, 0);
			m_pPlayer.CreateObject("U_CH_AH_10_1#U_EN_NO_10_1", 225,225, 0, 0);
			
			RemoveUnitAtPoint(88,146);
			RemoveUnitAtPoint(92,148);
			RemoveUnitAtPoint(92,146);
		}
			

		LookAtUnit(m_uEHero1);
		
		INITIALIZE_UNIT(Cannons);
		
		SetWind(0, 0);
		i = PlayCutscene("U_M2_C1.trc", true, true, true);
		return Start, i-eFadeTime;
	}

	

	state Start
	{

		m_nState=0;
		//m_nState=30;//XXXMD
		LookAtUnit(m_uEHero1);
		m_pPlayer.AddResource(eCrystal, 5000);
		m_pPlayer.AddResource(eMetal, 5000);

		m_pEnemy.AddResource(eMetal, 5000);
		m_pEnemy.AddResource(eWater, 5000);
		m_AgentAdded=false;
		return MissionFlow, 160;


		
	}
	
	int m_nKillCounter;
	state MissionFlow
	{
		int i,nGx, nGy;

		if(m_nState==0)
		{
			m_nState = 1;
			m_bDestroyedBuildingsCounter = 0;
			ENABLE_GOAL(EHero1MustSurvive);
			ENABLE_GOAL(DestroyCannons);
			ADD_BRIEFINGS(Start,IGOR_HEAD,ARIA_HEAD,7);
			EnableInterface(false);
			START_BRIEFING(eInterfaceDisabled);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(m_nState==1)// uruchomic patrole ED
		{
			EnableInterface(true);
			CreateEDPatrols();
			m_bBuildingCounter = 15;
			m_nState = 2;
			return state;
		}
		if(m_nState==2)
		{	
			if(GET_DIFFICULTY_LEVEL())
			{
				if(m_bBuildingCounter<30 && m_pPlayer.GetNumberOfBuildings()>=m_bBuildingCounter)
				{
					if(SendAttackToPlayerBase())m_bBuildingCounter = m_bBuildingCounter+7;
				}
				
				if(m_bDestroyedBuildingsCounter==12 || m_bDestroyedBuildingsCounter==26 || m_bDestroyedBuildingsCounter==35)
				{
					
					if(SendAttackToPlayerBase()) ++m_bDestroyedBuildingsCounter;
				}
			}

			if(!m_AgentAdded && m_pPlayer.GetNumberOfBuildings()> 5)
			{
				AddAgent(11); //Szajba
				m_AgentAdded = true;
			}

			if(!m_bAIActive && (m_pPlayer.GetNumberOfBuildings()>=(40-GET_DIFFICULTY_LEVEL()*5) || m_bDestroyedBuildingsCounter))
			{
				m_bAIActive = true;
				m_pEnemy.EnableAI(true);
				ActivateAI(m_pEnemy);
				m_pEnemy.SetAIControlOptions(eAIRebuildAllBuildings, true);
				m_pEnemy.SetAIControlOptions(eAIControlBuildBase, false);
			}

			if (m_bAIActive && (m_uCannons.GetHP()<m_uCannons.GetMaxHP() || m_bDestroyedBuildingsCounter>40))
			{
				m_nState = 3;
				ADD_BRIEFINGS(DestroyingCannons,ROCHLIN_HEAD,IGOR_HEAD,4);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 10*30);
				return state;
			}
			return state;
		}

		if(m_nState==3)
		{
			CreateReinforcements();
			m_nState=4;
			return state, 60;
		}

		if(m_nState==4)
		{
			if(!m_uCannons.IsLive())
			{
				m_nState = 15;
				ACHIEVE_GOAL(DestroyCannons);
				SetNeutrals(m_pEnemy,m_pPlayer);
				ADD_BRIEFINGS(CannonsDestroyed,IGOR_HEAD,ARIA_HEAD,4);
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 5*30);
			}
			return state, 5*30;
		}
		
		if(m_nState==15)
		{
			SaveEndMissionGame(302,null);
			EnableInterface(false);
			ShowInterface(false);
			m_nState=18;
			return state,60;
		}
		if(m_nState==18)
		{       
			SetWind(0, 0);SetTimer(2,0);
			EnableMessages(false);
			i = PlayCutscene("U_M2_C2.trc", true, true, true);
			return XXX, i-eFadeTime;
		
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
		if(uKilled.GetIFF()==m_pEnemy.GetIFF) ++m_bDestroyedBuildingsCounter;
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
