campaign "translateCampaignUCS"
{
    #include "..\\commonCampaign.ech"

    function void CreateGamePlayer()
    {
	    CreateGamePlayer(1, 1, eRaceUCS, true);
    }

    function void RegisterMissions()
    {
        RegisterMission(1, "Levels\\!UCS_M1.lnd", "Scripts\\Campaigns\\UCS\\Missions\\U_C1_Mission_01.eco", "translateU_M1_Name", "translateU_M1_Description", "", 0);
        RegisterMission(2, "Levels\\!UCS_M2.lnd", "Scripts\\Campaigns\\UCS\\Missions\\U_C1_Mission_02.eco", "translateU_M2_Name", "translateU_M2_Description", "", 0);
        RegisterMission(3, "Levels\\!UCS_M3.lnd", "Scripts\\Campaigns\\UCS\\Missions\\U_C1_Mission_03.eco", "translateU_M3_Name", "translateU_M3_Description", "Interface\\Campaign\\U_M3.prt", 54);
        RegisterMission(4, "Levels\\!UCS_M4.lnd", "Scripts\\Campaigns\\UCS\\Missions\\U_C1_Mission_04.eco", "translateU_M4_Name", "translateU_M4_Description", "Interface\\Campaign\\U_M4.prt", 54);
        RegisterMission(5, "Levels\\!UCS_M5.lnd", "Scripts\\Campaigns\\UCS\\Missions\\U_C1_Mission_05.eco", "translateU_M5_Name", "translateU_M5_Description", "Interface\\Campaign\\U_M5.prt", 54);
        RegisterMission(6, "Levels\\!UCS_M6.lnd", "Scripts\\Campaigns\\UCS\\Missions\\U_C1_Mission_06.eco", "translateU_M6_Name", "translateU_M6_Description", "", 0);
        RegisterMission(7, "Levels\\!UCS_M7.lnd", "Scripts\\Campaigns\\UCS\\Missions\\U_C1_Mission_07.eco", "translateU_M7_Name", "translateU_M7_Description", "", 0);
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
        }
        if (!IsMissionDone(4))
        {
            arrNextNumbers.Add(4);
		}
        if (!IsMissionDone(5))
        {
            arrNextNumbers.Add(5);
		}
		if (arrNextNumbers.GetSize() > 0)
        {
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

    enum requiredCampaigns
    {
	    "Scripts\\Campaigns\\ED\\100_CampaignED.eco",
	    "Scripts\\Campaigns\\LC\\200_CampaignLC.eco",
    multi:
	    ""
    }
    command RequiredCampaigns() button requiredCampaigns
    {
        return true;
    }
}
