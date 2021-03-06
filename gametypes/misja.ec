int n;
#ifndef creator

for(n=1 , n<8 , ++n)
	{
		pPlayer.CreateObject("E_CH_AH_12", nX+1, nY, 0, 0);
		pPlayer.CreateObject("E_CH_AH_12", nX, nY, 0, 0);
		pPlayer.CreateObject("E_CH_AH_12", nX-1, nY, 0, 0);
	}	
	
#endif
