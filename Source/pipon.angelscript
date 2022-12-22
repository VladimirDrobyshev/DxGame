void ETHCallback_dx_pipe_top(ETHEntity @thisEntity) {
	if (thisEntity.CheckCustomData("isInitialized") == DT_NODATA) {
		thisEntity.SetInt("isInitialized", 1);
		thisEntity.SetUInt("isPiponInitialized", 0);
	}
	
	uint isPiponInitialized = thisEntity.GetUInt("isPiponInitialized");
	if (IsActive(thisEntity) && isPiponInitialized == 0) {
		AddEntity("dx_pipon.ent", thisEntity.GetPosition(), 0);
		thisEntity.SetUInt("isPiponInitialized", 1);
	}
}

void ETHCallback_dx_pipon(ETHEntity @thisEntity) {	
	if (thisEntity.CheckCustomData("isInitialized") == DT_NODATA) {
		thisEntity.SetInt("isInitialized", 1);
		thisEntity.SetUInt("state", 0);			// 0 - on ground, 1 - up, 2 - fire, 3 - down
		thisEntity.SetInt("lastTime", GetTime());
		thisEntity.SetInt("lastBananaTime", GetTime());
		thisEntity.SetFloat("yOffset", thisEntity.GetPosition().y);
		thisEntity.SetFloat("height", thisEntity.GetSize().y);		
	}

	uint state = thisEntity.GetUInt("state");
	int lastTime = thisEntity.GetInt("lastTime");
		
	int time = GetTime();	
	if ((state == 1) || (state == 3)) {
		float height = thisEntity.GetFloat("height");
		float initYOffset = thisEntity.GetFloat("yOffset");
		float delta = height * (time - lastTime) / 1500;
		vector3 position = thisEntity.GetPosition();
		if (state == 1)
			position.y = initYOffset - delta;
		else
			position.y = initYOffset + delta;
		thisEntity.SetPosition(position);
	}
	
	AddLight(thisEntity.GetPosition() + vector3(0, 0, 32), vector3(0.3f, 0.2f, 0.1f), 100.0f, true);
	
	if (state == 2) {
		int lastBananaTime = thisEntity.GetInt("lastBananaTime");
		if (time - lastBananaTime > 300) {
			thisEntity.SetInt("lastBananaTime", time);
			AddEntity("dx_pipon_banana.ent", thisEntity.GetPosition() + vector3(0, -20, 0), 0);		
		}
	}
	
	ETHEntity @collideEntity;
	if (Collide(thisEntity, collideEntity)) {
		if ((collideEntity.GetInt("isHero") > 0) && (state != 0))
			collideEntity.SetInt("hit", 1);
	}
	
	if (time - lastTime > 1500) {
		thisEntity.SetInt("lastTime", time);
		state = (++state) % 4;
		thisEntity.SetUInt("state", state);
		thisEntity.SetFloat("yOffset", thisEntity.GetPosition().y);
	}
}

void ETHCallback_dx_pipon_banana(ETHEntity @thisEntity) {
	if (thisEntity.CheckCustomData("isInitialized") == DT_NODATA) {
		thisEntity.SetInt("isInitialized", 1);
		thisEntity.SetFloat("verSpeed", 2.0f);
		thisEntity.SetFloat("horSpeed", randF(-10.0, -5.0));
		thisEntity.SetFloat("angleSpeed", rand(2, 4));
	}
	
	float angleSpeed = thisEntity.GetFloat("angleSpeed");
	float verSpeed = thisEntity.GetFloat("verSpeed");
	float horSpeed = thisEntity.GetFloat("horSpeed");
	vector2 positionOffset(horSpeed, verSpeed);
	thisEntity.AddToPositionXY(positionOffset);
	thisEntity.AddToAngle(angleSpeed);
	verSpeed += verSpeed * UnitsPerSecond(1.0f);
	thisEntity.SetFloat("verSpeed", verSpeed);
	
	ETHEntity @collideEntity;
	if (Collide(thisEntity, collideEntity)) {
		int isHero = collideEntity.GetInt("isHero");
		if (isHero > 0) {
			collideEntity.SetInt("hit", 1);
			ExplodeBanana(thisEntity);
		}
		else {
			if (collideEntity.IsStatic())
				ExplodeBanana(thisEntity);
		}			
	}

	if (verSpeed > 30.0f)
		ExplodeBomb(thisEntity);
}

void ExplodeBanana(ETHEntity @thisEntity) {
	vector3 pos = thisEntity.GetPosition();
	AddEntity("explosion.ent", pos, 100);
	DeleteEntity(thisEntity);
}