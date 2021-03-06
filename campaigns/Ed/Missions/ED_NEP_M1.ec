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
	player m_pEnemyLC;  //3
	

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
		m_pPlayerED = GetPlayer(2);
	
		m_pEnemyLC = GetPlayer(3);
		m_pPlayerED.SetEnemy(m_pEnemyLC);
		m_pEnemyLC.SetEnemy(m_pPlayerED);
		RegisterGoal(1, "translateDestroyLC");
		EnableGoal(1, 1);
		 
		GetStartingPoint(m_pPlayerED.GetIFF(), nX, nY);
        m_pPlayerED.LookAt(nX, nY, 6,0,20);	
		

		for(n=0; n<GET_DIFFICULTY_LEVEL()+1;++n)
		{
			for (i=0; i<9; ++i)
			{
				GetMarker(i,nX,nY);
				m_pEnemyLC.CreateObject("L_E_MOON", nX+n, nY+n, 0, 0);
				m_pEnemyLC.CreateObject("L_I_MOON", nX+n, nY+n, 0, 0);	
				m_pEnemyLC.CreateObject("L_E_FANG", nX+n, nY+n, 0, 0);	
				m_pEnemyLC.CreateObject("L_E_FANG", nX+n, nY+n, 0, 0);	
				m_pEnemyLC.CreateObject("L_A_FANG", nX+n, nY+n, 0, 0);
				if((i+n)%2==0)
				{
					m_pEnemyLC.CreateObject("L_A_FANG", nX+n, nY+n, 0, 0);
				}
				else
				{		
					m_pEnemyLC.CreateObject("L_R_CRATER", nX+n, nY+n, 0, 0);
				}
				m_pEnemyLC.CreateObject("L_GURDIAN_1", nX+n, nY+n, 0, 0);
				m_pEnemyLC.CreateObject("L_GURDIAN_1", nX+n, nY+n, 0, 0);				
				m_pEnemyLC.CreateObject("L_R_GUARDIAN", nX+n, nY+n, 0, 0);
			}
		}
		GetStartingPoint(m_pPlayerED.GetIFFNum(), nX, nY);
   		m_pPlayerED.LookAt(nX, nY, 20,0,20);
		return fight, 5*30;
	}
	
	state fight
	{
		SquadsWork();
		if(m_pEnemyLC.GetNumberOfUnits()==0)
		{
			SetGoalState(1, 1);
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

