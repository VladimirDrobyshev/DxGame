void ETHCallback_dx_level_end(ETHEntity @thisEntity)
{
	ETHEntity @ent;
	if (CollideDynamic(thisEntity, ent))
	{
		if (ent.GetInt("isHero") > 0)
		{
			ent.SetInt("hit", 1);
			CompleteLevel(ent);
			return;
		}
	}	
}