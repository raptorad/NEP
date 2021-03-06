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
	player m_pPlayerED; //2
	player m_pEnemyLC1;  //3
	player m_pAllyED; //4
	player m_pEnemyLC2; //5

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
			
		m_pPlayerED = GetPlayer(2);
		m_pEnemyLC1 = GetPlayer(3);
		m_pAllyED = GetPlayer(4);
		m_pEnemyLC2 = GetPlayer(5);
		
		
		m_pAllyED.EnableAI(true);
		m_pEnemyLC1.EnableAI(true);
		m_pEnemyLC2.EnableAI(true);
		
		m_pPlayerED.SetEnemy(m_pEnemyLC1);
		m_pPlayerED.SetEnemy(m_pEnemyLC2);
		m_pPlayerED.SetAlly(m_pAllyED);
	//	m_pAllyED.SetAlly(m_pPlayerED);	
		
		m_pAllyED.SetEnemy(m_pEnemyLC1);
		m_pAllyED.SetEnemy(m_pEnemyLC2);
		m_pAllyED.SetAlly(m_pPlayerED);	
		
		m_pEnemyLC1.SetEnemy(m_pPlayerED);
		m_pEnemyLC2.SetEnemy(m_pPlayerED);
		m_pEnemyLC1.SetEnemy(m_pAllyED);
		m_pEnemyLC2.SetEnemy(m_pAllyED);
		
		ActivateAI(m_pAllyED);
		ActivateAI(m_pEnemyLC1);
		ActivateAI(m_pEnemyLC2);
		
		m_pPlayerED.AddResource(0,5000);
		m_pPlayerED.AddResource(1,5000);
		m_pPlayerED.AddResource(2,5000);
		
		RegisterGoal(1, "translateDestroyNorthLCBase");
		RegisterGoal(2,"translateDestroySouthLCBase");
		EnableGoal(1, 1);
		EnableGoal(2, 1);

		

		for(n=0; n<GET_DIFFICULTY_LEVEL()+1;++n)
		{
			for (i=0; i<5; ++i)
			{
				GetMarker(i,nX,nY);
				m_pEnemyLC2.CreateObject("L_E_MOON", nX+n, nY+n, 0, 0);
				m_pEnemyLC2.CreateObject("L_I_MOON", nX+n, nY+n, 0, 0);	
				m_pEnemyLC2.CreateObject("L_E_FANG", nX+n, nY+n, 0, 0);	
				m_pEnemyLC2.CreateObject("L_E_FANG", nX+n, nY+n, 0, 0);	
				m_pEnemyLC2.CreateObject("L_A_FANG.", nX+n, nY+n, 0, 0);		
				m_pEnemyLC2.CreateObject("L_E_CRATER", nX+n, nY+n, 0, 0);
				m_pEnemyLC2.CreateObject("L_GURDIAN_1", nX+n, nY+n, 0, 0);
				m_pEnemyLC2.CreateObject("L_GURDIAN_1", nX+n, nY+n, 0, 0);
				m_pEnemyLC2.CreateObject("L_R_GUARDIAN", nX+n, nY+n, 0, 0);
			}
		}
    GetStartingPoint(m_pPlayerED.GetIFFNum(), nX, nY);
    m_pPlayerED.LookAt(nX, nY, 20,0,20);				
	return fight;
	}
	
	state fight
	{
		SquadsWork();
		if(GetGoalState(1)==false)
		{
			if(m_pEnemyLC1.GetNumberOfBuildings()==0)
			{
				SetGoalState(1, true);
			}
		}
		if(GetGoalState(2)==false)
		{
			if(m_pEnemyLC2.GetNumberOfBuildings()==0)
			{
				SetGoalState(2, true);
				m_pAllyED.AddResource(0,5000);
				m_pAllyED.AddResource(1,5000);
				m_pAllyED.AddResource(2,5000);
			}
		}
		if(GetGoalState(1)==true && GetGoalState(2)==true)
		{
			EndMission(true);
		}
		if(m_pPlayerED.GetNumberOfUnits()==0)
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
