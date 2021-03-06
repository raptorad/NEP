player "translateAIPlayerEasy"
{
////    Declarations    ////

state Initialize;
state Nothing;

#include "..\\AIParameters.ech"

////    States    ////

state Initialize
{
	//SetName("translateAIPlayerEasy");

	InitAIParameters(eLevelEasy);

    return Nothing;
}//|

state Nothing
{
	AIWork(eLevelEasy);
    return Nothing, 60;
}//|

event AIPlayerFlags()
{
    return 0x0F;
}//|
}
