#define SUPPLIER_EC

#include "Translates.ech"
#include "Items.ech"

supplier "supplier"
{

////    Declarations    ////

state Initialize;
state Nothing;
state MovingToSuppyObject;
state StopMovingToSuppyObject;

unit m_uObjectToSupply;

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

function void ResetObjectToSupply()
{
    m_uObjectToSupply = null;
    SetObjectToSupply(null);
}//|

function int StopCurrentAction(int nCommand)
{
    UpdateLandAirMode();
    ResetCamouflageMode();
    StopCurrentActionAttacking();
    ResetObjectToSupply();
	return true;
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
}//|

state MovingToSuppyObject
{
    unit uMoveTo;
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("MovingToSuppyObject");
        if (!m_uObjectToSupply.IsLive() || (m_uObjectToSupply.GetIFFNum() != GetIFFNum()) || !m_uObjectToSupply.RequiresAmmoSupply() || !m_uObjectToSupply.IsStored())
        {
            //opozniamy zatrzymanie sie zeby podjechal troche blizej
            return StopMovingToSuppyObject, 100;
        }
        if (!m_uObjectToSupply.IsStored())
        {
            uMoveTo = m_uObjectToSupply.GetObjectContainingObject();
        }
        else
        {
            uMoveTo = m_uObjectToSupply;
        }
        if (uMoveTo != null)
        {
            MoveToPoint(uMoveTo.GetLocationX(), uMoveTo.GetLocationY());
            return MovingToSuppyObject, 20;
        }
        else
        {
            return StopMovingToSuppyObject, 100;
        }
    }
    else
    {
        ResetObjectToSupply();
        return Nothing, 0;
    }
}//|

state StopMovingToSuppyObject
{
    TRACE1("StopMovingToSuppyObject");
    CallStopMoving();
    ResetObjectToSupply();
    return Nothing, 0;
}//|

////    Events    ////

event CanAutoSupply()
{
    //nie jedzie do supplowanych
    //suppluje tylko te w bezposrednim zasiegu
    return false;
}//|

////    Commands    ////

//zamiast szukac w Nothing obiekty do supplowania sa przydzielane ta komenda przez playera
command AutoMoveToSupplyObject(unit uObject) hidden
{
    ASSERT(state == Nothing);
    m_uObjectToSupply = uObject;
    SetObjectToSupply(m_uObjectToSupply);
    MoveToPoint(m_uObjectToSupply.GetLocationX(), m_uObjectToSupply.GetLocationY());
    state MovingToSuppyObject;
    //nie robimy EndCommand
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
        ResetObjectToSupply();
    }
    return true;
}//|
}
