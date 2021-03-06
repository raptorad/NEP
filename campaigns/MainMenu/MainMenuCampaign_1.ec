campaign "MainMenuCampaign_1"
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
	CreateGamePlayer(3, 3, eRaceLC, true);
    SetLoadMissionsCount(1);

	i = Rand(3);
	if(i==1)
		LoadMission("Levels\\!MainMenu_02_1.lnd", "Scripts\\Campaigns\\MainMenu\\Missions\\M_Mission_02.eco", 0);
	else if(i==2)
		LoadMission("Levels\\!MainMenu_02_2.lnd", "Scripts\\Campaigns\\MainMenu\\Missions\\M_Mission_02.eco", 0);
	else
		LoadMission("Levels\\!MainMenu_02_3.lnd", "Scripts\\Campaigns\\MainMenu\\Missions\\M_Mission_02.eco", 0);
    
	//LoadMission("Levels\\!MainMenu_07.lnd", "Scripts\\Campaigns\\MainMenu\\Missions\\M_Mission_07.eco", 0);
	/*
	i = Rand(3);
	if(i==1)
		LoadMission("Levels\\!MainMenu_01.lnd", "Scripts\\Campaigns\\MainMenu\\Missions\\M_Mission_01.eco", 0);
	else if(i==2)
		LoadMission("Levels\\!MainMenu_02.lnd", "Scripts\\Campaigns\\MainMenu\\Missions\\M_Mission_02.eco", 0);
	else
		LoadMission("Levels\\!MainMenu_03.lnd", "Scripts\\Campaigns\\MainMenu\\Missions\\M_Mission_03.eco", 0);

  */
    SetActiveWorld(0);

	return Nothing;
}

state Nothing
{
	return Nothing, 0;
}
}
