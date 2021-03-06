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
            //eShowStatisticsOnExitSkirmish |
			0
			);
		m_pPlayerED = GetPlayer(2);
		m_pEnemyLC = GetPlayer(3);
		m_pPlayerED.SetEnemy(m_pEnemyLC);
		m_pEnemyLC.SetEnemy(m_pPlayerED);
		m_pEnemyLC.EnableAI(false);
		RegisterGoal(0,"translateED_M1_INTRO");
		RegisterGoal(1, "translateDestroyLC");
		EnableGoal(0,true);
		SetGoalState(0,true);
		EnableGoal(1, true);
		 
		GetStartingPoint(m_pPlayerED.GetIFF(), nX, nY);
        m_pPlayerED.LookAt(nX, nY, 6,0,20);	

		for (n=0; n<GET_DIFFICULTY_LEVEL()*2;++n)
		{
			for (i=1; i<9; ++i)
			{
				GetMarker(i,nX,nY);
				m_pEnemyLC.CreateObject("LC_MOON_E", nX+n, nY+n, 0, 0);
				m_pEnemyLC.CreateObject("LC_MOON_I", nX+n, nY+n, 0, 0);	
				m_pEnemyLC.CreateObject("LC_FANG_E", nX+n, nY+n, 0, 0);	
				m_pEnemyLC.CreateObject("LC_FANG_E", nX+n, nY+n, 0, 0);	
				m_pEnemyLC.CreateObject("LC_FANG_ART.", nX+n, nY+n, 0, 0);
				m_pEnemyLC.CreateObject("LC_FANG_ART.", nX+n, nY+n, 0, 0);		
				m_pEnemyLC.CreateObject("LC_CRATER_RA", nX+n, nY+n, 0, 0);
				m_pEnemyLC.CreateObject("LC_CRATER_RA", nX+n, nY+n, 0, 0);
				m_pEnemyLC.CreateObject("LC_GURDIAN_1", nX+n, nY+n, 0, 0);
				m_pEnemyLC.CreateObject("LC_GURDIAN_1", nX+n, nY+n, 0, 0);				
				m_pEnemyLC.CreateObject("LC_GUARDIAN_RA_1", nX+n, nY+n, 0, 0);
			}
		}
		GetStartingPoint(m_pPlayerED.GetIFFNum(), nX, nY);
   		m_pPlayerED.LookAt(nX, nY, 20,0,20);
		return fight;
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
event AddedBuilding(unit Building,  int nNotifyType)
{
	CheckUCSRafinery(Building);
}

event AddedUnit(unit uUnit,  int nNotifyType)
{
	CheckCarrierUnit(uUnit);
}
}

