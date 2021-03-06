mission "Ground battle"
{
	#include "..\..\common.ech"
	state Initialize;
	state PlayBenchmark;
	state End;
	state End1;

	player m_pLC;
	player m_pED;
	player m_pPlayer;	


	int nTicks;
	int nTimer;

function void CommandAttackMoveUnitFromMarkerToMarker(int nMarker1, int nMarker2)
{
	int nGx, nGy;
	unit uUnit;

	uUnit = GetUnitAtMarker(nMarker1);
	
	ASSERT(uUnit != null);

	VERIFY(GetMarker(nMarker2, nGx, nGy));

	uUnit.CommandMoveAttack(G2AMID(nGx), G2AMID(nGy));
}
state Initialize
{
	int nGx, nGy, i;
	m_pPlayer = GetPlayer(2);
	m_pED = GetPlayer(1);
	m_pLC = GetPlayer(3);

	m_pED.SetEnemy(m_pLC);
	m_pLC.SetEnemy(m_pED);
	
	SetAlly(m_pPlayer,m_pED);
	SetAlly(m_pPlayer,m_pLC);

	for(i= 1;i< 5;i=i+1)   CreatePlayerObjectAtMarker(m_pLC, "L_CH_AJ_01_1#L_WP_EL_01_3,L_AR_CH_01_1,L_EN_NO_01_1,L_IE_SG_01_3", i);
	for(i= 6;i<10;i=i+1)	CreatePlayerObjectAtMarker(m_pLC, "L_CH_GT_04_1#L_WP_PB_04_2,L_AR_CH_04_1,L_EN_NO_04_1,L_IE_SG_04_3", i);
	for(i=11;i<15;i=i+1)	CreatePlayerObjectAtMarker(m_pLC, "L_CH_AT_03_1#L_WP_PB_03_1,L_AR_CH_03_1,L_EN_NO_03_1,L_IE_SG_01_3", i);
	for(i=16;i<19;i=i+1)	CreatePlayerObjectAtMarker(m_pLC, "L_CH_GT_06_1#L_WP_MP_06_3#L_WP_SG_06_1,L_WP_MP2_06_3,L_WP_MP2_06_3,L_AR_RL_06_1,L_EN_PR_06_1,L_IE_SG_04_3", i);

	for(i=20;i<24;i=i+1)	CreatePlayerObjectAtMarker(m_pED, "E_CH_AJ_01_1#E_WP_SL_01_1,E_AR_CH_01_1,E_EN_SP_01_1,E_IE_SG_01_3", i);
	for(i=25;i<30;i=i+1)	CreatePlayerObjectAtMarker(m_pED, "E_CH_GT_05_1#E_WP_HL_05_1,E_AR_CH_05_1,E_EN_NO_05_1,E_IE_SG_04_3", i);
	for(i=31;i<35;i=i+1)	CreatePlayerObjectAtMarker(m_pED, "E_CH_GJ_03_1#E_WP_AR_03_1,E_AR_CH_03_1,E_EN_SP_03_1,E_IE_SG_01_3", i);
	for(i=36;i<39;i=i+1)	CreatePlayerObjectAtMarker(m_pED, "E_CH_GT_04_1#E_WP_CA_04_1,E_AR_CH_04_3,E_EN_SP_04_1,E_IE_SG_04_3", i);

	ShowInterface(false);
	EnableInterface(false);
	SetWind(60,100);//strenght[0-100],Direction[0-255]
	
	nTicks = PlayCutscene("Benchmark.trc", false, false, false) - 30*10;
	PlayMusic("Music\\Earth_AL.ogg", true);
	return PlayBenchmark, 30*10;
}

state PlayBenchmark
{
	int i;
	SetWind(20,100);
	for(i=1;i<=40;i=i+1)
	{
		CommandAttackMoveUnitFromMarkerToMarker(i,41);
	}
	return End1, nTicks-100;
}
state End1
{
	ShowInterface(false);
	return End, 60;
}

state End
{
        EndMission(0);
    
}

}
