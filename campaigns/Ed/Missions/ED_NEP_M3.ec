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
	player m_pEnemyUCS;
	player m_pPlayerED; //2
	player m_pEnemyLC1;  //3
	player m_pAllyED; //4
	player m_pEnemyLC2; //5
	unit uEscapeUnit;

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
		m_pEnemyUCS=GetPlayer(1);	
		m_pPlayerED = GetPlayer(2);
		m_pEnemyLC1 = GetPlayer(3);
		m_pAllyED = GetPlayer(4);
		m_pEnemyLC2 = GetPlayer(5);
		
		m_pEnemyUCS.EnableAI(true);
		m_pAllyED.EnableAI(true);
		m_pEnemyLC1.EnableAI(true);
		m_pEnemyLC2.EnableAI(true);
		
		m_pPlayerED.SetEnemy(m_pEnemyUCS);
		m_pPlayerED.SetEnemy(m_pEnemyLC1);
		m_pPlayerED.SetEnemy(m_pEnemyLC2);
		m_pPlayerED.SetAlly(m_pAllyED);

		
		m_pAllyED.SetEnemy(m_pEnemyUCS);
		m_pAllyED.SetEnemy(m_pEnemyLC1);
		m_pAllyED.SetEnemy(m_pEnemyLC2);
		m_pAllyED.SetAlly(m_pPlayerED);	
		
		m_pEnemyLC1.SetAlly(m_pEnemyLC2);
		
		m_pEnemyLC1.SetEnemy(m_pPlayerED);
		m_pEnemyLC2.SetEnemy(m_pPlayerED);
		m_pEnemyLC1.SetEnemy(m_pAllyED);
		m_pEnemyLC2.SetEnemy(m_pAllyED);
		m_pEnemyLC1.SetEnemy(m_pEnemyUCS);
		m_pEnemyLC2.SetEnemy(m_pEnemyUCS);
		addAllResearchED(m_pPlayerED);
		addAllResearchED(m_pAllyED);
		addAllResearchUCS(m_pEnemyUCS);
		addAllResearchLC(m_pEnemyLC1);
		addAllResearchLC(m_pEnemyLC2);
		
		m_pPlayerED.AddResource(0,10000);
		m_pPlayerED.AddResource(1,10000);
		m_pPlayerED.AddResource(2,10000);			
		
		m_pAllyED.AddResource(0,5000);
		m_pAllyED.AddResource(1,5000);
		m_pAllyED.AddResource(2,5000);
		
		m_pEnemyLC1.AddResource(0,15000);
		m_pEnemyLC1.AddResource(1,15000);
		m_pEnemyLC1.AddResource(2,15000);
		
		m_pEnemyLC2.AddResource(0,15000);
		m_pEnemyLC2.AddResource(1,15000);
		m_pEnemyLC2.AddResource(2,15000);
		
		m_pEnemyUCS.AddResource(0,15000);
		m_pEnemyUCS.AddResource(1,15000);
		m_pEnemyUCS.AddResource(2,15000);
		
		ActivateAI(m_pEnemyUCS);
		ActivateAI(m_pAllyED);
		ActivateAI(m_pEnemyLC1);
		ActivateAI(m_pEnemyLC2);
		
		RegisterGoal(1, "Znisz wszystkie wrogie budynki");
		RegisterGoal(2,"Chroń sprzymierzonego dowódcę ED");
		RegisterGoal(3,"Zbuduj 6 jednostek EDSF_BS w celu ewakuacji");
		//RegisterGoal(1, "translateDestroyAllEnemies");
		//RegisterGoal(2,"translateProtectAlly");
		//RegisterGoal(3,"tranlsateBuildEvacuacionShips");
		EnableGoal(1, 1);
		EnableGoal(2, 1);

		

		for(n=0; n<GET_DIFFICULTY_LEVEL()+1;++n)
		{
			for (i=0; i<=4; ++i)
			{
				CreateAndAttackFromMarkerToMarker(m_pEnemyLC2, "LC_MOON_E", 3, i, 20);
				CreateAndAttackFromMarkerToMarker(m_pEnemyLC2, "LC_FANG_E", 2, i, 20);
			}
		}
		for(i=5; i<=6;++i)
		{
				CreateAndAttackFromMarkerToMarker(m_pEnemyUCS, "UCS_PANTHER_G", 2, i, 20);
				CreateAndAttackFromMarkerToMarker(m_pEnemyUCS, "UCS_BAT_R", 2, i, 20);
				CreateAndAttackFromMarkerToMarker(m_pEnemyUCS, "UCS_JAGUAR_R", 2, i, 20);							
		}
		for(i=7; i<=8;++i)
		{
				CreateAndAttackFromMarkerToMarker(m_pEnemyLC1, "LC_CRATER_RA", 1, i, 20);
				CreateAndAttackFromMarkerToMarker(m_pEnemyLC1, "LC_FANG_ART", 1, i, 20);
				CreateAndAttackFromMarkerToMarker(m_pEnemyLC1, "LC_FANG_E", 2, i, 20);
		}
    	GetStartingPoint(m_pPlayerED.GetIFFNum(), nX, nY);
      	m_pPlayerED.LookAt(nX, nY, 20,0,20);		
		return fight;
	}

	state fight
	{
		++Time;
		SquadsWork();
		sTimer.Format("%d:%02d", Time/60, Time%60);

		SetConsoleText(sTimer); 
		Console2.Format("Built %d/%02d",m_pPlayerED.GetNumberOfUnitsWithChasis("EDSF_BS", false),6);
		SetConsole2Text(Console2);
		if(Time%120==0)
		{
			for(i=9; i<=15;++i)
			{
				while(n<2*GET_DIFFICULTY_LEVEL()+1+Time/120)
				{
						CreateAndAttackFromMarkerToMarker(m_pEnemyUCS, "UCS_BAT_R", 1, i, 20); ++n;
						CreateAndAttackFromMarkerToMarker(m_pEnemyUCS, "UCS_HELLWIND_NB", 1, i, 20); ++n;
				}
				
			}
		}			
		if(GetGoalState(1)==false)
		if(m_pEnemyLC1.GetNumberOfBuildings()==0 &&  m_pEnemyLC2.GetNumberOfBuildings()==0 && m_pEnemyUCS.GetNumberOfBuildings()==0 )
		{
			SetGoalState(1, true);
		}

		if(m_pPlayerED.GetNumberOfUnits()==0 || m_pAllyED.GetNumberOfUnits()==0)
		{
			MissionDefeat();
		}
		
		if(Time>15*60)
		{
			EnableGoal(3,true);
		}
		
		return fight, 30;
	}
	event AddedUnit(unit uUnit, int nNotifyType)
	{
		CheckCarrierUnit(uUnit);
		if(m_pPlayerED.GetNumberOfUnitsWithChasis("EDSF_BS", false)>5)
		{
			EndMission(true);
		}
	}
	event AddedBuilding(unit Building,  int nNotifyType)
	{
		CheckUCSRafinery(Building);
	}
}
