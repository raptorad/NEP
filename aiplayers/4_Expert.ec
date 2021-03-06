player "translateAIPlayerExpert"
{
////    Declarations    ////

state Initialize;
state Nothing;

#include "AIParameters.ech"

////    States    ////

state Initialize
{
	//SetName("translateAIPlayerExpert");

	InitAIParameters(eLevelExpert);

    return Nothing;
}//|

state Nothing
{
	AIWork(eLevelExpert);
	return Nothing, 60;
}//|

event AIPlayerFlags()
{
    return 0x0F;
}//|
}
