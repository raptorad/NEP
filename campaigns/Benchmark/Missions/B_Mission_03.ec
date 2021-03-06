mission "Invasion"
{
	state Initialize;
	state End;
	
	

state Initialize
{
	int nTicks;
	ShowInterface(false);
	EnableInterface(false);
	SetWind(60,100);//strenght[0-100],Direction[0-255]
	
	nTicks = PlayCutscene("BM_Army.trc", false, false, false);
	return End, nTicks;
}

state End
{
    EndMission(0);
}

}
