
//#define DEBUG

#include "trace.ech"
#include "squadStats.ech"
#include "consts.ech"

#define MISSION_GOAL_PREFIX     MISSION_NAME "_Goal_"
#define MISSION_BRIEFING_PREFIX MISSION_NAME "_Brief_"

#define WAVE_MISSION_SUFFIX ".ogg"

#ifndef DEF_GOALCONSOLE_LENGTH
#define DEF_GOALCONSOLE_LENGTH (10*30)
#endif

#define REGISTER_GOAL(GoalName) \
	RegisterGoal(goal ## GoalName, MISSION_GOAL_PREFIX # GoalName);

#define ENABLE_GOAL(GoalName) \
	EnableGoal(goal ## GoalName, true, false); \
    SetConsoleText(MISSION_GOAL_PREFIX # GoalName, DEF_GOALCONSOLE_LENGTH);

#define ACHIEVE_GOAL(GoalName) \
	SetGoalState(goal ## GoalName, goalAchieved, true);

#define INITIALIZE_UNIT(UnitName) \
	m_u ## UnitName = GetUnitAtMarker(marker ## UnitName);

#define CREATE_UNIT(PlayerName, UnitName, Unit) \
	m_u ## UnitName = CreatePlayerObjectAtMarker(m_p ## PlayerName, Unit, marker ## UnitName);

#define CREATE_UNIT_ALPHA(PlayerName, UnitName, Unit, nAlpha) \
	m_u ## UnitName = CreatePlayerObjectAtMarker(m_p ## PlayerName, Unit, marker ## UnitName, nAlpha);

#define CREATE_UNITS_ARR(PlayerName, UnitsArrName, Unit, UnitsNum) \
	if ( !m_au ## UnitsArrName.Exist() ) m_au ## UnitsArrName.Create(0); \
	CreatePlayerObjectsAtMarker(m_au ## UnitsArrName, m_p ## PlayerName, Unit, UnitsNum, marker ## UnitsArrName);

#define INITIALIZE_PLAYER(PlayerName) \
	m_p ## PlayerName = GetPlayer(player ## PlayerName);

#define PLAY_BRIEFING(BriefingName, AnimMesh, Modal) \
	PlayBriefing(AnimMesh, MISSION_BRIEFING_PREFIX # BriefingName, WAVE_MISSION_PREFIX # BriefingName WAVE_MISSION_SUFFIX, 0, Modal);

//makro SAVE_UNIT/RESTORE_SAVED_UNIT tylko do save'owania pojedynczych hero'esow
//markerXX uzywany tez jako numer bufora save'owanego unita
//dlatego gdyby byl taki sam dla dwoch hero'sow, to nie nalezyc uzywac makra tylko zasave'owac funkcja SaveUnit do osobnych buforow
#define SAVE_UNIT(PlayerName, UnitName, BufferNum) \
	m_p ## PlayerName.ClearSaveUnitBuffer(BufferNum);\
    if (!m_p ## PlayerName.IsUnitSavedInAnyBuffer(m_u ## UnitName)) \
    { \
        ASSERT(m_p ## PlayerName.GetNumberOfSavedUnitsInBuffer(BufferNum) == 0); \
        if (m_u ## UnitName.IsHero()) \
        { \
            m_p ## PlayerName.SaveUnit(BufferNum, m_u ## UnitName, true, false); \
        } \
        else \
        { \
            m_p ## PlayerName.SaveUnit(BufferNum, m_u ## UnitName); \
        } \
    } \
    else \
    { \
        __ASSERT_FALSE(); \
    }

#define RESTORE_SAVED_UNIT_ALPHA(PlayerName, UnitName, BufferNum, Alpha) \
    ASSERT(m_p ## PlayerName.GetNumberOfSavedUnitsInBuffer(BufferNum) == 1); \
    m_u ## UnitName = RestoreSavedUnitAtMarker(m_p ## PlayerName, BufferNum, marker ## UnitName, Alpha);

#define RESTORE_SAVED_UNIT(PlayerName, UnitName, BufferNum) \
    RESTORE_SAVED_UNIT_ALPHA(PlayerName, UnitName, BufferNum , 0)


#define GET_DIFFICULTY_LEVEL() SendCampaignEventGetDifficultyLevel()


#define DEACTIVATE_AI(AI) \
		AI.SetAIControlOptions(eAIControlTurnOn, false);

#define A2G(nA) (nA >> 8)
#define G2A(nG) (nG << 8)
#define G2AMID(nG) ((nG << 8) + 0x80)


consts
{
	eRaceUCS = 1;
	eRaceED = 2;
	eRaceLC = 3;
	eRaceAlien = 4;
	eRaceObserver = 5;
	eEnemy = 0;
	eNeutral = 1;
    eSaveBestInfantyBufferNum = 1108;
}
#define MAX_PLAYERS 8
	int m_nC[];//number of player's Carriers
	unit m_uCarrier[];
	int m_nL[];
	int m_nSquadType[];
	unit m_uLeader[]; 
	int m_nBuildTimer[];
	int m_nMovingPoints[];
	unit m_uSubordinate[];
	unit m_uLeaderContainingObject[];
	unit m_uContainingObject[];
	unit m_uUnit1[];  
	int m_nInfantryBuildTimer[];
	string AddedToSquad;
	string m_sUnitsToSquad[];
	unit uFactories[];
	int  nFactoryTime[]
	int m_nSquadUnderProduction[];

	int m_nF[];
	int m_nSquadType[];
	int m_nAIUnitIndex[];


//|
function void SetLimitedGameRect(int nMarker1, int nMarker2);
function unit GetUnitAtMarker(int nMarker);
function void KillUnitAtMarker(int nMarker);
function void KillUnitsAtMarkers(int nMarkerFirst, int nMarkerLast);
function void RemoveUnitAtMarker(int nMarker);
function void RemoveUnitsAtMarkers(int nMarkerFirst, int nMarkerLast);
function int  OnDifficultyLevelRemoveUnits(int nDifficultyLevel, int nMarkerFirst, int nMarkerLast);

function void CommandMoveUnitToMarker(unit uUnit, int nMarker);
function void CommandMoveUnitToMarker(unit uUnit, int nMarker, int nOffX, int nOffY);
function void CommandMoveUnitFromMarkerToMarker(int nMarker1, int nMarker2);
function void CommandHoldPosUnitFromMarker(int nMarker);
function void CommandMoveUnitsToMarker(unit auUnit[], int nMarker);
function void CommandMoveUnitsToMarker(unit auUnit[], int nMarker, int nOffX, int nOffY);
function void CommandMoveUnitToUnit(unit uUnit, unit uDestination);
function void CommandMoveUnitToUnit(unit uUnit, unit uDestination, int nOffX, int nOffY);
function void CommandMoveAttackUnitToUnit(unit uUnit, unit uDestination);
function void CommandMoveUnitsToUnit(unit auUnit[], unit uDestination);
function void CommandMoveUnitsToUnit(unit auUnit[], unit uDestination, int nOffX, int nOffY);
function void CommandAttackUnit(unit auUnit[], unit uTarget);
function void CommandMoveAttackUnitsToMarker(unit auUnit[], int nMarker);
function void CommandMoveAttackUnitsToPoint(unit auUnit[], int nAx, int nAy);
function void CommandMoveAttackUnitsToUnit(unit auUnit[], unit uTarget);
function void CommandPatrolBetween2Points(unit auUnit[], int nAx, int nAy, int nBx, int nBy);
function void CommandPatrolBetween3Points(unit auUnit[], int nAx, int nAy, int nBx, int nBy, int nCx, int nCy);
function void CommandBeginRecord(unit auUnit[]);
function void CommandRepeatRecordAndExecute(unit auUnit[]);
function void CommandPatrolBetweenMarkers(unit auUnit[], int nMarker1, int nMarker2);
function void CommandPatrolBetweenMarkers(unit auUnit[], int nMarker1, int nMarker2, int nMarker3);
function void CommandPatrolBetweenMarkers(unit auUnit[], int nMarker1, int nMarker2, int nMarker3, int nMarker4);

function int IsUnitNorthOfMarker(unit uUnit, int nMarker);
function int IsUnitNearMarker(unit uUnit, int nMarker, int nRange);
function int IsUnitNearMarkers(unit uUnit, int nFirstMarker, int nLastMarker, int nRange);
function int IsAnyOfUnitsNearMarker(unit auUnit[], int nMarker, int nRange);
function int IsUnitNearUnit(unit uUnit1, unit uUnit2, int nRange);
function int IsAnyUnitNearMarker(player pPlayer, int nMarker, int nRange);
function int IsAnyObjectNearMarker(player pPlayer, int nMarker, int nRange);
function int IsAnyUnitNearMarkerAndAttacking(player pPlayer, int nMarker, int nRange);
function int DistanceToMarkerG(unit uUnit, int nMarker);
function int IsAnyUnitAttacking(unit auUnit[]);

function unit CreateObjectAtMarker(string strObject, int nMarker, int nAlpha);
function unit CreateObjectAtMarker(string strObject, int nMarker);
function unit CreateObjectNearUnit(string strObject, unit uUnit, int nAlpha);
function unit CreateObjectNearUnit(string strObject, unit uUnit);
function unit CreatePlayerObjectAtMarker(player pPlayer, string strObject, int nMarker, int nAlpha);
function unit CreatePlayerObjectAtMarker(player pPlayer, string strObject, int nMarker);
function unit CreatePlayerObjectNearUnit(player pPlayer, string strObject, unit uUnit, int nAlpha);
function unit CreatePlayerObjectNearUnit(player pPlayer, string strObject, unit uUnit);
function void CreateTransportedCrew(unit uTransporter, string strCrew, int nCount);
function void CreateTransportedCrew(unit uTransporter, string strCrew, int nCount, unit auAddToArray[]);

function unit RestoreSavedUnitAtMarker(player pPlayer, int nBufferNum, int nMarkerNum, int nAlpha);
function void PrepareSaveUnits(player pPlayer);
function void SaveBestInfantry(player pPlayer, int nSaveCount);
function void RestoreBestInfantryAtMarker(player pPlayer, int nMarkerNum);
function void RestoreBestInfantryAtMarker(player pPlayer, int nMarkerNum, int nAlpha);
function void FinishRestoreUnits(player pPlayer);

function void GiveAllUnitsToPlayer(player pPlayerFrom, player pPlayerTo);
function void GiveAllInfantryToPlayer(player pPlayerFrom, player pPlayerTo);
function void GiveAllBuildingsToPlayer(player pPlayerFrom, player pPlayerTo);

function int IsPointBetweenMarkers(int nGx, int nGy, int nM1, int nM2);
function int IsUnitBetweenMarkers(unit uUnit, int nM1, int nM2);
function int IsAnyOfUnitsBetweenMarkers(unit auUnit[], int nM1, int nM2);
function int GetMarkerClosestToPoint(int nMarkerFirst, int nMarkerLast, int nGx, int nGy);

function void SetNeutrals(player p1, player p2);
function void SetEnemies(player p1, player p2);
function int SetAlly(player p1, player p2);

function void LookAtUnit(unit uUnit);
function void LookAtUnitClose(unit uUnit);
function void LookAtMarker(int nMarker);
function void LookAtMarker(int nMarker,int nZoom, int nAlpha);
function void LookAtMarkerClose(int nMarker);
function void SetUnitAtMarker(unit uUnit, int nMarker);
function void SetUnitAtMarker(unit uUnit, int nMarker, int nOffX, int nOffY);
function void AddMapSignAtMarker(int nMarker, int nType, int nTime);
function void AddMapSignAtUnit(unit uUnit, int nType, int nTime);
function void RemoveMapSignAtMarker(int nMarker);
function void RemoveMapSignAtUnit(unit uUnit);

function int RemoveUnitFromArray(unit auUnits[], unit uUnit);
function int RemoveIntFromArray(int anInts[], int nInt);
function int FindUnitInArray(unit auUnits[], unit uUnit);
function int FindIntInArray(int anInts[], int nInt);
function int IsUnitInArray(unit auUnits[], unit uUnit);
function int IsIntInArray(int anInts[], int nInt);
function int CountLessIntsInArray(int anInts[], int nInt);
function int RemoveLessIntsFromArray(int anInts[], int nInt);
function int CountUnitInArray(unit auUnits[], unit uUnit);

function void ClearLimitedGameRect();

function void CreateFxToCreatedUnit(unit uUnit,player P);
function void CreatePlayerObjectsAtMarker(unit auObject[], player pPlayer, string strObject, int nObjects, int nMarker);
function void CreatePlayerObjectsAtMarker(player pPlayer, string strObject, int nObjects, int nMarker, int nAlpha);
function void CreatePlayerObjectsAtMarker(player pPlayer, string strObject, int nObjects, int nMarker);

function void SetPlayer(unit auUnit[], player pPlayer);
function void SetExperienceLevel(unit auUnit[], int nExpLvl);
function void CreateAndAttackFromMarkerToMarker(player pPlayer, string strObject, int nNum, int nMarker1, int nMarker2);

function void MissionDefeat();
function void addAllResearchUCS(player p);
function void addAllResearchED(player p);
function void addAllResearchLC(player p);
function void addAllResearchAlien(player p);

function void AddSquad(unit uUnit1, unit uUnit2, unit uUnit3, unit uUnit4, unit uUnit5, unit uUnit6);
function void AddUnitToLeaderArray(unit uUnit);
function void IncInfantryBuildTimer(int nP,int i);
function void LeaderContainingObject(int nP,int i);
function void Replenish(int nP,int i, int n);
function void ContainigObjectToArray(int nP,int i,int n);
function void ChangeDeadLeader(int nP,int i);
function void MoveSubordinateToLeader(int nP,int i,int n);
function void SetSquadSelection(int nP,int i,int n);
function void AddUnitsToLeader();
function void AddUnitToCarrierArray(unit uUnit);
function void AddUnitsToCarrier();
function void FreeAddUnitsToCarrier() ;
function void CreateSquadFromGroup10();
function void SquadsWork();
function void InitCarriers();
function void CheckUCSRafinery(unit Building);
function void CheckCarrierUnit(unit uUnit);
function void AddToFactoriesArray(unit uFactory);
function void SetBuildCommands();

//|

function void SetLimitedGameRect(int nMarker1, int nMarker2)
	{
		int nGx, nGy;

		int nGxMin, nGxMax;
		int nGyMin, nGyMax;

		GetMarker(nMarker1, nGxMin, nGyMin);
		GetMarker(nMarker1, nGxMax, nGyMax);

		GetMarker(nMarker2, nGx, nGy);

		if ( nGx < nGxMin ) nGxMin = nGx;
		if ( nGy < nGyMin ) nGyMin = nGy;

		if ( nGx > nGxMax ) nGxMax = nGx;
		if ( nGy > nGyMax ) nGyMax = nGy;

		SetLimitedGameRect(nGxMin, nGyMin, nGxMax, nGyMax);
	}

function unit GetUnitAtMarker(int nMarker)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	return GetObject(nGx, nGy);
}

function void KillUnitAtMarker(int nMarker)
{
	unit uUnit;

	uUnit = GetUnitAtMarker(nMarker);

	ASSERT(uUnit != null);

	uUnit.KillObject();
}

function void KillUnitsAtMarkers(int nMarkerFirst, int nMarkerLast)
{
	int nMarker;

	for ( nMarker=nMarkerFirst; nMarker<=nMarkerLast; ++nMarker )
	{
		KillUnitAtMarker(nMarker);
	}
}

function void RemoveUnitAtMarker(int nMarker)
{
	unit uUnit;

	uUnit = GetUnitAtMarker(nMarker);

	ASSERT(uUnit != null);

	uUnit.RemoveObject();
}

function void RemoveUnitsAtMarkers(int nMarkerFirst, int nMarkerLast)
{
	int nMarker;

	for ( nMarker=nMarkerFirst; nMarker<=nMarkerLast; ++nMarker )
	{
		RemoveUnitAtMarker(nMarker);
	}
}

function int OnDifficultyLevelRemoveUnits(int nDifficultyLevel, int nMarkerFirst, int nMarkerLast)
{
	if ( SendCampaignEventGetDifficultyLevel() == nDifficultyLevel )
	{
		RemoveUnitsAtMarkers(nMarkerFirst, nMarkerLast);

		return true;
	}

	return false;
}

function void CommandMoveUnitToMarker(unit uUnit, int nMarker)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	ASSERT(uUnit != null);

	uUnit.CommandMove(G2AMID(nGx), G2AMID(nGy));
}

function void CommandMoveUnitToMarker(unit uUnit, int nMarker, int nOffX, int nOffY)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	ASSERT(uUnit != null);

	uUnit.CommandMove(G2AMID(nGx+nOffX), G2AMID(nGy+nOffY));
}

function void CommandMoveUnitFromMarkerToMarker(int nMarker1, int nMarker2)
{
	int nGx, nGy;
	unit uUnit;

	uUnit = GetUnitAtMarker(nMarker1);
	
	ASSERT(uUnit != null);

	VERIFY(GetMarker(nMarker2, nGx, nGy));

	uUnit.CommandMove(G2AMID(nGx), G2AMID(nGy));
}

function void CommandHoldPosUnitFromMarker(int nMarker)
{
	int nGx, nGy;
	unit uUnit;

	uUnit = GetUnitAtMarker(nMarker);

	ASSERT(uUnit != null);

	uUnit.CommandSetMovementMode(eMovementModeHoldPosition);
}

function void CommandMoveUnitsToMarker(unit auUnit[], int nMarker)
{
	int nGx, nGy;
	int i;

	unit uUnit;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit != null && uUnit.IsLive() )
		{
			uUnit.CommandMove(G2AMID(nGx), G2AMID(nGy));
		}
	}
}

function void CommandMoveUnitsToMarker(unit auUnit[], int nMarker, int nOffX, int nOffY)
{
	int nGx, nGy;
	int i;

	unit uUnit;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit != null && uUnit.IsLive() )
		{
			uUnit.CommandMove(G2AMID(nGx+nOffX), G2AMID(nGy+nOffY));
		}
	}
}

function void CommandMoveUnitToUnit(unit uUnit, unit uDestination)
{
	int nAx, nAy;

	ASSERT(uUnit != null);
	ASSERT(uDestination != null);

	uDestination.GetLocation(nAx, nAy);

	uUnit.CommandMove(nAx, nAy);
}

function void CommandMoveUnitToUnit(unit uUnit, unit uDestination, int nOffX, int nOffY)
{
	int nAx, nAy;

	ASSERT(uUnit != null);
	ASSERT(uDestination != null);

	uDestination.GetLocation(nAx, nAy);

	uUnit.CommandMove(nAx + G2A(nOffX), nAy + G2A(nOffY));
}

function void CommandMoveAttackUnitToUnit(unit uUnit, unit uDestination)
{
	int nAx, nAy;

	ASSERT(uUnit != null);
	ASSERT(uDestination != null);

	uDestination.GetLocation(nAx, nAy);

	uUnit.CommandMoveAttack(nAx, nAy);
}

function void CommandMoveUnitsToUnit(unit auUnit[], unit uDestination)
{
	int nAx, nAy;
	int i;

	unit uUnit;

	ASSERT(uDestination != null);

	uDestination.GetLocation(nAx, nAy);

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit != null && uUnit.IsLive() )
		{
			uUnit.CommandMove(nAx, nAy);
		}
	}
}

function void CommandMoveUnitsToUnit(unit auUnit[], unit uDestination, int nOffX, int nOffY)
{
	int nAx, nAy;
	int i;

	unit uUnit;

	ASSERT(uDestination != null);

	uDestination.GetLocation(nAx, nAy);

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit != null && uUnit.IsLive() )
		{
			uUnit.CommandMove(nAx + G2A(nOffX), nAy + G2A(nOffY));
		}
	}
}

function void CommandAttackUnit(unit auUnit[], unit uTarget)
{
	int i;

	unit uUnit;

	ASSERT(uTarget != null);

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit != null && uUnit.IsLive() )
		{
			uUnit.CommandAttack(uTarget);
		}
	}
}


function void CommandMoveAttackUnitsToMarker(unit auUnit[], int nMarker)
{
	int nGx, nGy;
	int i;

	unit uUnit;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit != null && uUnit.IsLive() )
		{
			uUnit.CommandMoveAttack(G2AMID(nGx), G2AMID(nGy));
		}
	}
}

function void CommandMoveAttackUnitsToPoint(unit auUnit[], int nAx, int nAy)
{
	int i;

	unit uUnit;

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit != null && uUnit.IsLive() )
		{
			uUnit.CommandMoveAttack(nAx, nAy);
		}
	}
}
function void CommandMoveUnitsToPoint(unit auUnit[], int nAx, int nAy)
{
	int i;

	unit uUnit;

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit != null && uUnit.IsLive() )
		{
			uUnit.CommandMove(nAx, nAy);
		}
	}
}
function void CommandPatrolBetween2Points(unit auUnit[], int nAx, int nAy, int nBx, int nBy)
{
	int i;

	unit uUnit;

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit != null && uUnit.IsLive() )
		{
			uUnit.CommandBeginRecord();
			uUnit.CommandMoveAttack(nAx, nAy);
			uUnit.CommandMoveAttack(nBx, nBy);
			uUnit.CommandRepeatExecution();
			uUnit.CommandExecuteRecord();
		}
	}
}
function void CommandPatrolBetween3Points(unit auUnit[], int nAx, int nAy, int nBx, int nBy, int nCx, int nCy)
{
	int i;

	unit uUnit;

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit != null && uUnit.IsLive() )
		{
			uUnit.CommandBeginRecord();
			uUnit.CommandMoveAttack(nAx, nAy);
			uUnit.CommandMoveAttack(nBx, nBy);
			uUnit.CommandMoveAttack(nCx, nCy);
			uUnit.CommandRepeatExecution();
			uUnit.CommandExecuteRecord();
		}
	}
}
function void CommandPatrol2Between3Points(unit auUnit[], int nAx, int nAy, int nBx, int nBy, int nCx, int nCy)
{
	int i;

	unit uUnit;

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit != null && uUnit.IsLive() )
		{
			uUnit.CommandBeginRecord();
			uUnit.CommandMove(nAx, nAy);
			uUnit.CommandMoveAttack(nBx, nBy);
			uUnit.CommandMoveAttack(nCx, nCy);
			uUnit.CommandRepeatExecution();
			uUnit.CommandExecuteRecord();
		}
	}
}

function void CommandMoveAttackUnitsToUnit(unit auUnit[], unit uTarget)
{
    int nX, nY;
    int nIndex, nSize;
    unit uUnit;

    uTarget.GetLocation(nX, nY);
    nSize = auUnit.GetSize();
    for (nIndex = 0; nIndex < nSize; ++nIndex)
    {
        uUnit = auUnit[nIndex];
        if ((uUnit != null) && uUnit.IsLive() && uUnit.IsStored())
        {
            uUnit.CommandMoveAttack(nX, nY);
        }
    }
}

function void CommandBeginRecord(unit auUnit[])
{
	int i;

	unit uUnit;

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit != null && uUnit.IsLive() )
		{
			uUnit.CommandBeginRecord();
		}
	}
}

function void CommandRepeatRecordAndExecute(unit auUnit[])
{
	int i;

	unit uUnit;

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit != null && uUnit.IsLive() )
		{
			uUnit.CommandRepeatExecution();
            uUnit.CommandExecuteRecord();
		}
	}
}

function void CommandPatrolBetweenMarkers(unit auUnit[], int nMarker1, int nMarker2)
{
    CommandBeginRecord(auUnit);
    CommandMoveAttackUnitsToMarker(auUnit, nMarker1);
    CommandMoveAttackUnitsToMarker(auUnit, nMarker2);
    CommandRepeatRecordAndExecute(auUnit);
}

function void CommandPatrolBetweenMarkers(unit auUnit[], int nMarker1, int nMarker2, int nMarker3)
{
    CommandBeginRecord(auUnit);
    CommandMoveAttackUnitsToMarker(auUnit, nMarker1);
    CommandMoveAttackUnitsToMarker(auUnit, nMarker2);
    CommandMoveAttackUnitsToMarker(auUnit, nMarker3);
    CommandRepeatRecordAndExecute(auUnit);
}

function void CommandPatrolBetweenMarkers(unit auUnit[], int nMarker1, int nMarker2, int nMarker3, int nMarker4)
{
    CommandBeginRecord(auUnit);
    CommandMoveAttackUnitsToMarker(auUnit, nMarker1);
    CommandMoveAttackUnitsToMarker(auUnit, nMarker2);
    CommandMoveAttackUnitsToMarker(auUnit, nMarker3);
    CommandMoveAttackUnitsToMarker(auUnit, nMarker4);
    CommandRepeatRecordAndExecute(auUnit);
}
function int IsUnitNorthOfMarker(unit uUnit, int nMarker)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	ASSERT(uUnit != null);

	if ( uUnit.GetLocationY()> G2AMID(nGy) )
	{
		return true;
	}

	return false;
}

function int IsUnitNearMarker(unit uUnit, int nMarker, int nRange)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	ASSERT(uUnit != null);

	if ( uUnit.DistanceTo(G2AMID(nGx), G2AMID(nGy)) <= G2A(nRange) )
	{
		return true;
	}

	return false;
}

function int IsUnitNearMarkers(unit uUnit, int nFirstMarker, int nLastMarker, int nRange)
{
	int nGx, nGy;
	int i;

	for(i=nFirstMarker; i<= nLastMarker; i=i+1)
	{
		VERIFY(GetMarker(i, nGx, nGy));
		ASSERT(uUnit != null);
		if ( uUnit.DistanceTo(G2AMID(nGx), G2AMID(nGy)) <= G2A(nRange) )
		{
			return true;
		}
	}
	return false;
}

function int IsAnyOfUnitsNearMarker(unit auUnit[], int nMarker, int nRange)
{
	int nGx, nGy;
	int i;

	unit uUnit;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit.DistanceTo(G2AMID(nGx), G2AMID(nGy)) <= G2A(nRange) )
		{
			return true;
		}
	}

	return false;
}

function int IsUnitNearUnit(unit uUnit1, unit uUnit2, int nRange)
{
	ASSERT(uUnit1 != null);
	ASSERT(uUnit2 != null);

	if ( uUnit1.DistanceTo(uUnit2) <= G2A(nRange) )
	{
		return true;
	}

	return false;
}

function int IsAnyUnitNearMarker(player pPlayer, int nMarker, int nRange)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));
    return IsUnitNearPoint(nGx, nGy, nRange, pPlayer.GetIFF());
}

function int IsAnyObjectNearMarker(player pPlayer, int nMarker, int nRange)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));
    return IsObjectNearPoint(nGx, nGy, nRange, pPlayer.GetIFF(), eTargetTypeAny | eTargetTypeLand | eTargetTypeAir);
}

function int IsAnyUnitNearMarkerAndAttacking(player pPlayer, int nMarker, int nRange)
{
    int nIndex, nUnitsCnt;
	int nX, nY;
    unit uUnit;

	VERIFY(GetMarker(nMarker, nX, nY));
    nX = G2AMID(nX);
    nY = G2AMID(nY);
    nRange = G2A(nRange);

    nUnitsCnt = pPlayer.GetNumberOfUnits();
    for (nIndex = 0; nIndex < nUnitsCnt; ++nIndex)
    {
        uUnit = pPlayer.GetUnit(nIndex);
        if (!uUnit.IsStored())
        {
            continue;
        }
        if ((uUnit.DistanceTo(nX, nY) <= nRange) && (uUnit.GetAttackTarget() != null))
        {
            return true;
        }
    }
    return false;
}

function int DistanceToMarkerG(unit uUnit, int nMarker)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	ASSERT(uUnit != null);

	return A2G(uUnit.DistanceTo(G2AMID(nGx), G2AMID(nGy)));
}

function int IsAnyUnitAttacking(unit auUnit[])
{
    int nIndex, nSize;
    unit uUnit;

    nSize = auUnit.GetSize();
    for (nIndex = 0; nIndex < nSize; ++nIndex)
    {
        uUnit = auUnit[nIndex];
        if ((uUnit != null) && uUnit.IsLive() && (uUnit.GetAttackTarget() != null))
        {
            return true;
        }
    }
    return false;
}

function unit CreateObjectAtMarker(string strObject, int nMarker, int nAlpha)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	return CreateObject(strObject, nGx, nGy, 0, nAlpha);
}

function unit CreateObjectAtMarker(string strObject, int nMarker)
{
	int nGx, nGy, nAlpha;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	nAlpha = 0;

	return CreateObject(strObject, nGx, nGy, 0, nAlpha);
}

function unit CreateObjectNearUnit(string strObject, unit uUnit, int nAlpha)
{
	int nGx, nGy;

	ASSERT(uUnit != null);

	uUnit.GetLocationG(nGx, nGy);

	return CreateObject(strObject, nGx, nGy, 0, nAlpha);
}

function unit CreateObjectNearUnit(string strObject, unit uUnit)
{
	int nGx, nGy;

	ASSERT(uUnit != null);

	uUnit.GetLocationG(nGx, nGy);

	return CreateObject(strObject, nGx, nGy, 0, 0);
}

function unit CreatePlayerObjectAtMarker(player pPlayer, string strObject, int nMarker, int nAlpha)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	return pPlayer.CreateObject(strObject, nGx, nGy, 0, nAlpha);
}

function unit CreatePlayerObjectAtMarker(player pPlayer, string strObject, int nMarker)
{
	int nGx, nGy, nAlpha;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	nAlpha = 0;

	return pPlayer.CreateObject(strObject, nGx, nGy, 0, nAlpha);
}

function unit CreatePlayerObjectNearUnit(player pPlayer, string strObject, unit uUnit, int nAlpha)
{
	int nGx, nGy;

	ASSERT(uUnit != null);

	uUnit.GetLocationG(nGx, nGy);

	return pPlayer.CreateObject(strObject, nGx, nGy, 0, nAlpha);
}

function unit CreatePlayerObjectNearUnit(player pPlayer, string strObject, unit uUnit)
{
	int nGx, nGy;

	ASSERT(uUnit != null);

	uUnit.GetLocationG(nGx, nGy);

	return pPlayer.CreateObject(strObject, nGx, nGy, 0, 0);
}

function void CreateTransportedCrew(unit uTransporter, string strCrew, int nCount)
{
    int nIndex;

    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        VERIFY(uTransporter.CreateTransportedCrew(strCrew));
    }
}

function void CreateTransportedCrew(unit uTransporter, string strCrew, int nCount, unit auAddToArray[])
{
    int nIndex;
    unit uUnit;

    ASSERT(auAddToArray.Exist());
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = uTransporter.CreateTransportedCrew(strCrew);
        if (uUnit != null)
        {
            auAddToArray.Add(uUnit);
        }
        else
        {
            __ASSERT_FALSE();
        }
    }
}

//funkcja "prywatna" dla makra RESTORE_SAVED_UNIT
function unit RestoreSavedUnitAtMarker(player pPlayer, int nBufferNum, int nMarkerNum, int nAlpha)
{
    int nGx, nGy;

    VERIFY(GetMarker(nMarkerNum, nGx, nGy));
    return pPlayer.RestoreSavedUnits(nBufferNum, nGx, nGy, 0, nAlpha);
}

function void PrepareSaveUnits(player pPlayer)
{
    pPlayer.ClearSaveUnitBuffer(eSaveBestInfantyBufferNum);
}

function void SaveBestInfantry(player pPlayer, int nSaveCount)
{
    int nIndex, nSize;
    unit uUnit;
    unit arrInfantry[];
    int arrExperience[];

    arrInfantry.Create(0);
    arrExperience.Create(0);
    nSize = pPlayer.GetNumberOfUnits();
    for (nIndex = 0; nIndex < nSize; ++nIndex)
    {
        uUnit = pPlayer.GetUnit(nIndex);
        if (!uUnit.IsInfantry() || !uUnit.IsLive())
        {
            continue;
        }
        if (uUnit.IsAgent() || uUnit.IsHero())
        {
            continue;
        }
        if (pPlayer.IsUnitSavedInAnyBuffer(uUnit))
        {
            //juz zapisany (hero)
            continue;
        }
        arrInfantry.Add(uUnit);
        arrExperience.Add(uUnit.GetExperiencePoints());
    }
    arrInfantry.SortWithKeys(arrExperience, false, true);
    ASSERT(pPlayer.GetNumberOfSavedUnitsInBuffer(eSaveBestInfantyBufferNum) == 0);
    if (nSaveCount > arrInfantry.GetSize())
    {
        nSaveCount = arrInfantry.GetSize();
    }
    for (nIndex = 0; nIndex < nSaveCount; ++nIndex)
    {
        pPlayer.SaveUnit(eSaveBestInfantyBufferNum, arrInfantry[nIndex]);
    }
}

function void RestoreBestInfantryAtMarker(player pPlayer, int nMarkerNum)
{
    RestoreBestInfantryAtMarker(pPlayer, nMarkerNum, 0);
}

function void RestoreBestInfantryAtMarker(player pPlayer, int nMarkerNum, int nAlpha)
{
    int nGx, nGy;

    VERIFY(GetMarker(nMarkerNum, nGx, nGy));
    pPlayer.RestoreSavedUnits(eSaveBestInfantyBufferNum, nGx, nGy, 0, nAlpha);
}

function void FinishRestoreUnits(player pPlayer)
{
    pPlayer.ClearSaveUnitBuffer(eSaveBestInfantyBufferNum);
}

function void GiveAllUnitsToPlayer(player pPlayerFrom, player pPlayerTo)
{
    unit auUnits[];
    int nIndex, nCount;
    unit uUnit;

    ASSERT((pPlayerFrom != null) && (pPlayerTo != null));
    auUnits.Create(0);
    nCount = pPlayerFrom.GetNumberOfUnits();
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = pPlayerFrom.GetUnit(nIndex);
        if (!uUnit.IsStored() || !uUnit.IsLive())
        {
            continue;
        }
        auUnits.Add(uUnit);
    }

    nCount = auUnits.GetSize();
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = auUnits[nIndex];
        uUnit.SetPlayer(pPlayerTo);
    }
}
function void GiveAllUnitsNotAroundHeroToPlayer(player pPlayerFrom, player pPlayerTo, unit uHero, int nRange)
{
    unit auUnits[];
    int nIndex, nCount,nAx,nAy;
    unit uUnit;

    ASSERT((pPlayerFrom != null) && (pPlayerTo != null));
    auUnits.Create(0);
    nCount = pPlayerFrom.GetNumberOfUnits();
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = pPlayerFrom.GetUnit(nIndex);
        if (!uUnit.IsStored() || !uUnit.IsLive())
        {
            continue;
        }
        auUnits.Add(uUnit);
    }
	nCount = pPlayerFrom.GetNumberOfBuildings();
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = pPlayerFrom.GetBuilding(nIndex);
        if (!uUnit.IsStored() || !uUnit.IsLive())
        {
            continue;
        }
        auUnits.Add(uUnit);
    }
    uHero.GetLocation(nAx,nAy);

    nCount = auUnits.GetSize();
    
	for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = auUnits[nIndex];
		if ( uUnit.DistanceTo(nAx, nAy) > G2A(nRange) )
		{
			uUnit.SetPlayer(pPlayerTo);
		}
	}
}

function void GiveAllInfantryToPlayer(player pPlayerFrom, player pPlayerTo)
{
    unit auUnits[];
    int nIndex, nCount;
    unit uUnit;

    ASSERT((pPlayerFrom != null) && (pPlayerTo != null));
    auUnits.Create(0);
    nCount = pPlayerFrom.GetNumberOfUnits();
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = pPlayerFrom.GetUnit(nIndex);
        if (!uUnit.IsInfantry() || !uUnit.IsStored() || !uUnit.IsLive())
        {
            continue;
        }
        auUnits.Add(uUnit);
    }
    nCount = auUnits.GetSize();
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = auUnits[nIndex];
        uUnit.SetPlayer(pPlayerTo);
    }
}

function void GiveAllBuildingsToPlayer(player pPlayerFrom, player pPlayerTo)
{
    unit auUnits[];
    int nIndex, nCount;
    unit uUnit;

    ASSERT((pPlayerFrom != null) && (pPlayerTo != null));
    auUnits.Create(0);
    nCount = pPlayerFrom.GetNumberOfBuildings();
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = pPlayerFrom.GetBuilding(nIndex);
        if (!uUnit.IsStored() || !uUnit.IsLive())
        {
            continue;
        }
        auUnits.Add(uUnit);
    }
    nCount = auUnits.GetSize();
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = auUnits[nIndex];
        uUnit.SetPlayer(pPlayerTo);
    }
}

function void RemoveCrewFroAllBuildings(player pPlayer)
{
    unit auUnits[];
    int nIndex, nCount;
    unit uUnit;

    ASSERT(pPlayer != null);
    auUnits.Create(0);
    nCount = pPlayer.GetNumberOfBuildings();
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = pPlayer.GetBuilding(nIndex);
        if (!uUnit.IsStored() || !uUnit.IsLive())
        {
            continue;
        }
        auUnits.Add(uUnit);
    }
    nCount = auUnits.GetSize();
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = auUnits[nIndex];
        if(uUnit.HaveCrew()) uUnit.RemoveCrew();
    }
}



function int IsPointBetweenMarkers(int nGx, int nGy, int nM1, int nM2)
{
	int nGxM1, nGxM2;
	int nGyM1, nGyM2;
	int nTemp;

	VERIFY(GetMarker(nM1, nGxM1, nGyM1));
	VERIFY(GetMarker(nM2, nGxM2, nGyM2));

	if( nGxM1 > nGxM2 ) { nTemp=nGxM2; nGxM2=nGxM1; nGxM1=nTemp; }
	if( nGyM1 > nGyM2 ) { nTemp=nGyM2; nGyM2=nGyM1; nGyM1=nTemp; }

	if ( nGx >= nGxM1 && nGy >= nGyM1 && nGx <= nGxM2 && nGy <= nGyM2 )
	{
		return true;
	}

	return false;
}

function int IsUnitBetweenMarkers(unit uUnit, int nM1, int nM2)
{
	int nGx, nGy;

	ASSERT(uUnit != null);

	uUnit.GetLocationG(nGx, nGy);

	return IsPointBetweenMarkers(nGx, nGy, nM1, nM2);
}

function int IsAnyOfUnitsBetweenMarkers(unit auUnit[], int nM1, int nM2)
{
	int i;

	unit uUnit;

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		if ( IsUnitBetweenMarkers(uUnit, nM1, nM2) )
		{
			return true;
		}
	}

	return false;
}

function int GetMarkerClosestToPoint(int nMarkerFirst, int nMarkerLast, int nGx, int nGy)
{
    int nGx2, nGy2;
    int nDist, nMinDist;
    int nMinMarker;
    int nIndex;

    nMinMarker = nMarkerFirst;
    nMinDist = 1000000;
    for (nIndex = nMarkerFirst; nIndex <= nMarkerLast; ++nIndex)
    {
        if (!GetMarker(nIndex, nGx2, nGy2))
        {
            continue;
        }
        nDist = Distance(nGx, nGy, nGx2, nGy2);
        if (nDist < nMinDist)
        {
            nMinDist = nDist;
            nMinMarker = nIndex;
        }
    }
    return nMinMarker;
}

function void SetNeutrals(player p1, player p2)
{
	ASSERT( p1 != null );
	ASSERT( p2 != null );
	ASSERT( p1 != p2 );

	p1.SetNeutral(p2);
	p2.SetNeutral(p1);
}

function void SetEnemies(player p1, player p2)
{
	ASSERT( p1 != null );
	ASSERT( p2 != null );
	ASSERT( p1 != p2 );

	p1.SetEnemy(p2);
	p2.SetEnemy(p1);
}

function int SetAlly(player p1, player p2)
{
	ASSERT( p1 != null );
	ASSERT( p2 != null );
	ASSERT( p1 != p2 );

	p1.SetAlly(p2);
	p2.SetAlly(p1);

	return true;
}

#define SET_3(SetFunc) \
	function void SetFunc(player p1, player p2, player p3) \
	{ \
		SetFunc(p1, p2); \
		SetFunc(p2, p3); \
		SetFunc(p1, p3); \
	}

#define SET_4(SetFunc) \
	function void SetFunc(player p1, player p2, player p3, player p4) \
	{ \
		SetFunc(p1, p2, p3); \
		SetFunc(p1, p4); \
		SetFunc(p2, p4); \
		SetFunc(p3, p4); \
	}

#define SET_5(SetFunc) \
	function void SetFunc(player p1, player p2, player p3, player p4, player p5) \
	{ \
		SetFunc(p1, p2, p3, p4); \
		SetFunc(p1, p5); \
		SetFunc(p2, p5); \
		SetFunc(p3, p5); \
		SetFunc(p4, p5); \
	}

#define SET_6(SetFunc) \
	function void SetFunc(player p1, player p2, player p3, player p4, player p5, player p6) \
	{ \
		SetFunc(p1, p2, p3, p4, p5); \
		SetFunc(p1, p6); \
		SetFunc(p2, p6); \
		SetFunc(p3, p6); \
		SetFunc(p4, p6); \
		SetFunc(p5, p6); \
	}
#define SET_7(SetFunc) \
	function void SetFunc(player p1, player p2, player p3, player p4, player p5, player p6, player p7) \
	{ \
		SetFunc(p1, p2, p3, p4, p5, p6); \
		SetFunc(p1, p7); \
		SetFunc(p2, p7); \
		SetFunc(p3, p7); \
		SetFunc(p4, p7); \
		SetFunc(p5, p7); \
		SetFunc(p6, p7); \
	}

SET_3(SetNeutrals)
SET_3(SetEnemies)
SET_3(SetAlly)

SET_4(SetNeutrals)
SET_4(SetEnemies)
SET_4(SetAlly)

SET_5(SetNeutrals)
SET_5(SetEnemies)
SET_5(SetAlly)

SET_6(SetNeutrals)
SET_7(SetNeutrals)

#undef SET_3
#undef SET_4
#undef SET_5
#undef SET_6

function void LookAtUnit(unit uUnit)
{
	int nAx, nAy;

	ASSERT(uUnit != null);

	uUnit.GetLocation(nAx, nAy);

	LookAt(nAx, nAy, -1, -1, -1);
}

function void LookAtUnitClose(unit uUnit)
{
	int nAx, nAy;

	ASSERT(uUnit != null);

	uUnit.GetLocation(nAx, nAy);

	LookAt(nAx, nAy, 4, -1, -1);
}

function void LookAtMarker(int nMarker)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));
	
	LookAt(G2AMID(nGx), G2AMID(nGy), -1, -1, -1);
}
function void LookAtMarker(int nMarker,int nZoom, int nAlpha)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));
	
	LookAt(G2AMID(nGx), G2AMID(nGy), nZoom, nAlpha, -1);
}
function void LookAtMarkerClose(int nMarker)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));
	
	LookAt(G2AMID(nGx), G2AMID(nGy), 4, -1, -1);
}

function void LookAtMarkerMedium(int nMarker)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));
	
	LookAt(G2AMID(nGx), G2AMID(nGy), 12, -1, -1);
}
function void LookAtMarkerMedium(int nMarker, int nAngle)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));
	
	LookAt(G2AMID(nGx), G2AMID(nGy), 12, nAngle, -1);
}
function void DelayedLookAtMarkerMedium(int nMarker, int nAngle, int nTime, int nClockWise)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));
	
	DelayedLookAt(G2AMID(nGx), G2AMID(nGy), 12, nAngle, -1, nTime, nClockWise);
}
function void SetUnitAtMarker(unit uUnit, int nMarker)
{
	int nGx, nGy, nAlpha;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	nAlpha = 0;

	uUnit.SetImmediatePosition(G2AMID(nGx), G2AMID(nGy), 0, nAlpha, true);
}

function void SetUnitAtMarker(unit uUnit, int nMarker, int nAlpha)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	uUnit.SetImmediatePosition(G2AMID(nGx), G2AMID(nGy), 0, nAlpha, true);
}

function void SetUnitAtMarker(unit uUnit, int nMarker, int nOffX, int nOffY)
{
	int nGx, nGy, nAlpha;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	nAlpha = 0;

	uUnit.SetImmediatePosition(G2AMID(nGx+nOffX), G2AMID(nGy+nOffY), 0, nAlpha, true);
}

function void AddMapSignAtMarker(int nMarker, int nType, int nTime)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	AddMapSign(nGx, nGy, nType, nTime);
}

function void AddMapSignAtUnit(unit uUnit, int nType, int nTime)
{
	int nGx, nGy;

	ASSERT(uUnit != null);

	uUnit.GetLocationG(nGx, nGy);

	AddMapSign(nGx, nGy, nType, nTime);
}

function void RemoveMapSignAtMarker(int nMarker)
{
	int nGx, nGy;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	RemoveMapSign(nGx, nGy);
}

function void RemoveMapSignAtUnit(unit uUnit)
{
	int nGx, nGy;

	ASSERT(uUnit != null);

	uUnit.GetLocationG(nGx, nGy);

	RemoveMapSign(nGx, nGy);
}

function int RemoveUnitFromArray(unit auUnits[], unit uUnit)
{
	int i;

	for ( i=0; i<auUnits.GetSize(); ++i )
	{
		if ( auUnits[i] == uUnit )
		{
			auUnits.RemoveAt(i);

			return true;
		}
	}

	return false;
}

function int RemoveIntFromArray(int anInts[], int nInt)
{
	int i;

	for ( i=0; i<anInts.GetSize(); ++i )
	{
		if ( anInts[i] == nInt )
		{
			anInts.RemoveAt(i);

			return true;
		}
	}

	return false;
}

function int FindUnitInArray(unit auUnits[], unit uUnit)
{
	int i;

	for ( i=0; i<auUnits.GetSize(); ++i )
	{
		if ( auUnits[i] == uUnit )
		{
			return i;
		}
	}

	return -1;
}

function int FindIntInArray(int anInts[], int nInt)
{
	int i;

	for ( i=0; i<anInts.GetSize(); ++i )
	{
		if ( anInts[i] == nInt )
		{
			return i;
		}
	}

	return -1;
}

function int IsUnitInArray(unit auUnits[], unit uUnit)
{
	if ( FindUnitInArray(auUnits, uUnit) != -1 )
	{
		return true;
	}

	return false;
}

function int IsIntInArray(int anInts[], int nInt)
{
	if ( FindIntInArray(anInts, nInt) != -1 )
	{
		return true;
	}

	return false;
}

function int CountLessIntsInArray(int anInts[], int nInt)
{
	int i;
	int nCount;

	nCount = 0;

	for ( i=0; i<anInts.GetSize(); ++i )
	{
		if ( anInts[i] < nInt )
		{
			++nCount;
		}
	}

	return nCount;
}

function int RemoveLessIntsFromArray(int anInts[], int nInt)
{
	int i;
	int nCount;

	nCount = 0;

	for ( i=0; i<anInts.GetSize(); ++i )
	{
		if ( anInts[i] < nInt )
		{
			anInts.RemoveAt(i);
			--i;

			++nCount;
		}
	}

	return nCount;
}

function int CountUnitInArray(unit auUnits[], unit uUnit)
{
	int i;
	int nCount;

	nCount = 0;

	for ( i=0; i<auUnits.GetSize(); ++i )
	{
		if ( auUnits[i] == uUnit )
		{
			++nCount;
		}
	}

	return nCount;
}

function void ClearLimitedGameRect()
{
	SetLimitedGameRect(0, 0, 0, 0);
}

function void CreatePlayerObjectsAtPoint(unit auObject[], player pPlayer, string strObject, int nObjects, int nGx, int nGy)
{
	int nAlpha, i;

	ASSERT(auObject.Exist());

	nAlpha = 0;

	for ( i=0; i<nObjects; ++i )
	{
		auObject.Add(pPlayer.CreateObject(strObject, nGx, nGy, 0, nAlpha));
			
	}
}


function void CreatePlayerObjectsAtMarker(unit auObject[], player pPlayer, string strObject, int nObjects, int nMarker)
{
	int nGx, nGy, nAlpha, i;

	ASSERT(auObject.Exist());

	VERIFY(GetMarker(nMarker, nGx, nGy));

	nAlpha = 0;

	for ( i=0; i<nObjects; ++i )
	{
		auObject.Add(CreatePlayerObjectAtMarker(pPlayer, strObject, nMarker));
	}
}

function void CreatePlayerObjectsAtMarker(player pPlayer, string strObject, int nObjects, int nMarker, int nAlpha)
{
	int nGx, nGy;
    int nIndex;

	VERIFY(GetMarker(nMarker, nGx, nGy));

	for (nIndex = 0; nIndex < nObjects; ++nIndex)
    {
	    pPlayer.CreateObject(strObject, nGx, nGy, 0, nAlpha);
    }
}

function void CreatePlayerObjectsAtMarker(player pPlayer, string strObject, int nObjects, int nMarker)
{
    CreatePlayerObjectsAtMarker(pPlayer, strObject, nObjects, nMarker, 0);
}

function void SetPlayer(unit auUnit[], player pPlayer)
{
	int i;

	unit uUnit;

	ASSERT( pPlayer != null );

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit != null && uUnit.IsLive() )
		{
			uUnit.SetPlayer(pPlayer);
		}
	}
}

function void SetExperienceLevel(unit auUnit[], int nExpLvl)
{
	int i;

	unit uUnit;

	for ( i = 0; i < auUnit.GetSize(); ++i )
	{
		uUnit = auUnit[i];

		ASSERT(uUnit != null);

		if ( uUnit != null && uUnit.IsLive() )
		{
			uUnit.SetExperienceLevel(nExpLvl);
		}
	}
}

function void CreateAndAttackFromMarkerToMarker(player pPlayer, string strObject, int nNum, int nMarker1, int nMarker2)
{
	unit auUnitsArray[];
	int nGx, nGy;
	
	auUnitsArray.Create(0); 
	CreatePlayerObjectsAtMarker(auUnitsArray, pPlayer, strObject, nNum, nMarker1);
	VERIFY(GetMarker(nMarker2, nGx, nGy));
	CommandMoveAttackUnitsToPoint(auUnitsArray, G2A(nGx), G2A(nGy));
}

function void CreateAndAttackFromMarkerToUnit(player pPlayer, string strObject, int nNum, int nMarker1, unit uTarget)
{
	unit auUnitsArray[];
	int nGx, nGy;
	auUnitsArray.Create(0); 
	CreatePlayerObjectsAtMarker(auUnitsArray, pPlayer, strObject, nNum, nMarker1);
	uTarget.GetLocation(nGx, nGy);
	CommandMoveAttackUnitsToPoint(auUnitsArray, nGx, nGy);
}



function void CreateAndAttackFromPointToUnit(player pPlayer, string strObject, int nNum, int nGx1, int nGy1, unit uTarget)
{
	unit auUnitsArray[];
	int nGx2, nGy2;
	auUnitsArray.Create(0); 
	CreatePlayerObjectsAtPoint(auUnitsArray, pPlayer, strObject, nNum, nGx1, nGy1);
	uTarget.GetLocation(nGx2, nGy2);
	CommandMoveAttackUnitsToPoint(auUnitsArray, nGx2, nGy2);
}
function void CreateAndAttackFromPointToPoint(player pPlayer, string strObject, int nNum, int nGx1, int nGy1, int nGx2, int nGy2)
{
	unit auUnitsArray[];
	auUnitsArray.Create(0); 
	CreatePlayerObjectsAtPoint(auUnitsArray, pPlayer, strObject, nNum, nGx1, nGy1);
	CommandMoveAttackUnitsToPoint(auUnitsArray, G2AMID(nGx2), G2AMID(nGy2));
}




function void CreateAndMoveFromMarkerToMarker(player pPlayer, string strObject, int nNum, int nMarker1, int nMarker2)
{
	unit auUnitsArray[];
	int nGx, nGy;
	
	auUnitsArray.Create(0); 
	CreatePlayerObjectsAtMarker(auUnitsArray, pPlayer, strObject, nNum, nMarker1);
	CommandMoveUnitsToMarker(auUnitsArray, nMarker2);
}
function void CreateAndMoveFromMarkerToMarker(player pPlayer, string strObject, int nNum, int nMarker1, int nMarker2, int nOffX, int nOffY)
{
	unit auUnitsArray[];
	int nGx, nGy;
	
	auUnitsArray.Create(0); 
	CreatePlayerObjectsAtMarker(auUnitsArray, pPlayer, strObject, nNum, nMarker1);
	CommandMoveUnitsToMarker(auUnitsArray, nMarker2, nOffX,  nOffY);
}

function void CreatePatrol(player pPlayer, string strObject, int nNum, int nMarker1, int nMarker2)
{
	unit auUnitsArray[];
	int nGx1, nGy1, nGx2, nGy2;
	if(!nNum)return;
	auUnitsArray.Create(0); 
	CreatePlayerObjectsAtMarker(auUnitsArray, pPlayer, strObject, nNum, nMarker1);
	VERIFY(GetMarker(nMarker2, nGx1, nGy1));
	VERIFY(GetMarker(nMarker1, nGx2, nGy2));
	CommandPatrolBetween2Points(auUnitsArray, G2A(nGx1), G2A(nGy1),G2A(nGx2), G2A(nGy2));
}
function void CreateDefenders(player pPlayer, string strObject, int nNum, int nMarker1)
{
	unit auUnitsArray[];
	int nGx1, nGy1, nGx2, nGy2;
	
	auUnitsArray.Create(0); 
	CreatePlayerObjectsAtMarker(auUnitsArray, pPlayer, strObject, nNum, nMarker1);
}

function void CreatePatrol(player pPlayer, string strObject, int nNum, int nCreateMarker, int nMarker1, int nMarker2, int nMarker3)
{
	unit auUnitsArray[];
	int nGx1, nGy1, nGx2, nGy2, nGx3, nGy3;
	
	auUnitsArray.Create(0); 
	CreatePlayerObjectsAtMarker(auUnitsArray, pPlayer, strObject, nNum, nCreateMarker);
	VERIFY(GetMarker(nMarker1, nGx1, nGy1));
	VERIFY(GetMarker(nMarker2, nGx2, nGy2));
	VERIFY(GetMarker(nMarker3, nGx3, nGy3));
	CommandPatrolBetween3Points(auUnitsArray, G2A(nGx1), G2A(nGy1),G2A(nGx2), G2A(nGy2),G2A(nGx3), G2A(nGy3));
}
function void CreatePatrol2(player pPlayer, string strObject, int nNum, int nCreateMarker, int nMarker1, int nMarker2, int nMarker3)
{
	unit auUnitsArray[];
	int nGx1, nGy1, nGx2, nGy2, nGx3, nGy3;
	
	auUnitsArray.Create(0); 
	CreatePlayerObjectsAtMarker(auUnitsArray, pPlayer, strObject, nNum, nCreateMarker);
	VERIFY(GetMarker(nMarker1, nGx1, nGy1));
	VERIFY(GetMarker(nMarker2, nGx2, nGy2));
	VERIFY(GetMarker(nMarker3, nGx3, nGy3));
	CommandPatrol2Between3Points(auUnitsArray, G2A(nGx1), G2A(nGy1),G2A(nGx2), G2A(nGy2),G2A(nGx3), G2A(nGy3));
}

function void KillAllPlayerUnits(player pPlayer)
{
	unit auUnits[];
    int nIndex, nCount,nGx,nGy;
    unit uUnit;

    ASSERT((pPlayer != null));
    auUnits.Create(0);
    nCount = pPlayer.GetNumberOfUnits();
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = pPlayer.GetUnit(nIndex);
        if (!uUnit.IsStored() || !uUnit.IsLive())
        {
            continue;
        }
        auUnits.Add(uUnit);
    }
	nCount = auUnits.GetSize();
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = auUnits[nIndex];
        uUnit.KillObject();
    }
}
function void RemoveAllPlayerUnits(player pPlayer)
{
	unit auUnits[];
    int nIndex, nCount,nGx,nGy;
    unit uUnit;

    ASSERT((pPlayer != null));
    auUnits.Create(0);
    nCount = pPlayer.GetNumberOfUnits();
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = pPlayer.GetUnit(nIndex);
        if (!uUnit.IsStored() || !uUnit.IsLive())
        {
            continue;
        }
        auUnits.Add(uUnit);
    }
	nCount = auUnits.GetSize();
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = auUnits[nIndex];
        uUnit.RemoveObject();
    }
}
function void MoveAllPlayerUnitsToMarker(player pPlayer, int nMarker)
{
	unit auUnits[];
    int nIndex, nCount,nGx,nGy;
    unit uUnit;

    ASSERT((pPlayer != null));
	VERIFY(GetMarker(nMarker, nGx, nGy));
    auUnits.Create(0);
    nCount = pPlayer.GetNumberOfUnits();
    for (nIndex = 0; nIndex < nCount; ++nIndex)
    {
        uUnit = pPlayer.GetUnit(nIndex);
        if (!uUnit.IsStored() || !uUnit.IsLive())
        {
            continue;
        }
        auUnits.Add(uUnit);
    }
	CommandMoveUnitsToPoint(auUnits, G2A(nGx), G2A(nGy));

}

function void ActivateAI(player pPlayer)
{
		pPlayer.EnableAI(true);
		pPlayer.SetPlayerMaxUnitLimitSize(1000);
		pPlayer.SetAIControlOptions(eAIControlAll, true);
		pPlayer.SetAIControlOptions(eAIControlChooseEnemies,false);
		pPlayer.SetAIControlOptions(eAIControlAINeutralAI, false);
		pPlayer.SetAIControlOptions(eAIControlWarUnitsFromScript, false);
		
		pPlayer.AddResource(eCrystal, 5000);
		pPlayer.AddResource(eWater, 5000);
		pPlayer.AddResource(eMetal, 5000);

		if(GET_DIFFICULTY_LEVEL()==0) pPlayer.LoadScript("Scripts\\AIPlayers\\Campaigns\\singleEasy.eco"); 
		if(GET_DIFFICULTY_LEVEL()==1) pPlayer.LoadScript("Scripts\\AIPlayers\\Campaigns\\singleMedium.eco");
		if(GET_DIFFICULTY_LEVEL()==2) pPlayer.LoadScript("Scripts\\AIPlayers\\Campaigns\\singleHard.eco");
}

function void MissionDefeat()
{
    //EndMission(false);
    ShowMissionFailedLoadDialog();
}

function int IsTransformationCopula(player pPlayer, string pszObjectID)
{
    int nIndex, nSize;
    unit uCopula;
    string strCopulaID;

    nSize = pPlayer.GetNumberOfTransformationCopulas();
    for (nIndex = 0; nIndex < nSize; ++nIndex)
    {
        uCopula = pPlayer.GetTransformationCopula(nIndex);
        strCopulaID = uCopula.GetObjectIDName();
        if (!strCopulaID.CompareNoCase(pszObjectID))
        {
            return true;
        }
    }
    return false;
}
function void AddAgent(int nAgent)
{
	string sAgent, sVehicle;
	

	sAgent.Format("N_IN_VA_%02d",nAgent);

	if(!IsAgentInHire(sAgent) && !IsAgentInWorld(sAgent))
	{

		if (nAgent==4 || nAgent==6 || nAgent==7)
			sVehicle="";
		else
		{
			sVehicle.Format("N_CH_VA_%02d",nAgent);
		}
		AddAgentToHire(sAgent,sVehicle);
		
	}
}
function void addAllResearchUCS(player p) {

	p.AddResearch("UCS_LAND_TECH1");
	p.AddResearch("UCS_LAND_TECH2");
	p.AddResearch("UCS_LAND_TECH3");
	p.AddResearch("UCS_LAND_TECH4");
	p.AddResearch("UCS_LAND_ARMOUR1");
	p.AddResearch("UCS_LAND_ARMOUR2");
	p.AddResearch("UCS_LAND_ARMOUR3");
	p.AddResearch("UCS_AIR_TECH1");
	p.AddResearch("UCS_AIR_TECH2");
	p.AddResearch("UCS_AIR_TECH3");
	p.AddResearch("UCS_AIR_TECH4");
	p.AddResearch("UCS_AIR_ARMOUR1");
	p.AddResearch("UCS_AIR_ARMOUR2");
	p.AddResearch("UCS_AIR_ARMOUR3");
	p.AddResearch("UCS_DEFENSE_TECH1");
	p.AddResearch("UCS_DEFENSE_TECH2");
	p.AddResearch("UCS_DEFENSE_TECH3");
	p.AddResearch("UCS_DEFENSE_TECH4");
	p.AddResearch("UCS_BUILDINGS_ARMOUR1");
	p.AddResearch("UCS_BUILDINGS_ARMOUR2");
	p.AddResearch("UCS_BUILDINGS_ARMOUR3");
	p.AddResearch("UCS_PULSE_GUN");
	p.AddResearch("UCS_PULSE_GUN2");
	p.AddResearch("UCS_PULSE_GUN3");
	p.AddResearch("UCS_PULSE_BULLET");
	p.AddResearch("UCS_PULSE_BULLET2");
	p.AddResearch("UCS_PULSE_BULLET3");
	p.AddResearch("UCS_ROENTGEN_EMMITER");
	p.AddResearch("UCS_ROENTGEN_EMMITER2");
	p.AddResearch("UCS_ROENTGEN_EMMITER3");
	p.AddResearch("UCS_ROENTGEN_GENERATOR");
	p.AddResearch("UCS_ROENTGEN_GENERATOR2");
	p.AddResearch("UCS_ROENTGEN_GENERATOR3");
	p.AddResearch("UCS_PLASMA_GUN");
	p.AddResearch("UCS_PLASMA_GUN2");
	p.AddResearch("UCS_PLASMA_GUN3");
	p.AddResearch("UCS_PLASMA_GENERATOR1");
	p.AddResearch("UCS_PLASMA_GENERATOR2");
	p.AddResearch("UCS_PLASMA_GENERATOR3");
	p.AddResearch("UCS_PLASMA_CANNON");
	p.AddResearch("UCS_ROCKET_LAUNCHER");
	p.AddResearch("UCS_ROCKET_LAUNCHER2");
	p.AddResearch("UCS_ROCKET_LAUNCHER3");
	p.AddResearch("UCS_ROCKET");
	p.AddResearch("UCS_ROCKET2");
	p.AddResearch("UCS_ROCKET3");
	p.AddResearch("UCS_GRANADE_LAUNCHER");
	p.AddResearch("UCS_GRANADE_LAUNCHER2");
	p.AddResearch("UCS_GRANADE_LAUNCHER3");
	p.AddResearch("UCS_GRANADE");
	p.AddResearch("UCS_GRANADE2");
	p.AddResearch("UCS_GRANADE3");
	p.AddResearch("UCS_BOMB_LAUNCHER");
	p.AddResearch("UCS_BOMB_LAUNCHER2");
	p.AddResearch("UCS_BOMB_LAUNCHER3");
	p.AddResearch("UCS_BOMB");
	p.AddResearch("UCS_BOMB2");
	p.AddResearch("UCS_BOMB3");
	p.AddResearch("UCS_SHIELD");
	p.AddResearch("UCS_SHIELD2");
	p.AddResearch("UCS_SHIELD3");
	p.AddResearch("UCS_ANTI_SHIELD");
	p.AddResearch("UCS_ANTI_SHIELD2");
	p.AddResearch("UCS_ANTI_SHIELD3");
	p.AddResearch("UCS_AMIS_LAUNCHER");
	p.AddResearch("UCS_AMIS_LAUNCHER2");
	p.AddResearch("UCS_AMIS_LAUNCHER3");
	p.AddResearch("UCS_DRONE");
	p.AddResearch("UCS_DRONE2");
	p.AddResearch("UCS_SDI");
	p.AddResearch("UCS_RADAR");
	p.AddResearch("UCS_SENSORS");
	p.AddResearch("UCS_SENSORS2");
	p.AddResearch("UCS_SENSORS3");
	p.AddResearch("SHADOW");
	p.AddResearch("SHADOW2");
	p.AddResearch("SHADOW3");
	p.AddResearch("UCS_TELEPORT1");
	p.AddResearch("UCS_TELEPORT2");
	p.AddResearch("UCS_TELEPORT3");
}

function void addAllResearchED(player p) {

	p.AddResearch("ED_LAND_TECH1");
	p.AddResearch("ED_LAND_TECH2");
	p.AddResearch("ED_LAND_TECH3");
	p.AddResearch("ED_LAND_TECH4");
	p.AddResearch("ED_LAND_ARMOUR1");
	p.AddResearch("ED_LAND_ARMOUR2");
	p.AddResearch("ED_LAND_ARMOUR3");
	p.AddResearch("ED_AIR_TECH1");
	p.AddResearch("ED_AIR_TECH2");
	p.AddResearch("ED_AIR_TECH3");
	p.AddResearch("ED_AIR_TECH4");
	p.AddResearch("ED_AIR_ARMOUR1");
	p.AddResearch("ED_AIR_ARMOUR2");
	p.AddResearch("ED_AIR_ARMOUR3");
	p.AddResearch("ED_DEFENSE_TECH1");
	p.AddResearch("ED_DEFENSE_TECH2");
	p.AddResearch("ED_DEFENSE_TECH3");
	p.AddResearch("ED_DEFENSE_TECH4");
	p.AddResearch("ED_BUILDINGS_ARMOUR1");
	p.AddResearch("ED_BUILDINGS_ARMOUR2");
	p.AddResearch("ED_BUILDINGS_ARMOUR3");
	p.AddResearch("ED_PULSE_GUN");
	p.AddResearch("ED_PULSE_GUN2");
	p.AddResearch("ED_PULSE_GUN3");
	p.AddResearch("ED_PULSE_BULLET");
	p.AddResearch("ED_PULSE_BULLET2");
	p.AddResearch("ED_PULSE_BULLET3");
	p.AddResearch("ED_PPANC_CANNON");
	p.AddResearch("ED_PPANC_CANNON2");
	p.AddResearch("ED_PPANC_CANNON3");
	p.AddResearch("ED_PPANC_AMMO");
	p.AddResearch("ED_PPANC_AMMO2");
	p.AddResearch("ED_PPANC_AMMO3");
	p.AddResearch("ED_ARTYLERY_CANNON");
	p.AddResearch("ED_LASER_GUN");
	p.AddResearch("ED_LASER_GUN2");
	p.AddResearch("ED_LASER_GUN3");
	p.AddResearch("ED_LASER_GENERATOR");
	p.AddResearch("ED_LASER_GENERATOR2");
	p.AddResearch("ED_LASER_GENERATOR3");
	p.AddResearch("ED_JON_GUN");
	p.AddResearch("ED_JON_GUN2");
	p.AddResearch("ED_JON_GUN3");
	p.AddResearch("ED_JON_GENERATOR");
	p.AddResearch("ED_JON_GENERATOR2");
	p.AddResearch("ED_JON_GENERATOR3");
	p.AddResearch("ED_ROCKET_LAUNCHER");
	p.AddResearch("ED_ROCKET_LAUNCHER2");
	p.AddResearch("ED_ROCKET_LAUNCHER3");
	p.AddResearch("ED_ROCKET");
	p.AddResearch("ED_ROCKET2");
	p.AddResearch("ED_ROCKET3");
	p.AddResearch("ED_BALISTIC_ROCKET");
	p.AddResearch("ED_BOMB_LAUNCHER");
	p.AddResearch("ED_BOMB_LAUNCHER2");
	p.AddResearch("ED_BOMB_LAUNCHER3");
	p.AddResearch("ED_BOMB");
	p.AddResearch("ED_BOMB2");
	p.AddResearch("ED_BOMB3");
	p.AddResearch("ED_NUCLEAR_WARHEAD");
	p.AddResearch("ED_SHIELD");
	p.AddResearch("ED_SHIELD2");
	p.AddResearch("ED_SHIELD3");
	p.AddResearch("ED_SHIELD_SUCKER");
	p.AddResearch("ED_SHIELD_SUCKER2");
	p.AddResearch("ED_SHIELD_SUCKER3");
	p.AddResearch("ED_AMIS_LAUNCHER");
	p.AddResearch("ED_AMIS_LAUNCHER2");
	p.AddResearch("ED_AMIS_LAUNCHER3");
	p.AddResearch("ED_DRONE");
	p.AddResearch("ED_DRONE2");
	p.AddResearch("ED_SDI");
	p.AddResearch("ED_RADAR");
	p.AddResearch("ED_SENSORS");
	p.AddResearch("ED_SENSORS2");
	p.AddResearch("ED_SENSORS3");
	p.AddResearch("ED_ARMOUR_UP");
	p.AddResearch("ED_ARMOUR_UP2");
	p.AddResearch("ED_ARMOUR_UP3");
	p.AddResearch("ED_MOBILE_RAFINERY2");
	p.AddResearch("ED_MOBILE_RAFINERY3");
	p.AddResearch("ED_MOBILE_RAFINERY4");

}

function void addAllResearchLC(player p) {

	p.AddResearch("LC_LAND_TECH1");
	p.AddResearch("LC_LAND_TECH2");
	p.AddResearch("LC_LAND_TECH3");
	p.AddResearch("LC_LAND_TECH4");
	p.AddResearch("LC_LAND_ARMOUR1");
	p.AddResearch("LC_LAND_ARMOUR2");
	p.AddResearch("LC_LAND_ARMOUR3");
	p.AddResearch("LC_AIR_TECH1");
	p.AddResearch("LC_AIR_TECH2");
	p.AddResearch("LC_AIR_TECH3");
	p.AddResearch("LC_AIR_TECH4");
	p.AddResearch("LC_AIR_ARMOUR1");
	p.AddResearch("LC_AIR_ARMOUR2");
	p.AddResearch("LC_AIR_ARMOUR3");
	p.AddResearch("LC_DEFENSE_TECH1");
	p.AddResearch("LC_DEFENSE_TECH2");
	p.AddResearch("LC_DEFENSE_TECH3");
	p.AddResearch("LC_DEFENSE_TECH4");
	p.AddResearch("LC_BUILDINGS_ARMOUR1");
	p.AddResearch("LC_BUILDINGS_ARMOUR2");
	p.AddResearch("LC_BUILDINGS_ARMOUR3");
	p.AddResearch("LC_PULSE_GUN");
	p.AddResearch("LC_PULSE_GUN2");
	p.AddResearch("LC_PULSE_GUN3");
	p.AddResearch("LC_PULSE_BULLET");
	p.AddResearch("LC_PULSE_BULLET2");
	p.AddResearch("LC_PULSE_BULLET3");
	p.AddResearch("LC_MAGNETIC_CANNON");
	p.AddResearch("LC_MAGNETIC_CANNON2");
	p.AddResearch("LC_MAGNETIC_CANNON3");
	p.AddResearch("LC_MAGNETIC_AMMO");
	p.AddResearch("LC_MAGNETIC_AMMO2");
	p.AddResearch("LC_MAGNETIC_AMMO3");
	p.AddResearch("LC_ALTYLERY_CANNON");
	p.AddResearch("LC_ELECTRIC_CANNON");
	p.AddResearch("LC_ELECTRIC_CANNON2");
	p.AddResearch("LC_ELECTRIC_CANNON3");
	p.AddResearch("LC_ELECTRIC_GENERATOR");
	p.AddResearch("LC_ELECTRIC_GENERATOR2");
	p.AddResearch("LC_ELECTRIC_GENERATOR3");
	p.AddResearch("LC_STORM_GENERATOR");
	p.AddResearch("LC_SONIC_CANNON");
	p.AddResearch("LC_SONIC_CANNON2");
	p.AddResearch("LC_SONIC_CANNON3");
	p.AddResearch("LC_SONIC_GENERATOR");
	p.AddResearch("LC_SONIC_GENERATOR2");
	p.AddResearch("LC_SONIC_GENERATOR3");
	p.AddResearch("LC_ROCKET_LAUNCHER");
	p.AddResearch("LC_ROCKET_LAUNCHER2");
	p.AddResearch("LC_ROCKET_LAUNCHER3");
	p.AddResearch("LC_ROCKET");
	p.AddResearch("LC_ROCKET2");
	p.AddResearch("LC_ROCKET3");
	p.AddResearch("LC_BOMB_LAUNCHER");
	p.AddResearch("LC_BOMB_LAUNCHER2");
	p.AddResearch("LC_BOMB_LAUNCHER3");
	p.AddResearch("LC_BOMB");
	p.AddResearch("LC_BOMB2");
	p.AddResearch("LC_BOMB3");
	p.AddResearch("LC_NEMEZIS_CANNON");
	p.AddResearch("LC_SHIELD");
	p.AddResearch("LC_SHIELD2");
	p.AddResearch("LC_SHIELD3");
	p.AddResearch("LC_SHIELD_REGENERATOR");
	p.AddResearch("LC_SHIELD_REGENERATOR2");
	p.AddResearch("LC_SHIELD_REGENERATOR3");
	p.AddResearch("LC_AMIS_LAUNCHER");
	p.AddResearch("LC_AMIS_LAUNCHER2");
	p.AddResearch("LC_AMIS_LAUNCHER3");
	p.AddResearch("LC_DRONE");
	p.AddResearch("LC_DRONE2");
	p.AddResearch("LC_SDI");
	p.AddResearch("LC_RADAR");
	p.AddResearch("LC_SENSORS");
	p.AddResearch("LC_SENSORS2");
	p.AddResearch("LC_SENSORS3");
	p.AddResearch("LC_DISPERSER");
	p.AddResearch("LC_DISPERSER2");
	p.AddResearch("LC_DISPERSER3");
	p.AddResearch("LC_MINE_UPGRADE");
	p.AddResearch("LC_MINE_UPGRADE2");
	p.AddResearch("LC_MINE_UPGRADE3");

}

function void addAllResearchAlien(player p) {
}


function void CreateFxToCreatedUnit(unit uUnit,player P)
{
		P.CreateObject("TELEPORT_OUT", uUnit.GetLocationX(),uUnit.GetLocationY(),uUnit.GetLocationZ(),0);
}




function void AddSquad(unit uUnit1, unit uUnit2, unit uUnit3, unit uUnit4, unit uUnit5, unit uUnit6)
{
	int nP,i,n;
	player pPlayer;
	unit uUnit;
	string Console2;
	pPlayer=GetPlayer(uUnit1.GetIFFNum());
	nP=pPlayer.GetIFFNum();
	for(n=1; n<=m_nL[nP];++n)
    {
		uUnit=m_uLeader[(nP-1)*200+n];
       	if(!uUnit.IsLive())
		{
			uUnit=null;
		}
		if(uUnit==null)
        {
			break;
         }
		 if(n==m_nL[nP])
		 {
		 	++m_nL[nP];
			n=m_nL[nP];
			break;
		 }
      }
	if(m_nL[nP]==0)
	{
		 	++m_nL[nP];
			n=m_nL[nP];
	}
	m_uLeaderContainingObject[(nP-1)*200+n]=uUnit1;
    if (uUnit1.HaveCrew())
	{
		m_uLeader[(nP-1)*200+n]=uUnit1.GetCrew();
	} else m_uLeader[(nP-1)*200+n]=uUnit1;

	m_uContainingObject[(nP-1)*200+(n-1)*5+1]=uUnit2;
	if (uUnit2.HaveCrew())
	{
		m_uSubordinate[(nP-1)*200+(n-1)*5+1]=uUnit2.GetCrew();
	}else m_uSubordinate[(nP-1)*200+(n-1)*5+1]=uUnit2;

	m_uContainingObject[(nP-1)*200+(n-1)*5+2]=uUnit3;
	if (uUnit3.HaveCrew())
	{
		m_uSubordinate[(nP-1)*200+(n-1)*5+2]=uUnit3.GetCrew();
	}else m_uSubordinate[(nP-1)*200+(n-1)*5+2]=uUnit3;	

	m_uContainingObject[(nP-1)*200+(n-1)*5+3]=uUnit4;
	if (uUnit4.HaveCrew())
	{
		m_uSubordinate[(nP-1)*200+(n-1)*5+3]=uUnit4.GetCrew();
	}else m_uSubordinate[(nP-1)*200+(n-1)*5+3]=uUnit4;
	
	m_uContainingObject[(nP-1)*200+(n-1)*5+4]=uUnit5;	
	if (uUnit5.HaveCrew())
	{
		m_uSubordinate[(nP-1)*200+(n-1)*5+4]=uUnit5.GetCrew();
	}else m_uSubordinate[(nP-1)*200+(n-1)*5+4]=uUnit5;
	
	m_uContainingObject[(nP-1)*200+(n-1)*5+5]=uUnit6;
	if (uUnit6.HaveCrew())
	{
		m_uSubordinate[(nP-1)*200+(n-1)*5+5]=uUnit6.GetCrew();
	}else m_uSubordinate[(nP-1)*200+(n-1)*5+5]=uUnit6;  
	Console2.Translate("translateSquadAddedToArray");
	SetConsole2Text(Console2,90);

}
function void AddUnitToLeaderArray(unit uUnit)
{
	int nP,i,n;
	player pPlayer;
	unit uUnit1;
	pPlayer=GetPlayer(uUnit.GetIFFNum());
	nP=pPlayer.GetIFFNum();
	for(n=1; n<=m_nL[nP];++n)
    {
		uUnit1=m_uLeader[(nP-1)*200+n];
       	if(!uUnit1.IsLive())
		{
			uUnit1=null;
		}
		if(uUnit1==null)
        {
			break;
         }
		 if(n==m_nL[nP])
		 {
		 	++m_nL[nP];
			n=m_nL[nP];
			break;
		 }
      }
	if(m_nL[nP]==0)
	{
		 	++m_nL[nP];
			n=m_nL[nP];
	}
    if (uUnit.HaveCrew())
	{
		m_uLeader[(nP-1)*200+n]=uUnit.GetCrew();
	} else m_uLeader[(nP-1)*200+n]=uUnit;
	m_uLeaderContainingObject[(nP-1)*200+n]=uUnit;
	for(i=1; i<6; ++i)
	{
		m_uContainingObject[(nP-1)*200+(n-1)*5+i]=uUnit;
	}
}
function void IncInfantryBuildTimer(int nP,int i)
{
	if (m_nInfantryBuildTimer[(nP-1)*200+i]>0)
	{
		++ m_nInfantryBuildTimer[(nP-1)*200+i];
	}	
}
function void LeaderContainingObject(int nP,int i)
{
	unit uUnit;
	uUnit=m_uLeader[(nP-1)*200+i];
	if(uUnit.IsLive() && !uUnit==null)
	{			
		if(!uUnit.IsStored())
		{
			uUnit=uUnit.GetObjectContainingObject();
			if(uUnit.IsBuilding())
			{
				m_uLeader[(nP-1)*200+i]=null;
				uUnit=null;
				m_uLeaderContainingObject[(nP-1)*200+i]=null;
			}
			else
			{
				if(!uUnit.IsTransporter())
				{
					m_uLeaderContainingObject[(nP-1)*200+i]=uUnit;
				}							
			}
		}
		else
		{
			m_uLeaderContainingObject[(nP-1)*200+i]=uUnit;
		}
	}	
}
function void Replenish(int nP,int i, int n)
{
	string UnitIDName,Console2;
	unit uUnit,uUnit2;
	int nX,nY,nZ,nPrice;
	player P;
	P=GetPlayer(nP);
	uUnit=m_uLeader[(nP-1)*200+i];
	nX=uUnit.GetLocationX();
	nY=uUnit.GetLocationY();
	nZ=uUnit.GetLocationZ();
	if (m_uSubordinate[(nP-1)*200+(i-1)*5+n] == null)
	if (!m_uContainingObject[(nP-1)*200+(i-1)*5+n] == null) 
	{
		if(m_nInfantryBuildTimer[(nP-1)*200+i]==-1)
		{
			m_nInfantryBuildTimer[(nP-1)*200+i]=1;
		}
		else
		{
			uUnit2=m_uContainingObject[(nP-1)*200+(i-1)*5+n];
			UnitIDName=uUnit2.GetObjectIDName();
			UnitIDName=GetSubordinateUnitID(UnitIDName,P.GetRace());
			nPrice=PriceIfGoodTimeAndRace(UnitIDName,P.GetRace(),m_nInfantryBuildTimer[(nP-1)*200+i],uUnit2.IsInfantry());
			if(nPrice)
			{
				if(nPrice<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
				{	 
					m_uContainingObject[(nP-1)*200+(i-1)*5+n]=P.CreateObject(UnitIDName,nX,nY,40,uUnit.GetDirectionAlpha());	 P.AddResource(1, -nPrice);
					uUnit2=m_uContainingObject[(nP-1)*200+(i-1)*5+n];
					CreateFxToCreatedUnit(uUnit2,P);
					Console2="translate";
					Console2.Append(UnitIDName);
					Console2.Translate(Console2);
					Console2.Append(AddedToSquad);
					P.SetConsole2Text(Console2,90);
					uUnit2.SetGroupNum(uUnit.GetGroupNum());
					if(uUnit2.HaveCrew())
					{
						m_uSubordinate[(nP-1)*200+(i-1)*5+n]=uUnit2.GetCrew();
					}
					else
					{
						m_uSubordinate[(nP-1)*200+(i-1)*5+n]=uUnit2;
					}
					uUnit2=m_uSubordinate[(nP-1)*200+(i-1)*5+n];
					uUnit2.CommandMove(nX, nY);					
					m_nInfantryBuildTimer[(nP-1)*200+i]=-1;
				}
			}
		}
	}
	else
	{
		if(m_nInfantryBuildTimer[(nP-1)*200+i]==-1)
		{
			m_nInfantryBuildTimer[(nP-1)*200+i]=1;
		}
		else
		{
			
			uUnit2=m_uSubordinate[(nP-1)*200+(i-1)*5+n];
			UnitIDName=uUnit.GetObjectIDName();
			UnitIDName=GetSubordinateUnitID(UnitIDName,P.GetRace());
			nPrice=PriceIfGoodTimeAndRace(UnitIDName,P.GetRace(),m_nInfantryBuildTimer[(nP-1)*200+i],uUnit.IsInfantry());
			if(nPrice)
			{
				
					if(nPrice<P.GetResource(1, 1, 1))
					{
						m_uContainingObject[(nP-1)*200+(i-1)*5+n]=m_uSubordinate[(nP-1)*200+(i-1)*5+n]=P.CreateObject(UnitIDName,nX,nY,40,uUnit.GetDirectionAlpha());
						uUnit2=m_uSubordinate[(nP-1)*200+(i-1)*5+n];
						CreateFxToCreatedUnit(uUnit2,P);
						uUnit2.SetGroupNum(uUnit.GetGroupNum());	
						P.AddResource(1,  -GetUnitPrice(UnitIDName));
					}
					uUnit2=m_uSubordinate[(nP-1)*200+(i-1)*5+n];
					uUnit2.CommandMove(nX+Rand(300)-15, nY+Rand(300)-150);					
					m_nInfantryBuildTimer[(nP-1)*200+i]=-1;
			}
		}
	}
}
function void ContainigObjectToArray(int nP,int i,int n)
{
	unit uUnit2;	
	uUnit2=m_uSubordinate[(nP-1)*200+(i-1)*5+n];
	if(uUnit2.IsLive() && !uUnit2==null)
	{
		if(!uUnit2.IsStored())
		{
			uUnit2=uUnit2.GetObjectContainingObject();

			if(uUnit2.IsBuilding())
			{
				m_uSubordinate[(nP-1)*200+(i-1)*5+n]=null;
				m_uContainingObject[(nP-1)*200+(i-1)*5+n]=null;
				uUnit2=null;
			}
			else
			{
				if (!uUnit2.IsTransporter())
				{
					m_uContainingObject[(nP-1)*200+(i-1)*5+n]=uUnit2;
				}							
			}
		}
		else
		{
			m_uContainingObject[(nP-1)*200+(i-1)*5+n]=uUnit2;
		}
	}

}
function void ChangeDeadLeader(int nP,int i)
{
	unit uUnit,uUnit2;
	int n;
	uUnit=m_uLeader[(nP-1)*200+i];
	if(!uUnit.IsLive())
	{
		for (n=1;n<=5;++n)
		{
			uUnit2=m_uSubordinate[(nP-1)*200+(i-1)*5+n];
			if(uUnit2.IsLive())
			{
				m_uSubordinate[(nP-1)*200+(i-1)*5+n]=null;
				m_uLeader[(nP-1)*200+i]=uUnit2;
				uUnit=uUnit2;
				uUnit2=m_uContainingObject[(nP-1)*200+(i-1)*5+n];
				m_uContainingObject[(nP-1)*200+(i-1)*5+n]=m_uLeaderContainingObject[(nP-1)*200+i];
				m_uLeaderContainingObject[(nP-1)*200+i]=uUnit2;
				
				break;
			}
		}
	}
}
function void MoveSubordinateToLeader(int nP,int i,int n)
{
	unit uUnit,uUnit2;
	int nX,nY,nZ;
	uUnit=m_uLeader[(nP-1)*200+i];
	nX=uUnit.GetLocationX();
	nY=uUnit.GetLocationY();
	nZ=uUnit.GetLocationZ();
	uUnit2=m_uSubordinate[(nP-1)*200+(i-1)*5+n];
	if(!uUnit2.IsMoving() && (uUnit.DistanceToClosestGrid(uUnit2)>(400+1000*!uUnit2.IsStored()) || uUnit.DistanceToClosestGrid(uUnit2)<40) && uUnit.IsLive() && !uUnit.IsSelected() && !uUnit2.IsSelected())
	{
		if (!uUnit2.IsStored())
		{
			uUnit=uUnit2.GetObjectContainingObject();
			if (!uUnit.IsTransporter())
			{
				uUnit2=uUnit;
				uUnit=m_uLeader[(nP-1)*200+i];
				if(!IsHarvesterID(uUnit2.GetObjectIDName()) && !uUnit2.IsSelected())
				{
					uUnit2.CommandMoveXYZA(nX+Rand(300)-150, nY+Rand(300)-150, 2, uUnit.GetDirectionAlpha());
				}
			}
		}
		else
		{
			uUnit=m_uLeader[(nP-1)*200+i];
			uUnit2.CommandMoveXYZA(nX+Rand(160)-80, nY+Rand(160)-80, 2, uUnit.GetDirectionAlpha());
		}
	}
}
function void SetSquadSelection(int nP,int i,int n)
{
	unit uUnit,uUnit2;
	int m;
						uUnit=m_uLeader[(nP-1)*200+i];
						uUnit2=m_uSubordinate[(nP-1)*200+(i-1)*5+n];
						if(!uUnit.IsStored())
						{
							uUnit=m_uLeaderContainingObject[(nP-1)*200+i];
						}
						if(!uUnit2.IsStored())
						{
							uUnit2=m_uContainingObject[(nP-1)*200+(i-1)*5+n];
						}						
						if(uUnit.IsSelected() && !uUnit2.IsSelected() && uUnit.IsLive())
						{
						 uUnit2.SetSelected(true);
						}
						if(uUnit2.IsSelected() && !uUnit.IsSelected() && uUnit.IsLive())
						{
							uUnit.SetSelected(true);
							for(m=1;m<6;++m)
							{ 
								uUnit=m_uSubordinate[(nP-1)*200+(i-1)*5+m];
								if(!uUnit.IsStored())
								{
									uUnit=uUnit.GetObjectContainingObject();
								}
								if(!uUnit.IsSelected())
								{
									uUnit.SetSelected(true);
								}
							}
						}
}
function void AddUnitsToLeader()
{
	player P;
	int nP;
	int nX,nY,nZ, nX2, nY2;
	int i,n,m;
	unit uUnit, uUnit2;
	int nTr,nExist;
	string UnitIDName,Name;
	for(nP=1;nP<=8;++nP)
	{
		P=GetPlayer(nP);
		for(i=1;i<=m_nL[nP];++i)
		{
				IncInfantryBuildTimer(nP,i);
				ChangeDeadLeader(nP,i);
				uUnit=m_uLeader[(nP-1)*200+i];
				if (uUnit.GetGroupNum()==9)
				{
					uUnit.SetGroupNum(8);
				}
				LeaderContainingObject(nP,i);
				uUnit=m_uLeader[(nP-1)*200+i];
				for(n=1;n<=5;++n)
				{
					if(!uUnit==null && uUnit.IsLive())
					{
						uUnit2=m_uSubordinate[(nP-1)*200+(i-1)*5+n];
						if (uUnit2.GetGroupNum()==9)
						{
							uUnit2.SetGroupNum(8);
						}

						if(!uUnit2.IsLive())     
						{	
							m_uSubordinate[(nP-1)*200+(i-1)*5+n]=null;
							Replenish(nP,i,n);
						}						
						uUnit2=m_uSubordinate[(nP-1)*200+(i-1)*5+n];
						if(uUnit2.IsLive())
						{
							ContainigObjectToArray(nP,i,n);
							MoveSubordinateToLeader(nP,i,n);
							SetSquadSelection(nP,i,n);
						}
					}
				}
		}
	}
}
function void AddUnitToCarrierArray(unit uUnit)
{
	int nP,i,n;
	player pPlayer;
	unit uUnit2;
	pPlayer=GetPlayer(uUnit.GetIFFNum());
	nP=pPlayer.GetIFFNum();
	for(n=1; n<=m_nC[nP];++n)
    {
		uUnit2=m_uCarrier[(nP-1)*20+n];
       	if(!uUnit2.IsLive())
		{
			uUnit2=null;
		}
		if(uUnit2==null)
        {
             m_uCarrier[(nP-1)*20+n]=uUnit;
			break;
         }
		 if(n==m_nC[nP])
		 {
		 	++m_nC[nP];
			n=m_nC[nP];
			m_uCarrier[(nP-1)*20+n]=uUnit;
			break;
		 }
      }
	if(m_nC[nP]==0)
	{
		 	++m_nC[nP];
			n=m_nC[nP];
			m_uCarrier[(nP-1)*20+n]=uUnit;	
	}	  
}
function void AddUnitsToCarrier()
{
	player P;
	int nP;
	int nX,nY,nZ;
	int i,n,m;
	unit uUnit, uUnit2;
	int nTr,nExist;
	string sName;
	int nMinMovingPoints;
	int nUnitWithMinMovingPoints;
	string LowConsole;
	string Console2;
	string AddedToCarrier;
	AddedToCarrier.Translate("translateAddedToCarrier");
	for(nP=1;nP<=8;++nP)
	{
		P=GetPlayer(nP);
		nMinMovingPoints=9000;
		nUnitWithMinMovingPoints=9000;
		for(i=1;i<=m_nC[nP];++i)
		{
				++ m_nBuildTimer[(nP-1)*20+i];	
				uUnit=m_uCarrier[(nP-1)*20+i];

				nX=uUnit.GetLocationX();
			 	nY=uUnit.GetLocationY();
			 	nZ=uUnit.GetLocationZ();
				sName=uUnit.GetObjectIDName();
				if (!sName.Compare("UCSSF_HBATLE") || !sName.Compare("UCSSF_BATLE") || !sName.Compare("EDSF_HBATLE") || !sName.Compare("EDSF_BATLE") || !sName.Compare("LCSF_HBATLE") || !sName.Compare("LCSF_BATLE"))
				{
					if(uUnit.IsMoving())
					{  
						if(m_nMovingPoints[(nP-1)*20+i]>0) --m_nMovingPoints[(nP-1)*20+i];
						if(m_nMovingPoints[(nP-1)*20+i]<1) 	uUnit.CommandStop();
					}	
					else 
					{
						if(m_nMovingPoints[(nP-1)*20+i]<10) ++m_nMovingPoints[(nP-1)*20+i];
					}
					if(m_nMovingPoints[(nP-1)*20+i]<nMinMovingPoints) nMinMovingPoints=m_nMovingPoints[(nP-1)*20+i];
					if(uUnit.IsSelected() && m_nMovingPoints[(nP-1)*20+i]==nMinMovingPoints)
					{
				 		nMinMovingPoints=m_nMovingPoints[(nP-1)*20+i];
						nUnitWithMinMovingPoints=i;
					}
				}

				if (uUnit.GetGroupNum()==9)
				{	
					uUnit.SetGroupNum(8);
				}
			if(uUnit.IsLive() && !uUnit==null && sName.Compare("LCSF_BATLE") && sName.Compare("EDSF_BATLE") && sName.Compare("UCSSF_BATLE"))	
			for(n=1;n<=8;++n)
			{
					uUnit=m_uUnit1[(nP-1)*20+(i-1)*8+n];
					if (uUnit.GetGroupNum()==9)
					{	
						uUnit.SetGroupNum(8);
					}
					if(!uUnit.IsLive())     
					{
						m_uUnit1[(nP-1)*20+(i-1)*8+n]=null;
					}
					if (m_uUnit1[(nP-1)*20+(i-1)*8+n] == null && m_nBuildTimer[(nP-1)*20+i]>10)
					{
						if (n==7 || n==8)
						{
							if(!sName.Compare("EDSF_BS")) if(GetUnitPrice(E_T_BOMBER)<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateED_BOMBER_TORP"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject(E_T_BOMBER,nX,nY,2,uUnit.GetDirectionAlpha());P.AddResource(1, -GetUnitPrice(E_T_BOMBER));							
							}
							if(!sName.Compare("LCSF_BS")) if(GetUnitPrice(L_T_THUNDER)<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateLC_THUNDER_TORP"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject(L_T_THUNDER,nX,nY,2,uUnit.GetDirectionAlpha());P.AddResource(1, -GetUnitPrice(L_T_THUNDER));							
							}
							if(!sName.Compare("UCSSF_BS")) if(GetUnitPrice(U_T_HELLWIND)<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateUCS_HELLWIND_TORP"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject(U_T_HELLWIND,nX,nY,2,uUnit.GetDirectionAlpha());P.AddResource(1, -GetUnitPrice(U_T_HELLWIND));														
							}
						}
						if(n==3 || n==6)
						{
							if(P.GetRace()==eRaceUCS) if(GetUnitPrice(U_R_BAT)<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateUCS_BAT_R"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject(U_R_BAT,nX,nY,2,uUnit.GetDirectionAlpha()); P.AddResource(1, -GetUnitPrice(U_R_BAT));
							}
							if(P.GetRace()==eRaceED) if(GetUnitPrice(E_HR_INTERCEPTOR)<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateE_HR_INTERCEPTOR"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject(E_HR_INTERCEPTOR,nX,nY,2,uUnit.GetDirectionAlpha()); P.AddResource(1, -GetUnitPrice(E_HR_INTERCEPTOR));					
							}
							if(P.GetRace()==eRaceLC) if(GetUnitPrice(L_R_THUNDER)<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateLC_THUNDER_HRA"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject(L_R_THUNDER,nX,nY,2,uUnit.GetDirectionAlpha()); P.AddResource(1, -GetUnitPrice(L_R_THUNDER));				
							}
							if(P.GetRace()==eRaceAlien)
							{
								Console2.Translate("translateMORPHOID_FIGHTER"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("MORPHOID_FIGHTER",nX,nY,2,uUnit.GetDirectionAlpha());			
							}							
						}
						else
						if (n<7)
						{
							if(P.GetRace()==eRaceUCS) if(GetUnitPrice(U_R_HAWK)<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateUCS_HAWK_AAR"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject(U_R_HAWK,nX,nY,2,uUnit.GetDirectionAlpha());P.AddResource(1, -GetUnitPrice(U_R_HAWK));
							}
							if(P.GetRace()==eRaceED) if(GetUnitPrice(E_R_INTERCEPTOR)<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateE_R_INTERCEPTOR"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject(E_R_INTERCEPTOR,nX,nY,2,uUnit.GetDirectionAlpha()); P.AddResource(1, -GetUnitPrice(E_R_INTERCEPTOR));										
							}
							if(P.GetRace()==eRaceLC) if(GetUnitPrice(L_R_SFIGHTER)<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateLC_SFIGHTER_2XAAR"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject(L_R_SFIGHTER,nX,nY,2,uUnit.GetDirectionAlpha()); P.AddResource(1, -GetUnitPrice(L_R_SFIGHTER));									
							}
							if(P.GetRace()==eRaceAlien)
							{
								Console2.Translate("translateMORPHOID_FIGHTER"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("MORPHOID_FIGHTER",nX,nY,2,uUnit.GetDirectionAlpha());					
							}
						}
						uUnit2=m_uUnit1[(nP-1)*20+(i-1)*8+n];
						CreateFxToCreatedUnit(uUnit2,P);
						m_nBuildTimer[(nP-1)*20+i]=0;
					}
					uUnit2=m_uUnit1[(nP-1)*20+(i-1)*8+n];
					if(n==1 || n==4 || n==7) 
					{
						uUnit=m_uCarrier[(nP-1)*20+i];
						if( uUnit.DistanceToClosestGrid(uUnit2)>(3000) && uUnit.IsLive() && !uUnit.IsSelected() && !uUnit2.IsSelected())
						uUnit2.CommandMoveXYZA(nX+Rand(500)-250, nY+Rand(500)-250, Rand(4)+3, uUnit.GetDirectionAlpha());
					}
					else
					if(n<4)
					{
						uUnit=m_uUnit1[(nP-1)*20+(i-1)*8+1];
						if( uUnit.DistanceToClosestGrid(uUnit2)>(300) && uUnit.IsLive() && !uUnit.IsSelected() && !uUnit2.IsSelected())
						uUnit2.CommandMoveXYZA(uUnit.GetLocationX()+Rand(150)-75, uUnit.GetLocationY()+Rand(150)-75,uUnit.GetLocationZ(), uUnit.GetDirectionAlpha());
					}
					else
					if(n<7)
					{
						uUnit=m_uUnit1[(nP-1)*20+(i-1)*8+4];
						if( uUnit.DistanceToClosestGrid(uUnit2)>(300) && uUnit.IsLive() && !uUnit.IsSelected() && !uUnit2.IsSelected())
						uUnit2.CommandMoveXYZA(uUnit.GetLocationX()+Rand(150)-75, uUnit.GetLocationY()+Rand(150)-75,uUnit.GetLocationZ(), uUnit.GetDirectionAlpha());							
					}
					else
					if(n<9)
					{
						uUnit=m_uUnit1[(nP-1)*20+(i-1)*8+7];
						if( uUnit.DistanceToClosestGrid(uUnit2)>(300) && uUnit.IsLive() && !uUnit.IsSelected() && !uUnit2.IsSelected())
						uUnit2.CommandMoveXYZA(uUnit.GetLocationX()+Rand(150)-75, uUnit.GetLocationY()+Rand(150)-75,uUnit.GetLocationZ(), uUnit.GetDirectionAlpha());									
					}
					uUnit=m_uCarrier[(nP-1)*20+i];
					if(uUnit.IsSelected() && !uUnit2.IsSelected() && uUnit.IsLive())
					{
					 uUnit2.SetSelected(true);
					}
					if(uUnit2.IsSelected() && !uUnit.IsSelected() && uUnit.IsLive())
					{
						if (n<4)
						{
							for(m=1;m<4;++m)
							{ 
								uUnit=m_uUnit1[(nP-1)*20+(i-1)*8+m];
								if(!uUnit.IsSelected())
								{
								uUnit.SetSelected(true);
								}
							}
						}
						if (n<7 && n>3) 
						{
							for(m=4;m<7;++m)
							{ 
								uUnit=m_uUnit1[(nP-1)*20+(i-1)*8+m];
								if(!uUnit.IsSelected())
								{
									uUnit.SetSelected(true);
								}
							}
						}	
						if (n>6)
						{
								if (n==7)  uUnit=m_uUnit1[(nP-1)*20+(i-1)*8+8];
								if (n==8) uUnit=m_uUnit1[(nP-1)*20+(i-1)*8+7];
								if(!uUnit.IsSelected())
								{
									uUnit.SetSelected(true);
								}
						}//if (n>6)
					}//if (uUnit2.IsSelected() && !uUnit.IsSelected() && uUnit.IsLive())
				}//for(n=1;n<=8;++n)
				

				
				if (nUnitWithMinMovingPoints<900)
				{
					LowConsole.Format("MovingPoints:%d",m_nMovingPoints[(nP-1)*20+nUnitWithMinMovingPoints]);
					P.SetLowConsoleText(LowConsole,30);
				}
				
		}//for(i=1;i<=m_nC[nP];++i)
	}//for(nP=1;nP<=8;++nP)
}
function void FreeAddUnitsToCarrier() //Funkcja  bazuje na AddUnitsToCarrier(), ale nie uwzględnia opłat oraz czasu i limitu jednostek
{
	player P;
	int nP;
	int nX,nY,nZ;
	int i,n,m;
	unit uUnit, uUnit2;
	int nTr,nExist;
	int CurrUnitIndex;
	string sName;

	for(nP=1;nP<=8;++nP)
	{
		P=GetPlayer(nP);
		for(i=1;i<=m_nC[nP];++i)
		{
				uUnit=m_uCarrier[(nP-1)*20+i];
				nX=uUnit.GetLocationX();
			 	nY=uUnit.GetLocationY();
			 	nZ=uUnit.GetLocationZ();
				uUnit=m_uCarrier[(nP-1)*20+i];
			if(uUnit.IsLive() && !uUnit==null && sName.Compare("LCSF_BATLE") && sName.Compare("EDSF_BATLE") && sName.Compare("UCSSF_BATLE"))		
			for(n=1;n<=8;++n)
			{
					CurrUnitIndex = (nP-1)*20+(i-1)*8+n;
					if(n==3 || n==6)
						{
							if(P.GetRace()==eRaceUCS)
							{
								m_uUnit1[CurrUnitIndex]=P.CreateObject(U_R_BAT,nX,nY,nZ,uUnit.GetDirectionAlpha());
							}
							if(P.GetRace()==eRaceED)
							{
								m_uUnit1[CurrUnitIndex]=P.CreateObject(E_HR_INTERCEPTOR,nX,nY,nZ,uUnit.GetDirectionAlpha());	
							}
							if(P.GetRace()==eRaceLC) 
							{
								m_uUnit1[CurrUnitIndex]=P.CreateObject(L_R_THUNDER,nX,nY,nZ,uUnit.GetDirectionAlpha()); 			
							}
							if(P.GetRace()==eRaceAlien)
							{
								m_uUnit1[CurrUnitIndex]=P.CreateObject("MORPHOID_FIGHTER",nX,nY,nZ,uUnit.GetDirectionAlpha());			
							}							
						}
						else
						if (n<7)
						{
							if(P.GetRace()==eRaceUCS)
							{
								m_uUnit1[CurrUnitIndex]=P.CreateObject(U_R_HAWK,nX,nY,nZ,uUnit.GetDirectionAlpha());
							}
							if(P.GetRace()==eRaceED)
							{
								m_uUnit1[CurrUnitIndex]=P.CreateObject(E_R_INTERCEPTOR,nX,nY,nZ,uUnit.GetDirectionAlpha()); 									
							}
							if(P.GetRace()==eRaceLC)
							{
								m_uUnit1[CurrUnitIndex]=P.CreateObject(L_R_SFIGHTER,nX,nY,nZ,uUnit.GetDirectionAlpha()); 								
							}
							if(P.GetRace()==eRaceAlien)
							{
								m_uUnit1[CurrUnitIndex]=P.CreateObject("MORPHOID_FIGHTER",nX,nY,nZ,uUnit.GetDirectionAlpha());					
							}
						}
						if (n==7 || n==8)
						{
							if(!sName.Compare("EDSF_BS"))
							{
								m_uUnit1[CurrUnitIndex]=P.CreateObject(E_T_BOMBER,nX,nY,nZ,uUnit.GetDirectionAlpha());						
							}
							if(!sName.Compare("LCSF_BS"))
							{
								m_uUnit1[CurrUnitIndex]=P.CreateObject(L_T_THUNDER,nX,nY,nZ,uUnit.GetDirectionAlpha());						
							}
							if(!sName.Compare("UCSSF_BS"))
							{
								m_uUnit1[CurrUnitIndex]=P.CreateObject(U_T_HELLWIND,nX,nY,nZ,uUnit.GetDirectionAlpha());										
							}
						}
					}
		}
	}
}
function void CreateSquadFromGroup10()
{
	int i,n;
	unit uUnit;
	player P;
	int nUnits;
	unit mUnit[];
	mUnit.Create(7);
	for(i=1;i<=8;++i)
	{
		
		P=GetPlayer(i);
		nUnits=0;
		for (n=1;n<=P.GetNumberOfUnits(); ++n)
		{
			uUnit=P.GetUnit(n);
			if (uUnit.GetGroupNum()==9)
			{
				++nUnits;
				mUnit[nUnits]=uUnit;
			}
			if(nUnits>5)
			{
			 break;
			}
		}
		if (nUnits>5)
		{
			AddSquad(mUnit[1], mUnit[2], mUnit[3], mUnit[4], mUnit[5],  mUnit[6]);
			for (n=1; n<=6; ++n)
			{
				uUnit=mUnit[n];
				uUnit.SetGroupNum(8);
			}
		}
	}
}
function void SquadsWork()
{
	AddUnitsToCarrier();
	SetBuildCommands();
	AddUnitsToLeader();
	CreateSquadFromGroup10();
}

function void InitCarriers()
{
	int i,n;
	unit uUnit;
	player P;
	string UnitIDName;
	AddedToSquad.Translate("translateAddedToSquad");
	m_nC.Create(8); m_nL.Create(8); m_nF.Create(8); m_nSquadType.Create(8);
	m_sUnitsToSquad.Create(8*6);
	
	m_AIUnitIndex.Create(8);
	m_uLeader.Create(8*200);
	m_uLeaderContainingObject.Create(8*200);
	m_uCarrier.Create(20*8);
	uFactories.Create(20*8);
	nFactoryTime.Craete(8*20);
	m_nMovingPoints.Create(20*8);
	m_nBuildTimer.Create(20*8);
	m_nInfantryBuildTimer.Create(8*200);
	m_uUnit1.Create(20*8*8);
	m_uSubordinate.Create(200*8*5);
	m_uContainingObject.Create(200*8*5);
	for (i=1;i<=1600;++i)//1600=8*200
	{
		m_nInfantryBuildTimer[i]=-1; //
	}

	for(i=1;i<=8;++i)
	{
		m_nC[i]=0;
		P=GetPlayer(i);
		for (n=1;n<=P.GetNumberOfUnits(); ++n)
		{
			uUnit=P.GetUnit(n);
			UnitIDName=uUnit.GetObjectIDName();
			if(uUnit.IsTransporter() && uUnit.GetMaxHP()>600 && uUnit.IsAirObject())
			{
				AddUnitToCarrierArray(uUnit);
			}
			if(IsLeaderName(UnitIDName)) 
			{
				AddUnitToLeaderArray(uUnit);
			}			
		}
	}

}

function void CheckUCSRafinery(unit Building)
{
	int nX,nY;
	player P;
	string BuildingName;
	unit uUnit;
	P=GetPlayer(Building.GetIFFNum());
	nX=Building.GetLocationX();
	nY=Building.GetLocationY();
	BuildingName=Building.GetObjectIDName();
	if(P.IsAIPlayer())
	{
		if(!BuildingName.Compare("ED_MOLOCH"))
		{
			AddToFactoriesArray(Building);
		}
	}
	 if(!BuildingName.Compare("UCS_RAFINERY_POD"))
	 {
	 	P.CreateObject("UCS_TERMIT",nX,nY,0,0);
		CreateFxToCreatedUnit(uUnit,P);
	 } 
	if(!BuildingName.Compare("UCS_RAFINERY"))
	 {
		 P.CreateObject("UCS_TERMIT",nX+1,nY+1,0,0);
		CreateFxToCreatedUnit(uUnit,P);
	 }
	 
}

function void CheckCarrierUnit(unit uUnit)
{
	int i;
	player P;
	string UnitIDName;
	UnitIDName=uUnit.GetObjectIDName();
	//UCS
	if(uUnit.IsTransporter() && uUnit.GetMaxHP()>600 && uUnit.IsAirObject())
	{
		AddUnitToCarrierArray(uUnit);
	}
	if(IsLeaderName(UnitIDName)) 
	{
		AddUnitToLeaderArray(uUnit);
	}	
	/*if(!UnitIDName.Compare("UCS_TARNSPORTER_I"))
	{
		for(i=1;i<7;++i){uUnit.CreateTransportedCrew(U_I_SILVER_ONE_1);}
	}
	if(!UnitIDName.Compare("UCS_TARNSPORTER_R"))
	{
		for(i=1;i<7;++i){uUnit.CreateTransportedCrew(U_R_SILVER);}
	}
	if(!UnitIDName.Compare("UCS_TARNSPORTER_P"))
	{
		for(i=1;i<7;++i){uUnit.CreateTransportedCrew(U_P_SILVER);}
	}
	//ED
	if(!UnitIDName.Compare("ED_BTVA_I"))
	{
		for(i=1;i<9;++i){uUnit.CreateTransportedCrew(E_TROOPER);}
	}
	if(!UnitIDName.Compare("ED_BTVA_R"))
	{
		for(i=1;i<9;++i){uUnit.CreateTransportedCrew(E_ROCKETER);}
	}
	//LC
	if(!UnitIDName.Compare("LC_FATGIRL_2AAR"))
	{
		for(i=1;i<7;++i){uUnit.CreateTransportedCrew(L_R_GUARDIAN);}
	}
	if(!UnitIDName.Compare("LC_FATGIRL_2E"))
	{
		for(i=1;i<7;++i){uUnit.CreateTransportedCrew(L_E_GUARDIAN);}
	}
	if(!UnitIDName.Compare("LC_FATGIRL_2I"))
	{
		for(i=1;i<7;++i){uUnit.CreateTransportedCrew(L_GURDIAN_1);}
	}
	if(!UnitIDName.Compare("LC_FATGIRL_2S"))
	{
		for(i=1;i<7;++i){uUnit.CreateTransportedCrew(L_M_CYBER_GUARDIAN);}
	}
	*/
	
}
function void AddToFactoriesArray(unit uFactory)
{
	player P;
	int i,nP,n;
	unit uUnit;
	P=GetPlayer(uFactory.GetIFFNum());
	nP=P.GetIFFNum();
	for(n=1;n<=m_nF[nP];++n)
	{
	 uUnit=uFactories[(nP-1)*20+n];
	 if(!uUnit.IsLive())
	 {
	 	uUnit=null;
	 }
	 if(uUnit==null)
	 {
	 	uFactories[(nP-1)*20+n]=uFactory;
		break;
	 }
	 if(n==m_nF[nP])
	 {
	 	++m_nF[nP];
		n=m_nF[nP];
		uFactories[(nP-1)*20+n]=uFactory;
		break;
	 }
	}
	if(m_nF[nP]==0)
	{
		 	++m_nF[nP];
			n=m_nF[nP];
			m_uCarrier[(nP-1)*20+n]=uFactory;	
	}	 
}
function void SetBuildCommands()
{
	player P;
	int nP;
	int nX,nY,nZ;
	int i,n,m,nPrice;
	unit uFactory;
	int nTr,nExist;
	string sName;

	for(nP=1;nP<=8;++nP)
	{
		P=GetPlayer(nP);
		for(i=1;i<=m_nC[nP];++i)
		{
				uFactory=uFactories[(nP-1)*20+i];
				nX=uFactory.GetLocationX();
			 	nY=uFactory.GetLocationY();
			 	nZ=uFactory.GetLocationZ();
			if(uFactory.IsLive() && !uFactory==null)
			{	
				sName=AIGetUnitName(P.GetRace(),m_nSquadType[nP],m_AIUnitIndex[nP]);
				nPrice=PriceIfGoodTimeAndRace(sName,P.GetRace(),nFactoryTime[(nP)*20+i],0);
				if(nPrice)
				{
						m_uContainingObject[(nP-1)*200+(i-1)*5+n]=m_uSubordinate[(nP-1)*200+(i-1)*5+n]=P.CreateObject(sName,nX,nY,40,uFactory.GetDirectionAlpha());
						CreateFxToCreatedUnit(uUnit2,P);
						P.AddResource(1,  -nPrice);
					//create unit with sName on factory location
					//check if sqad is full then call it to move to waiting loaction
				}
				//P.SetCommandBuildBuilding("ED_MOBILE_RAFINERY", nX+3, nY+3,0,uFactory);
			}		
		}
	}
}

function UnitKilledUpdateStatisitcis(unit uKilled, unit uDamageCauser)
{
	pPlayer P;
	int nP;
	int LostUnitType;
	int DamagerUnitType;
	//funkcja do aktualizacji statystyk
	//trzeba wyciągnąć ai_playera i zauktualizować mu statystyki z jakich squadów ponosi straty i jakimi zadaje straty
	//
	P=GetPlayer(uKilled.GetIFFNum());
	nP=P.GetIFFNum();
	LostUnitType =GetSquadType(uKilled.GetName());
	++m_nPlayerLosts[nP*8*eSquadTypesNum+LostUnitType];
	DamagerUnitType = GetSquadType(uDamageCauser.GetName());
	++m_nPlayerEnemyDamageCausers[nP*8*eSquadTypesNum+DamagerUnitType];
}
