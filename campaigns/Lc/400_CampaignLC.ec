campaign "translateNEPCampaignLC"
{
    #include "..\\commonCampaign.ech"

    function void CreateGamePlayer()
    {
	    CreateGamePlayer(3, 3, eRaceLC, true);
    }

    function void RegisterMissions()
    {
        RegisterMission(1, "Levels\\prolog.lnd", "Scripts\\Campaigns\\LC\\Missions\\LC_PROLOG.eco", "translateL_PROLOG_Name", "translateLC_PROLOG_INTRO", "", 0);
		RegisterMission(2, "Levels\\fps.lnd", "Scripts\\Campaigns\\LC\\Missions\\LC_NEP_M1.eco", "translateLC_M1_Name", "translateLC_M1_INTRO", "", 0);
        RegisterMission(3, "Levels\\lc2.lnd", "Scripts\\Campaigns\\LC\\Missions\\LC_NEP_M2.eco", "translateLC_M2_Name", "translateLC_M2_INTRO", "", 53);
        RegisterMission(4, "Levels\\lc3.lnd", "Scripts\\Campaigns\\LC\\Missions\\LC_NEP_M3.eco", "translateLC_M3_Name", "translateLC_M3_INTRO", "", 53);
        RegisterMission(5, "Levels\\lc4.lnd", "Scripts\\Campaigns\\LC\\Missions\\LC_NEP_M4.eco", "translateLC_M4_Name", "translateLC_M4_INTRO", "", 0);
    }

    function int GetNextMissions(int arrNextNumbers[])
    {
        if (!IsMissionDone(1))
        {
            //pierwsza misja
            arrNextNumbers.Add(1);
			return false;
        }
        if (!IsMissionDone(2))
        {
            arrNextNumbers.Add(2);
			return false;
        }
        if (!IsMissionDone(3))
        {
            arrNextNumbers.Add(3);
			return false;
        }
 	     if (!IsMissionDone(4))
        {
            arrNextNumbers.Add(4);
			return false;
        }
        if (!IsMissionDone(5))
        {
            arrNextNumbers.Add(5);
			return false;
        }

        return true;
    }
}
