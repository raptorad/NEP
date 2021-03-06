#define LASERUNIT_EC

#include "Translates.ech"
#include "Items.ech"

laserunit "laserunit"
{

////    Declarations    ////

state Initialize;
state Nothing;
state FlyingToBaseBuilding;
state StartMovingToStartLaserAttack;
state MovingToStartLaserAttack;
state TurningToLaserAttack;
state MakingLaserAttack;

int m_nBaseBuildingX, m_nBaseBuildingY, m_nBaseBuildingZ;
int m_nStartLaserX, m_nStartLaserY;
int m_nEndLaserX, m_nEndLaserY;

#define STOPCURRENTACTION
function int StopCurrentAction(int nCommand);

#include "Common.ech"
#include "Accuracy.ech"
#include "Camouflage.ech"
#include "Lights.ech"
#include "Move.ech"
#include "Special.ech"
#include "Attack.ech"

////    Functions    ////

function int StopCurrentAction(int nCommand)
{
    UpdateLandAirMode();
    if ((state == MakingLaserAttack) || IsMakingLaserAttack())
    {
        return false;
    }
    StopCurrentActionAttacking();
	return true;
}//|

function int FlyToBaseBuildingSlot()
{
    int nX, nY, nZ, nAlpha;
    unit uBuilding;

    if (HaveBaseBuilding())
    {
        if (IsInBaseBuildingSlotPos())
        {
            return false;
        }
        if (GetBaseBuildingSlotPos(nX, nY, nZ, nAlpha))
        {
            //lecimy o 1 klatke wyzej, potem ladujemy
            if (DistanceTo(nX, nY) > 0x80)
            {
                CallHelicopterFlyToPoint(nX, nY, nZ + eOneGridSize);
            }
            else
            {
                CallHelicopterFlyToPoint(nX, nY, nZ);
            }
            uBuilding = GetBaseBuilding();
            m_nBaseBuildingX = uBuilding.GetLocationX();
            m_nBaseBuildingY = uBuilding.GetLocationY();
            m_nBaseBuildingZ = uBuilding.GetLocationZ();
            return true;
        }
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
    if (HaveBaseBuilding() && !IsInBaseBuildingSlotPos())
    {
        if (FlyToBaseBuildingSlot())
        {
            return FlyingToBaseBuilding;
        }
    }
    return Nothing;
}//|

state FlyingToBaseBuilding
{
    unit uBuilding;
    int nX, nY, nZ, nAlpha;
    int bBuildingOpen;

    if (!HaveBaseBuilding())
    {
        //dolecimy do konca i staniemy
        return Nothing;
    }
    if (DistanceTo(m_nBaseBuildingX, m_nBaseBuildingY) < G2A(4))
    {
        bBuildingOpen = PrepareOpenLaserUnitBaseBuilding();
    }
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("FlyingToBaseBuilding");
        uBuilding = GetBaseBuilding();
        if ((uBuilding.GetLocationX() != m_nBaseBuildingX) ||
            (uBuilding.GetLocationY() != m_nBaseBuildingY) ||
            (uBuilding.GetLocationZ() != m_nBaseBuildingZ))
        {
            //zmiana wysokosci po rozwaleniu budynku ponizej
            FlyToBaseBuildingSlot();
        }
        return FlyingToBaseBuilding, 10;
    }
    else
    {
        if (GetBaseBuildingSlotPos(nX, nY, nZ, nAlpha))
        {
            if (DistanceTo(nX, nY) > 0x40)
            {
                FlyToBaseBuildingSlot();
                return FlyingToBaseBuilding, 10;
            }
            else if ((GetLocationZ() - nZ) > 0x40)
            {
                if (!bBuildingOpen)
                {
                    //czekamy az budynek sie otworzy przy okazji sie obracamy
                    if (ABS(GetAngleDiff(nAlpha)) > 5)
                    {
                        CallTurnToAngle(nAlpha);
                    }
                    return FlyingToBaseBuilding;
                }
                //ladujemy
                CallHelicopterSetHeight(nZ, nAlpha);
                return FlyingToBaseBuilding, 10;
            }
            else if (ABS(GetAngleDiff(nAlpha)) > 5)
            {
                CallTurnToAngle(nAlpha);
            }
            //else przechodzimy do Nothing
        }
        return Nothing;
    }
}//|

state StartMovingToStartLaserAttack
{
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("StartMovingToStartLaserAttack");
        return StartMovingToStartLaserAttack, 10;
    }
    else
    {
        CloseLaserUnitBaseBuilding();//zamykamy budynek
        CallMoveToPoint(m_nStartLaserX, m_nStartLaserY);
        TRACE1("StartMovingToStartLaserAttack->MovingToStartLaserAttack");
        return MovingToStartLaserAttack;
    }
}//|

state MovingToStartLaserAttack
{
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("MovingToStartLaserAttack");
        return MovingToStartLaserAttack, 10;
    }
    else
    {
        if (DistanceTo(m_nStartLaserX, m_nStartLaserY) <= 0x80)
        {
            TRACE1("MovingToStartLaserAttack->TurningToLaserAttack");
            CallTurnToAngle(AngleTo(m_nEndLaserX, m_nEndLaserY));
            return TurningToLaserAttack;
        }
        else
        {
            TRACE1("MovingToStartLaserAttack->MovingToStartLaserAttack");
            CallMoveToPoint(m_nStartLaserX, m_nStartLaserY);
            return MovingToStartLaserAttack;
        }
    }
}//|

state TurningToLaserAttack
{
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("TurningToLaserAttack");
        return TurningToLaserAttack, 10;
    }
    else
    {
        TRACE1("TurningToLaserAttack->AttackingLaser");
        CallMakeLaserAttack(m_nEndLaserX, m_nEndLaserY);
        return MakingLaserAttack;
    }
}//|

state MakingLaserAttack
{
    if (IsMakingLaserAttack())
    {
        return MakingLaserAttack;
    }
    else
    {
        EndCommand(true);
        return Nothing, 0;//w Nothing wracamy do budynku
    }
}//|

////    Events    ////

event OnHit(unit uByUnit)
{
    //nic nie robi
}//|

event Timer()
{
    CheckArmedState();
}//|

////    Commands    ////

command LaserAttack(int nX1, int nY1, int nX2, int nY2) button TRL_LASERATTACK item ITEM_LASERATTACK priority PRIOR_LASERATTACK
{
    if (!CanMakeLaserAttack(nX1, nY1, nX2, nY2))
    {
        return false;
    }
    CHECK_STOP_CURR_ACTION(eCommandLaserAttack);
    m_nStartLaserX = nX1;
    m_nStartLaserY = nY1;
    m_nEndLaserX = nX2;
    m_nEndLaserY = nY2;
    //najpierw startujemy w gore
    CallHelicopterSetHeight(GetLocationZ() + eOneGridSize);
    state StartMovingToStartLaserAttack;
    return true;
}//|

command SetLaserUnitBaseBuilding(unit uBuilding) hidden
{
    //zmieniamy budynek tylko jesli teraz nie mamy
    if (HaveBaseBuilding() || !CanSetLaserUnitBaseBuilding(uBuilding))
    {
        return false;
    }
    CHECK_STOP_CURR_ACTION(eCommandSetLaserUnitBaseBuilding);
    if (SetLaserUnitBaseBuilding(uBuilding) && FlyToBaseBuildingSlot())
    {
        state FlyingToBaseBuilding;
        SetStateDelay(0);
        EndCommand(false);//zeby juz nie trzeba bylo wywolywac w FlyingToBaseBuilding
    }
    else
    {
        state Nothing;
        EndCommand(false);
    }
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
    }
    return true;
}//|
}
