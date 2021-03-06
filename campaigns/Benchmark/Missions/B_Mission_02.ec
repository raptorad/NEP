mission "Space battle"
{
	state Initialize;
	state End;
	
	

state Initialize
{
	int nTicks;
	ShowInterface(false);
	EnableInterface(false);
	SetWind(0,100);//strenght[0-100],Direction[0-255]
	
	nTicks = PlayCutscene("BM_SpaceBattle.trc", false, false, false);
	return End, nTicks;
}

state End
{
    EndMission(0);
}

}
