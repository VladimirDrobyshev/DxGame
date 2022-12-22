void InitNewBonusBox(ETHEntity @box) {
	vector3 boxPosition = box.GetPosition();
	// attach sensor
	ETHEntity @sensor;
	AddEntity("bonus_box_sensor.ent", vector3(boxPosition.x, boxPosition.y + 32, boxPosition.z), sensor);
	sensor.SetInt("__attachedBox__", box.GetID());
	box.SetInt("__state__", 1);		// 1 - has bonus, 0 - empty box
	box.SetInt("__initialized__", 1);
	box.SetUInt("__lastTime__", GetTime());
	box.SetInt("__delta__", 0);
	box.SetFloat("__popUpFactor__", 0);
	box.SetInt("__isPopUp__", 0);
	box.SetFloat("__lightTime__", 0);
	
}

void UpdateBonusBox(ETHEntity @box) {
	uint time = GetTime();
	uint delta = time - box.GetUInt("__lastTime__");
	
	int fps = box.GetInt("AnimationFPS");
	
	int animInterval = 0;
	if (fps > 0)
		animInterval = int(1.0f / float(fps) * 1000.0f);
		
	box.AddToInt("__delta__", delta);
	
	if (box.GetInt("__state__") == 0)
		box.SetFrame(1);
	else
		box.SetFrame(0);
		
	
	if (box.GetInt("__isPopUp__") > 0) {
		float f = box.GetFloat("__popUpFactor__");
		
		f += float(delta) / 3000.0f * float(fps);
		
		if (f >= 1)
		{
			box.SetInt("__isPopUp__", 0);
			box.SetPosition(box.GetVector3("__popUpStartPos__"));
			return;
		}
		
		float y = (1 - f * f) * 20;
		
		vector3 pos = box.GetVector3("__popUpStartPos__");
		
		pos.y = pos.y - y;
		
		box.SetPosition(pos);
		box.SetFloat("__popUpFactor__", f);
	}
	
	if (box.GetInt("__state__") != 0) {
		box.AddToFloat("__lightTime__", float(delta) / 300);		
		float fl = box.GetFloat("__lightTime__");		
		AddLight(box.GetPosition() + vector3(cos(fl) * 8, -sin(fl) * 8, 32), vector3(0.5f, 0.5f, 0.0f), 50.0f, true);
	}	
	box.SetUInt("__lastTime__", time);
}

void BonusBoxHit(ETHEntity @sensor) {
	ETHEntity @box = SeekEntity(sensor.GetInt("__attachedBox__"));
	if (box.GetInt("__state__") == 1)
	{
		box.SetInt("__state__", 0);
		box.SetInt("__delta__", 0);
		box.SetFrame(box.GetUInt("EmptyAnimationStart"));
		box.SetInt("__isPopUp__", 1);
		box.SetFloat("__popUpFactor__", -1);
		box.SetVector3("__popUpStartPos__", box.GetPosition());
				
		SpawnBonus(box);
	}
}

void ETHCallback_bonus_box_sensor(ETHEntity @sensor) {
	
	ETHEntity @hit;
	
	if (sensor.GetInt("hit") != 0)
		BonusBoxHit(sensor);
	
	// Hero take care
	/*
	if (CollideDynamic(sensor, hit))
	{
		if (hit.GetInt("isHero") != 0)
		{
			BonusBoxHit(sensor);
		}
	}
	*/
}

void ETHCallback_dx_bonus_box(ETHEntity @box) {
	if (box.GetInt("__initialized__") == 0)
		InitNewBonusBox(box);
		
	UpdateBonusBox(box);
}

void SpawnBonus(ETHEntity @box) {
	string name = box.GetString("BonusEntity");
	
	vector3 pos = box.GetPosition();
	
	if (name == "shroom" || name == "helmet") {
		ETHEntity@ bonus;
		AddEntity("bonus_" + name + ".ent", pos, bonus);
		bonus.SetLayerDepth(box.GetLayerDepth() - 0.01f);
	}
	else {
		ETHEntity @coin;
		string bonusName;
		int Floor = box.GetInt("Floor");
		switch (Floor) {
			case 7:
				bonusName = "cscoin.ent";
				break;
			case 10:
				bonusName = "dxcoin.ent";
				break;
			default:
				bonusName = "cccoin.ent";
				break;
		}
		AddEntity(bonusName, pos, coin);
		coin.SetLayerDepth(box.GetLayerDepth() - 0.001f);
		coin.SetInt("LayerValid", 1);
		coin.SetInt("hit", 1);
		ETHEntity @hero = FindHero();
		if (hero !is null) {
			int heroBonus = hero.GetInt("bonus");
			int coinBonus = coin.GetInt("bonus");
			hero.SetInt("bonus", heroBonus + coinBonus);
			gameState.OnCoinCollected(coinBonus);
		}
	}
}

void InitNewBonus(ETHEntity @bonus) {
	vector3 pos = bonus.GetPosition();
	
	bonus.SetInt("__isSpawning__", 1);
	bonus.SetUInt("__lastTime__", GetTime());
	bonus.SetUInt("__spawnTime__", GetTime());
	bonus.SetVector3("__spawnPos__", pos);
	bonus.SetVector3("__spawnEndPos__", vector3(pos.x, pos.y - 64, pos.z));
	bonus.SetUInt("__delta__", 0);
	bonus.SetInt("__initialized__", 1);
	bonus.SetInt("Direction", 0);
	bonus.SetInt("bonus", 1);
	bonus.SetInt("IsBonus", 1);
	
	DXSoundSample@ spawn = GetGameSound("bonus_spawn.wav");
	if (spawn !is null)
		spawn.Play();
	
}
void UpdateBonus(ETHEntity @bonus) {
	if (bonus.GetInt("hit") > 0)
	{
		DXSoundSample@ pick = GetGameSound("bonus_pick.wav");
		if (pick !is null)
			pick.Play();
		DeleteEntity(bonus);
		return;
	}
	
	uint time = GetTime();
	uint delta = time - bonus.GetInt("__lastTime__");
	
	if (bonus.GetInt("__isSpawning__") > 0)
	{
		vector3 spawnPos = bonus.GetVector3("__spawnPos__");
		vector3 spawnEndPos = bonus.GetVector3("__spawnEndPos__");
		vector3 dir = spawnEndPos - spawnPos;
		
		float f = float(time - bonus.GetUInt("__spawnTime__")) / 1000;
		
		if (f > 1)
		{
			bonus.SetInt("__isSpawning__", 0);
			//spawnEndPos.z += 0.1f;
			bonus.SetPosition(spawnEndPos);
		}
		else
		{
			dir *= f;
			bonus.SetPosition(spawnPos + dir);
		}
	
	}
	else
	{
		if (bonus.GetInt("UseEnemyAI") != 0) 
			MoveCharacter(bonus);
	}
		
	bonus.SetInt("__lastTime__", time);
}

void CommonBonusCallback(ETHEntity @bonus) {
	if (bonus.GetInt("__initialized__") == 0)
		InitNewBonus(bonus);
	
	UpdateBonus(bonus);
}
void ETHCallback_bonus_shroom(ETHEntity @bonus) {
	CommonBonusCallback(bonus);
}
void ETHCallback_bonus_helmet(ETHEntity @bonus) {
	CommonBonusCallback(bonus);
}
