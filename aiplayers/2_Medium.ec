player "translateAIPlayerMedium"
{
////    Declarations    ////

state Initialize;
state Nothing;

#include "AIParameters.ech"

////    States    ////

state Initialize
{
	//SetName("translateAIPlayerMedium");

	InitAIParameters(eLevelMedium);

    return Nothing;
}//|

state Nothing
{
	AIWork(eLevelMedium);
    return Nothing, 60;
}//|

event AIPlayerFlags()
{
    return 0x0F;
}//|
}
