#include "..\..\defines.ech"

#define MISSION_NAME "translateU_M7"

#define WAVE_MISSION_PREFIX "UCS\\M7\\U_M7_Brief_"


/*
ladowanie - briefing zniszcz siedliska obcych

znalezienie bazy z przejetymi ludzikami ed - briefing od troffa 

zniszczenie jakiegokolwiek unita z ai 7 - briefing od Troffa - radzisz sobe dobrze w tescie ktory przygotowalem, 

zniszczenie wszystkichj byudynków ai 7 -  briefing of troffa - brawo zdales test - zabieram cie  do siebie - cutscena z krazownikami

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
		playerPlayer    = 1;
		playerEnemy1     = 4;// Aliens
		playerEnemy2     = 6;// Aliens
		playerEnemy3     = 7;// Aliens
		playerNeutral = 2; //ED - infected guys
		
		goalEHero1MustSurvive = 0;
		goalDestroyAliens = 1;
		
		markerEHero1 = 1;
		markerAlienBase1 = 2;
		markerFirstWave = 3; //-7
		markerSecondWave = 8; //-10
		markerThirdWave = 11;//-13
		markerInfected =14;
	}

	player m_pPlayer;
	player m_pEnemy1;
	player m_pEnemy2;
	player m_pEnemy3;
	player m_pNeutral;

	unit m_uEHero1;

	int bEndSecondWave;
	int m_nAttackCounter;
	int m_nState;
		
	state Start;
	state MissionFlow;
	state XXX;

	function void CreateFirstWave()
	{
		int i, k;

		i = Rand(5);

		k = 3+(GET_DIFFICULTY_LEVEL()*2)+m_pPlayer.GetNumberOfUnits()/4;
		if(k>10)k=10;
		if(!GET_DIFFICULTY_LEVEL())k=2;
		if(Rand(2))
		{
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_GJ_02_2", k/2, markerFirstWave+i, m_uEHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_GJ_03_2", k/2, markerFirstWave+i, m_uEHero1);
		}
		else
		{
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_GJ_02_1", k, markerFirstWave+i, m_uEHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_GJ_02_2", k/2, markerFirstWave+i, m_uEHero1);
		}
		
	}

	function void CreateSecondWave()
	{
		int i, k;

		i = Rand(3);

		k = 3+(GET_DIFFICULTY_LEVEL()*2)+m_pPlayer.GetNumberOfUnits()/4;
		if(k>10)k=10;

		if(!GET_DIFFICULTY_LEVEL())k=2;
		if(Rand(2))
		{
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_GJ_02_1", k, markerSecondWave+i, m_uEHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_GJ_03_2", k, markerSecondWave+i, m_uEHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_GT_04_1", k/2, markerSecondWave+i, m_uEHero1);
		}
		else
		{
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_GJ_03_1", k, markerSecondWave+i, m_uEHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_GJ_02_2", k, markerSecondWave+i, m_uEHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_GT_04_2", k/2, markerSecondWave+i, m_uEHero1);
		}
		
	}

	function void CreateThirdWave()
	{
		int i, k, nGx, nGy;

		i = Rand(3);
		VERIFY(GetMarker(markerThirdWave+i, nGx, nGy));
		if (!m_pPlayer.IsFogInPoint(nGx, nGy))
		{
			if(i) i=0;
			else i=1;
			VERIFY(GetMarker(markerThirdWave+i, nGx, nGy));
			if (!m_pPlayer.IsFogInPoint(nGx, nGy)) return;
		}

		k = 3+(GET_DIFFICULTY_LEVEL()*2)+m_pPlayer.GetNumberOfUnits()/4;

		if(k>10)k=10;
		if(!GET_DIFFICULTY_LEVEL())k=2;
		if(Rand(2))
		{
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_LC_13_1", 1, markerThirdWave+i, m_uEHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_GJ_03_2", k, markerThirdWave+i, m_uEHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_GA_05_1", k/2, markerThirdWave+i, m_uEHero1);
		}
		else
		{
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_AF_12_1", k/2, markerThirdWave+i, m_uEHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_GJ_03_1", k, markerThirdWave+i, m_uEHero1);
			CreateAndAttackFromMarkerToUnit(m_pEnemy1, "A_CH_GT_04_2", k/2, markerThirdWave+i, m_uEHero1);
		}
		
	}
	function void CreateFinalWave(unit uUnit)
	{
		int i, k, nGx, nGy,nX1, nY1, nX2, nY2, nDx1, nDy1, nDx2, nDy2;
		
		// duzo statkow wokol  unita
		uUnit.GetLocation(nGx, nGy);

		nGx = A2G(nGx);
		nGy = A2G(nGy);

		for (i=0; i<26; i=i+1)
		{
			//TurnRadiusByAngle(int nR, int nAngle, int& pDx, int& pDy)

			TurnRadiusByAngle(23, i*10, nDx1, nDy1);
			TurnRadiusByAngle(3+5*(i%4), i*10, nDx2, nDy2);
			nX1 = nGx + nDx1;
			nY1 = nGy + nDy1;
			nX2 = nGx + nDx2;
			nY2 = nGy + nDy2;
			if(nX1>16 && nX1<256-16 &&nY1>16 && nY1<256-16)
			{
				if((i%4)==0)CreateAndAttackFromPointToPoint(m_pEnemy3, "A_CH_AF_12_1", 1, nX1, nY1, nX2, nY2);
				if((i%4)==1)CreateAndAttackFromPointToPoint(m_pEnemy3, "A_CH_LC_13_1", 1, nX1, nY1, nX2, nY2);
				if((i%4)==2)CreateAndAttackFromPointToPoint(m_pEnemy3, "A_CH_HC_14_1", 1, nX1, nY1, nX2, nY2);
				if((i%4)==3)CreateAndAttackFromPointToPoint(m_pEnemy3, "A_CH_DE_15_1", 1, nX1, nY1, nX2, nY2);
			}
		}
	}


	state Initialize
	{
		int i;
		unit uVehicle;

		FadeInCutscene(0, 0, 0, 0);

		INITIALIZE_PLAYER(Player);
		INITIALIZE_PLAYER(Enemy1);
		INITIALIZE_PLAYER(Enemy2);
		INITIALIZE_PLAYER(Enemy3);
		INITIALIZE_PLAYER(Neutral);
		
		m_pEnemy1.EnableAI(false);
		m_pEnemy2.EnableAI(false);
		m_pEnemy3.EnableAI(false);
		m_pNeutral.EnableAI(false);


		// BY TZ

		if(GET_DIFFICULTY_LEVEL() == 0)// easy
		{
			for(i=40; i<=116;i=i+1) RemoveUnitAtMarker(i);
			for(i=120; i<=130;i=i+1) RemoveUnitAtMarker(i);//alien nests
		}

		if(GET_DIFFICULTY_LEVEL() == 1)// middle
		{
			for(i=27; i<=33;i=i+1) RemoveUnitAtMarker(i);
			for(i=90; i<=116;i=i+1) RemoveUnitAtMarker(i);
		}

		if(GET_DIFFICULTY_LEVEL() == 2)//hard
		{
			for(i=20; i<=33;i=i+1) RemoveUnitAtMarker(i);
		}


		SetPlayerTemplateseUCSCampaign(m_pPlayer, 7);
		SetPlayerResearchesUCSCampaign(m_pPlayer, 7);
		//AddPlayerResearchesUCSCampaign(m_pPlayer, 7);

		SetEnemies(m_pEnemy1,m_pPlayer);
		SetNeutrals(m_pNeutral,m_pPlayer);
		SetNeutrals(m_pNeutral,m_pEnemy1,m_pEnemy2,m_pEnemy3);

		//ACTIVATE_AI(m_pEnemy1);

		REGISTER_GOAL(EHero1MustSurvive);
		REGISTER_GOAL(DestroyAliens);
		
		RESTORE_SAVED_UNIT(Player, EHero1, eBufferEHero1);
		RestoreBestInfantryAtMarker(m_pPlayer, markerEHero1);
		FinishRestoreUnits(m_pPlayer);

		
		SetWind(20, 0);
		i = PlayCutscene("U_M7_C1.trc", true, true, true);
		return Start, i-eFadeTime;
		
		
	}

	

	state Start
	{
		m_nState=0;
		//m_nState=5;//XXXMD
		LookAtUnit(m_uEHero1);
		m_pPlayer.AddResource(eCrystal, 5000);
		m_pPlayer.AddResource(eMetal, 5000);
		return MissionFlow, eFadeTime;


		
	}
	int m_nKillCounter;
	state MissionFlow
	{
		int i,nGx, nGy;
		int nAx, nAy;

		if(m_nState==0)
		{
			m_nState = 11;
			EnableInterface(false);
			ENABLE_GOAL(EHero1MustSurvive);
			ENABLE_GOAL(DestroyAliens);
		
			ADD_BRIEFINGS(Start1,IGOR_HEAD,SZATMAR_HEAD,3);
			ADD_BRIEFINGS(Start2,ARIA_HEAD,IGOR_HEAD,2);
			ADD_BRIEFINGS(Start3,PROFFESOR_HEAD,IGOR_HEAD,2);
			ADD_BRIEFINGS(Start4,NATASHA_HEAD,IGOR_HEAD,2);
			START_BRIEFING(eInterfaceDisabled);
			WaitToEndBriefing(state, 30);
			return state;
		}
		if(m_nState==11)
		{
			m_nState = 1;
			EnableInterface(true);
			return state;
		}
		
		if(m_nState==1)// rozbudowa
		{
			if(m_pPlayer.GetNumberOfBuildings()>10)
			{
				m_nState=2;
				m_nAttackCounter = 0;
				CreateFirstWave();
			}
			return state;
		}
		if(m_nState==2)
		{
			++m_nAttackCounter;
			if(m_nAttackCounter> 60*5-(GET_DIFFICULTY_LEVEL()*30))
			{
				m_nAttackCounter = 0;
				CreateFirstWave();
			}
			VERIFY(GetMarker(markerInfected, nGx, nGy));
			if (!m_pPlayer.IsFogInPoint(nGx, nGy))
			{
				m_nState = 3;
				SetAlly(m_pPlayer, m_pNeutral);
				LookAtMarkerMedium(markerInfected,0);
				DelayedLookAtMarkerMedium(markerInfected,192,30*30,1);
				ADD_BRIEFINGS(FirstEncounter,BAD_TROFF_HEAD,IGOR_HEAD,8);// witaj  majorze, proponuje panu wielka potege,  ci zolnierze z robia wszystko ...bla bla bla
				START_BRIEFING(eInterfaceDisabled);
				WaitToEndBriefing(state, 30);
				return state;
			}
			return state,30;
		}


		if(m_nState==3)
		{
			m_nState = 4;
			LookAtMarkerMedium(markerInfected,0);
			SetEnemies(m_pNeutral, m_pPlayer);
			m_nAttackCounter = 0;
			CreateSecondWave();
			return state,30;
		}
		
		if(m_nState==4)// uciekaj Igor
		{
			++m_nAttackCounter;
			if(m_nAttackCounter> 60*4-(GET_DIFFICULTY_LEVEL()*30))
			{
				m_nAttackCounter = 0;
				CreateSecondWave();
			}
			if(bEndSecondWave)
			{
				m_nState = 5;
				m_nAttackCounter = 120;
				ADD_BRIEFINGS(SecondEncounter,BAD_TROFF_HEAD,IGOR_HEAD,8);// dobrze sobie radzisz  - przyda mi sie taki zdolny przywodzca - przed toba ostatni test -czy zdolasz  zdobyc moja baze?
				START_BRIEFING(eInterfaceEnabled);
				WaitToEndBriefing(state, 5*30);

				return state;
			}
			return state,30;
		
		}
		if(m_nState==5)
		{
			++m_nAttackCounter;
			if(m_nAttackCounter> 60*4 - (GET_DIFFICULTY_LEVEL()*30))
			{
				m_nAttackCounter = 0;
				CreateThirdWave();
			}
			if (!m_pEnemy3.GetNumberOfBuildings() && !m_pEnemy3.GetNumberOfUnits())
			{
				m_nState = 6;
				SetAlly(m_pPlayer, m_pEnemy3);
				ACHIEVE_GOAL(DestroyAliens);
				ADD_BRIEFINGS(ThirdEncounter,BAD_TROFF_HEAD,IGOR_HEAD,3);// Excellent - zapraszam do mnie. opor nie ma sensu. 
				ADD_BRIEFING(ThirdEncounter2,ARIA_HEAD);
				ADD_BRIEFINGS(ThirdEncounter3,IGOR_HEAD,BAD_TROFF_HEAD,4);
				START_BRIEFING(eInterfaceDisabled);
				WaitToEndBriefing(state, 10*30);
				return state;
			}
			return state,30;
		}
		if(m_nState==6)
		{
			m_nState = 15;
			SetAlly(m_pPlayer, m_pEnemy3);
			EnableInterface(false);
			ShowInterface(false);
			CreateFinalWave(m_uEHero1);
			m_uEHero1.CommandStop();
	
			m_uEHero1.GetLocation(nAx, nAy);
			LookAt(nAx, nAy, 15, 64, 50);
//			DelayedLookAt(int nX, int nY, int nZ, int nAngle, int nViewAngle, int nDelay, int bClockWise)
			DelayedLookAt(nAx, nAy,35,128, 45, 9*30+150, 1);    //zoom out  //xxxmd
			return state, 9*30;
		}
		if(m_nState==15)
		{
			SaveEndMissionGame(307,null);
			m_nState=18;
			return state,60;
		}
		if(m_nState==18)
		{                      
			SetWind(0, 0);SetTimer(2,0);
			EnableMessages(false);
			i = PlayCutscene("U_M7_C2.trc", true, true, true);
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
	}

	event RemovedBuilding(unit uKilled, unit uAttacker, int nNotifyType)
	{
		if(uKilled.GetIFF()==m_pEnemy2.GetIFF())
			bEndSecondWave = true;
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
