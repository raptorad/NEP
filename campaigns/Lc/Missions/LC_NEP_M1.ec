
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
	player m_pPlayerLC; //3
	player m_pEnemyUCS; //1
	player m_pNeutralLC;//4
	player m_pAllyLC;//5
	unit uHero,uTank,uFleet,uSubordinate1,uSubordinate2;
	string Console,Console2,Console3;
	function void MoveToMarker(int nMarker,unit uUnit, player Player)
{
		if(IsUnitNearMarker(uUnit, nMarker,6))
		{
			for (i=0;i<Player.GetNumberOfUnits();++i)
			{
				CommandMoveUnitToMarker(Player.GetUnit(i),nMarker+10);
			}
			
		}
}
	state fight;

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
			eNoAllianceDialog |
			//eForceAllianceDialog |
			//eForceAllianceDialog |
			eNoMoneyDisplay |
			//eNoMenuButton |
            eShowStatisticsOnExitSkirmish |
			0
			);
		m_pPlayerLC = GetPlayer(3);
		m_pNeutralLC=GetPlayer(4);
		m_pEnemyUCS = GetPlayer(1);
		m_pAllyLC=GetPlayer(5);
		m_pPlayerLC.SetEnemy(m_pEnemyUCS);
		m_pPlayerLC.SetAlly(m_pAllyLC);
		m_pPlayerLC.SetNeutral(m_pNeutralLC);
		
		m_pEnemyUCS.SetEnemy(m_pPlayerLC);
		m_pEnemyUCS.SetNeutral(m_pNeutralLC);
		m_pEnemyUCS.SetEnemy(m_pAllyLC);
		
		m_pAllyLC.SetEnemy(m_pEnemyUCS);
		m_pAllyLC.SetAlly(m_pPlayerLC);
		m_pAllyLC.SetNeutral(m_pNeutralLC);
		RegisterGoal(0, "translateLC_M1_INTRO");
		EnableGoal(0,1);
		SetGoalState(0, true);		
				
		RegisterGoal(1, "translateDestroyAllUCSUnits");
		EnableGoal(1,1);


		 
		GetStartingPoint(m_pPlayerLC.GetIFF(), nX, nY);
   		
		GetStartingPoint(m_pPlayerLC.GetIFFNum(), nX, nY);
   		m_pPlayerLC.LookAt(nX, nY, 20,0,20);
		uHero=m_pPlayerLC.CreateObject("LC_HERO_JESICA", nX+n, nY, 2, 0);
		uHero.CommandSetAttackMode(1);
		return fight;
	}
	
	state fight
	{
		SquadsWork();

		if (!IsCameraFPPMode() && (uHero.IsSelected() || uTank.IsSelected()))
		{
			SetCameraFPPMode(true);
		}		
		if(!uHero.IsStored())
		{
			uTank=uHero.GetObjectContainingObject();
		}
		else
		{
			uTank=uHero;
		}		
 		nX=uTank.GetLocationX();
		nY=uTank.GetLocationY();
		MoveToMarker(2,uTank,m_pAllyLC);
		MoveToMarker(3,uTank,m_pAllyLC);
		MoveToMarker(4,uTank,m_pAllyLC);
		MoveToMarker(5,uTank,m_pAllyLC);
		MoveToMarker(6,uTank,m_pAllyLC);
		if(uSubordinate1.DistanceToClosestGrid(uTank)>200)
		{
			uSubordinate1.CommandMoveXYZA(nX,nY,0,0);
		}
		if(uSubordinate2.DistanceToClosestGrid(uTank)>200)
		{
			uSubordinate2.CommandMoveXYZA(nX,nY,0,0);
		}
		if (uTank.IsOutOfAmmo())
		{

			Console.Format("HP %d/%02d OUT OF AMMO",uTank.GetHP(),uTank.GetMaxHP());
		}
		else
		{
			Console.Format("HP %d/%02d",uTank.GetHP(),uTank.GetMaxHP());
		}
		Console2.Translate("transleteFPP");
		SetConsole2Text(Console2);

		SetConsoleText(Console);

		if(m_pEnemyUCS.GetNumberOfUnits()==0)
		{
			SetCameraFPPMode(false);
			SetGoalState(1, 1);
			EndMission(true);	
		}
		return fight;
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
	if (uKilled==uHero)
	{
		state MissionFailed;
	}
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

