#define TRANSPORTER_EC

#include "Translates.ech"
#include "Items.ech"

transporter "transporter"
{

////    Declarations    ////

state Initialize;
state Nothing;
state WaitingToStopExitTransportedCrew;
state LandingToExitTransportedCrew;
state ExitTransportedCrew;
state RaisingAfterExitTransportedCrew;
state WaitingToStopExitOneTransportedCrew;
state ExitOneTransportedCrew;
state MovingToLandAndExitTransportedCrew;
state MovingToLandToEnterTransportedCrew;
state LandingToEnterTransportedCrew;
int nInit;
int m_bRaiseAfterExitTransportedCrew;
unit m_arrCrewMovingToFlyingTransporter[];

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


function void AddTransportedCrew()
{
	/*	int i;
		int nLevel;
		nLevel=GetExperienceLevel(); //Potyrzebne na wypadek zmiany ilości HP po uzyskaniu większego poziomu doświadczenia
		SetExperienceLevel(0);
		if (GetMaxHP()==400 || GetMaxHP()==200 || GetMaxHP()==2000 || GetMaxHP()==1900 || GetMaxHP()==1200 || GetMaxHP()==800 || GetMaxHP()==3000 || GetMaxHP()==2600)
		{ 
			for(i=1; i<=60; ++i)
			{
				CreateTransportedCrew("UCS_SILVER_ONE_1"); 
			}
	 	}

	 	if (GetMaxHP()==500 || GetMaxHP()==150 || GetMaxHP()==220 || GetMaxHP()==2100 || GetMaxHP()==1100 || GetMaxHP()==1300 || GetMaxHP()==900 || GetMaxHP()==3200 || GetMaxHP()==620)
	 	{
	 		for(i=1; i<=60; ++i)
			{	
				CreateTransportedCrew("ED_TROOPER");
			}
	 	}
		if (GetMaxHP()==180 || GetMaxHP()==510 || GetMaxHP()==2350 || GetMaxHP()==2250 || GetMaxHP()==1260 || GetMaxHP()==550 || GetMaxHP()==3050 || GetMaxHP()==700 )
		{
			for(i=1;i<=60;++i)
			{
				CreateTransportedCrew("LC_GURDIAN_1");
			}
		}
		SetExperienceLevel(nLevel);*/
}
function int StopCurrentAction(int nCommand)
{
    UpdateLandAirMode();
    StopCurrentActionAttacking();
    m_arrCrewMovingToFlyingTransporter.RemoveAll();
	return true;
}//|

////    States    ////

state Initialize
{
	AddTransportedCrew();
	return Nothing;
}//|

state Nothing
{

	if(nInit!=1)//Na wypadek jeśli unit został zainicjalizowany przed wyprodukowaniem
	{
			AddTransportedCrew();
			nInit=1;
	}
	 if (HaveCannonAndCanAttackInCurrentState())
    {
        if (!FindNothingTarget())
        {
            return Nothing;
        }
        //else state ustawiony w NothingAttack
    }
}//|

state WaitingToStopExitTransportedCrew
{
    if (IsMoving())
    {
        TRACE1("WaitingToStopExitTransportedCrew");
        return WaitingToStopExitTransportedCrew, 5;
    }
    else if (!IsLandObject())
    {
        TRACE1("WaitingToStopExitTransportedCrew->LandingToExitTransportedCrew");
        landAirMode = eModeLand;
        ChangedCommandState();
        CallHelicopterLand();
        m_bRaiseAfterExitTransportedCrew = true;
        return LandingToExitTransportedCrew;
    }
    else
    {
        TRACE1("WaitingToStopExitTransportedCrew->ExitTransportedCrew");
        CallExitTransportedCrew();
        return ExitTransportedCrew, 1;
    }
}//|

state LandingToExitTransportedCrew
{
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("LandingToExitTransportedCrew");
        return LandingToExitTransportedCrew, 5;
    }
    else
    {
        if (!IsHelicopterOnLand())
        {
            //z jakiegos powodu nie wyladowal
            landAirMode = eModeAir;
            ChangedCommandState();
            TRACE1("LandingToExitTransportedCrew->landAirMode = eModeAir->Nothing");
            EndCommand(true);
            return Nothing;
        }
        else
        {
            TRACE1("LandingToExitTransportedCrew->ExitTransportedCrew");
            CallExitTransportedCrew();
            return ExitTransportedCrew, 1;
        }
    }
}//|

state ExitTransportedCrew
{
    if (IsExitTransporterCrew())
    {
        TRACE1("ExitTransportedCrew");
        return ExitTransportedCrew, 5;
    }
    else
    {
        if (m_bRaiseAfterExitTransportedCrew)
        {
            TRACE1("ExitTransportedCrew->RaisingAfterExitTransportedCrew");
            m_bRaiseAfterExitTransportedCrew = false;
            landAirMode = eModeAir;
            ChangedCommandState();
            CallHelicopterRaise();
            return RaisingAfterExitTransportedCrew;
        }
        else
        {
            TRACE1("ExitTransportedCrew->Nothing");
            EndCommand(true);
            return Nothing, 0;
        }
    }
}//|

state RaisingAfterExitTransportedCrew
{
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("RaisingAfterExitTransportedCrew");
        return RaisingAfterExitTransportedCrew, 5;
    }
    else
    {
        if (IsHelicopterOnLand())
        {
            //z jakiegos powodu nie wystartowal
            landAirMode = eModeLand;
            ChangedCommandState();
            TRACE1("RaisingAfterExitTransportedCrew->landAirMode = eModeLand");
        }
        TRACE1("RaisingAfterExitTransportedCrew->Nothing");
        EndCommand(true);
        return Nothing;
    }
}//|

state WaitingToStopExitOneTransportedCrew
{
    if (IsMoving())
    {
        TRACE1("WaitingToStopExitOneTransportedCrew");
        return WaitingToStopExitOneTransportedCrew, 5;
    }
    else
    {
        TRACE1("WaitingToStopExitOneTransportedCrew->ExitOneTransportedCrew");
        CallExitOneTransportedCrew();
        return ExitOneTransportedCrew, 1;
    }
}//|

state ExitOneTransportedCrew
{
   	 if (IsExitOneTransporterCrew())
    {
        TRACE1("ExitOneTransportedCrew");
        return ExitOneTransportedCrew, 5;
    }
    else
    {
        TRACE1("ExitOneTransportedCrew->Nothing");
        EndCommand(true);
        return Nothing, 0;
    }

}//|

state MovingToLandAndExitTransportedCrew
{
    if (IsMoving())
    {
        TRACE1("MovingToLandAndExitTransportedCrew");
        return MovingToLandAndExitTransportedCrew, 5;
    }
    else if (!IsLandObject())
    {
        TRACE1("MovingToLandAndExitTransportedCrew->LandingToExitTransportedCrew");
        landAirMode = eModeLand;
        ChangedCommandState();
        CallHelicopterLand();
        //bez raising?
        //m_bRaiseAfterExitTransportedCrew = true;
        return LandingToExitTransportedCrew;
    }
    else
    {
        TRACE1("MovingToLandAndExitTransportedCrew->ExitTransportedCrew");
        CallExitTransportedCrew();
        return ExitTransportedCrew, 1;
    }
}//|

state MovingToLandToEnterTransportedCrew
{
    unit uFlyTo;
    //sprawdzamy czy infantry do ktorego lecimy zyje i czy dalej do nas idzie
    if (!m_arrCrewMovingToFlyingTransporter.GetSize())
    {
        __ASSERT_FALSE();
        TRACE1("MovingToLandToEnterTransportedCrew->!crew->Nothing");
        CallStopMoving();
        EndCommand(true);
        return Nothing;
    }
    uFlyTo = m_arrCrewMovingToFlyingTransporter[0];
    while (!uFlyTo.IsLive() || !uFlyTo.IsStored() || !uFlyTo.IsExecutingMoveCrewInsideObjectCommand())
    {
        m_arrCrewMovingToFlyingTransporter.RemoveAt(0);
        if (!m_arrCrewMovingToFlyingTransporter.GetSize())
        {
            TRACE1("MovingToLandToEnterTransportedCrew->!crew->Nothing");
            CallStopMoving();
            EndCommand(true);
            return Nothing;
        }
        uFlyTo = m_arrCrewMovingToFlyingTransporter[0];
    }
    if (IsMoving())
    {
        TRACE1("MovingToLandToEnterTransportedCrew->MovingToLandToEnterTransportedCrew");
        if (DistanceTo(uFlyTo) <= G2A(4))
        {
            CallStopMoving();
        }
        else
        {
            CallMoveToPoint(uFlyTo.GetLocationX(), uFlyTo.GetLocationY());
        }
        return MovingToLandToEnterTransportedCrew, 5;
    }
    else if (DistanceTo(uFlyTo) > G2A(4))
    {
        TRACE1("MovingToLandToEnterTransportedCrew->dist>1->MovingToLandToEnterTransportedCrew");
        CallMoveToPoint(uFlyTo.GetLocationX(), uFlyTo.GetLocationY());
        return MovingToLandToEnterTransportedCrew, 5;
    }
    else if (!IsLandObject())
    {
        TRACE1("MovingToLandToEnterTransportedCrew->LandingToEnterTransportedCrew");
        m_arrCrewMovingToFlyingTransporter.RemoveAll();//juz niepotrzebne
        landAirMode = eModeLand;
        ChangedCommandState();
        CallHelicopterLand();
        return LandingToEnterTransportedCrew;
    }
    else
    {
        TRACE1("MovingToLandToEnterTransportedCrew->onLand->Nothing");
        m_arrCrewMovingToFlyingTransporter.RemoveAll();
        EndCommand(true);
        return Nothing;
    }
}//|

state LandingToEnterTransportedCrew
{
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("LandingToEnterTransportedCrew");
        return LandingToEnterTransportedCrew, 5;
    }
    else
    {
        if (!IsHelicopterOnLand())
        {
            //z jakiegos powodu nie wyladowal
            landAirMode = eModeAir;
            ChangedCommandState();
            TRACE1("LandingToEnterTransportedCrew->landAirMode = eModeAir->Nothing");
            EndCommand(true);
            return Nothing;
        }
        else
        {
            TRACE1("LandingToEnterTransportedCrew->Nothing");
            EndCommand(true);
            return Nothing;
        }
    }
}//|

////    Commands    ////

command ExitTransportedCrew() button TRL_EXITTRANSPORTEDCREW item ITEM_EXITTRANSPORTEDCREW priority PRIOR_EXITTRANSPORTEDCREW
{
    if (!HaveTransportedCrew() || (!IsLandObject() && !IsTypeHelicopterWithLandMode()))
    {
        return false;
    }
    CHECK_STOP_CURR_ACTION(eCommandExitTransportedCrew);
    m_bRaiseAfterExitTransportedCrew = false;
    if (IsMoving())
    {
        CallStopMoving();
        state WaitingToStopExitTransportedCrew;
    }
    else if (!IsLandObject())
    {
        landAirMode = eModeLand;
        ChangedCommandState();
        CallHelicopterLand();
        m_bRaiseAfterExitTransportedCrew = true;
        state LandingToExitTransportedCrew;
    }
    else
    {
        CallExitTransportedCrew();
        state ExitTransportedCrew;
    }
    SetStateDelay(0);
    return true;
}//|

command SelfExitOneCrew(unit uUnit) hidden
{
    if (!HaveTransportedCrew() || !IsLandObject() || (uUnit != GetUnitRef()))
    {
        return false;
    }
    CHECK_STOP_CURR_ACTION(eCommandSelfExitOneCrew);
    if (IsMoving())
    {
        CallStopMoving();
        state WaitingToStopExitTransportedCrew;
    }
    else
    {
        CallExitOneTransportedCrew();
        state ExitOneTransportedCrew;
    }
    SetStateDelay(0);
    return true;
}//|

command LandAndExitTransportedCrew(int nX, int nY) hidden
{
    if (!HaveTransportedCrew() || (!IsLandObject() && !IsTypeHelicopterWithLandMode()))
    {
        return false;
    }
    CHECK_STOP_CURR_ACTION(eCommandLandAndExitTransportedCrew);
    m_bRaiseAfterExitTransportedCrew = false;
    if (IsLandObject())
    {
        if (IsMoving())
        {
            CallStopMoving();
            state WaitingToStopExitTransportedCrew;
        }
        else
        {
            CallExitTransportedCrew();
            state ExitTransportedCrew;
        }
    }
    else
    {
        CallMoveToPoint(nX, nY);
        state MovingToLandAndExitTransportedCrew;
    }
    SetStateDelay(0);
    return true;
}//|

//rozkaz wydany przez crew ktory dostal rozkaz wejscia do nas gdy jestesmy w powietrzu
//musimy poleciec w jego kierunku i wyladowac gdy bedziemy blisko
//musimy zapamietac wszystkie infantry ktore wydaly ten rozkaz bo ostani mogl zostac zabity lub zmieniona
//dla niego komenda a pozostale moga dalej isc do transportera
command MoveAndLandToEnterTransportedCrew(unit uCrew) hidden
{
    if (uCrew == null)
    {
        return false;
    }
    //nie robimy CHECK_STOP_CURR_ACTION bo to kasuje m_arrCrewMovingToFlyingTransporter
    m_arrCrewMovingToFlyingTransporter.Add(uCrew);
    if ((m_arrCrewMovingToFlyingTransporter.GetSize() == 1) || (state != MovingToLandToEnterTransportedCrew))
    {
        CallMoveToPoint(uCrew.GetLocationX(), uCrew.GetLocationY());
    }
    state MovingToLandToEnterTransportedCrew;
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
        m_arrCrewMovingToFlyingTransporter.Create(0);
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
        if (m_arrCrewMovingToFlyingTransporter.Exist())
        {
            m_arrCrewMovingToFlyingTransporter.RemoveAll();
            m_arrCrewMovingToFlyingTransporter.Delete();
        }
    }
    return true;
}//|
}
