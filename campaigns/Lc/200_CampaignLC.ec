campaign "translateCampaignLC"
{
    #include "..\\commonCampaign.ech"

    function void CreateGamePlayer()
    {
	    CreateGamePlayer(3, 3, eRaceLC, true);
    }

    function void RegisterMissions()
    {
        RegisterMission(1, "Levels\\fps.lnd", "Scripts\\Campaigns\\LC\\Missions\\LC_NEP_M1.eco", "translateL_M1_Name", "translateL_M1_Description", "", 0);
        RegisterMission(2, "Levels\\!LC_M2.lnd", "Scripts\\Campaigns\\LC\\Missions\\LC_NEP_M2.eco", "translateL_M2_Name", "translateL_M2_Description", "Interface\\Campaign\\L_M2.prt", 53);
        RegisterMission(3, "Levels\\lc3.lnd", "Scripts\\Campaigns\\LC\\Missions\\L_C1_Mission_03.eco", "translateL_M3_Name", "translateL_M3_Description", "Interface\\Campaign\\L_M3.prt", 53);
        RegisterMission(4, "Levels\\!LC_M4.lnd", "Scripts\\Campaigns\\LC\\Missions\\L_C1_Mission_04.eco", "translateL_M4_Name", "translateL_M4_Description", "", 0);
        RegisterMission(5, "Levels\\!LC_M5.lnd", "Scripts\\Campaigns\\LC\\Missions\\L_C1_Mission_05.eco", "translateL_M5_Name", "translateL_M5_Description", "", 0);
        RegisterMission(6, "Levels\\!LC_M6.lnd", "Scripts\\Campaigns\\LC\\Missions\\L_C1_Mission_06.eco", "translateL_M6_Name", "translateL_M6_Description", "", 0);
        RegisterMission(7, "Levels\\!LC_M7.lnd", "Scripts\\Campaigns\\LC\\Missions\\L_C1_Mission_07.eco", "translateL_M7_Name", "translateL_M7_Description", "", 0);
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
        }
        if (!IsMissionDone(3))
        {
            arrNextNumbers.Add(3);
        }
        if (arrNextNumbers.GetSize() > 0)
        {
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
        if (!IsMissionDone(6))
        {
            arrNextNumbers.Add(6);
            return false;
        }
        if (!IsMissionDone(7))
        {
            arrNextNumbers.Add(7);
            return false;
        }
        return true;
    }
}
