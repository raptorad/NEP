campaign "Space battle"
{
consts
{
    eRaceUCS = 1;
    eRaceED = 2;
    eRaceLC = 3;
    eRaceAlien = 4;
}
state Initialize;
state Nothing;

state Initialize
{
	int i;
    CreateGamePlayer(1, 1, eRaceUCS, false);
	CreateGamePlayer(2, 2, eRaceED, true);
	CreateGamePlayer(3, 3, eRaceLC, false);
    SetLoadMissionsCount(1);

    LoadMission("Levels\\!Benchmark2.lnd", "Scripts\\Campaigns\\Benchmark\\Missions\\B_Mission_02.eco", 0);
    SetActiveWorld(0);

	return Nothing;
}

state Nothing
{
	return Nothing, 0;
}

event EndMission(int nWorldNum, int nResult)
{
	EndGame();
}

}
