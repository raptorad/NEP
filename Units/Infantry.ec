#define INFANTRY_EC

#include "Translates.ech"
#include "Items.ech"

infantry "infantry"
{

////    Declarations    ////

state Initialize;
state Nothing;

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

function int StopCurrentAction(int nCommand)
{
    UpdateLandAirMode();
    ResetCamouflageMode();
    StopCurrentActionAttacking();
    if (nCommand != eCommandStop)
    {
        StopAutoCrawlMode();
    }
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

////    Commands    ////

command Initialize()
{
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
        ResetCrewInsideObject();
    }
    return true;
}//|

}
