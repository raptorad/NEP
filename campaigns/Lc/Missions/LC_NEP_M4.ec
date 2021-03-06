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
	player pEnemy2; //Działa
	player pWraki;
	unit uUnit;
	

	state fight;
	state MissionFailed;
	state MissionFailed2;

function void EnableLCBuildings(player P, int b)
{
	P.EnableBuilding("LC_XENO_PLANT", b);
	P.EnableBuilding("LC_UNIT_FACTORY", b);
	P.EnableBuilding("LC_BARACKS", b);
	P.EnableBuilding("LC_RESEARCH_CENTER", b);
	P.EnableBuilding("LC_BATERY", b);
	P.EnableBuilding("LC_SUPLY_CENTER", b);
	P.EnableBuilding("LC_MINE", b);	
	P.EnableBuilding("LC_LASER_FANCE", b);
	P.EnableBuilding("LC_TWIN_TOWER", b);
	P.EnableBuilding("LC_HEAVY_TOWER_C3", b);
	P.EnableBuilding("LC_BASTION", b);
	P.EnableBuilding("LC_ALTILERY_NEST", b);	
	P.EnableBuilding("LC_SDI_CENTER", b);
	P.EnableBuilding("LC_SUNLIGHT_CANNON", b);
	P.EnableBuilding("LC_ANTI_SCHIP_CANNON", b);
	P.EnableBuilding("LC_BL_BARD", b);
}
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
		pPlayer=GetPlayer(3);
		pPlayer.SetResearchTimeMultiplyPercent(50);
		pEnemy2=GetPlayer(4);//on ma działa
		pEnemy=GetPlayer(2);     pEnemy.EnableAI(true);
		pWraki=GetPlayer(5);

		EnableLCBuildings(pPlayer , false);			
		
		pPlayer.SetEnemy(pEnemy);
		pPlayer.SetEnemy(pEnemy2);
		
		pEnemy.SetEnemy(pPlayer);
		pEnemy.SetAlly(pEnemy2);
		
		pEnemy2.SetEnemy(pPlayer);
		pEnemy2.SetAlly(pEnemy);

		pPlayer.AddResource(0,10000);
		pPlayer.AddResource(1,10000);
		pPlayer.AddResource(2,10000);			

		pEnemy.AddResource(0,15000);
		pEnemy.AddResource(1,15000);
		pEnemy.AddResource(2,15000);
		ActivateAI(pEnemy);
		AddEnemyResearchesLCCampaign(pEnemy, 4);
		GetStartingPoint(pPlayer.GetIFFNum(), nX, nY);
		for(n=1;n<5;++n)
		{
			uUnit=pPlayer.CreateObject("LC_MERKURY_I", nX+n, nY, 2, 0);
			for(i=1;i<9;++i)
			{
				uUnit.CreateTransportedCrew("LC_GURDIAN_1");
			}
		}
		for (n=1; n<(3-GET_DIFFICULTY_LEVEL())*2+2;++n)
		{
			pPlayer.CreateObject("LC_CRUSCHER_2XMG_2XR", nX+n, nY+20, 0, 0);
		}
		RegisterGoal(0, "translateLC_M4_INTRO");
		EnableGoal(0,1);
		SetGoalState(0, true);		
		
		RegisterGoal(1, "translateDestroyAllEnemyStructures");
		EnableGoal(1, 1);

      	pPlayer.LookAt(nX, nY, 20,0,20);	

		return fight;
	}

	state fight
	{

		SquadsWork();

		if(GetGoalState(1)==false)
		if(pEnemy.GetNumberOfBuildings()==0 &&  pEnemy2.GetNumberOfBuildings()==0)
		{
			SetGoalState(1, true);
			EndMission(true);
		}

		if(pPlayer.GetNumberOfUnits()==0 && pPlayer.GetNumberOfUnits()==0)
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
