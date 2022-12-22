void ETHCallback_cccoin(ETHEntity @thisEntity) {
	if (thisEntity.GetInt("Freeze") == 0) {
		CoinCallback(thisEntity);
		AddLight(thisEntity.GetPosition() + vector3(0, 0, 16), vector3(0.0f, 0.25f, 0.0f), 32.0f, true);
		AddLight(thisEntity.GetPosition() + vector3(0, -16, -8), vector3(0.0f, 0.25f, 0.0f), 32.0f, true);
	}
}

void ETHCallback_cscoin(ETHEntity @thisEntity) {
	if (thisEntity.GetInt("Freeze") == 0) {
		CoinCallback(thisEntity);
		AddLight(thisEntity.GetPosition() + vector3(0, 0, 16), vector3(0.0f, 0.0f, 0.25f), 32.0f, true);
		AddLight(thisEntity.GetPosition() + vector3(0, -16, -8), vector3(0.0f, 0.0f, 0.25f), 32.0f, true);
	}
}

void ETHCallback_dxcoin(ETHEntity @thisEntity) {
	if (thisEntity.GetInt("Freeze") == 0) {
		CoinCallback(thisEntity);
		AddLight(thisEntity.GetPosition() + vector3(0, 0, 16), vector3(1.0f, 0.5f, 0.0f), 32.0f, true);
		AddLight(thisEntity.GetPosition() + vector3(0, -16, -8), vector3(1.0f, 0.5f, 0.0f), 32.0f, true);
	}
}

void ETHCallback_dx_question(ETHEntity @thisEntity) {
	if (thisEntity.GetInt("Freeze") > 0) {
		CoinCallback(thisEntity);
	}
	else {
		if (IsActive(thisEntity)) {
			DATA_TYPE dataType = thisEntity.CheckCustomData("startTime");
						  if (dataType == DT_NODATA)
					thisEntity.SetInt("startTime", GetTime());
			
			int startTime = thisEntity.GetInt("startTime");
			int time = GetTime();
			float delta = (time - startTime) / 1000.0f;
			float changeColorTime = 4.0f;

			if (delta > 2 * changeColorTime) {
				thisEntity.SetFrame(0);
				MoveVertically(thisEntity);
				thisEntity.SetInt("bonus", 0);
				
				ETHEntity @other;
				if (CollideDynamic(thisEntity, other)) {
					if (other.GetInt("isHero") > 0)
						other.SetInt("hit", 1);
				}  
			}
			else {
				CoinCallback(thisEntity);
				float g, r;
				if (delta > changeColorTime) {
					r = 1.0f;
					g = 1 - (delta - changeColorTime) / changeColorTime;
				}
				else {
					g = 1.0f;
					r = delta / changeColorTime;
				}
				if (thisEntity.GetInt("Freeze") == 0) {
					AddLight(thisEntity.GetPosition() + vector3(0, 0, 16), vector3(r, g, 0.0f), 32.0f, true);
					AddLight(thisEntity.GetPosition() + vector3(0, -16, -8), vector3(r, g, 0.0f), 32.0f, true);
				}
			}
		}
	}
}

void CoinCallback(ETHEntity @thisEntity) {   
	DATA_TYPE dataType = thisEntity.CheckCustomData("isInitialized");
	if (dataType == DT_NODATA) {
		thisEntity.SetFloat("verSpeed", 0.0f);
		DATA_TYPE hitType = thisEntity.CheckCustomData("hit");
		if (hitType == DT_NODATA)
			thisEntity.SetInt("hit", 0);
		thisEntity.SetInt("isAlive", 1);
		thisEntity.SetInt("isInitialized", 1);
		thisEntity.SetInt("lastTime", GetTime());
		thisEntity.SetInt("delta", 0);
		if (thisEntity.GetInt("LayerValid") == 0)
			thisEntity.SetLayerDepth(0.5f);
		
		if (thisEntity.GetInt("Freeze") > 0) {
			thisEntity.SetEmissiveColor(vector3(0.0f, 1.0f, 0.0f)); 
		}
	}
	
	if (thisEntity.GetInt("Freeze") == 0) {
		RotateCoin(@thisEntity);

		int hit = thisEntity.GetInt("hit");
		if (hit > 0) {
			int isAlive = thisEntity.GetInt("isAlive");
			if (isAlive > 0) {
				thisEntity.SetInt("isAlive", 0);
				thisEntity.SetInt("startKillTime", GetTime());
				thisEntity.SetInt("currentKillTime", 0);
				thisEntity.SetInt("killTime", 500);
				DXSoundSample@ collect = GetGameSound("coin_collect.wav");
				if (collect !is null)
					collect.Play(0.8f);
			}
			DestroyCoin(@thisEntity);
		}
	}
}

void RotateCoin(ETHEntity @thisEntity) {
	uint time = GetTime();
  	uint delta = time - thisEntity.GetInt("lastTime");
	int fps = 18;
	int animInterval = 0;
	if (thisEntity.GetInt("isAlive") == 0) {
		uint killTime = GetTime() - thisEntity.GetInt("startKillTime");
		thisEntity.SetInt("currentKillTime", killTime);
		float f = float(killTime) / float(thisEntity.GetInt("killTime"));
		f = pow(f, 3);
		f = 1 - f;
		thisEntity.SetAlpha(f);
		thisEntity.SetScale(vector2(f, f));
		if (fps > 0)
			animInterval = int(1.0f / float(fps) * 1000 * f);
	}
	else {
		if (fps > 0)
			animInterval = int(1.0f / float(fps) * 1000.0f);
	}
	thisEntity.AddToInt("delta", delta);
	if (thisEntity.GetInt("delta") > animInterval) {
		thisEntity.SetInt("delta", thisEntity.GetInt("delta") - animInterval);
		int frame = thisEntity.GetFrame();
		frame++;
		if (frame == 16)
			frame = 0;
		thisEntity.SetFrame(frame);
	}
	thisEntity.SetInt("lastTime", time);
}

void DestroyCoin(ETHEntity @thisEntity) {
	vector3 v3Dir(0, 0, 0);
	float speed = UnitsPerSecond(150.0f);
	float currentVer = thisEntity.GetFloat("verSpeed");
	vector3 verDir(0, currentVer * UnitsPerSecond(9.8f), 0);	
	thisEntity.AddToPosition(verDir);
	currentVer = currentVer - speed;
	//if (currentVer < -75.0f) {
	if (thisEntity.GetInt("currentKillTime") >= thisEntity.GetInt("killTime")) {
		@thisEntity = DeleteEntity(thisEntity);
	}
	else {
		thisEntity.SetFloat("verSpeed", currentVer);
	}
}