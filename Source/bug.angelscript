void ETHCallback_dx_background(ETHEntity @thisEntity) {
	int Floor = thisEntity.GetInt("Floor");
	switch (Floor) {
		case 7:
			thisEntity.SetFrame(0);
			break;
		case 8:
			thisEntity.SetFrame(1);
			break;
		case 9:
			thisEntity.SetFrame(2);
			break;
		default:
			thisEntity.SetFrame(3);
			break;
	}
}

void ETHCallback_bug(ETHEntity @thisEntity) {
	DATA_TYPE dataType = thisEntity.CheckCustomData("isInitialized");
	if (dataType == DT_NODATA) {
		thisEntity.SetFloat("verSpeed", 0.0f);
		thisEntity.SetInt("hit", 0);
		thisEntity.SetInt("isAlive", 1);
		thisEntity.SetInt("isInitialized", 1);
	}
	
	if (thisEntity.GetInt("Freeze") != 0)
		return;
	
	if (IsActive(thisEntity)) {
		int hit = thisEntity.GetInt("hit");
		if (hit > 0) {
			int isAlive = thisEntity.GetInt("isAlive");
			if (isAlive > 0) {
				thisEntity.SetFloat("verSpeed", -30.0f);
				thisEntity.SetInt("isAlive", 0);
				thisEntity.SetFrame(8);
				gameState.OnBugKilled();
				DXSoundSample@ killSound = GetGameSound("bug_kill.wav");
				if (killSound !is null)
					killSound.Play(0.6f);
			}
			KillEnemy(@thisEntity);
			AddLight(thisEntity.GetPosition() + vector3(0, -16, -8), vector3(0.0f, 0.0f, 1.0f), 32.0f, true);
		}
		else {
			MoveCharacter(@thisEntity);
			CheckCollisionWithHero(@thisEntity);
			AddLight(thisEntity.GetPosition() + vector3(0, -16, -8), vector3(1.0f, 0.4f, 0.0f), 32.0f, true);
		}
	}
}

void CheckCollisionWithHero(ETHEntity @thisEntity) {
	ETHEntity @collideEntity;
	if (CollideDynamic(thisEntity, collideEntity)) {
		int isHero = collideEntity.GetInt("isHero");
		if (isHero > 0) {
			int isHeroJump = collideEntity.GetInt("isJump");
			if (isHeroJump > 0) {
				float verSpeed = collideEntity.GetFloat("verSpeed");
				if (verSpeed < 0) {
					collideEntity.SetInt("hit", 1);
				}
			}
			else {
				collideEntity.SetInt("hit", 1);
			}
		}
	}
}

void KillEnemy(ETHEntity @thisEntity) {
	vector3 v3Dir(0,0,0);
	vector3 lastPos = thisEntity.GetPosition();
	float speed = UnitsPerSecond(150.0f);
	float currentVer = thisEntity.GetFloat("verSpeed");
	vector3 verDir(0,currentVer * UnitsPerSecond(9.8f),0);	
	thisEntity.AddToPosition(verDir);
	currentVer = currentVer + speed;
	if (currentVer > 1000.0f) {
		@thisEntity = DeleteEntity(thisEntity);
	}
	else {
		thisEntity.SetFloat("verSpeed", currentVer);
	}
}