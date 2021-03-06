campaign "translateCampaignAL"
{
    #include "..\\commonCampaign.ech"

    function void CreateGamePlayer()
    {
	    CreateGamePlayer(4, 4, eRaceAlien, true);
    }

    function void RegisterMissions()
    {
        RegisterMission(1, "Levels\\!AL_M1.lnd", "Scripts\\Campaigns\\ALIEN\\Missions\\A_C1_Mission_01.eco", "translateA_M1_Name", "translateA_M1_Description", "", 0);
        RegisterMission(2, "Levels\\!AL_M2.lnd", "Scripts\\Campaigns\\ALIEN\\Missions\\A_C1_Mission_02.eco", "translateA_M2_Name", "translateA_M2_Description", "", 0);
        RegisterMission(3, "Levels\\!AL_M3.lnd", "Scripts\\Campaigns\\ALIEN\\Missions\\A_C1_Mission_03.eco", "translateA_M3_Name", "translateA_M3_Description", "", 0);
        RegisterMission(4, "Levels\\!AL_M4.lnd", "Scripts\\Campaigns\\ALIEN\\Missions\\A_C1_Mission_04.eco", "translateA_M4_Name", "translateA_M4_Description", "Interface\\Campaign\\A_M4.prt", 55);
        RegisterMission(5, "Levels\\!AL_M5.lnd", "Scripts\\Campaigns\\ALIEN\\Missions\\A_C1_Mission_05.eco", "translateA_M5_Name", "translateA_M5_Description", "Interface\\Campaign\\A_M5.prt", 55);
        RegisterMission(6, "Levels\\!AL_M6.lnd", "Scripts\\Campaigns\\ALIEN\\Missions\\A_C1_Mission_06.eco", "translateA_M6_Name", "translateA_M6_Description", "Interface\\Campaign\\A_M6.prt", 55);
        RegisterMission(7, "Levels\\!AL_M7.lnd", "Scripts\\Campaigns\\ALIEN\\Missions\\A_C1_Mission_07.eco", "translateA_M7_Name", "translateA_M7_Description", "", 0);
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
		
        }
        if (!IsMissionDone(5))
        {
            arrNextNumbers.Add(5);
		
        }
        if (!IsMissionDone(6))
        {
            arrNextNumbers.Add(6);
        
        }
		if (arrNextNumbers.GetSize() > 0)
        {
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
	    "Scripts\\Campaigns\\UCS\\300_CampaignUCS.eco",
    multi:
	    ""
    }
    command RequiredCampaigns() button requiredCampaigns
    {
        return true;
    }
}
