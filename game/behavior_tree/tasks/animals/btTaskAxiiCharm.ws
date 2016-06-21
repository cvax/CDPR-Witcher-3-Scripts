/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTTaskAxiiCharmMonitor extends IBehTreeTask
{
	var wasCharmed : bool;
	var removeCharmCooldown : float;
	
	default wasCharmed = false;
	
	latent function Main() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		
		while( true )
		{
			Sleep(1.0);
			CharmCheck();
			
			if( wasCharmed == true && removeCharmCooldown > 0 )
			{
				Sleep( removeCharmCooldown );
				wasCharmed = false;
			}
		}
		return BTNS_Active;
	}
	
	function CharmCheck() : bool
	{
		var owner : CActor = GetActor();
		
		if( owner.HasBuff(EET_Confusion) ||
			owner.HasBuff(EET_AxiiGuardMe))
		{
			return true;
		}
		return false;
	}
};


class CBTTaskAxiiCharmMonitorDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskAxiiCharmMonitor';

	editable var removeCharmCooldown : float;
};