campaign "translateCampaignED"
{
    #include "..\\commonCampaign.ech"
    function void CreateGamePlayer()
    {
	    CreateGamePlayer(2, 2, eRaceED, true);
    }

    function void RegisterMissions()//UWAGA! Przed premierą przenieś mapy z 'levels\\Editor' do 'levels' 
    {
        RegisterMission(1, "Levels\\Editor\\ed1.lnd", "Scripts\\Campaigns\\ED\\Missions\\ED1.eco", "translateE_M1_Name", "translateE_M1_Description", "", 0);
        RegisterMission(2, "Levels\\Editor\\ed2.lnd", "Scripts\\Campaigns\\ED\\Missions\\ED2.eco", "translateE_M2_Name", "translateE_M2_Description", "", 0);
        RegisterMission(3, "Levels\\Editor\\ed3.lnd", "Scripts\\Campaigns\\ED\\Missions\\ED3.eco", "translateE_M3_Name", "translateE_M3_Description", "", 0);
		RegisterMission(3, "Levels\\Editor\\ed3.lnd", "Scripts\\Campaigns\\ED\\Missions\\ED4.eco", "translateE_M3_Name", "translateE_M3_Description", "", 0);
    }

    function int GetNextMissions(int arrNextNumbers[])
    {
        if (!IsMissionDone(1))
        {
            //pierwsza misja
            arrNextNumbers.Add(1);
        }
        if (!IsMissionDone(2))
        {
            arrNextNumbers.Add(2);
        }
        if (!IsMissionDone(3))
        {
            arrNextNumbers.Add(3);
        }

        if (arrNextNumbers.GetSize() > 0)
        {
            return false;
        }
        //else 1-5 done

        return true;
    }
}
