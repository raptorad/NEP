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
	#include  "..\..\Researches.ech"
	state Initialize; // musi byc ztutaj zeby od niego rozpoczal sie skrypt
	#include "..\..\dialog2.ech"
	int nStep;
	int i,n;
	int nX,nY;
	player Player; //1
	player Enemy;  //2
	

	state fight;

	state Initialize
	{

	
	InitCarriers();
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
		Player= GetPlayer(1);
	
		Enemy = GetPlayer(2);
		Player.SetEnemy(Enemy);
		Enemy.SetEnemy(Player);
		Enemy.EnableAI(true);
		RegisterGoal(1, "translateDestroyLC");
		EnableGoal(1, 1);
		 
		GetStartingPoint(Player.GetIFF(), nX, nY);
        Player.LookAt(nX, nY, 6,0,20);	

		GetStartingPoint(Player.GetIFFNum(), nX, nY);
   		Player.LookAt(nX, nY, 20,0,20);
		return fight;
	}
	
	state fight
	{
		SquadsWork();
		if(Enemy.GetNumberOfBuildings()==0)
		{
			SetGoalState(1, 1);
			EndMission(true);
		}
		if(Player.GetNumberOfBuildings()==0)
		{
			MissionDefeat();
		}
		return fight, 30;
	}
event AddedBuilding(unit Building,  int nNotifyType)
{
	CheckUCSRafinery(Building);
}

event AddedUnit(unit uUnit,  int nNotifyType)
{
	CheckCarrierUnit(uUnit);
}
}

