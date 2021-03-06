#define HARVESTER_EC

#include "Translates.ech"
#include "Items.ech"

harvester "harvester"
{

////    Declarations    ////

state Initialize;
state Nothing;

state MovingToHarvestPos;
state LandingInHarvestPos;
state SettingHeightInHarvestPos;
state Harvesting;
state MovingToRefinery;
state StartSettingHeightInRefinery;
state SettingHeightInRefinery;
state PuttingResourceToRefinery;
state RaiseWaitingToPutResourceToRefinery;
state WaitingToPutResourceToRefinery;

int m_nHarvestMode;
int m_nHarvestSource;
int m_nLastResourceType;
unit m_uResource;
int m_nLiquidX, m_nLiquidY;
unit m_uRefinery;

int m_nFindNothingCounter;

consts 
{
    eSourceNone = 0;
    eSourcePassive = 1;
    eSourceLiquid = 2;
}

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

function int StopCurrentAction(int nCommand)
{
    UpdateLandAirMode();
    ResetCamouflageMode();
    StopCurrentActionAttacking();
    if (IsHarvesting())
    {
        CallStopHarvest();
    }
    m_nFindNothingCounter = 0;//jakas komenda
    //resetujemy zeby przy auto nie jechal do byc moze odleglego resource'u
    m_nHarvestSource = eSourceNone;
    m_uResource = null;
    SetHarvestSource(0, 0);
    SetHarvestSource(null);
    m_nHarvestMode = 0;
	return true;
}//|

function void ResetHarvester()
{
    m_nHarvestSource = eSourceNone;
    m_uResource = null;
    m_uRefinery = null;
    SetHarvestSource(0, 0);
    SetHarvestSource(null);
    SetHarvestDestination(null);
}//|

function int MoveToRefinery(int bChooseBest)
{
    int nZ, nAlpha;
    unit uBestRefinery;

    if ((m_uRefinery == null) || !CanTransportResourceToRefinery(m_uRefinery))
    {
        m_uRefinery = FindClosestResourceRefinery();
        SetHarvestDestination(m_uRefinery);
    }
    if (m_uRefinery != null)
    {
        if (bChooseBest)
        {
            uBestRefinery = FindFreeRefinery(m_uRefinery);
            if ((uBestRefinery != null) && (uBestRefinery != m_uRefinery))
            {
                m_uRefinery = uBestRefinery;
                SetHarvestDestination(m_uRefinery);
            }
        }
        GetRefineryTransportResourcePos(m_uRefinery, m_nMoveToX, m_nMoveToY, nZ, nAlpha);
        //lecimy nad budynek zeby nas nie odepchal - potem podlecimy nizej
        CallHelicopterFlyToPoint(m_nMoveToX, m_nMoveToY, nZ + eOneGridSize);
        return true;
    }
    return false;
}//|

//jesli nie mamy ustawionej rafinerii to jej szukamy ale nie jedziemy do niej
function void CheckFindRefinery()
{
    ASSERT(MustTransportResourceToRefinery());
    if ((m_uRefinery == null) || !CanTransportResourceToRefinery(m_uRefinery))
    {
        m_uRefinery = FindClosestResourceRefinery();
        SetHarvestDestination(m_uRefinery);
    }
}//|

function int MoveToResource()
{
    if (m_nHarvestSource == eSourceLiquid)
    {
        ASSERT(CanHarvestLiquidResource(m_nLiquidX, m_nLiquidY));
        FindPositionToHarvestLiquidResource(m_nLiquidX, m_nLiquidY, m_nMoveToX, m_nMoveToY);
        CallHelicopterFlyToPoint(m_nMoveToX, m_nMoveToY, GetAirLiquidHarvestHeight(m_nLiquidX, m_nLiquidY) + 2*eOneGridSize);
        return true;
    }
    if ((m_uResource == null) || !CanHarvestPassiveResource(m_uResource))
    {
        m_uResource = FindNextPassiveResource(m_uResource, m_nLastResourceType);
    }
    if (m_uResource != null)
    {
        m_nHarvestSource = eSourcePassive;
        SetHarvestSource(0, 0);
        SetHarvestSource(m_uResource);
        m_nLastResourceType = GetResourceType(m_uResource);
        FindPositionToHarvestPassiveResource(m_uResource, m_nMoveToX, m_nMoveToY);
        CallHelicopterFlyToPoint(m_nMoveToX, m_nMoveToY, GetAirHarvestHeight(m_uResource) + 2*eOneGridSize);
        return true;
    }
    else
    {
        if (FindLiquidResource(m_nLastResourceType, m_nLiquidX, m_nLiquidY))
        {
            m_nHarvestSource = eSourceLiquid;
            SetHarvestSource(m_nLiquidX, m_nLiquidY);
            SetHarvestSource(null);
            m_nLastResourceType = GetResourceType(m_nLiquidX, m_nLiquidY);
            FindPositionToHarvestLiquidResource(m_nLiquidX, m_nLiquidY, m_nMoveToX, m_nMoveToY);
            MoveToPoint(m_nMoveToX, m_nMoveToY);
            return true;
        }
        else
        {
            m_nHarvestSource = eSourceNone;
            SetHarvestSource(0, 0);
            SetHarvestSource(null);
            return false;
        }
    }
    return false;
}//|

//jesli nie mamy resource'ow to ich szukamy ale nie jedziemy do nich
function void CheckFindResources()
{
    //skopiowane z funkcji powyzej
    if (m_nHarvestSource == eSourceLiquid)
    {
        return;
    }
    if ((m_uResource == null) || !CanHarvestPassiveResource(m_uResource))
    {
        m_uResource = FindNextPassiveResource(m_uResource, m_nLastResourceType);
    }
    if (m_uResource != null)
    {
        m_nHarvestSource = eSourcePassive;
        SetHarvestSource(0, 0);
        SetHarvestSource(m_uResource);
        m_nLastResourceType = GetResourceType(m_uResource);
        return;
    }
    else
    {
        if (FindLiquidResource(m_nLastResourceType, m_nLiquidX, m_nLiquidY))
        {
            m_nHarvestSource = eSourceLiquid;
            SetHarvestSource(m_nLiquidX, m_nLiquidY);
            SetHarvestSource(null);
            m_nLastResourceType = GetResourceType(m_nLiquidX, m_nLiquidY);
            return;
        }
        else
        {
            m_nHarvestSource = eSourceNone;
            SetHarvestSource(0, 0);
            SetHarvestSource(null);
            return;
        }
    }
}//|

function int FindNothingHarvest()
{
    if (m_nHarvestMode == 0)
    {
        return false;
    }
    //funkcja wywolywana co wiecej niz 20 tickow
    if (m_nFindNothingCounter > 0)
    {
        --m_nFindNothingCounter;
        return false;
    }
    m_nFindNothingCounter = 5;
    if (!MustTransportResourceToRefinery() || !HaveFullResources())
    {
        if (MoveToResource())
        {
            ResetCamouflageMode();
            TRACE1("Nothing->MovingToHarvestPos");
            state MovingToHarvestPos;
            SetStateDelay(0);
            return true;
        }
    }
    if (MustTransportResourceToRefinery() && HaveAnyResource())
    {
        if (MoveToRefinery(true))
        {
            ResetCamouflageMode();
            TRACE1("Nothing->MovingToRefinery");
            state MovingToRefinery;
            SetStateDelay(0);
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
    if (FindNothingHarvest())
    {
        //state zmieniony w FindNothingHarvest
    }
    else if (HaveCannonAndCanAttackInCurrentState())
    {
        if (!FindNothingTarget())
        {
            return Nothing;
        }
        //else state ustawiony w FindNothingTarget
    }
}//|

state MovingToHarvestPos
{
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("MovingToHarvestPos");
        return MovingToHarvestPos, 10;
    }
    else
    {
        if ((m_nHarvestSource == eSourcePassive) && !CanHarvestPassiveResource(m_uResource))
        {
            if (MoveToResource())
            {
                TRACE1("MovingToHarvestPos->!Can->MovingToHarvestPos");
                return MovingToHarvestPos, 0;
            }
            else
            {
                TRACE1("MovingToHarvestPos->!Can->Nothing");
                return Nothing, 0;
            }
        }
        ASSERT(IsHelicopterMove());
        if (DistanceTo(m_nMoveToX, m_nMoveToY) >= 0x20)
        {
            TRACE1("MovingToHarvestPos->!point->MovingToHarvestPos");
            MoveToResource();
            return MovingToHarvestPos, 0;
        }
        else if (MustLandNearResource())
        {
            if (CanHelicopterLandInCurrPos())
            {
                TRACE1("MovingToHarvestPos->LandingInHarvestPos");
                if (m_nHarvestSource == eSourcePassive)
                {
                    CallHelicopterLand(GetAngleToResource(m_uResource));
                }
                else
                {
                    ASSERT(m_nHarvestSource == eSourceLiquid);
                    CallHelicopterLand(GetAngleToLiquidResource(m_nLiquidX, m_nLiquidY));
                }
                return LandingInHarvestPos, 0;
            }
            else
            {
                TRACE1("MovingToHarvestPos->!land->MovingToHarvestPos");
                MoveToResource();
                return MovingToHarvestPos, 0;
            }
        }
        else
        {
            TRACE1("MovingToHarvestPos->SettingHeightInHarvestPos");
            if (m_nHarvestSource == eSourcePassive)
            {
                CallHelicopterSetHeight(GetAirHarvestHeight(m_uResource));
            }
            else
            {
                ASSERT(m_nHarvestSource == eSourceLiquid);
                CallHelicopterSetHeight(GetAirLiquidHarvestHeight(m_nLiquidX, m_nLiquidY));
            }
            return SettingHeightInHarvestPos, 0;
        }
    }
}//|

state LandingInHarvestPos
{
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("LandingInHarvestPos");
        return LandingInHarvestPos, 5;
    }
    else
    {
        if (m_nHarvestSource == eSourcePassive)
        {
            if (IsInGoodPlaceToHarvest(m_uResource))
            {
                //zakladamy ze kat juz zmieniony przy ladowaniu
                TRACE1("LandingInHarvestPos->Harvesting");
                CallHarvestPassiveResource(m_uResource);
                return Harvesting, 0;
            }
            else
            {
                //nie udalo sie wyladowac?
                TRACE1("LandingInHarvestPos->MovingToHarvestPos");
                MoveToResource();
                return MovingToHarvestPos, 0;
            }
        }
        else
        {
            ASSERT(m_nHarvestSource == eSourceLiquid);
            if (IsInGoodPlaceToHarvest(m_nLiquidX, m_nLiquidY))
            {
                //zakladamy ze kat juz zmieniony przy ladowaniu
                TRACE1("LandingInHarvestPos->Harvesting");
                CallHarvestLiquidResource(m_nLiquidX, m_nLiquidY);
                return Harvesting, 0;
            }
            else
            {
                //nie udalo sie wyladowac?
                TRACE1("LandingInHarvestPos->MovingToHarvestPos");
                MoveToResource();
                return MovingToHarvestPos, 0;
            }
        }
    }
}//|

state SettingHeightInHarvestPos
{
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("SettingHeightInHarvestPos");
        return SettingHeightInHarvestPos, 5;
    }
    else
    {
        if (m_nHarvestSource == eSourcePassive)
        {
            if (IsInGoodPlaceToHarvest(m_uResource))
            {
                //kata nie trzeba zmieniac
                TRACE1("SettingHeightInHarvestPos->Harvesting");
                CallHarvestPassiveResource(m_uResource);
                return Harvesting, 0;
            }
            else
            {
                //nie udalo sie zejsc na ta wysokosc?
                TRACE1("SettingHeightInHarvestPos->MovingToHarvestPos");
                MoveToResource();
                return MovingToHarvestPos, 0;
            }
        }
        else
        {
            ASSERT(m_nHarvestSource == eSourceLiquid);
            if (IsInGoodPlaceToHarvest(m_nLiquidX, m_nLiquidY))
            {
                //kata nie trzeba zmieniac
                TRACE1("SettingHeightInHarvestPos->Harvesting");
                CallHarvestLiquidResource(m_nLiquidX, m_nLiquidY);
                return Harvesting, 0;
            }
            else
            {
                //nie udalo sie zejsc na ta wysokosc?
                TRACE1("SettingHeightInHarvestPos->MovingToHarvestPos");
                MoveToResource();
                return MovingToHarvestPos, 0;
            }
        }
    }
}//|

state Harvesting
{
    if (IsHarvesting())
    {
        TRACE1("Harvesting");
        return Harvesting, 10;
    }
    else
    {
        if (MustTransportResourceToRefinery() && HaveFullResources())
        {
            if (MoveToRefinery(true))
            {
                TRACE1("Harvesting->MovingToRefinery");
                return MovingToRefinery, 0;
            }
            else
            {
                TRACE1("Harvesting->Nothing");
                return Nothing, 0;
            }
        }
        else
        {
            //zloze wyczerpane, szukamy nowego
            if (MoveToResource())
            {
                TRACE1("Harvesting->MovingToHarvestPos");
                return MovingToHarvestPos, 0;
            }
            else if (MustTransportResourceToRefinery() && HaveAnyResource() && MoveToRefinery(true))
            {
                TRACE1("Harvesting->MovingToRefinery");
                return MovingToRefinery, 0;
            }
            else
            {
                TRACE1("Harvesting->Nothing");
                return Nothing, 0;
            }
        }
    }
}//|

state MovingToRefinery
{
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("MovingToRefinery");
        return MovingToRefinery, 5;
    }
    else
    {
        if (!CanTransportResourceToRefinery(m_uRefinery))
        {
            if (MoveToRefinery(true))
            {
                TRACE1("MovingToRefinery->MovingToRefinery");
                return MovingToRefinery, 5;
            }
            else
            {
                TRACE1("MovingToRefinery->Nothing");
                return Nothing, 0;
            }
        }
        ASSERT(IsHelicopterMove());
        if (DistanceTo(m_nMoveToX, m_nMoveToY) >= 0x20)
        {
            TRACE1("MovingToRefinery->!point->MovingToRefinery");
            MoveToRefinery(false);
            return MovingToRefinery, 0;
        }
        else
        {
            TRACE1("MovingToRefinery->StartSettingHeightInRefinery");
            return StartSettingHeightInRefinery, 0;

        }
    }
}//|

state StartSettingHeightInRefinery
{
    int nZ, nAlpha;
    unit uBestRefinery;

    if (!CanTransportResourceToRefinery(m_uRefinery))
    {
        if (MoveToRefinery(true))
        {
            TRACE1("StartSettingHeightInRefinery->MovingToRefinery");
            return MovingToRefinery, 5;
        }
        else
        {
            TRACE1("StartSettingHeightInRefinery->Nothing");
            return Nothing, 0;
        }
    }
    if (!IsOtherHarvesterPuttingResourceToRefinery(m_uRefinery))
    {
        GetRefineryTransportResourcePos(m_uRefinery, m_nMoveToX, m_nMoveToY, nZ, nAlpha);
        CallHelicopterSetHeight(nZ, nAlpha);
        return SettingHeightInRefinery, 0;
    }
    else
    {
        //probujemy poszukac innej
        uBestRefinery = FindFreeRefinery(m_uRefinery);
        if ((uBestRefinery != null) && (uBestRefinery != m_uRefinery))
        {
            m_uRefinery = uBestRefinery;
            SetHarvestDestination(m_uRefinery);
            MoveToRefinery(false);
            TRACE1("StartSettingHeightInRefinery->MovingToRefinery");
            return MovingToRefinery, 5;
        }
        return StartSettingHeightInRefinery, 15;
    }
}//|

state SettingHeightInRefinery
{
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("SettingHeightInRefinery");
        return SettingHeightInRefinery, 5;
    }
    else
    {
        if (IsInGoodPlaceToPutResourceToRefinery(m_uRefinery))
        {
            //zakladamy ze kat juz zmieniony przy ladowaniu
            TRACE1("SettingHeightInRefinery->PuttingResourceToRefinery");
            CallPutResourceToRefinery(m_uRefinery);
            return PuttingResourceToRefinery, 0;
        }
        else
        {
            //nie udalo sie wyladowac?
            TRACE1("SettingHeightInRefinery->MovingToRefinery");
            MoveToRefinery(false);
            return MovingToRefinery, 0;
        }
    }
}//|

state PuttingResourceToRefinery
{
    if (IsPuttingResourceToRefinery())
    {
        TRACE1("PuttingResourceToRefinery");
        return PuttingResourceToRefinery, 5;
    }
    else
    {
        //jesli nie udalo sie (prawie) nic wrzucic do magazynow to odlatujemy na bok i czekamy
        if (GetResourcesSizePercent() > 95)
        {
            TRACE1("PuttingResourceToRefinery->RaiseWaitingToPutResourceToRefinery");
            CallHelicopterRaise();
            return RaiseWaitingToPutResourceToRefinery;
        }
        if (MoveToResource())
        {
            TRACE1("PuttingResourceToRefinery->MovingToHarvestPos");
            return MovingToHarvestPos, 0;
        }
        else
        {
            return Nothing, 0;
        }
    }
}//|

state RaiseWaitingToPutResourceToRefinery
{
    if (IsMoving() || IsStartingMoving())
    {
        TRACE1("RaiseWaitingToPutResourceToRefinery");
        return RaiseWaitingToPutResourceToRefinery, 5;
    }
    else
    {
        CallMoveToPoint(GetLocationX(), GetLocationY() + G2A(2));
        TRACE1("RaiseWaitingToPutResourceToRefinery->WaitingToPutResourceToRefinery");
        return WaitingToPutResourceToRefinery, 5;
    }
}//|

state WaitingToPutResourceToRefinery
{
    CheckFindRefinery();
    if (m_uRefinery == null)
    {
        TRACE1("WaitingToPutResourceToRefinery->Nothing");
        return Nothing;
    }
    if (CanPutAnyResourceToRefinery(m_uRefinery))
    {
        TRACE1("WaitingToPutResourceToRefinery->MovingToRefinery");
        MoveToRefinery(true);
        return MovingToRefinery, 0;
    }
    else
    {
        TRACE1("WaitingToPutResourceToRefinery->WaitingToPutResourceToRefinery");
        return WaitingToPutResourceToRefinery, 40;
    }
}//|

////    Events    ////

//sprawdza czy lecimy/wrzucamy resource'y do rafinerii uRefinery
event IsMovingOrPuttingToRefinery(unit uRefinery, int bOnlyLanding)
{
    if ((uRefinery == m_uRefinery) &&
        ((!bOnlyLanding && ((state == MovingToRefinery) || (state == StartSettingHeightInRefinery))) || 
         (state == SettingHeightInRefinery) ||
         (state == PuttingResourceToRefinery)))
    {
        return true;
    }
    return false;
}//|

////    Commands    ////

command HarvestPassiveResource(unit uRes) hidden
{
    unit uResource;
    unit uResource2;

    uResource = uRes;
    if (!CanHarvestPassiveResource(uResource))
    {
        return false;
    }
    CHECK_STOP_CURR_ACTION(eCommandHarvestPassiveResource);
    m_nHarvestMode = 1;
    if (IsOtherHarvesterHarvestResource(uResource))
    {
        uResource2 = FindNextPassiveResource(uResource, GetResourceType(uResource));
        if (uResource2 != null )
        {
            uResource = uResource2;
        }
    }

    m_uResource = uResource;
   	m_nHarvestSource = eSourcePassive;
    SetHarvestSource(0, 0);
	SetHarvestSource(m_uResource);

    m_nLastResourceType = GetResourceType(m_uResource);
    if (!MustTransportResourceToRefinery() || !HaveFullResources() || CanResetOtherResources(m_uResource))
    {
        //jesli mamy juz full ale nic nie mozemy wrzucic to lecimy do resource'a i przy rozpoczeciu harvestowania
        //zresetujemy resource'y ktorych nie mozemy wrzucic
        MoveToResource();
        //jesli nie mamy rafinerii to od razu szukamy aby unit zniknal z listy
        if (MustTransportResourceToRefinery())
        {
            CheckFindRefinery();
        }
        state MovingToHarvestPos;
    }
    else
    {
        if (MoveToRefinery(true))
        {
            state MovingToRefinery;
        }
        else
        {
            state Nothing;
        }
    }
    SetStateDelay(0);
    EndCommand(true);
    return true;
}//|

command HarvestLiquidResource(int nX, int nY) hidden
{
    int nX2, nY2;

    nX = G2AMID(A2G(nX));//wyrownanie do srodka kratki
    nY = G2AMID(A2G(nY));
    if (!CanHarvestLiquidResource(nX, nY))
    {
        return false;
    }
    if (IsOtherHarvesterHarvestResource(nX, nY))
    {
        if (FindLiquidResource(GetResourceType(nX, nY), nX, nY, nX2, nY2))
        {
				nX = nX2;
            	nY = nY2;
        }
    }
    if (MustLandNearResource())
    {
        if (!FindLiquidNearBank(nX, nY))
        {
            return false;
        }
    }
    CHECK_STOP_CURR_ACTION(eCommandHarvestLiquidResource);
    m_nHarvestMode = 1;
    m_uResource = null;
    m_nLiquidX = nX;
    m_nLiquidY = nY;
    m_nHarvestSource = eSourceLiquid;
	SetHarvestSource(m_nLiquidX, m_nLiquidY);
    SetHarvestSource(null);
    m_nLastResourceType = GetResourceType(m_nLiquidX, m_nLiquidY);
    if (!MustTransportResourceToRefinery() || !HaveFullResources() || CanResetOtherResources(m_nLiquidX, m_nLiquidY))
    {
        MoveToResource();
        //jesli nie mamy rafinerii to od razu szukamy aby unit zniknal z listy
        if (MustTransportResourceToRefinery())
        {
            CheckFindRefinery();
        }
        state MovingToHarvestPos;
    }
    else
    {
        if (MoveToRefinery(true))
        {
            state MovingToRefinery;
        }
        else
        {
            state Nothing;
        }
    }
    SetStateDelay(0);
    EndCommand(true);
    return true;
}//|

command SetResourceRefinery(unit uRefinery) hidden
{
    if (!MustTransportResourceToRefinery() || !CanTransportResourceToRefinery(uRefinery))
    {
        return false;
    }
    CHECK_STOP_CURR_ACTION(eCommandSetResourceRefinery);
    m_nHarvestMode = 1;
    m_uRefinery = uRefinery;
    SetHarvestDestination(m_uRefinery);
    if (HaveAnyResource() && MoveToRefinery(true))
    {
        //jesli nie mamy ustawionych resource'ow to od razu szukamy aby unit zniknal z listy
        CheckFindResources();
        state MovingToRefinery;
        SetStateDelay(0);
    }
    else if (!HaveFullResources() && MoveToResource())
    {
        TRACE1("PuttingResourceToRefinery->MovingToHarvestPos");
        state MovingToHarvestPos;
        SetStateDelay(0);
    }
    EndCommand(true);
    return true;
}//|

command Initialize()
{
    m_nLastResourceType = -1;
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
        ResetHarvester();
    }
    return true;
}//|
}
