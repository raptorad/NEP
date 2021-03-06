player "User"
{
////    Declarations    ////

state Initialize;
state Nothing;

#include "..\\AIParameters.ech"

/*
    eAgentAIRecon                  AI od patrolowania bazy i swiata - buduje najszybsze jednostki i rozsy�a je po planszy.
    eAgentAIHarvest                AI od szaftow - sam buduje i wysy�a harwestery oraz kopalnie.
    eAgentAIUnitsConstructor       AI od modeli - sama sk�ada kolejne modele pojazd�w.
    eAgentAIPower                  AI od pr�du - prze�acza zasilanie do tych budynk�w kt�re go aktualnie potrzebuja. Przydatny w czasie niedoboru pr�du. Buduje elektrownie jesli sa potrzebne.
    eAgentAIAttackEnemy            AI od atak�w wroga - buduje jednostki i przeprowadza nimi ataki na wroga. Potrafi mu uporzykrzyc zycie.
    eAgentAIResearches             AI od wynalazk�w - sama w�acza kolejne wynalazki. Szpieguje innych graczy i w�acza odpowiednie wynalazki na podstawie zebranych danych.
    eAgentAIBuildBase              AI od budowania bazy. Buduje baz� za gracza. Aby sterowac  szybkoscia budowy mozna zmienic priorytety wydawania kasy.
    eAgentAICannonsUpgrade         AI od swich'a wiezyczek- zmienia bro� na wiezyczkach w zaleznosci od potrzeb - upgrade za darmo.
*/

function void SetAgentAIType(int nAgentAIType)
{
	SetAIControlOptions(eAIControlTurnOn, true);

    if (nAgentAIType == eAgentAIRecon)
    {
        SetAIControlOptions(eAIControlPatrols, true);		//kontroluje(buduje) plutony do patrolowania (bazy, swiata)
    }
    else if (nAgentAIType == eAgentAIHarvest)
    {
        SetAIControlOptions(eAIControlResources, true);		//kontroluje(buduje) harvesterki, kopalnie
    }
    else if (nAgentAIType == eAgentAIUnitsConstructor)
    {
        //!! eAIControlConstructUnits
		SetAIControlOptions(eAIControlConstructUnits, true);
    }
    else if (nAgentAIType == eAgentAIPower)
    {
        SetAIControlOptions(eAIControlBasePower, true);		//kontroluje(buduje) elektrownie
    }
    else if (nAgentAIType == eAgentAIAttackEnemy)
    {
        SetAIControlOptions(eAIControlAttack | eAIControlDefence | eAIControlSupply | eAIControlRepairing, true);
    }
    else if (nAgentAIType == eAgentAIResearches)
    {
        SetAIControlOptions(eAIControlResearches | eAIControlSpyEnemies, true);	//kontroluje wymyslanie wynalazkow
    }
    else if (nAgentAIType == eAgentAIBuildBase)
    {
        SetAIControlOptions(eAIControlBuildBase | eAIControlBasePower, true);	//buduje wiezyczki, magazyny, standardowe budynki (oprocz fabryk i kopalni)
    }
    else if (nAgentAIType == eAgentAICannonsUpgrade)
    {
        SetAIControlOptions(eAIControlUpgradeCannons, true);
    }
	else
	{
		SetAIControlOptions(eAIControlTurnOn, false);
	}
}//����������������������������������������������������������������������������������������������������|

function void UpdateAgentAITypes()
{
    int nIndex;
    int nAgentAITypes;

    SetAIControlOptions(eAIControlAll, false);

    nAgentAITypes = GetAgentAITypes();
    for (nIndex = 0; nIndex < 32; ++nIndex)
    {
        if (nAgentAITypes & (1 << nIndex))
        {
            SetAgentAIType(1 << nIndex);
        }
    }
}//����������������������������������������������������������������������������������������������������|

////    States    ////

state Initialize
{
	UpdateAgentAITypes();

	InitAIParameters(eLevelMedium);

    return Nothing;
}//����������������������������������������������������������������������������������������������������|

state Nothing
{
	return Nothing, 60;
}//����������������������������������������������������������������������������������������������������|

event AIPlayerFlags()
{
    return 0x00;
}//����������������������������������������������������������������������������������������������������|

event ChangedAgentAITypes(int nOldAgentAITypes, int nNewAgentAITypes)
{
    UpdateAgentAITypes();
}//����������������������������������������������������������������������������������������������������|
}

