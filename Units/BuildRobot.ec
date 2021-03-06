#define BUILDROBOT_EC

#include "Translates.ech"
#include "Items.ech"

buildrobot "buildrobot"
{

////    Declarations    ////

state Initialize;
state Nothing;

state MovingToBuildPos;
state LandingOnBuildPlace;
state StartingBuildBuilding;
state RaisingFromBuildPlace;

state MovingToRepairPos;
state Repairing;
state EndRepairing;
state MovingToHoldPosAfterRepair;

int m_nBuildPosX, m_nBuildPosY, m_nBuildPosZ;

unit m_uRepairTarget;
int m_nRepairTargetPosX, m_nRepairTargetPosY;
int m_nFindBuilderPlaceCnt;

#define STOPCURRENTACTION
function int StopCurrentAction(int nCommand);

#include "Common.ech"
#include "Accuracy.ech"
#include "Camouflage.ech"
#include "Entrenchment.ech"
#include "Lights.ech"
#include "Move.ech"
#include "Special.ech"
#include "Attack.ech"
#include "Crew.ech"
#include "Events.ech"

////    Functions    ////

function int IsInAnyBuildState()
{
    if ((state == MovingToBuildPos) || 
        (state == LandingOnBuildPlace) ||
        (state == StartingBuildBuilding) ||
        (state == RaisingFromBuildPlace))
    {
        return true;
    }
    return false;
}//|

function void SetRepairedTarget(unit uTarget)
{
    m_uRepairTarget = uTarget;
    SetRepairTarget(uTarget);
}//|

function int StopCurrentAction(int nCommand)
{
    UpdateLandAirMode();
    ResetCamouflageMode();
    StopCurrentActionAttacking();
    if (IsStartingBuildBuilding())
    {
        CallStopWork();
    }
    else if (IsInAnyBuildState())
    {
        SetBuildBuildingTarget(0, 0, 0, 0);//zresetowac trzymany wskaznik na budynek
    }
    SetRepairTarget(null);
	return true;
}//|

function void MoveToRepairPos()
{
    int nX, nY, nZ;

    ASSERT(IsHelicopterMove());
    FindPositionToRepair(m_uRepairTarget, nX, nY, nZ);
    if (m_uRepairTarget.IsBuilding())
    {
        if (DistanceTo(nX, nY) < 0x20)
        {
            CallHelicopterSetHeight(nZ);
        }
        else
        {
            //lecimy nad budynek zeby nas nie odepchal - potem podlecimy nizej
            CallHelicopterFlyToPoint(nX, nY, nZ + eOneGridSize);
        }
    }
    else
    {
        CallHelicopterFlyToPoint(nX, nY, nZ);
    }
}//|

function int FindRepairNothingTarget(int bSetHoldPos)
{
    unit uTarget;

    if (bSetHoldPos)
    {
        uTarget = FindClosestObjectToRepair(GetLocationX(), GetLocationY());
    }
    else
    {
        uTarget = FindClosestObjectToRepair(m_nHoldPosX, m_nHoldPosY);
    }
    if (uTarget != null)
    {
        m_bAutoTarget = true;
        if (bSetHoldPos)
        {
            GetLocation(m_nHoldPosX, m_nHoldPosY);
        }
        ResetCamouflageMode();
        SetRepairedTarget(uTarget);
        m_uRepairTarget.GetLocation(m_nRepairTargetPosX, m_nRepairTargetPosY);
        MoveToRepairPos();
        m_nFindBuilderPlaceCnt = 0;
        state MovingToRepairPos;
        SetStateDelay(10);
        return true;
    }
    return false;
}//|

////    States    ////

state Initialize
{
    return Nothing;
}//|

state Nothing
{
    if (HaveCannonAndCanAttackInCurrentState())
    {
        if (!FindNothingTarget())
        {
            return Nothing;
        }
        //else state ustawiony w NothingAttack
    }
    //tryb automatycznego naprawiania jest zawsze wlaczony
    if (CanRepair())
    {
        if (FindRepairNothingTarget(true))
        {
            return state, GetStateDelay();
        }
    }
}//|

state MovingToBuildPos
{
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("MovingToBuildPos");
        return MovingToBuildPos, 10;
    }
    else
    {
        if (IsInGoodPlaceToStartBuild())
        {
            if (ABS(GetAngleDiff(GetAngleToBuildBuilding())) > 0x05)
            {
                CallTurnToAngle(GetAngleToBuildBuilding());
                TRACE1("MovingToBuildPos->CallTurnToAngle->MovingToBuildPos");
                return MovingToBuildPos, 5;
            }
            else
            {
                TRACE1("MovingToBuildPos->LandingOnBuildPlace");
                CallHelicopterSetHeight(m_nBuildPosZ);
                return LandingOnBuildPlace, 0;
            }
        }
        else if (m_nFindBuilderPlaceCnt < 3)
        {
            ++m_nFindBuilderPlaceCnt;
            TRACE1("MovingToBuildPos->++m_nFindBuilderPlaceCnt->MovingToBuildPos");
            FindPositionToBuildBuilding(m_nBuildPosX, m_nBuildPosY, m_nBuildPosZ);
            if (IsHelicopterMove())
            {
                CallHelicopterFlyToPoint(m_nBuildPosX, m_nBuildPosY, m_nBuildPosZ + G2A(2));
            }
            else
            {
                MoveToPoint(m_nBuildPosX, m_nBuildPosY);
            }
            return MovingToBuildPos, 0;
        }
        else 
        {
            TRACE1("MovingToBuildPos->m_nFindBuilderPlaceCnt==3->Nothing");
            EndCommand(false);
            return Nothing, 0;
        }
    }
}//|

state LandingOnBuildPlace
{
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("LandingOnBuildPlace");
        return LandingOnBuildPlace, 5;
    }
    else
    {
        if (GetLocationZ() <= (m_nBuildPosZ + 0x20))
        {
            TRACE1("LandingOnBuildPlace->StartingBuildBuilding");
            CallStartBuildBuilding();
            return StartingBuildBuilding, 0;
        }
        else
        {
            TRACE1("LandingOnBuildPlace->MovingToBuildPos");
            FindPositionToBuildBuilding(m_nBuildPosX, m_nBuildPosY, m_nBuildPosZ);
            if (IsHelicopterMove())
            {
                CallHelicopterFlyToPoint(m_nBuildPosX, m_nBuildPosY, m_nBuildPosZ + G2A(2));
            }
            else
            {
                MoveToPoint(m_nBuildPosX, m_nBuildPosY);
            }
            return MovingToBuildPos, 0;
        }
    }
}//|

state StartingBuildBuilding
{
    if (IsStartingBuildBuilding())
    {
        TRACE1("StartingBuildBuilding");
        return StartingBuildBuilding, 10;
    }
    else
    {
        TRACE1("StartingBuildBuilding->RaisingFromBuildPlace");
        return RaisingFromBuildPlace, 50;
    }
}//|

state RaisingFromBuildPlace
{
    TRACE1("RaisingFromBuildPlace->Nothing");
    CallHelicopterRaise();
    EndCommand(true);
    return Nothing, 0;
}//|

state MovingToRepairPos
{
    int nX, nY;
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("MovingToRepairPos");
        if (!CanRepairObject(m_uRepairTarget))
        {
            //lecimy dalej w tamtym kierunku ale nie do x,y,z tylko do x,y
            GetMoveTarget(nX, nY);
            SetRepairedTarget(null);
            TRACE1("->!CanRepair");
            EndCommand(true);
            return EndRepairing, 0;
        }
        m_uRepairTarget.GetLocation(nX, nY);
        if ((nX != m_nRepairTargetPosX) || (nY != m_nRepairTargetPosY))
        {
            m_nFindBuilderPlaceCnt = 0;
            m_nRepairTargetPosX = nX;
            m_nRepairTargetPosY = nY;
            MoveToRepairPos();
        }
        if (m_bAutoTarget && (DistanceTo(nX, nY) > (3*GetMaxAutoRepairRange()/2 + eOneGridSize)))
        {
            SetRepairedTarget(null);
            CallStopMoving();
            TRACE1("-> > autoRange");
            EndCommand(true);
            return EndRepairing, 0;
        }
        return MovingToRepairPos, 10;
    }
    else
    {
        if (!CanRepairObject(m_uRepairTarget))
        {
            TRACE1("MovingToRepairPos->!Can->EndRepairing");
            SetRepairedTarget(null);
            EndCommand(true);
            return EndRepairing, 0;
        }
        if (IsInGoodPlaceToRepair(m_uRepairTarget))
        {
            TRACE1("MovingToRepairPos->Repairing");
            CallRepair(m_uRepairTarget);
            return Repairing, 10;
        }
        else if (m_nFindBuilderPlaceCnt < 3)
        {
            TRACE1("MovingToRepairPos->++m_nFindBuilderPlaceCnt->MovingToRepairPos");
            ++m_nFindBuilderPlaceCnt;
            MoveToRepairPos();
            return MovingToRepairPos, 10;
        }
        else
        {
            TRACE1("MovingToRepairPos->m_nFindBuilderPlaceCnt==3->EndRepairing");
            EndCommand(false);
            return EndRepairing, 0;
        }
    }
}//|

state Repairing
{
    if (IsRepairing())
    {
        return Repairing, 10;
    }
    else
    {
        if (CanRepairObject(m_uRepairTarget))
        {
            TRACE1("Repairing->MovingToRepairPos");
            //uciekl nam
            MoveToRepairPos();
            m_nFindBuilderPlaceCnt = 0;
            return MovingToRepairPos, 10;
        }
        TRACE1("Repairing->EndRepairing");
        SetRepairedTarget(null);
        CallHelicopterRaise();
        EndCommand(true);
        return EndRepairing, 0;
    }
}//|

state EndRepairing
{
    if (m_bAutoTarget)
    {
        //szukamy nowego celu
        if (FindRepairNothingTarget(false))
        {
            TRACE1("EndRepairing->MovingToRepairPos");
            return state, GetStateDelay();
        }
        TRACE1("EndRepairing->MovingToHoldPosAfterRepair");
        CallMoveToPoint(m_nHoldPosX, m_nHoldPosY);
        return MovingToHoldPosAfterRepair, 5;
    }
    else
    {
        TRACE1("EndRepairing->Nothing");
        return Nothing, 0;
    }
}//|

state MovingToHoldPosAfterRepair
{
	if (IsMoving() || IsStartingMoving())
	{
        //szukamy nowego celu
        if (FindRepairNothingTarget(false))
        {
            TRACE1("MovingToHoldPosAfterRepair->MovingToRepairPos");
            return state, GetStateDelay();
        }
        return MovingToHoldPosAfterRepair;
    }
    else
    {
        TRACE1("MovingToHoldPosAfterRepair->Nothing");
        return Nothing, 0;
    }
}//|

////    Commands    ////

command BuildBuilding(int nX, int nY, int nAlpha, int nObjectID) hidden
{
    if (!CanBuildBuildings())
    {
        return false;
    }
    CHECK_STOP_CURR_ACTION(eCommandBuildBuilding);
    //nObjectID nie mozemy trzymac w tym obiekcie bo po zaladowaniu ID obiektu moglby byc juz walniety
	SetBuildBuildingTarget(nX, nY, nAlpha, nObjectID);
    FindPositionToBuildBuilding(m_nBuildPosX, m_nBuildPosY, m_nBuildPosZ);
    if (IsHelicopterMove())
    {
        CallHelicopterFlyToPoint(m_nBuildPosX, m_nBuildPosY, m_nBuildPosZ + G2A(2));
    }
    else
    {
        MoveToPoint(m_nBuildPosX, m_nBuildPosY);
    }
    m_nFindBuilderPlaceCnt = 0;
    state MovingToBuildPos;
    SetStateDelay(0);
    return true;
}//|

command Repair(unit uTarget) hidden
{
    if (!CanRepair())
    {
        return false;
    }
    if (!CanRepairObject(uTarget))
    {
        return false;
    }
    m_bAutoTarget = false;
    SetRepairedTarget(uTarget);
    m_uRepairTarget.GetLocation(m_nRepairTargetPosX, m_nRepairTargetPosY);
    MoveToRepairPos();
    m_nFindBuilderPlaceCnt = 0;
    state MovingToRepairPos;
    SetStateDelay(0);
    return true;
}//|

command Initialize()
{
    if (GetUnitRef())
    {
        SetCannonsAutoFire();
        SetAccuracyMode(0);//na wypadek przeladowania skryptu
        SetCamouflageMode(0);
        if (HaveCannon())
        {
            SetTimer(20);//uzywany tylko do CheckArmedState
        }
    }
    return true;
}//|

command Uninitialize()
{
    if (GetUnitRef())
    {
        ResetEnterBuilding();
        ResetAttackTarget();
        SetRepairTarget(null);
    }
    return true;
}//|
}
