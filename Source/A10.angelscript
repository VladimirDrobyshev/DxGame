void ETHCallback_dx_A10(ETHEntity @thisEntity) {
	DATA_TYPE dataType = thisEntity.CheckCustomData("lastTime");
	if (dataType == DT_NODATA) {
		thisEntity.SetInt("lastTime", GetTime());
	}
	
	int lastTime = thisEntity.GetInt("lastTime");
	int time = GetTime();
	
	if (time - lastTime > 1500) {
		thisEntity.SetInt("lastTime", time);
		vector3 pos = thisEntity.GetPosition();
		AddEntity("dx_A10_bomb.ent", pos, 0);
	}
	
	AddLight(thisEntity.GetPosition() + vector3(0, 0, 32), vector3(0.3f, 0.2f, 0.1f), 100.0f, true);
	
	vector2 camera = GetCameraPos();
	vector3 position = thisEntity.GetPosition();
	position.x += -3;
	position.y = 10        ;
	int x = position.x - camera.x;
	vector2 screen = GetScreenSize();
	if (x < -300)
		position.x = camera.x + screen.x + 300;
	thisEntity.SetPosition(position);
	
	ETHEntity @collideEntity;
	if (Collide(thisEntity, collideEntity)) {
		if (collideEntity.GetInt("isHero") > 0)
			collideEntity.SetInt("hit", 1);
	}
}

void ETHCallback_dx_A10_bomb(ETHEntity @thisEntity) {
	DATA_TYPE dataType = thisEntity.CheckCustomData("isInitialized");
	if (dataType == DT_NODATA) {
		thisEntity.SetInt("isInitialized", 1);
		thisEntity.SetFloat("verSpeed", 2.0f);
		thisEntity.SetFloat("angleSpeed", rand(2, 4));
	}
	
	float angleSpeed = thisEntity.GetFloat("angleSpeed");
	float verSpeed = thisEntity.GetFloat("verSpeed");
	float horSpeed = -sqrt(sqrt(verSpeed));
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
			ExplodeBomb(thisEntity);
		}
		else {
			if (collideEntity.IsStatic())
				ExplodeBomb(thisEntity);
		}			
	}

	if (verSpeed > 30.0f)
		ExplodeBomb(thisEntity);
}

void ExplodeBomb(ETHEntity @thisEntity) {
	vector3 pos = thisEntity.GetPosition();
	AddEntity("explosion.ent", pos, 100);
	DeleteEntity(thisEntity);
}