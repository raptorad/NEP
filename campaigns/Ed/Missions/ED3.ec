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
	int nTime,nTanks;
	int nX,nY;
	player m_pPlayerED; //2
	player m_pEnemyLC;  //3
	player m_pEnemyED; //4
	string sName, sConsole, s2;
	unit uUnit;
	

	state fight;
	state MissionFailed;
	state MissionFailed2;

	state Initialize
	{
	nTime=0;
	nTanks=30+GET_DIFFICULTY_LEVEL()*10;
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
            //eShowStatisticsOnExitSkirmish |
			0
			);
		m_pPlayerED = GetPlayer(2);
		SetPlayerResearchesEDCampaign(m_pPlayerED, 3);
		m_pPlayerED.SetResearchTimeMultiplyPercent(50);
		m_pEnemyLC = GetPlayer(3);
		AddEnemyResearchesEDCampaign(m_pEnemyLC, 3);
		m_pEnemyED=GetPlayer(4);
		m_pPlayerED.AddResource(eMetal,30000);
		m_pEnemyLC.AddResource(eMetal,20000*(GET_DIFFICULTY_LEVEL()+1));
		
		m_pPlayerED.SetEnemy(m_pEnemyLC);
		m_pPlayerED.SetEnemy(m_pEnemyED);
		m_pEnemyLC.SetEnemy(m_pPlayerED);
		m_pEnemyLC.SetAlly(m_pEnemyED);
		m_pEnemyED.SetEnemy(m_pPlayerED);
		m_pEnemyED.SetAlly(m_pEnemyLC);
		m_pEnemyLC.EnableAI(true);
		m_pEnemyED.EnableAI(false);
		RegisterGoal(0,"translateED_M3_INTRO");
		EnableGoal(0,true);
		SetGoalState(0,true);
		RegisterGoal(1, "translateDestroyLC");
		EnableGoal(1, 1);
		RegisterGoal(2,"translateSendTanks2");
		EnableGoal(2,false);
		RegisterGoal(3,"translateDestroyTanks");
		EnableGoal(3,false);
		GetStartingPoint(m_pPlayerED.GetIFF(), nX, nY);
        m_pPlayerED.LookAt(nX, nY, 6,0,20);	
		//
		GetStartingPoint(m_pPlayerED.GetIFFNum(), nX, nY);
   		m_pPlayerED.LookAt(nX, nY, 20,0,20);
		return fight;
	}
	
	state fight
	{
		++nTime;
		if(nTime>20*60 && nTime<30*60 && !GetGoalState(2))
		{
				for( i=0;i<=m_pPlayerED.GetNumberOfUnits();++i)
				{
					uUnit=m_pPlayerED.GetUnit(i);
					sName=uUnit.GetObjectIDName();
					if(IsUnitNearMarker(uUnit, 1,4) && !sName.Compare("ED_PAMIR_RA"))
					{ 
						uUnit.RemoveObject();
						--nTanks;
					}
				}
				if(!IsGoalEnabled(2)) EnableGoal(2,true);
				sConsole.Translate("translateYouMustSend");
				s2.Format(" %d ",nTanks);
				sConsole.Append(s2);
				s2.Translate("translateTanksIn");
				sConsole.Append(s2);
				s2.Format("%d:%d",((30*60)-nTime)/60,((30*60)-nTime)%60);
				sConsole.Append(s2);
				SetConsoleText(sConsole,30);
				if(nTanks<=0)
				{
					SetGoalState(2,true);
				}
		}
		if(nTime>32*60 && !GetGoalState(3))
		{
			if(!IsGoalEnabled(3))
			{
				CreateAndAttackFromMarkerToMarker(m_pEnemyLC, "LC_CRUSCHER_2XMG_2XR", 2*(GET_DIFFICULTY_LEVEL()+2), 1, 2);
				CreateAndAttackFromMarkerToMarker(m_pEnemyED, "ED_PAMIR_RA", 30+GET_DIFFICULTY_LEVEL()*10, 1, 2); 
				EnableGoal(3,true);
			}
			if(m_pEnemyED.GetNumberOfUnits()==0)
			{
				SetGoalState(3,true);
			}
		}
		SquadsWork();
		if(m_pEnemyLC.GetNumberOfBuildings()==0)
		{
			SetGoalState(1, 1);
			if( (GetGoalState(3) || !IsGoalEnabled(3)) && (GetGoalState(2) || !IsGoalEnabled(2)) ) EndMission(true);
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

