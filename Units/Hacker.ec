//oba define'y
#define INFANTRY_EC
#define HACKER_EC

#include "Translates.ech"
#include "Items.ech"

hacker "hacker"
{

////    Declarations    ////

state Initialize;
state Nothing;
state MovingToCaptureTarget;
state TurningToCaptureTarget;
state CapturingObject;
state EndCapturingTarget;
state MovingHackerToHoldAreaPos;

unit m_uCaptureTarget;

enum captureMode
{
    TRL_CAPTUREMODE_0 item ITEM_CAPTUREMODE_0,
    TRL_CAPTUREMODE_1 item ITEM_CAPTUREMODE_1,
multi:
    TRL_CAPTUREMODE_X item ITEM_CAPTUREMODE_X
}//|

#define HAVEMOVEMENTMODE true

#define STOPCURRENTACTION
function int StopCurrentAction(int nCommand);

#include "Common.ech"
#include "Accuracy.ech"
#include "Camouflage.ech"
#include "Move.ech"
#include "Special.ech"
#include "Attack.ech"
#include "Infantry.ech"
#include "Events.ech"//po Infantry.ech

////    Functions    ////

function void ResetCaptureTarget()
{
    m_uCaptureTarget = null;
    SetCaptureTarget(null);
}//|

function int StopCurrentAction(int nCommand)
{
    UpdateLandAirMode();
    ResetCamouflageMode();
    StopCurrentActionAttacking();
    if (nCommand != eCommandStop)
    {
        StopAutoCrawlMode();
    }
    ResetCaptureTarget();
	return true;
}//|

function int StartCaptureObject(unit uTarget)
{
    ASSERT(CanCaptureObject(uTarget));
    if (IsObjectInCaptureRange(uTarget))
    {
        if (GetRelativeAngleTo(uTarget) > 0x20)
        {
            CallTurnToAngle(AngleTo(uTarget));
            state TurningToCaptureTarget;
        }
        else
        {
            CallCaptureObject(uTarget);
            state CapturingObject;
        }
        SetStateDelay(0);
        return true;
    }
    else
    {
        if (m_bAutoTarget)
        {
            if (movementMode == eModeHoldPosition)
            {
                return false;
            }
            if ((movementMode == eModeHoldArea) && (DistanceTo(m_nHoldPosX, m_nHoldPosY) > G2A(eHoldAreaRange)))
            {
                return false;
            }
        }
        MoveToPoint(uTarget.GetLocationX(), uTarget.GetLocationY());
        state MovingToCaptureTarget;
        SetStateDelay(0);
        return true;
    }
    return true;
}//|

function int FindHackerNothingTarget(int bStoreHoldPos)
{
    unit uTarget;

    if (HaveCannonAndCanAttackInCurrentState())
    {
        if (FindNothingTarget(bStoreHoldPos))
        {
            return true;
        }
    }
    if (captureMode == 1)
    {
        if (movementMode == eModeHoldPosition)
        {
            uTarget = FindClosestObjectToCapture(true);
        }
        else
        {
            uTarget = FindClosestObjectToCapture(false);
        }
        if (uTarget != null)
        {
            if (bStoreHoldPos)
            {
                StoreHoldPos();
            }
            if (StartCaptureObject(uTarget))
            {
                ResetCamouflageMode();
                m_uCaptureTarget = uTarget;
                m_bAutoTarget = true;
                SetCaptureTarget(m_uCaptureTarget);
                return true;
            }
            else
            {
                __ASSERT_FALSE();
            }
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
    if (!FindHackerNothingTarget(true))
    {
        return Nothing;
    }
    //else state ustawiony w NothingAttack
}//|

state MovingToCaptureTarget
{
    if (!CanCaptureObject(m_uCaptureTarget) || !IsVisible(m_uCaptureTarget))
    {
        TRACE1("MovingToCaptureTarget->!CanCaptureObject");
        ResetCaptureTarget();
        CallStopMoving();
        EndCommand(true);
        return EndCapturingTarget, 0;
    }
    if (IsObjectInCaptureRange(m_uCaptureTarget))
    {
        CallStopMoving();
        if (IsMoving())
        {
            return MovingToCaptureTarget, 5;
        }
    }
    if (!StartCaptureObject(m_uCaptureTarget))
    {
        TRACE1("MovingToCaptureTarget->!StartCaptureObject->EndCapturingTarget");
        ResetCaptureTarget();
        CallStopMoving();
        EndCommand(true);
        return EndCapturingTarget, 0;
    }
    else
    {
        TRACE1("MovingToCaptureTarget->StartCaptureObject");
    }
}//|

state TurningToCaptureTarget
{
    if (!CanCaptureObject(m_uCaptureTarget) || !IsVisible(m_uCaptureTarget))
    {
        TRACE1("TurningToCaptureTarget->!CanCaptureObject");
        ResetCaptureTarget();
        CallStopMoving();
        EndCommand(true);
        return EndCapturingTarget, 0;
    }
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("TurningToCaptureTarget");
        return TurningToCaptureTarget, 5;
    }
    else
    {
        if (!StartCaptureObject(m_uCaptureTarget))
        {
            TRACE1("TurningToCaptureTarget->!StartCaptureObject->EndCapturingTarget");
            ResetCaptureTarget();
            CallStopMoving();
            EndCommand(true);
            return EndCapturingTarget, 0;
        }
        else
        {
            TRACE1("TurningToCaptureTarget->StartCaptureObject");
        }
    }
}//|

state CapturingObject
{
    if (IsCapturing())
    {
        return CapturingObject, 5;
    }
    else
    {
        if (!CanCaptureObject(m_uCaptureTarget) || !IsVisible(m_uCaptureTarget))
        {
            TRACE1("CapturingObject->!CanCaptureObject");
            ResetCaptureTarget();
            EndCommand(true);
            return EndCapturingTarget, 0;
        }
        else
        {
            //poza zasiegiem
            if (!StartCaptureObject(m_uCaptureTarget))
            {
                TRACE1("CapturingObject->!StartCaptureObject->EndCapturingTarget");
                ResetCaptureTarget();
                EndCommand(true);
                return EndCapturingTarget, 0;
            }
            else
            {
                TRACE1("CapturingObject->StartCaptureObject");
            }
        }
    }
}//|

state EndCapturingTarget
{
    int nDist;

    TRACE1("EndCapturingTarget");
    if (!m_bAutoTarget)
    {
        TRACE1("    ->!Auto->Nothing");
        return Nothing, 0;
    }
    else if (movementMode == eModeHoldArea)
    {
        TRACE1("  ->eModeHoldArea");
        //sprawdzamy czy w poblizu jest inny cel
        nDist = DistanceTo(m_nHoldPosX, m_nHoldPosY);
        if (nDist < G2A(eHoldAreaRange/2))
        {
            if (FindHackerNothingTarget(false))
            {
                TRACE1("    ->FindNothingTarget");
                return state, GetStateDelay();//state ustawiony w FindNothingTarget
            }
        }
        if (nDist > eHalfGridSize)
        {
            TRACE1("    ->MovingHackerToHoldAreaPos");
            CallMoveToPoint(m_nHoldPosX, m_nHoldPosY);
            return MovingHackerToHoldAreaPos, 5;
        }
        else
        {
            TRACE1("    ->Nothing");
            return Nothing, 0;
        }
    }
    else
    {
        TRACE1("    ->Nothing");
        return Nothing, 0;
    }
}//|

state MovingHackerToHoldAreaPos
{
	if (IsMoving() || IsStartingMoving())
	{
		TRACE("MovingHackerToHoldAreaPos\n");
        //sprawdzamy czy w poblizu jest inny cel
        if (DistanceTo(m_nHoldPosX, m_nHoldPosY) < G2A(eHoldAreaRange - 3))
        {
            if (FindHackerNothingTarget(false))
            {
                TRACE("   ->AttackingTarget\n");
                return state, GetStateDelay();//state ustawiony w FindNothingTarget
            }
        }
        return MovingHackerToHoldAreaPos;
	}
	else
	{
		TRACE("MovingHackerToHoldAreaPos -> Nothing\n");
        //to bylo z m_bAutoTarget
		return Nothing, 0;
	}
}//|

////    Commands    ////

command SetCaptureMode(int nMode) button captureMode priority PRIOR_CAPTUREMODE
{
    if (nMode == -1)
    {
        captureMode = (captureMode + 1) % 2;
    }
    else
    {
        captureMode = nMode;
    }
    EndCommand(true);
    return true;
}//|

command CaptureObject(unit uTarget) hidden
{
    if (!CanCaptureObject(uTarget))
    {
        return false;
    }
    m_uCaptureTarget = uTarget;
    m_bAutoTarget = false;
    SetCaptureTarget(m_uCaptureTarget);
    StartCaptureObject(m_uCaptureTarget);
    return true;
}//|

command Initialize()
{
    captureMode = 1;
    if (GetUnitRef())
    {
        SetAccuracyMode(0);//na wypadek przeladowania skryptu
        SetCamouflageMode(0);
        if (IsCrawlModeUnit())
        {
            SetTimer(20);//uzywany tylko do CheckAutoCrawlMode
            SetCheckAnyAllyHitInLastStepVisibility(true);
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
        ResetCaptureTarget();
        ResetCrewInsideObject();
    }
    return true;
}//|

}
