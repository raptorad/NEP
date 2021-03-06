#include "..\..\defines.ech"


#define MISSION_NAME "translateE_M3"




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
	#include  "..\..\Researches.ech"
	state Initialize; // musi byc ztutaj zeby od niego rozpoczal sie skrypt
	#include "..\..\dialog2.ech"
	int nStep;
	int i,n;
	int nX,nY;
	int Time;
	string sTimer;
			string Console2;
	player pPlayer;
	player pEnemy;
	player pAlly;
	player pWraki;
	unit uUnit;

	state part1;//I Atak
	state part2;//II Atak
	state part3;// III Atak
	state part4;
	state part5;
	state MissionFailed;
	state MissionFailed2;

	state Initialize
	{
		InitCarriers();
			SetInterfaceOptions(
			eNoConstructorDialog |
		    eNoResearchCenterDialog |
			eNoBuildingUpgradeDialog |
			eNoBuildPanelDialog |
			eNoMoneyConfigDialog |
			//eNoGoalsDialog |
			//eNoCommandsDialog |
			//eNoMapDialog |
			//eNoAllianceDialog |
			//eForceAllianceDialog |
			//eForceAllianceDialog |
			eNoMoneyDisplay |
			//eNoMenuButton |
            eShowStatisticsOnExitSkirmish |
			0
			);
		pPlayer=GetPlayer(3);
		pEnemy=GetPlayer(4);

		pAlly=GetPlayer(5);//ośrodek naukowy
		
		
		pPlayer.SetEnemy(pEnemy);
		pPlayer.SetAlly(pAlly);
		
		pEnemy.SetEnemy(pPlayer);
		pEnemy.SetAlly(pAlly);
		
		pAlly.SetEnemy(pEnemy);
		pAlly.SetAlly(pPlayer);


		for(n=0; n<GET_DIFFICULTY_LEVEL()+1;++n)
		{
				CreateAndMoveFromMarkerToMarker(pEnemy, "LC_CRION_ART.", 6, 1, 4);
				CreateAndMoveFromMarkerToMarker(pEnemy, "LC_CRION_ART.", 6, 2, 4);
				CreateAndMoveFromMarkerToMarker(pEnemy, "LC_CRATER_MG", 4, 3, 4);
		}
		GetStartingPoint(pPlayer.GetIFFNum(), nX, nY);
		
		RegisterGoal(0, "translateLC_M3_INTRO");
		EnableGoal(0,1);
		SetGoalState(0, true);		
		
		RegisterGoal(1, "translateLC_M3_1");//Zniszcz artylerie wroga wraz z eskortą
		RegisterGoal(2,"translateLC_M3_2");//Obroń bazę przed nalotem powietrznym
		RegisterGoal(3,"translateLC_M3_3");//Obroń bazę przed kolejnym atakiem
		RegisterGoal(4,"translateLC_M3_4"); //Ostatni atak
		RegisterGoal(5,"translateNorthBaseMustSurvive");//Baza na północy musi przetrwać
		EnableGoal(5, true);
		EnableGoal(1, true);

      	pPlayer.LookAt(nX, nY, 20,0,20);	

		return part1;
	}

	state part1
	{

		SquadsWork();

		if(pEnemy.GetNumberOfUnits()==0)
		{
			SetGoalState(1, true);
			EnableGoal(2,true);
						SetInterfaceOptions(
			//eNoConstructorDialog |
		    //eNoResearchCenterDialog |
			//eNoBuildingUpgradeDialog |
			//eNoBuildPanelDialog |
			//eNoMoneyConfigDialog |
			//eNoGoalsDialog |
			//eNoCommandsDialog |
			//eNoMapDialog |
			//eNoAllianceDialog |
			//eForceAllianceDialog |
			//eForceAllianceDialog |
			//eNoMoneyDisplay |
			//eNoMenuButton |
            eShowStatisticsOnExitSkirmish |
			0
			);
			pPlayer.SetResearchTimeMultiplyPercent(25);
			pPlayer.AddResource(eMetal,15000);
			pPlayer.AddResource(eCrystal,30000);
			GiveAllBuildingsToPlayer(pAlly, pPlayer);
			for(n=0; n<GET_DIFFICULTY_LEVEL()+1;++n)
			{
				CreateAndAttackFromMarkerToMarker(pEnemy, "LC_METEOR_E", 6, 1, 4);
				CreateAndAttackFromMarkerToMarker(pEnemy, "LC_THUNDER_HRA", 7, 2, 4);
				CreateAndAttackFromMarkerToMarker(pEnemy, "LC_SFIGHTER_2XE", 6, 3, 4);
			}
			return part2;
		}
		if(pPlayer.GetNumberOfUnits()==0 || pAlly.GetNumberOfBuildings("LC_RESEARCH_CENTER")==0)
		{
			return MissionFailed;
		}
		return part1, 30;
	}
	
	state part2
	{
		if(pEnemy.GetNumberOfUnits()==0)
		{
			SetGoalState(2, true);
			EnableGoal(3,true);
			pPlayer.AddResource(eMetal,10000);
			pPlayer.AddResource(eCrystal,10000);
			for(n=0; n<GET_DIFFICULTY_LEVEL()+1;++n)
			{
				CreateAndMoveFromMarkerToMarker(pEnemy, "LC_CRATER_RA.", 6, 5, 4);
				CreateAndAttackFromMarkerToMarker(pEnemy, "LC_FANG_ART.", 7, 5, 4);
				CreateAndAttackFromMarkerToMarker(pEnemy, "LC_FANG_MG", 8, 6, 4);
				CreateAndAttackFromMarkerToMarker(pEnemy, "LC_MOON_I", 5, 6, 4);
				CreateAndAttackFromMarkerToMarker(pEnemy, "LCSF_DD", 1, 1, 4);
			}
			return part3;
		}
		if(pPlayer.GetNumberOfUnits()==0 || pPlayer.GetNumberOfBuildings("LC_RESEARCH_CENTER")==0)
		{
			return MissionFailed;
		}
		return part2, 30;
	}
	
	state part3
	{
		if(pEnemy.GetNumberOfUnits()==0)
		{
			SetGoalState(3, true);
			EnableGoal(4,true);
			pPlayer.AddResource(eMetal,10000);
			pPlayer.AddResource(eCrystal,10000);
			for(n=0; n<GET_DIFFICULTY_LEVEL()+1;++n)
			{
				CreateAndMoveFromMarkerToMarker(pEnemy, "LC_FATGIRL_2S", 8, 5, 4);
				CreateAndMoveFromMarkerToMarker(pEnemy, "LC_FANG_ART.", 7, 5, 4);
				CreateAndAttackFromMarkerToMarker(pEnemy, "LC_THUNDER_BOMB", 4, 6, 4);
				CreateAndMoveFromMarkerToMarker(pEnemy, "LC_FANG_MG", 8, 6, 4);
				CreateAndMoveFromMarkerToMarker(pEnemy, "LC_MOON_I", 5, 6, 4);
			}
			return part4;
		}
		if(pPlayer.GetNumberOfUnits()==0 || pPlayer.GetNumberOfBuildings("LC_RESEARCH_CENTER")==0)
		{
			return MissionFailed;
		}
		return part3, 30;	
	}
	state part4
	{
		if(pEnemy.GetNumberOfUnits()==0)
		{
			SetGoalState(3, true);
			EnableGoal(4,true);
			pPlayer.AddResource(eMetal,10000);
			pPlayer.AddResource(eCrystal,10000);
			for(n=0; n<GET_DIFFICULTY_LEVEL()+1;++n)
			{
				CreateAndAttackFromMarkerToMarker(pEnemy, "LC_CRATER_RA.", 6, 5, 4);
				CreateAndMoveFromMarkerToMarker(pEnemy, "LC_CRUSCHER_2XS.", 7, 5, 4);
				CreateAndAttackFromMarkerToMarker(pEnemy, "LC_THUNDER_BOMB", 4, 6, 4);
				CreateAndAttackFromMarkerToMarker(pEnemy, "LC_CRUSCHER_2XE", 5, 6, 4);
				CreateAndAttackFromMarkerToMarker(pEnemy, "LCSF_DD", 2, 1, 4);
			}
			return part5;
		}
		if(pPlayer.GetNumberOfUnits()==0 || pPlayer.GetNumberOfBuildings("LC_RESEARCH_CENTER")==0)
		{
			return MissionFailed;
		}
		return part4, 30;
	}
	 state part5
	 {
		if(pEnemy.GetNumberOfUnits()==0)
		{
			SetGoalState(4, true);
			SetGoalState(5,true);
			EndMission(true);
		}	 
	 	if(pPlayer.GetNumberOfUnits()==0 || pPlayer.GetNumberOfBuildings("LC_RESEARCH_CENTER")==0)
		{
			return MissionFailed;
		}
		return part5, 30;
	 }
	
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
	event RemovedUnit(unit uKilled, unit uAttacker, int nNotifyType)
{
	AIKillStatictics(uKilled,uAttacker);
}
	event AddedUnit(unit uUnit, int nNotifyType)
	{
		CheckCarrierUnit(uUnit);
	}
	event AddedBuilding(unit Building,  int nNotifyType)
	{
		CheckUCSRafinery(Building);
	}
}
