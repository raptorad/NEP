campaign "translateCampaignED"
{
    #include "..\\commonCampaign.ech"

    function void CreateGamePlayer()
    {
	    CreateGamePlayer(2, 2, eRaceED, true);
    }

    function void RegisterMissions()
    {
        RegisterMission(1, "Levels\\!ED_NEP_M1.lnd", "Scripts\\Campaigns\\ED\\Missions\\ED_NEP_M1.eco", "translateE_M1_Name", "translateE_M1_Description", "", 0);
        RegisterMission(2, "Levels\\!ED_NEP_M2.lnd", "Scripts\\Campaigns\\ED\\Missions\\ED_NEP_M2.eco", "translateE_M2_Name", "translateE_M2_Description", "", 0);
        RegisterMission(3, "Levels\\!ED_NEP_M3.lnd", "Scripts\\Campaigns\\ED\\Missions\\ED_NEP_M3.eco", "translateE_M3_Name", "translateE_M3_Description", "", 0);
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
