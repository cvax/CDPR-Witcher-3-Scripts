class W3Effect_SlowdownFrost extends CBaseGameplayEffect
{
	private saved var slowdownCauserId : int;

	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_SlowdownFrost;
	default attributeName = 'slowdownFrost';
		
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		slowdownCauserId = target.SetAnimationSpeedMultiplier( 0.7 );		
	}
	
	event OnEffectRemoved()
	{
		target.ResetAnimationSpeedMultiplier(slowdownCauserId);
		super.OnEffectRemoved();			
	}
		
	event OnEffectAddedPost()
	{
		if( IsAddedByPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation12 ) && target != thePlayer )
		{
			GetWitcherPlayer().AddMutation12Decoction();
		}
		
		super.OnEffectAddedPost();
	}
}