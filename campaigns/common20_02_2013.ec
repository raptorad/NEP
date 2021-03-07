
//#define DEBUG

#include "trace.ech"
#include "unitNames.ech"
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
	InfantrySquad=10;
    eSaveBestInfantyBufferNum = 1108;
	eLandAASquad=0;
	eTankSquad=1;
	eArtSquad=2;
	eAirAASquad=3;
	eBomberSquad=4;
}
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
function int IsHarvesterID(string Name);
function int GetUnitPrice(string Name);
function void CreateFxToCreatedUnit(unit uUnit,player P);
function int IsLeaderName(string UnitIDName);
function int PriceIfGoodTimeAndRace(string Name,int nRace,int nTime,int bInfantry);
function int GetUnitProductionTime(string Name);

function string GetSubordinateUnitID(string IDName,int Race);
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

function int IsHarvesterID(string Name)
{
	int nB;
	string UnitIDName;
	UnitIDName=Name;
	

	if(!UnitIDName.Compare("U_CH_AH_10_1") ||
	!UnitIDName.Compare("UCS_TERMIT") ||
	!UnitIDName.Compare("E_CH_AH_12") ||
	!UnitIDName.Compare("E_CH_AH_12_2") ||
	!UnitIDName.Compare("E_CH_AH_12_3") ||
	!UnitIDName.Compare("E_CH_AH_12_4") ||
	!UnitIDName.Compare("ED_MOBILE_RAFINERY") ||
	!UnitIDName.Compare("ED_MOBILE_RAFINERY2") ||
	!UnitIDName.Compare("ED_MOBILE_RAFINERY3")	||
	!UnitIDName.Compare("ED_MOBILE_RAFINERY4"))
	{
		nB=true;
	}
	else
	{
		nB=false;
	}
	return nB;
}
function int GetUnitPrice(string Name)
{
	string UnitIDName; int price;
	price=0;
	UnitIDName=Name;
	if(!UnitIDName.Compare("U_I_SILVER_ONE_1")){ price=50; }else
	if(!UnitIDName.Compare("U_P_SILVER")){ price= 200; }else
	if(!UnitIDName.Compare("U_R_SILVER")){ price= 100; }else
	if(!UnitIDName.Compare("U_X_SILVER")){ price= 200; }else
	if(!UnitIDName.Compare("U_I3_SILVER_MK3")){ price= 200; }else
	if(!UnitIDName.Compare("UCS_SILVER_MK3_RA")){ price= 200; }else
	if(!UnitIDName.Compare("UCS_SILVER_MK3_PLASMA_GUN")){ price= 200; }else
	if(!UnitIDName.Compare("UCS_ATACK_DRONE")){ price= 200; }else
	if(!UnitIDName.Compare("UCS_ATACK_DRONE_PLASMA_GUN")){ price= 200; }else

	if(!UnitIDName.Compare("ED_TROOPER")){ price= 50; }else
	if(!UnitIDName.Compare("ED_ROCKETER")){ price= 100;}else
	if(!UnitIDName.Compare("ED_SNIPER")){ price= 200; }else
	if(!UnitIDName.Compare("ED_JON_TROOPER")){ price= 200; }else
	if(!UnitIDName.Compare("ED_HEAVYTROOPER")){ price= 200; }else
	if(!UnitIDName.Compare("ED_LASER_HEAVYTROOPER")){ price= 200; }else
	if(!UnitIDName.Compare("ED_PPANC_HEAVYTROOPER")){ price =200; }else
	if(!UnitIDName.Compare("ED_DUBNA_MGUN")){ price= 200; }else
	if(!UnitIDName.Compare("ED_ED_DUBNA_RA")){ price=  200; }else
	if(!UnitIDName.Compare("ED_DUBNA_RA")){ price=  200; }else
	if(!UnitIDName.Compare("E_CH_AH_12")){ price=  400; }else
	if(!UnitIDName.Compare("E_CH_AH_12_2")){ price=  400; }else
	if(!UnitIDName.Compare("E_CH_AH_12_3")){ price=  400; }else
	if(!UnitIDName.Compare("E_CH_AH_12_4")){ price=  400; }else
	if(!UnitIDName.Compare("ED_MOBILE_RAFINERY")){ price=  400; }else
	if(!UnitIDName.Compare("ED_MOBILE_RAFINERY2")){ price=  400; }else
	if(!UnitIDName.Compare("ED_MOBILE_RAFINERY3")){ price=  400; }else
	if(!UnitIDName.Compare("ED_MOBILE_RAFINERY4")){ price=  400; }else


	if(!UnitIDName.Compare("LC_GURDIAN_1")){ price=  50; }else
	if(!UnitIDName.Compare("LC_GUARDIAN_RA_1")){ price=  100; }else
	if(!UnitIDName.Compare("LC_SCHOCK_GUARDIAN_1")){ price=  200; }else
	if(!UnitIDName.Compare("LC_CYBER_GUARDIAN")){ price=  200; }else
	if(!UnitIDName.Compare("LC_CYBER_GUARDIAN_MAGNETIC")){ price=  200; }else
	if(!UnitIDName.Compare("LC_CYBER_GUARDIAN_ELECTRIC")){ price=  200; }else

	if(!UnitIDName.Compare(U_R_GARGOIL)){ price=  550; }else
	if(!UnitIDName.Compare(U_P_GARGOIL)){ price=  650; }else
	if(!UnitIDName.Compare(U_R_RAPTOR)){ price=  350; }else
	if(!UnitIDName.Compare(U_P_RAPTOR)){ price=  450; }else
	if(!UnitIDName.Compare(U_P_SPIDER)){ price=  800; }else
	if(!UnitIDName.Compare(U_AP_SPIDER)){ price=  800; }else
	if(!UnitIDName.Compare(U_R_SPIDER)){ price=  500; }else
	if(!UnitIDName.Compare(U_D_SPIDER)){ price=  500; }else
	if(!UnitIDName.Compare(U_R_TIGER)){ price=  650; }else
	if(!UnitIDName.Compare(U_G_TIGER)){ price=  650; }else
	if(!UnitIDName.Compare(U_P_TIGER)){ price=  750; }else
	if(!UnitIDName.Compare(U_R_PANTHER)){ price=  1300; }else
	if(!UnitIDName.Compare(U_G_PANTHER)){ price=  1400; }else
	if(!UnitIDName.Compare(U_P_PANTHER)){ price=  1700; }else
	if(!UnitIDName.Compare(U_R_BAT)){ price=  1100; }else
	if(!UnitIDName.Compare(U_P_BAT_P)){ price=  1300; }else
	if(!UnitIDName.Compare(U_R_HAWK)){ price=  1400; }else
	if(!UnitIDName.Compare(U_P_HAWK)){ price=  1500; }else
	if(!UnitIDName.Compare(U_N_HELLWIND)){ price=  2200; }else
	if(!UnitIDName.Compare(U_P_HELLWIND)){ price=  2900; }else
	if(!UnitIDName.Compare(U_R_JAGUAR)){ price=  1900; }else
	if(!UnitIDName.Compare(U_P_JAGUAR)){ price=  2500; }else
	if(!UnitIDName.Compare(U_R_TARANTULA)){ price=  1800; }else
	if(!UnitIDName.Compare(U_P_TARANTULA)){ price=  2300; }else
	if(!UnitIDName.Compare(U_G_TARANTULA)){ price=  2500; }else
	if(!UnitIDName.Compare(U_SHADOW)){ price=  2000; } else
	if(!UnitIDName.Compare("U_CH_AH_10_1")){ price=  300; }else
	if(!UnitIDName.Compare("UCS_TERMIT")){ price=  300; }else
	
	if(!UnitIDName.Compare("ED_STORM_R")){ price=  400; }else
	if(!UnitIDName.Compare("ED_STORM_I")){ price=  350; }else
	if(!UnitIDName.Compare("ED_BTTI_R")){ price=  200; }else
	if(!UnitIDName.Compare("ED_BTTI_I")){ price=  150; }else
	if(!UnitIDName.Compare("ED_BTTV_AAR")){ price=  450; }else
	if(!UnitIDName.Compare("ED_BTTV_HRA")){ price=  450; }else
	if(!UnitIDName.Compare("ED_BTTV_4XL")){ price=  650; }else
	if(!UnitIDName.Compare("ED_PAMIR_RA")){ price=  800; }else
	if(!UnitIDName.Compare("ED_PAMIR_PC")){ price=  650; }else
	if(!UnitIDName.Compare("ED_PAMIR_J")){ price=  1100; }else
	if(!UnitIDName.Compare("ED_PAMIR_L")){ price=  1000; }else
	if(!UnitIDName.Compare("KAUKAZ_2XPC")){ price=  1050; }else
	if(!UnitIDName.Compare("KAUKAZ_2XL")){ price=  1400; }else
	if(!UnitIDName.Compare("KAUKAZ_J")){ price=  1450; }else
	if(!UnitIDName.Compare("ED_HT30_4XL")){ price=  2400; }else
	if(!UnitIDName.Compare("ED_HT30_2XHRA")){ price=  1700; }else
	if(!UnitIDName.Compare("ED_HT30_2XJ")){ price=  2600; }else
	if(!UnitIDName.Compare("E_R_INTERCEPTOR")){ price=  950; }else
	if(!UnitIDName.Compare("E_HR_INTERCEPTOR")){ price=  1100; }else
	if(!UnitIDName.Compare("E_CB_BOMBER")){ price=  2050; }else
	if(!UnitIDName.Compare("ED_BOMBER_HBOMB")){ price=  3050; }else
	if(!UnitIDName.Compare("ED_BOMBER_TORP")){ price=  1000; }else
	if(!UnitIDName.Compare("ED_MBA_BRA")){ price=  1800; }else
	if(!UnitIDName.Compare("ED_MBA_NBRA")){ price=  2000; }else
	if(!UnitIDName.Compare("ED_PROTECTOR_SDI")){ price=  350; }else
	if(!UnitIDName.Compare("ED_AFCC")){ price=  1000; }
	
	if(!UnitIDName.Compare(L_R_METEOR)){ price=  400; }else
	if(!UnitIDName.Compare(L_E_METEOR)){ price=  500; }else
	if(!UnitIDName.Compare(L_I_MOON)){ price=  250; }else
	if(!UnitIDName.Compare(L_R_MOON)){ price=  300; }else
	if(!UnitIDName.Compare(L_E_MOON)){ price=  400; }else
	if(!UnitIDName.Compare(L_G_FANG)){ price=  500; }else
	if(!UnitIDName.Compare(L_E_FANG)){ price=  700; }else
	if(!UnitIDName.Compare(L_A_FANG)){ price=  800; }else
	if(!UnitIDName.Compare(L_R_THUNDER)){ price=  1400; }else
	if(!UnitIDName.Compare(L_T_THUNDER)){ price=  2200; }else
	if(!UnitIDName.Compare(L_B_THUNDER)){ price=  2000; }else
	if(!UnitIDName.Compare(L_E_THUNDER)){ price=  1800; }else
	if(!UnitIDName.Compare(L_G_CRATER)){ price=  900; }else
	if(!UnitIDName.Compare(L_E_CRATER)){ price=  1200; }else
	if(!UnitIDName.Compare(L_R_CRATER)){ price=  700; }else
	if(!UnitIDName.Compare(L_R_CRUSCHER)){ price=  1600; }else
	if(!UnitIDName.Compare(L_E_CRUSCHER)){ price=  2600; }else
	if(!UnitIDName.Compare(L_S_CRUSCHER)){ price=  2400; }else
	if(!UnitIDName.Compare(L_G_CRUSCHER)){ price=  2000; }else
	if(!UnitIDName.Compare(L_E_SFIGHTER)){ price=  1250; }else
	if(!UnitIDName.Compare(L_R_SFIGHTER)){ price=  1050; }else
	if(!UnitIDName.Compare(L_A_CRION)){ price=  2200; }else
	if(!UnitIDName.Compare(L_P_CRION)){ price=  2200; }	
	if(!UnitIDName.Compare(L_FOBOS)){ price=  1000; }

	return price;

}
function void CreateFxToCreatedUnit(unit uUnit,player P)
{
		P.CreateObject("TELEPORT_OUT", uUnit.GetLocationX(),uUnit.GetLocationY(),uUnit.GetLocationZ(),0);
}
function int IsLeaderName(string UnitIDName)
{
	if(!UnitIDName.Compare("E_L_TROOPER") || !UnitIDName.Compare("E_L_ROCKETER") || !UnitIDName.Compare("E_L_SNIPER") || !UnitIDName.Compare("E_L_J_TROOPER") ||
	!UnitIDName.Compare("E_L_HEAVYTROOPER") || !UnitIDName.Compare("E_L_LL_HEAVYTROOPER") || !UnitIDName.Compare("E_L_PP_HEAVYTROOPER") || 
	!UnitIDName.Compare("E_L_I_DUBNA") || !UnitIDName.Compare("E_L_R_DUBNA") ||
	
	!UnitIDName.Compare("U_A_I_SILVER_ONE_1") || !UnitIDName.Compare("U_A_R_SILVER") || !UnitIDName.Compare("U_A_P_SILVER") ||
	!UnitIDName.Compare("U_A_I3_SILVER_MK3") || !UnitIDName.Compare("U_A_P3_SILVER_MK3") || !UnitIDName.Compare("U_A_R3_SILVER_MK3") ||
	!UnitIDName.Compare("U_A_I_ATACK_DRONE") || !UnitIDName.Compare("U_A_P_ATACK_DRONE")||
	
	!UnitIDName.Compare("LC_LEADER_GURDIAN_1") || !UnitIDName.Compare("LC_LEADER_GUARDIAN_RA_1") || !UnitIDName.Compare("LC_LEADER_SCHOCK_GUARDIAN_1") ||
	!UnitIDName.Compare("LC_LEADER_CYBER_GUARDIAN") || !UnitIDName.Compare("LC_LEADER_CYBER_GUARDIAN_MAGNETIC") || !UnitIDName.Compare("LC_LEADER_CYBER_GUARDIAN_ELECTRIC") || 

	!UnitIDName.Compare("E_CH_AH_12")  || !UnitIDName.Compare("E_CH_AH_12_2") || !UnitIDName.Compare("E_CH_AH_12_3") || !UnitIDName.Compare("E_CH_AH_12_4") ||  
	!UnitIDName.Compare("U_CH_AH_10_1"))
		return 1;

	return 0;
}
function int PriceIfGoodTimeAndRace(string Name,int nRace,int nTime,int bInfantry)
{
	string UnitIDName; int price;
	price=0;
	UnitIDName=Name;
	if(bInfantry)
	{
		if(nRace==eRaceUCS)
		{
			if(nTime>=4)
			{
				if(!UnitIDName.Compare("U_I_SILVER_ONE_1")){ price=50; }else
				if(!UnitIDName.Compare("U_P_SILVER")){ price=200; }else
				if(!UnitIDName.Compare("U_R_SILVER")){ price=100; }else
				if(!UnitIDName.Compare("U_X_SILVER")){ price=200; }else
				if(!UnitIDName.Compare("U_I3_SILVER_MK3")){ price=350; }else
				if(!UnitIDName.Compare("UCS_SILVER_MK3_RA")){ price=400; }else
				if(!UnitIDName.Compare("UCS_SILVER_MK3_PLASMA_GUN")){ price=500; }else
				if(!UnitIDName.Compare("UCS_ATACK_DRONE")){ price=100; }else
				if(!UnitIDName.Compare("UCS_ATACK_DRONE_PLASMA_GUN")){ price=200; }
			}
		}
		else
		if(nRace==eRaceED)
		{
			if(nTime>=4)
			{
				if(!UnitIDName.Compare("ED_TROOPER")){ price=50; }else
				if(!UnitIDName.Compare("ED_ROCKETER")){ price=100;}else
				if(!UnitIDName.Compare("ED_SNIPER")){ price=200; }else
				if(!UnitIDName.Compare("ED_JON_TROOPER")){ price=200; }else
				if(!UnitIDName.Compare("ED_HEAVYTROOPER")){ price=350; }else
				if(!UnitIDName.Compare("ED_LASER_HEAVYTROOPER")){ price=500; }else
				if(!UnitIDName.Compare("ED_PPANC_HEAVYTROOPER")){ price =400; }else
				if(!UnitIDName.Compare("ED_DUBNA_MGUN")){ price= 100; }else
				if(!UnitIDName.Compare("ED_ED_DUBNA_RA")){ price=150; }else
				if(!UnitIDName.Compare("ED_DUBNA_RA")){ price=150; }
			}
		}
		else
		if(nRace==eRaceLC)
		{
			if(nTime>=4)
			{
				if(!UnitIDName.Compare("LC_GURDIAN_1")){ price=50; }else
				if(!UnitIDName.Compare("LC_GUARDIAN_RA_1")){ price=100; }else
				if(!UnitIDName.Compare("LC_SCHOCK_GUARDIAN_1")){ price=200; }else
				if(!UnitIDName.Compare("LC_CYBER_GUARDIAN")){ price=400; }else
				if(!UnitIDName.Compare("LC_CYBER_GUARDIAN_MAGNETIC")){ price=450; }else
				if(!UnitIDName.Compare("LC_CYBER_GUARDIAN_ELECTRIC")){ price=500; }
			}
		}
	}
	else
	{
		if(nRace==eRaceUCS)
		{
			if(nTime>=42)
			{
				if(!UnitIDName.Compare(U_P_HELLWIND)){ price=2900; }
			}
			if(nTime>=36 && !price)
			{
				if(!UnitIDName.Compare(U_N_HELLWIND)){ price=2200; }
			}
			if(nTime>=30 && !price)
			{
				if(!UnitIDName.Compare(U_P_JAGUAR)){ price=2500; }
			}
			if(nTime>=28 && !price)
			{
				if(!UnitIDName.Compare(U_G_TARANTULA)){ price=2500; }
			}
			if(nTime>=24 && !price)
			{
				if(!UnitIDName.Compare(U_R_JAGUAR)){ price=1900; }else
				if(!UnitIDName.Compare(U_P_TARANTULA)){ price=2300; }
			}
			if(nTime>=22 && !price)
			{
				if(!UnitIDName.Compare(U_P_PANTHER)){ price=1700; }else
				if(!UnitIDName.Compare(U_P_HAWK)){ price=1500; }
			}
			if(nTime>=20 && !price)
			{
				if(!UnitIDName.Compare(U_P_BAT)){ price=1300; }else
				if(!UnitIDName.Compare(U_G_PANTHER)){ price=1400; }else
				if(!UnitIDName.Compare(U_R_TARANTULA)){ price=1800; }
			}
			if(nTime>=18 && !price)
			{
				if(!UnitIDName.Compare(U_R_BAT)){ price=1100; }else
				if(!UnitIDName.Compare(U_R_HAWK)){ price=1400; }else
				if(!UnitIDName.Compare(U_P_TIGER)){ price=750; }else
				if(!UnitIDName.Compare(U_R_PANTHER)){ price=1300; }
			}
			if(nTime>=16 && !price)
			{			
				if(!UnitIDName.Compare(U_P_GARGOIL)){ price=650; }
			}
			if(nTime>=14 && !price)
			{
				if(!UnitIDName.Compare(U_R_GARGOIL)){ price=550; }else
				if(!UnitIDName.Compare(U_R_TIGER)){ price=650; }else
				if(!UnitIDName.Compare(U_G_TIGER)){ price=650; }
			}
			if(nTime>=10 && !price)
			{
				if(!UnitIDName.Compare(U_P_RAPTOR)){ price=450; }else
				if(!UnitIDName.Compare(U_P_SPIDER)){ price=800; }else
				if(!UnitIDName.Compare(U_AP_SPIDER)){ price=800; }else
				if(!UnitIDName.Compare("UCS_SPIDER_SDI_C")){ price=500; }else
				if(!UnitIDName.Compare(U_SHADOW)){ price=2000; } 
			}
			if(nTime>=8 && !price)
			{
				if(!UnitIDName.Compare(U_R_RAPTOR)){ price=350; }else
				if(!UnitIDName.Compare(U_R_SPIDER)){ price=500; }else
				if(!UnitIDName.Compare("U_CH_AH_10_1")){ price=300; }else
				if(!UnitIDName.Compare("UCS_TERMIT")){ price=500; }
			}
		}
		else
		if(nRace==eRaceED)
		{
			if(nTime>=52)
			{
				if(!UnitIDName.Compare("ED_BOMBER_TORP")){ price=1000; }
			}
			if(nTime>=36 && !price)
			{
				if(!UnitIDName.Compare("E_CB_BOMBER")){ price=2050; }
			}
			if(nTime>=30 && !price)
			{
				if(!UnitIDName.Compare("ED_HT30_4XL")){ price=2400; }else
				if(!UnitIDName.Compare("ED_HT30_2XJ")){ price=2600; }
			}
			if(nTime>=26 && !price)
			{
				if(!UnitIDName.Compare("KAUKAZ_J")){ price=1450; }
			}
			if(nTime>=24 && !price)
			{
				if(!UnitIDName.Compare("ED_PAMIR_J")){ price=1100; }else
				if(!UnitIDName.Compare("ED_MBA_NBRA")){ price=2000; }
			}
			if(nTime>=22 && !price)
			{
				if(!UnitIDName.Compare("KAUKAZ_2XL")){ price=  11; }
			}
			if(nTime>=20 && !price)
			{
				if(!UnitIDName.Compare("ED_PAMIR_L")){ price=1000; }else
				if(!UnitIDName.Compare("E_R_INTERCEPTOR")){ price=950; }else
				if(!UnitIDName.Compare("E_HR_INTERCEPTOR")){ price=1100; }else
				if(!UnitIDName.Compare("ED_MBA_BRA")){ price=1800; }
			}
			if(nTime>=18 && !price)
			{
				if(!UnitIDName.Compare("KAUKAZ_2XPC")){ price=1050; }else
				if(!UnitIDName.Compare("ED_HT30_2XHRA")){ price=1700; }
			}
			if(nTime>=16 && !price)
			{
				if(!UnitIDName.Compare("ED_BOMBER_HBOMB")){ price=3050; }//???Bad production time
			}
			if(nTime>=14 && !price)
			{
				if(!UnitIDName.Compare("ED_PAMIR_RA")){ price=800; }else
				if(!UnitIDName.Compare("ED_PAMIR_PC")){ price=650; }else
				if(!UnitIDName.Compare("ED_STORM_R")){ price=400; }
			}
			if(nTime>=12 && !price)
			{
				if(!UnitIDName.Compare("ED_STORM_I")){ price=350; }
			}else
			if(nTime>=10 && !price)
			{
				if(!UnitIDName.Compare("ED_BTTV_AAR")){ price=450; }else
				if(!UnitIDName.Compare("ED_BTTV_HRA")){ price=450; }else
				if(!UnitIDName.Compare("ED_BTTV_4XL")){ price=650; }else
				if(!UnitIDName.Compare("ED_PROTECTOR_SDI")){ price=350; }else
				if(!UnitIDName.Compare("ED_AFCC")){ price=1000; }
			}
			if(nTime>=8 && !price)
			{
				if(!UnitIDName.Compare("E_CH_AH_12")){ price=400; }else
				if(!UnitIDName.Compare("E_CH_AH_12_2")){ price=400; }else
				if(!UnitIDName.Compare("E_CH_AH_12_3")){ price=400; }else
				if(!UnitIDName.Compare("E_CH_AH_12_4")){ price=400; }else
				if(!UnitIDName.Compare("ED_MOBILE_RAFINERY")){ price=400; }else
				if(!UnitIDName.Compare("ED_MOBILE_RAFINERY2")){ price=400; }else
				if(!UnitIDName.Compare("ED_MOBILE_RAFINERY3")){ price=400; }else
				if(!UnitIDName.Compare("ED_MOBILE_RAFINERY4")){ price=400; }	
			}
			if(nTime>=6 && !price)
			{
				if(!UnitIDName.Compare("ED_BTTI_R")){ price=200; }else
				if(!UnitIDName.Compare("ED_BTTI_I")){ price=150; }
			}
		}
		else
		if(nRace==eRaceLC)
		{
			if(nTime>=52)
			{
				if(!UnitIDName.Compare("LC_CRION_ART.")){ price=2200; }else
				if(!UnitIDName.Compare("LC_CRION_HPLASMA")){ price=2200; }
			}
			if(nTime>=36 && !price)
			{
				if(!UnitIDName.Compare("LC_CRUSCHER_2XE")){ price=2600; }
			}
			if(nTime>=32 && !price)
			{
				if(!UnitIDName.Compare("LC_THUNDER_TORP")){ price=2200; }else
				if(!UnitIDName.Compare("LC_THUNDER_BOMB")){ price=2000; }
			}
			if(nTime>=28 && !price)
			{
				if(!UnitIDName.Compare("LC_THUNDER_E")){ price=1800; }else
				if(!UnitIDName.Compare("LC_CRUSCHER_2XS")){ price=2400; }else
				if(!UnitIDName.Compare("LC_CRUSCHER_2XMG_2XR")){ price=2000; }
			}
			if(nTime>=24 && !price)
			{
				if(!UnitIDName.Compare("LC_THUNDER_HRA")){ price=1400; }else
				if(!UnitIDName.Compare("LC_SFIGHTER_2XE")){ price=1250; }else
				if(!UnitIDName.Compare("LC_SFIGHTER_2XAAR")){ price=1050; }
				//if(!UnitIDName.Compare("LC_SFIGHTER_2XR")){ price=1050; }
			}
			if(nTime>=20 && !price)
			{
				if(!UnitIDName.Compare("LC_CRATER_E")){ price=1200; }else
				if(!UnitIDName.Compare(L_R_CRUSCHER)){ price=1600; }
			}
			if(nTime>=16 && !price)
			{
				if(!UnitIDName.Compare("LC_CRATER_MG")){ price=900; }
			}
			if(nTime>=14 && !price)
			{
				//if(!UnitIDName.Compare("LC_METEOR_R")){ price=400; }else
				if(!UnitIDName.Compare("LC_METEOR_AAR")){ price=400; }else
				if(!UnitIDName.Compare("LC_METEOR_E")){ price=500; }
			}
			if(nTime>=12 && !price)
			{
				if(!UnitIDName.Compare("LC_FANG_E")){ price=700; }else
				if(!UnitIDName.Compare(L_R_CRATER)){ price=700; }else
				if(!UnitIDName.Compare("LC_FOBOS")){ price=1000; }
			}
			if(nTime>=8 && !price)
			{
				if(!UnitIDName.Compare("LC_MOON_I")){ price=250; }else
				//if(!UnitIDName.Compare(L_R_MOON)){ price=  4; }else
				if(!UnitIDName.Compare("LC_MOON_AAR")){ price=300; }else
				if(!UnitIDName.Compare("LC_MOON_E")){ price=400; }else
				if(!UnitIDName.Compare("LC_FANG_MG")){ price=500; }else
				if(!UnitIDName.Compare("LC_FANG_ART.")){ price=800; }
			}
		}
	}
	return price;

}
function int GetUnitProductionTime(string Name)
{
	string UnitIDName; int time;
	time=0;
	UnitIDName=Name;
	if(!UnitIDName.Compare("U_I_SILVER_ONE_1")){ time=2; }else
	if(!UnitIDName.Compare("U_P_SILVER")){ time= 2; }else
	if(!UnitIDName.Compare("U_R_SILVER")){ time= 2; }else
	if(!UnitIDName.Compare("U_X_SILVER")){ time= 2; }else
	if(!UnitIDName.Compare("U_I3_SILVER_MK3")){ time= 2; }else
	if(!UnitIDName.Compare("UCS_SILVER_MK3_RA")){ time= 2; }else
	if(!UnitIDName.Compare("UCS_SILVER_MK3_PLASMA_GUN")){ time= 2; }else
	if(!UnitIDName.Compare("UCS_ATACK_DRONE")){ time= 2; }else
	if(!UnitIDName.Compare("UCS_ATACK_DRONE_PLASMA_GUN")){ time= 2; }else

	if(!UnitIDName.Compare("ED_TROOPER")){ time= 2; }else
	if(!UnitIDName.Compare("ED_ROCKETER")){ time= 2;}else
	if(!UnitIDName.Compare("ED_SNIPER")){ time= 2; }else
	if(!UnitIDName.Compare("ED_JON_TROOPER")){ time= 2; }else
	if(!UnitIDName.Compare("ED_HEAVYTROOPER")){ time= 2; }else
	if(!UnitIDName.Compare("ED_LASER_HEAVYTROOPER")){ time= 2; }else
	if(!UnitIDName.Compare("ED_PPANC_HEAVYTROOPER")){ time =2; }else
	if(!UnitIDName.Compare("ED_DUBNA_MGUN")){ time= 2; }else
	if(!UnitIDName.Compare("ED_ED_DUBNA_RA")){ time=  2; }else
	if(!UnitIDName.Compare("ED_DUBNA_RA")){ time=  2; }else

	if(!UnitIDName.Compare("LC_GURDIAN_1")){ time=  2; }else
	if(!UnitIDName.Compare("LC_GUARDIAN_RA_1")){ time=  2; }else
	if(!UnitIDName.Compare("LC_SCHOCK_GUARDIAN_1")){ time=  2; }else
	if(!UnitIDName.Compare("LC_CYBER_GUARDIAN")){ time=  2; }else
	if(!UnitIDName.Compare("LC_CYBER_GUARDIAN_MAGNETIC")){ time=  2; }else
	if(!UnitIDName.Compare("LC_CYBER_GUARDIAN_ELECTRIC")){ time=  2; }else

	if(!UnitIDName.Compare(U_R_GARGOIL)){ time=  7; }else
	if(!UnitIDName.Compare(U_P_GARGOIL)){ time=  8; }else
	if(!UnitIDName.Compare(U_R_RAPTOR)){ time=  4; }else
	if(!UnitIDName.Compare(U_P_RAPTOR)){ time=  5; }else
	if(!UnitIDName.Compare(U_P_SPIDER)){ time=  5; }else
	if(!UnitIDName.Compare(U_AP_SPIDER)){ time=  5; }else
	if(!UnitIDName.Compare(U_R_SPIDER)){ time=  4; }else
	if(!UnitIDName.Compare("UCS_SPIDER_SDI_C")){ time=  5; }else
	if(!UnitIDName.Compare(U_R_TIGER)){ time=  7; }else
	if(!UnitIDName.Compare(U_G_TIGER)){ time=  7; }else
	if(!UnitIDName.Compare(U_P_TIGER)){ time=  9; }else
	if(!UnitIDName.Compare(U_R_PANTHER)){ time=  9; }else
	if(!UnitIDName.Compare(U_G_PANTHER)){ time=  10; }else
	if(!UnitIDName.Compare(U_P_PANTHER)){ time=  11; }else
	if(!UnitIDName.Compare(U_R_BAT)){ time=  9; }else
	if(!UnitIDName.Compare(U_P_BAT)){ time=  10; }else
	if(!UnitIDName.Compare(U_R_HAWK)){ time=  9; }else
	if(!UnitIDName.Compare(U_P_HAWK)){ time=  11; }else
	if(!UnitIDName.Compare(U_N_HELLWIND)){ time=  18; }else
	if(!UnitIDName.Compare(U_P_HELLWIND)){ time=  21; }else
	if(!UnitIDName.Compare(U_R_JAGUAR)){ time=  12; }else
	if(!UnitIDName.Compare(U_P_JAGUAR)){ time=  15; }else
	if(!UnitIDName.Compare(U_R_TARANTULA)){ time=  10; }else
	if(!UnitIDName.Compare(U_P_TARANTULA)){ time=  12; }else
	if(!UnitIDName.Compare(U_G_TARANTULA)){ time=  14; }else
	if(!UnitIDName.Compare(U_SHADOW)){ time=  5; } else
	if(!UnitIDName.Compare("U_CH_AH_10_1")){ time=  4; }else
	if(!UnitIDName.Compare("UCS_TERMIT")){ time=  4; }else
	
	if(!UnitIDName.Compare("ED_STORM_R")){ time=  7; }else
	if(!UnitIDName.Compare("ED_STORM_I")){ time=  6; }else
	if(!UnitIDName.Compare("ED_BTTI_R")){ time=  3; }else
	if(!UnitIDName.Compare("ED_BTTI_I")){ time=  3; }else
	if(!UnitIDName.Compare("ED_BTTV_AAR")){ time=  5; }else
	if(!UnitIDName.Compare("ED_BTTV_HRA")){ time=  5; }else
	if(!UnitIDName.Compare("ED_BTTV_4XL")){ time=  5; }else
	if(!UnitIDName.Compare("ED_PAMIR_RA")){ time=  7; }else
	if(!UnitIDName.Compare("ED_PAMIR_PC")){ time=  7; }else
	if(!UnitIDName.Compare("ED_PAMIR_J")){ time=  12; }else
	if(!UnitIDName.Compare("ED_PAMIR_L")){ time=  10; }else
	if(!UnitIDName.Compare("KAUKAZ_2XPC")){ time=  9; }else
	if(!UnitIDName.Compare("KAUKAZ_2XL")){ time=  11; }else
	if(!UnitIDName.Compare("KAUKAZ_J")){ time=  13; }else
	if(!UnitIDName.Compare("ED_HT30_4XL")){ time=  15; }else
	if(!UnitIDName.Compare("ED_HT30_2XHRA")){ time=  9; }else
	if(!UnitIDName.Compare("ED_HT30_2XJ")){ time=  15; }else
	if(!UnitIDName.Compare("E_R_INTERCEPTOR")){ time=  10; }else
	if(!UnitIDName.Compare("E_HR_INTERCEPTOR")){ time=  10; }else
	if(!UnitIDName.Compare("E_CB_BOMBER")){ time=  18; }else
	if(!UnitIDName.Compare("ED_BOMBER_HBOMB")){ time=  8; }else
	if(!UnitIDName.Compare("ED_BOMBER_TORP")){ time=  26; }else
	if(!UnitIDName.Compare("ED_MBA_BRA")){ time=  10; }else
	if(!UnitIDName.Compare("ED_MBA_NBRA")){ time=  12; }else
	if(!UnitIDName.Compare("ED_PROTECTOR_SDI")){ time=  5; }else
	if(!UnitIDName.Compare("ED_AFCC")){ time=  5; }else
	if(!UnitIDName.Compare("E_CH_AH_12")){ time=  4; }else
	if(!UnitIDName.Compare("E_CH_AH_12_2")){ time=  4; }else
	if(!UnitIDName.Compare("E_CH_AH_12_3")){ time=  4; }else
	if(!UnitIDName.Compare("E_CH_AH_12_4")){ time=  4; }else
	if(!UnitIDName.Compare("ED_MOBILE_RAFINERY")){ time=  4; }else
	if(!UnitIDName.Compare("ED_MOBILE_RAFINERY2")){ time=  4; }else
	if(!UnitIDName.Compare("ED_MOBILE_RAFINERY3")){ time=  4; }else
	if(!UnitIDName.Compare("ED_MOBILE_RAFINERY4")){ time=  4; }else	
	
	if(!UnitIDName.Compare("LC_METEOR_R")){ time=  7; }else
	if(!UnitIDName.Compare("LC_METEOR_AAR")){ time=  7; }else
	if(!UnitIDName.Compare("LC_METEOR_E")){ time=  7; }else
	if(!UnitIDName.Compare("LC_MOON_I")){ time=  4; }else
	if(!UnitIDName.Compare(L_R_MOON)){ time=  4; }else
	if(!UnitIDName.Compare("LC_MOON_AAR")){ time=  4; }else
	if(!UnitIDName.Compare("LC_MOON_E")){ time=  4; }else
	if(!UnitIDName.Compare("LC_FANG_MG")){ time=  4; }else
	if(!UnitIDName.Compare("LC_FANG_E")){ time=  6; }else
	if(!UnitIDName.Compare("LC_FANG_ART.")){ time=  4; }else
	if(!UnitIDName.Compare("LC_THUNDER_HRA")){ time=  12; }else
	if(!UnitIDName.Compare("LC_THUNDER_TORP")){ time=  16; }else
	if(!UnitIDName.Compare("LC_THUNDER_BOMB")){ time=  16; }else
	if(!UnitIDName.Compare("LC_THUNDER_E")){ time=  14; }else
	if(!UnitIDName.Compare("LC_CRATER_MG")){ time=  8; }else
	if(!UnitIDName.Compare("LC_CRATER_E")){ time=  10; }else
	if(!UnitIDName.Compare(L_R_CRATER)){ time=  6; }else
	if(!UnitIDName.Compare(L_R_CRUSCHER)){ time=  10; }else
	if(!UnitIDName.Compare("LC_CRUSCHER_2XE")){ time=  18; }else
	if(!UnitIDName.Compare("LC_CRUSCHER_2XS")){ time=  14; }else
	if(!UnitIDName.Compare("LC_CRUSCHER_2XMG_2XR")){ time=  14; }else
	if(!UnitIDName.Compare("LC_SFIGHTER_2XE")){ time=  12; }else
	if(!UnitIDName.Compare("LC_SFIGHTER_2XAAR")){ time=  12; }else
	if(!UnitIDName.Compare("LC_SFIGHTER_2XR")){ time=  12; }else
	if(!UnitIDName.Compare("LC_CRION_ART.")){ time=  26; }else
	if(!UnitIDName.Compare("LC_CRION_HPLASMA")){ time=  26; }	
	if(!UnitIDName.Compare("LC_FOBOS")){ time=  6; }
	time=2*time;
	return time;

}
function string GetSubordinateUnitID(string IDName,int Race)
{
	string Name;
	int r;
 	Name=IDName;
	if(Race==eRaceUCS)
	{
	 	if(!Name.Compare("U_CH_AH_10_1")){ return "UCS_TERMIT"; }else	
 		if(!Name.Compare("UCS_LEADER_SILVER_ONE_1")){ return "U_I_SILVER_ONE_1"; }else
		if(!Name.Compare("UCS_LEADER_SILVER_PLASMA_1")){ return "U_P_SILVER"; }else
		if(!Name.Compare("UCS_LEADER_SILVER_RA_1")){ return "U_R_SILVER"; }else
		if(!Name.Compare("UCS_LEADER_SILVER_MK3")){ return "U_I3_SILVER_MK3"; }else
		if(!Name.Compare("UCS_LEADER_SILVER_MK3_RA")){ return "UCS_SILVER_MK3_RA"; }else 
		if(!Name.Compare("UCS_LEADER_SILVER_MK3_PLASMA_GUN")){ return "UCS_SILVER_MK3_PLASMA_GUN"; }else
		if(!Name.Compare("UCS_LEADER_ATACK_DRONE")){ return "UCS_ATACK_DRONE"; }else
		if(!Name.Compare("UCS_LEADER_ATACK_DRONE_PLASMA_GUN")){ return "UCS_ATACK_DRONE_PLASMA_GUN"; }
	}
	else
	if(Race==eRaceED)
	{
	 	if(!Name.Compare("E_CH_AH_12")){ return "ED_MOBILE_RAFINERY"; }else	
		 if(!Name.Compare("E_CH_AH_12_2")){ return "ED_MOBILE_RAFINERY2"; }else
 		if(!Name.Compare("E_CH_AH_12_3")){ return "ED_MOBILE_RAFINERY3"; }else	
 		if(!Name.Compare("E_CH_AH_12_4")){ return "ED_MOBILE_RAFINERY4"; }else		
		 if(!Name.Compare("ED_LEADER_TROOPER")){ return "ED_TROOPER"; }else
		 if(!Name.Compare("ED_LEADER_ROCKETER")){ return "ED_ROCKETER"; }else
		 if(!Name.Compare("ED_LEADER_SNIPER")){ return "ED_SNIPER"; }else
		 if(!Name.Compare("ED_LEADER_JON_TROOPER")){ return "ED_JON_TROOPER"; }else
		 if(!Name.Compare("ED_LEADER_HEAVYTROOPER")){ return "ED_HEAVYTROOPER"; }else
		 if(!Name.Compare("ED_LEADER_LASER_HEAVYTROOPER")){ return "ED_LASER_HEAVYTROOPER"; }else 
		 if(!Name.Compare("ED_LEADER_PPANC_HEAVYTROOPER")){ return "ED_PPANC_HEAVYTROOPER"; }else
		 if(!Name.Compare("ED_LEADER_DUBNA_MGUN")){ return "ED_DUBNA_MGUN"; }else
		 if(!Name.Compare("ED_LEADER_ED_DUBNA_RA")){ return "ED_ED_DUBNA_RA"; }
 	}
	else
	if(Race==eRaceLC)
	{
	 	if(!Name.Compare("LC_LEADER_GURDIAN_1")){ return "LC_GURDIAN_1"; }else
 		if(!Name.Compare("LC_LEADER_GUARDIAN_RA_1")){ return"LC_GUARDIAN_RA_1"; }else
 		if(!Name.Compare("LC_LEADER_SCHOCK_GUARDIAN_1")){ return "LC_SCHOCK_GUARDIAN_1"; }else
		if(!Name.Compare("LC_LEADER_CYBER_GUARDIAN")){ return"LC_CYBER_GUARDIAN"; }else
		if(!Name.Compare("LC_LEADER_CYBER_GUARDIAN_MAGNETIC")){ return"LC_CYBER_GUARDIAN_MAGNETIC"; }else
 		if(!Name.Compare("LC_LEADER_CYBER_GUARDIAN_ELECTRIC")){ return "LC_CYBER_GUARDIAN_ELECTRIC"; }
	}
		
	return IDName;
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
				if(uUnit.IsLive() && !uUnit==null){			
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
				}}	
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
						if(uUnit2.IsLive() && !uUnit2==null){
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
						}}

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
							if(!sName.Compare("EDSF_BS")) if(GetUnitPrice("ED_BOMBER_TORP")<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateED_BOMBER_TORP"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("ED_BOMBER_TORP",nX,nY,2,uUnit.GetDirectionAlpha());P.AddResource(1, -GetUnitPrice("ED_BOMBER_TORP"));							
							}
							if(!sName.Compare("LCSF_BS")) if(GetUnitPrice("LC_THUNDER_TORP")<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateLC_THUNDER_TORP"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("LC_THUNDER_TORP",nX,nY,2,uUnit.GetDirectionAlpha());P.AddResource(1, -GetUnitPrice("LC_THUNDER_TORP"));							
							}
							if(!sName.Compare("UCSSF_BS")) if(GetUnitPrice("UCS_HELLWIND_TORP")<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateUCS_HELLWIND_TORP"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("UCS_HELLWIND_TORP",nX,nY,2,uUnit.GetDirectionAlpha());P.AddResource(1, -GetUnitPrice("UCS_HELLWIND_TORP"));														
							}
						}
						if(n==3 || n==6)
						{
							if(P.GetRace()==eRaceUCS) if(GetUnitPrice(U_R_BAT)<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateUCS_BAT_R"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject(U_R_BAT,nX,nY,2,uUnit.GetDirectionAlpha()); P.AddResource(1, -GetUnitPrice(U_R_BAT));
							}
							if(P.GetRace()==eRaceED) if(GetUnitPrice("E_HR_INTERCEPTOR")<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateE_HR_INTERCEPTOR"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("E_HR_INTERCEPTOR",nX,nY,2,uUnit.GetDirectionAlpha()); P.AddResource(1, -GetUnitPrice("E_HR_INTERCEPTOR"));					
							}
							if(P.GetRace()==eRaceLC) if(GetUnitPrice("LC_THUNDER_HRA")<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateLC_THUNDER_HRA"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("LC_THUNDER_HRA",nX,nY,2,uUnit.GetDirectionAlpha()); P.AddResource(1, -GetUnitPrice("LC_THUNDER_HRA"));				
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
							if(P.GetRace()==eRaceED) if(GetUnitPrice("E_R_INTERCEPTOR")<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateE_R_INTERCEPTOR"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("E_R_INTERCEPTOR",nX,nY,2,uUnit.GetDirectionAlpha()); P.AddResource(1, -GetUnitPrice("E_R_INTERCEPTOR"));										
							}
							if(P.GetRace()==eRaceLC) if(GetUnitPrice("LC_SFIGHTER_2XAAR")<P.GetResource(1, 1, 1) && P.GetCurrUnitLimitSize()<P.GetPlayerMaxUnitLimitSize())
							{
								Console2.Translate("translateLC_SFIGHTER_2XAAR"); Console2.Append(AddedToCarrier); P.SetConsole2Text(Console2,90);
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("LC_SFIGHTER_2XAAR",nX,nY,2,uUnit.GetDirectionAlpha()); P.AddResource(1, -GetUnitPrice("LC_SFIGHTER_2XAAR"));									
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
					if(n==3 || n==6)
						{
							if(P.GetRace()==eRaceUCS)
							{
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject(U_R_BAT,nX,nY,nZ,uUnit.GetDirectionAlpha());
							}
							if(P.GetRace()==eRaceED)
							{
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("E_HR_INTERCEPTOR",nX,nY,nZ,uUnit.GetDirectionAlpha());	
							}
							if(P.GetRace()==eRaceLC) 
							{
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("LC_THUNDER_HRA",nX,nY,nZ,uUnit.GetDirectionAlpha()); 			
							}
							if(P.GetRace()==eRaceAlien)
							{
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("MORPHOID_FIGHTER",nX,nY,nZ,uUnit.GetDirectionAlpha());			
							}							
						}
						else
						if (n<7)
						{
							if(P.GetRace()==eRaceUCS)
							{
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject(U_R_HAWK,nX,nY,nZ,uUnit.GetDirectionAlpha());
							}
							if(P.GetRace()==eRaceED)
							{
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("E_R_INTERCEPTOR",nX,nY,nZ,uUnit.GetDirectionAlpha()); 									
							}
							if(P.GetRace()==eRaceLC)
							{
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("LC_SFIGHTER_2XAAR",nX,nY,nZ,uUnit.GetDirectionAlpha()); 								
							}
							if(P.GetRace()==eRaceAlien)
							{
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("MORPHOID_FIGHTER",nX,nY,nZ,uUnit.GetDirectionAlpha());					
							}
						}
						if (n==7 || n==8)
						{
							if(!sName.Compare("EDSF_BS"))
							{
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("ED_BOMBER_TORP",nX,nY,nZ,uUnit.GetDirectionAlpha());						
							}
							if(!sName.Compare("LCSF_BS"))
							{
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("LC_THUNDER_TORP",nX,nY,nZ,uUnit.GetDirectionAlpha());						
							}
							if(!sName.Compare("UCSSF_BS"))
							{
								m_uUnit1[(nP-1)*20+(i-1)*8+n]=P.CreateObject("UCS_HELLWIND_TORP",nX,nY,nZ,uUnit.GetDirectionAlpha());										
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
		for(i=1;i<7;++i){uUnit.CreateTransportedCrew("U_I_SILVER_ONE_1");}
	}
	if(!UnitIDName.Compare("UCS_TARNSPORTER_R"))
	{
		for(i=1;i<7;++i){uUnit.CreateTransportedCrew("U_R_SILVER");}
	}
	if(!UnitIDName.Compare("UCS_TARNSPORTER_P"))
	{
		for(i=1;i<7;++i){uUnit.CreateTransportedCrew("U_P_SILVER");}
	}
	//ED
	if(!UnitIDName.Compare("ED_BTVA_I"))
	{
		for(i=1;i<9;++i){uUnit.CreateTransportedCrew("E_TROOPER");}
	}
	if(!UnitIDName.Compare("ED_BTVA_R"))
	{
		for(i=1;i<9;++i){uUnit.CreateTransportedCrew("E_ROCKETER");}
	}
	//LC
	if(!UnitIDName.Compare("LC_FATGIRL_2AAR"))
	{
		for(i=1;i<7;++i){uUnit.CreateTransportedCrew("L_R_GUARDIAN");}
	}
	if(!UnitIDName.Compare("LC_FATGIRL_2E"))
	{
		for(i=1;i<7;++i){uUnit.CreateTransportedCrew("L_E_GUARDIAN");}
	}
	if(!UnitIDName.Compare("LC_FATGIRL_2I"))
	{
		for(i=1;i<7;++i){uUnit.CreateTransportedCrew("L_GURDIAN_1");}
	}
	if(!UnitIDName.Compare("LC_FATGIRL_2S"))
	{
		for(i=1;i<7;++i){uUnit.CreateTransportedCrew("L_M_CYBER_GUARDIAN");}
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
				}
				//P.SetCommandBuildBuilding("ED_MOBILE_RAFINERY", nX+3, nY+3,0,uFactory);
			}		
		}
	}
}
function string AIGetUnitName(int Race,int SquadType,int n)
{

	if(Race==eRaceED)
	{
		if(SquadType==eLandAASquad)
		{
			if(n==0) return "E_R_BTTI";
			if(n==1) return "E_R_BTTI";
			if(n==2) return "E_AAR_BTTV";
			if(n==3) return "E_AAR_BTTV";
			if(n==4) return "E_AAR_BTTV";
			if(n==5) return "E_AAR_BTTV";
		}
		if(SquadType==eTankSquad)
		{
			if(n==0) return "E_I_BTTI_I";
			if(n==1) return "E_I_BTTI_I";
			if(n==2) return "E_C_PAMIR";
			if(n==3) return "E_C_PAMIR";
			if(n==4) return "E_C_KAUKAZ";
			if(n==5) return "E_C_KAUKAZ";		
		}
		if(SquadType==eArtSquad)
		{
			if(n==0) return "E_R_PAMIR";
			if(n==1) return "E_R_PAMIR";
			if(n==2) return "E_R_PAMIR";
			if(n==3) return "E_R_PAMIR";
			if(n==4) return "ED_MBA_BRA";
			if(n==5) return "ED_MBA_NBRA";		
		}
		if(SquadType==eAirAASquad)
		{
			if(n==0) return "E_R_INTERCEPTOR";
			if(n==1) return "E_R_INTERCEPTOR";
			if(n==2) return "E_R_INTERCEPTOR";
			if(n==3) return "E_R_INTERCEPTOR";
			if(n==4) return "E_R_INTERCEPTOR";
			if(n==5) return "E_R_INTERCEPTOR";		
		}
		if(SquadType==eBomberSquad)
		{
			if(n==0) return "E_HR_INTERCEPTOR";
			if(n==1) return "E_HR_INTERCEPTOR";
			if(n==2) return "E_HR_INTERCEPTOR";
			if(n==3) return "E_CB_BOMBER";
			if(n==4) return "ED_BOMBER_HBOMB";
			if(n==5) return "ED_BOMBER_TORP";		
		}
	}
	if(Race==eRaceUCS)
	{
		if(SquadType==eLandAASquad)
		{
			if(n==0) return U_R_SPIDER;
			if(n==1) return U_R_SPIDER;
			if(n==2) return U_R_SPIDER;
			if(n==3) return U_R_TIGER;
			if(n==4) return U_R_TIGER;
			if(n==5) return U_R_JAGUAR;
		}
		if(SquadType==eTankSquad)
		{
			if(n==0) return U_P_RAPTOR;
			if(n==1) return U_P_RAPTOR;
			if(n==2) return U_P_TIGER;
			if(n==3) return U_P_TIGER;
			if(n==4) return U_P_PANTHER;
			if(n==5) return U_P_PANTHER;		
		}
		if(SquadType==eArtSquad)
		{
			if(n==0) return U_G_TIGER;
			if(n==1) return U_G_TIGER;
			if(n==2) return U_G_PANTHER;
			if(n==3) return U_G_PANTHER;
			if(n==4) return U_G_TARANTULA;
			if(n==5) return U_G_TARANTULA;		
		}
		if(SquadType==eAirAASquad)
		{
			if(n==0) return U_R_HAWK;
			if(n==1) return U_R_HAWK;
			if(n==2) return U_R_HAWK;
			if(n==3) return U_R_HAWK;
			if(n==4) return U_R_HAWK;
			if(n==5) return U_R_HAWK;		
		}
		if(SquadType==eBomberSquad)
		{
			if(n==0) return U_P_BAT;
			if(n==1) return U_P_BAT;
			if(n==2) return U_P_BAT;
			if(n==3) return U_P_HELLWIND;
			if(n==4) return U_P_HELLWIND;
			if(n==5) return U_P_HELLWIND;		
		}
	}
	if(Race==eRaceLC)
	{
		if(SquadType==eLandAASquad)
		{
			if(n==0) return L_R_MOON;
			if(n==1) return L_R_MOON;
			if(n==2) return L_R_MOON;
			if(n==3) return L_R_CRATER;
			if(n==4) return L_R_CRATER;
			if(n==5) return L_R_CRUSCHER;
		}
		if(SquadType==eTankSquad)
		{
			if(n==0) return "LC_MOON_I";
			if(n==1) return "LC_MOON_I";
			if(n==2) return "LC_FANG_MG";
			if(n==3) return "LC_FANG_MG";
			if(n==4) return "LC_CRATER_MG";
			if(n==5) return "LC_CRUSCHER_2XMG_2XR";		
		}
		if(SquadType==eArtSquad)
		{
			if(n==0) return "LC_FANG_ART.";
			if(n==1) return "LC_FANG_ART.";
			if(n==2) return "LC_FANG_ART.";
			if(n==3) return "LC_CRION_ART.";
			if(n==4) return "LC_CRION_ART.";
			if(n==5) return "LC_CRION_ART.";		
		}
		if(SquadType==eAirAASquad)
		{
			if(n==0) return "LC_SFIGHTER_2XAAR";
			if(n==1) return "LC_SFIGHTER_2XAAR";
			if(n==2) return "LC_SFIGHTER_2XAAR";
			if(n==3) return "LC_SFIGHTER_2XAAR";
			if(n==4) return "LC_SFIGHTER_2XAAR";
			if(n==5) return "LC_SFIGHTER_2XAAR";		
		}
		if(SquadType==eBomberSquad)
		{
			if(n==0) return "LC_THUNDER_HRA";
			if(n==1) return "LC_THUNDER_HRA";
			if(n==2) return "LC_THUNDER_BOMB";
			if(n==3) return "LC_THUNDER_BOMB";
			if(n==4) return "LC_THUNDER_TORP";
			if(n==5) return "LC_THUNDER_TORP";		
		}
	}	
}
