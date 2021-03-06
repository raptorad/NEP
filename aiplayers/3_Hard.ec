player "translateAIPlayerHard"
{
////    Declarations    ////

state Initialize;
state Nothing;

#include "AIParameters.ech"

////    States    ////

state Initialize
{
	//SetName("translateAIPlayerHard");

	InitAIParameters(eLevelHard);

    return Nothing;
}//|

state Nothing
{
	AIWork(eLevelHard);
	return Nothing, 60;
}//|

event AIPlayerFlags()
{
    return 0x0F;
}//|
}
