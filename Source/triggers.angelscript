uint tits_lastTime = 0;
ETHEntityArray screenTriggersEntities;

void UpdateTriggerEntities()
{
	screenTriggersEntities.removeDeadEntities();
	
	for (uint t = 0; t < screenTriggersEntities.size(); t++)
	{
		ETHEntity @entity = screenTriggersEntities[t];
		if (entity is null)
			continue;
		if (!entity.IsAlive())
			continue;
		vector2 pos = GetCameraPos();
		entity.SetPosition(vector3(pos.x, pos.y, 100));
		uint delta = GetTime() - entity.GetInt("__lastTime__");
		entity.AddToInt("__delay__", -delta);
		if (entity.GetInt("__delay__") < 0)
			DeleteEntity(entity);
		else 
			entity.SetInt("__lastTime__", GetTime());
	}
}

void SpawnScreenEntity(ETHEntity @trigger)
{
	ETHEntity @spawn;
	vector2 pos = GetCameraPos();
	AddEntity(trigger.GetString("ShowEntity") + ".ent", vector3(pos.x, pos.y, 100), spawn);
	spawn.SetInt("__delay__", trigger.GetInt("ShowEntityDelay"));
	spawn.SetInt("__lastTime__", GetTime());
	screenTriggersEntities.push_back(spawn);
	trigger.SetUInt("__spawnID__", spawn.GetID());
}

void ETHCallback_trigger_screen(ETHEntity @trigger)
{
	if (trigger.GetInt("Repeats") == 0)
		return;
		
	uint spawnID = trigger.GetUInt("__spawnID__");
	if (spawnID != 0)
	{
		ETHEntity @spawn = SeekEntity(spawnID);
		
		if ((spawn is null) || (!spawn.IsAlive()))
			trigger.SetUInt("__spawnID__", 0);
	}
	
	ETHEntity @hit;
	if (CollideDynamic(trigger, hit) && (hit.GetEntityName() == "hero.ent"))
	{
		if ((trigger.GetString("ShowEntity") != "none") && (trigger.GetUInt("__spawnID__") == 0))
		{
			SpawnScreenEntity(trigger);
			if (trigger.GetInt("Repeats") > 0)
				trigger.AddToInt("Repeats", -1);
		}
	}
}

