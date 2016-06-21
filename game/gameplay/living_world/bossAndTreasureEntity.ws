enum EEP2PoiType
{
	EPT_Default,
	EPT_Belgard,
	EPT_Coronata,
	EPT_Vermentino,
}

class W3POI_BossAndTreasureEntity extends CR4MapPinEntity
{	
	private editable var regionType : EEP2PoiType;

	public function GetRegionType() : int
	{
		return (int) regionType;
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var mapManager : CCommonMapManager;
		var component : CComponent;
		
		if ( activator.GetEntity() == thePlayer )
		{
			component = GetComponent( "FirstDiscoveryTrigger" );
			if( area == component )
			{
				component.SetEnabled( false );			
				mapManager = theGame.GetCommonMapManager();
				if ( mapManager )
				{
					mapManager.SetEntityMapPinDiscoveredScript( false, entityName, true );
				}
			}
		}
	}	
}
