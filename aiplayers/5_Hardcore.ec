player "translateAIPlayerHardcore"
{
////    Declarations    ////

state Initialize;
state Nothing;

#include "AIParameters.ech"

////    States    ////

state Initialize
{
	//SetName("Hardcore");

	InitAIParameters(eLevelHardcore);

    return Nothing;
}//|

state Nothing
{
	AIWork(eLevelHardcore);

	return Nothing, 60;
}//|

event AIPlayerFlags()
{
    return 0x0F;
}//|
}
