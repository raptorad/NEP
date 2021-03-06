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

	state fight;
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
			//eNoMoneyDisplay |
			//eNoMenuButton |
            eShowStatisticsOnExitSkirmish |
			0
			);
		pPlayer=GetPlayer(3);
		pEnemy=GetPlayer(2);

					
		
		pPlayer.SetEnemy(pEnemy);
		pEnemy.SetEnemy(pPlayer);
		pPlayer.AddResource(eMetal, 50000);
		pEnemy.AddResource(eMetal, 70000+(30000*GET_DIFFICULTY_LEVEL()));



		RegisterGoal(0, "translateLC_PROLOG_INTRO");
		EnableGoal(0,1);
		SetGoalState(0, true);		
		
		RegisterGoal(1, "translateDestroyAllEDUnits");
		EnableGoal(1, 1);



		

		for(n=0; n<GET_DIFFICULTY_LEVEL()+1;++n)
		{
			for (i=1; i<3; ++i)
			{
				CreatePlayerObjectsAtMarker(pEnemy, "EDSF_BC", 1, i);
			}

		}
		FreeAddUnitsToCarrier();
	   	GetStartingPoint(pPlayer.GetIFFNum(), nX, nY);
      	pPlayer.LookAt(nX, nY, 20,0,20);		
		return fight;
	}

	state fight
	{
		++Time;
		Time=Time%(30*60);
		if (Time==0)
		{
			pPlayer.AddResource(eMetal, 5000);
		}
		SquadsWork();


		if(pPlayer.GetNumberOfUnits()==0)
		{
			return MissionFailed;
		}
		return fight, 30;
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

		if(GetGoalState(1)==false)
		if(pEnemy.GetNumberOfUnits()==0)
		{
			SetGoalState(1, true);
			EndMission(true);

		}
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
