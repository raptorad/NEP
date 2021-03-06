player "translateAIPlayerEasy"
{
////    Declarations    ////
state Initialize;
state Nothing;

#include "AIParameters3.ech"


////    States    ////

state Initialize
{
	//SetName("translateAIPlayerEasy");

	InitAIParameters(eLevelEasy);

    return Nothing;
}//|

state Nothing
{
    return Nothing, 60;
}//|

event AIPlayerFlags()
{
    return 0x0F;
}//|
}
