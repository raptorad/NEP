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
	int nTime;
	string sTimer;
			string Console2;
	player P;
	player pPlayer;
	player pEnemy1;
	player pEnemy2;
	player pEnemy3;
	player pAlly1;
	player pAlly2;
	player pAlly3;


	state fight;
	state MissionFailed;
	state MissionFailed2;

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
		pAlly1=GetPlayer(4);//on ma działa
		pAlly2=GetPlayer(7); 
		pAlly3=GetPlayer(8);
		pEnemy1=GetPlayer(5);
		pEnemy2=GetPlayer(6);
		pEnemy3=GetPlayer(9);
		pPlayer.SetResearchTimeMultiplyPercent(25);
		
		for (i=5; i<10; ++i);
		{
			P=GetPlayer(i);
			P.EnableAI(true);
		}
		for (i=3; i<10; ++i)
		{
			P=GetPlayer(i);
			P.AddResearch("LC_LAND_TECH1");
			P.AddResearch("LC_ELECTRIC_CANNON");
			P.AddResearch("LC_SONIC_CANNON");
			P.AddResearch("LC_MAGNETIC_CANNON");
			P.AddResearch("LC_SDI");
			P.AddResearch("LC_RADAR");
			P.AddResearch("LC_AIR_TECH1");
			
		}

		
		pPlayer.SetEnemy(pEnemy1);
		pPlayer.SetEnemy(pEnemy2);
		pPlayer.SetEnemy(pEnemy3);
		pPlayer.SetAlly(pAlly1);
		pPlayer.SetAlly(pAlly2);
		pPlayer.SetAlly(pAlly3);
		
		pAlly1.SetEnemy(pEnemy1);
		pAlly1.SetEnemy(pEnemy2);
		pAlly1.SetEnemy(pEnemy3);
		pAlly1.SetAlly(pPlayer);
		pAlly1.SetAlly(pAlly2);
		pAlly1.SetAlly(pAlly3);
				
		pAlly2.SetEnemy(pEnemy1);
		pAlly2.SetEnemy(pEnemy2);
		pAlly2.SetEnemy(pEnemy3);
		pAlly2.SetAlly(pPlayer);
		pAlly2.SetAlly(pAlly1);
		pAlly2.SetAlly(pAlly3);
		
		pAlly3.SetEnemy(pEnemy1);
		pAlly3.SetEnemy(pEnemy2);
		pAlly3.SetEnemy(pEnemy3);
		pAlly3.SetAlly(pPlayer);
		pAlly3.SetAlly(pAlly1);
		pAlly3.SetAlly(pAlly2);
		
		pEnemy1.SetAlly(pEnemy2);
		pEnemy1.SetAlly(pEnemy3);
		pEnemy1.SetEnemy(pPlayer);
		pEnemy1.SetEnemy(pAlly1);
		pEnemy1.SetEnemy(pAlly2);
		pEnemy1.SetEnemy(pAlly3);
		
		pEnemy2.SetAlly(pEnemy1);
		pEnemy2.SetAlly(pEnemy3);
		pEnemy2.SetEnemy(pPlayer);
		pEnemy2.SetEnemy(pAlly1);
		pEnemy2.SetEnemy(pAlly2);
		pEnemy2.SetEnemy(pAlly3);
		
		pEnemy3.SetAlly(pEnemy1);
		pEnemy3.SetAlly(pEnemy2);
		pEnemy3.SetEnemy(pPlayer);
		pEnemy3.SetEnemy(pAlly1);
		pEnemy3.SetEnemy(pAlly2);
		pEnemy3.SetEnemy(pAlly3);

		pPlayer.AddResource(eMetal,15000);;			
		pAlly2.AddResource(eMetal,15000);
		pAlly3.AddResource(eMetal,15000);
		pEnemy1.AddResource(eMetal,4000+5000*GET_DIFFICULTY_LEVEL());
		pEnemy2.AddResource(eMetal,4000+5000*GET_DIFFICULTY_LEVEL());
		pEnemy3.AddResource(eMetal,4000+5000*GET_DIFFICULTY_LEVEL());

				
		ActivateAI(pEnemy1);
		ActivateAI(pEnemy2);
		ActivateAI(pEnemy3);
		ActivateAI(pAlly2);
		ActivateAI(pAlly3);
		
		
		RegisterGoal(0, "translateLC_M2_INTRO");
		EnableGoal(0,1);
		SetGoalState(0, true);		
		
		
		RegisterGoal(1, "translateDestroyAllEnemyStructuresOrSurvive30Min");
		RegisterGoal(2,"translate3SunlightCannonsMustSurvive");
		
		//RegisterGoal(1, "translateDestroyAllEnemies");
		//RegisterGoal(2,"translateProtectAlly");
		//RegisterGoal(3,"tranlsateBuildEvacuacionShips");
		EnableGoal(1, 1);
		EnableGoal(2, 1);

		

		for(n=0; n<GET_DIFFICULTY_LEVEL()+1;++n)
		{
			for (i=2; i<=3; ++i)
			{
				CreateAndAttackFromMarkerToMarker(pEnemy2, "LC_MOON_E", 3, i, 1);
				CreateAndAttackFromMarkerToMarker(pEnemy2, "LC_FANG_E", 2, i, 1);
			}
			for(i=4; i<=5;++i)
			{
					CreateAndAttackFromMarkerToMarker(pEnemy3, "LC_FANG_MG", 2, i, 1);
					CreateAndAttackFromMarkerToMarker(pEnemy3, "LC_FANG_ART.", 2, i, 1);
					CreateAndAttackFromMarkerToMarker(pEnemy3, "LC_CRATER_RA", 2, i, 1);							
			}
		}
		CreateAndAttackFromMarkerToMarker(pAlly2, "LC_CRATER_RA", 1, 6, 1);
		CreateAndAttackFromMarkerToMarker(pAlly2, "LC_FANG_ART", 1, 6, 1);
		CreateAndAttackFromMarkerToMarker(pAlly2, "LC_FANG_E", 2, 6, 1);
		
		CreateAndAttackFromMarkerToMarker(pAlly3, "LC_CRATER_RA", 1, 7, 1);
		CreateAndAttackFromMarkerToMarker(pAlly3, "LC_FANG_ART", 1, 7, 1);
		CreateAndAttackFromMarkerToMarker(pAlly3, "LC_FANG_E", 2, 7, 1);
		nTime=0;
    	GetStartingPoint(pPlayer.GetIFFNum(), nX, nY);
      	pPlayer.LookAt(nX, nY, 20,0,20);		
		return fight;
	}

	state fight
	{
		++nTime;
		SquadsWork();
		sTimer.Format("%d:%d",((30*60)-nTime)/60,((30*60)-nTime)%60);
		if(nTime==3*60)
		{
			pEnemy1.AddResearch("LC_AIR_TECH2");
			pEnemy2.AddResearch("LC_AIR_TECH2");
			pEnemy3.AddResearch("LC_AIR_TECH2");
		}
		if(nTime==12*60)
		{
			pEnemy1.AddResearch("LC_AIR_TECH3");
			pEnemy2.AddResearch("LC_AIR_TECH3");
			pEnemy3.AddResearch("LC_AIR_TECH3");		
		}
		if(nTime==10*60)
		{
			CreateAndMoveFromMarkerToMarker(pEnemy3, "LC_CRUSCHER_2XHRA", 2*GET_DIFFICULTY_LEVEL()+4, 10, 12);
		}
		if(nTime==15*60)
		{
			CreateAndMoveFromMarkerToMarker(pEnemy3, "LCSF_DD", 2*GET_DIFFICULTY_LEVEL()+2, 10, 1);	
			CreateAndMoveFromMarkerToMarker(pEnemy3, "LC_THUNDER_BOMB", 2*GET_DIFFICULTY_LEVEL()+3, 11, 1);			
		}
		if(nTime==20*60)
		{
			CreateAndMoveFromMarkerToMarker(pEnemy3, "LCSF_DD", 2*GET_DIFFICULTY_LEVEL()+2, 10, 12);
			CreateAndMoveFromMarkerToMarker(pEnemy3, "LC_CRUSCHER_2XHRA", 3*GET_DIFFICULTY_LEVEL()+6, 10, 12);	
			CreateAndMoveFromMarkerToMarker(pEnemy3, "LCSF_DD", 2*GET_DIFFICULTY_LEVEL()+2, 11, 12);		
		
		}
		if(nTime==25*60)
		{
			CreateAndMoveFromMarkerToMarker(pEnemy3, "LCSF_HCR", 2*GET_DIFFICULTY_LEVEL()+2, 10, 1);	
			CreateAndMoveFromMarkerToMarker(pEnemy3, "LCSF_BS", 2*GET_DIFFICULTY_LEVEL()+2, 11, 1);	
		}
		SetConsoleText(sTimer);
		if(GetGoalState(1)==false)
		if((!pEnemy1.IsAlive() &&  !pEnemy2.IsAlive() && !pEnemy3.IsAlive())||nTime>30*60)
		{
			SetGoalState(1, true);
			EndMission(true);
		}

		if(pAlly1.GetNumberOfBuildings("LC_SUNLIGHT_CANNON")<3)
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
	event RemovedBuilding(unit uKilled, unit uAttacker, int nNotifyType)
	{
		player pPlayer;
		pPlayer=GetPlayer(uKilled.GetIFFNum());
		if(pPlayer.GetNumberOfUnits()==0)
		{
			pPlayer.GameDefeat(true);
		}
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
