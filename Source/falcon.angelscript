const uint falcon_numFrames = 4;
const int smokeTime = 2000;

uint falcon_lastTime = 0;

void FalconInitialize(ETHEntity @falcon) {
	falcon.SetUInt("__movingDir__", 0);		// 0 - left, 1 - right
	falcon.SetUInt("__state__", 0);			// 0 - on ground, 1 - jumping, 2 - fire
	falcon.SetUInt("__fireTime__", 0);
	falcon.SetInt("__changeDirTime__", 0);
	falcon.SetInt("__isFlipped__", 0);
	falcon.SetInt("FrameIndex", 0);
	falcon.SetInt("FrameTime", GetTime());
	
	if (falcon.CheckCustomData("Speed") == DT_NODATA)
		falcon.SetUInt("Speed", 500);
	if (falcon.CheckCustomData("FireInterval") == DT_NODATA)
		falcon.SetUInt("FireInterval", 1000);
	FalconUpdateState(@falcon);
}

bool FalconIsNew(ETHEntity @falcon) {
	if (falcon.GetInt("isInitialized") == 0) {
		FalconInitialize(@falcon);
		falcon.SetInt("isInitialized", 1);
		return true;
	}
	return false;
}

void FalconFire(ETHEntity @falcon) {
	bool flipped = (falcon.GetInt("__isFlipped__") > 0);
	vector3 pos;
	if (flipped) {
		pos = falcon.GetPosition() + vector3(-6, -110, 0.5);
		AddEntity("falcon_smoke_right.ent", pos, null);
	}
	else {
		pos = falcon.GetPosition() + vector3(-33, -110, 0.5);
		AddEntity("falcon_smoke_left.ent", pos, null);
	}
}

void ProcessMovingState(ETHEntity @falcon) {
	vector3 falconPos = falcon.GetPosition();
	ETHEntity @hero = SeekEntity("hero.ent");
	uint delta = GetTime() - falcon_lastTime;
	uint speed = falcon.GetUInt("Speed");
	if (hero !is null) {
		vector3 heroPos = hero.GetPosition();
		if ((heroPos.x - falconPos.x) < 0) {
			if (falcon.GetInt("__isFlipped__") == 1)
				falcon.SetInt("__isFlipped__", 0);
		}
		else {
			if (falcon.GetInt("__isFlipped__") == 0)
				falcon.SetInt("__isFlipped__", 1);
		}
	}
	
	falcon.AddToUInt("__fireTime__", delta);
	if (falcon.GetUInt("FireInterval") <= falcon.GetUInt("__fireTime__")) {
		if (rand(0, 1) == 1) {
			FalconFire(@falcon);
			falcon.SetUInt("__state__", 2);
			falcon.SetInt("smokeBegin", GetTime());
			return;
		}
		else {
			if (rand(0, 1) == 1) {
				falcon.SetUInt("__state__", 1);
				falcon.SetInt("StartJump", GetTime());
				falcon.SetFloat("verSpeed", -60);
				return;
			}
		}
		falcon.SetUInt("__fireTime__", 0);
	}
	falcon.AddToInt("__changeDirTime__", delta * speed / 1000);

	if (falcon.GetInt("__changeDirTime__") > 1000) {
		falcon.SetInt("__changeDirTime__", 0);
		falcon.SetUInt("__movingDir__", rand(0, 1));
	}	

	vector3 storePosition = falcon.GetPosition();
	uint movingDir = falcon.GetUInt("__movingDir__");
	float toGo = float(falcon.GetUInt("Speed")) * float(delta) / 10000;
	if (movingDir == 0)
		falcon.AddToPosition(vector3(-toGo, 0, 0));
	else
		falcon.AddToPosition(vector3(toGo, 0, 0));

	ETHEntity @other;
	if (CollideStatic(falcon))
		falcon.SetPosition(storePosition);

	MoveVertically(falcon);
}
void ProcessFireState(ETHEntity @falcon) {
	int smokeBegin = falcon.GetInt("smokeBegin");
	int time = GetTime();
	if (time - smokeBegin > smokeTime)
		falcon.SetUInt("__state__", 0);
}
void ProcessJumpState(ETHEntity @falcon) {
	MoveVertically(falcon);
	if (GetTime() - falcon.GetInt("StartJump") > 1000)
		falcon.SetUInt("__state__", 0);
}
void FalconUpdateState(ETHEntity @falcon) {
	switch (falcon.GetUInt("__state__")) {
		case 0:
			ProcessMovingState(falcon);
			break;
		case 1:
			ProcessJumpState(falcon);
			break;
		case 2:
			ProcessFireState(falcon);
			break;
	}
	
	int time = GetTime();
	int frameTime = falcon.GetInt("FrameTime");
	int frameIndex = falcon.GetInt("FrameIndex");
	if (time - frameTime > 200) {
		falcon.SetInt("FrameTime", time);
		if (frameIndex == 3)
			frameIndex = 0;
		else
			frameIndex  += 1;
		falcon.SetInt("FrameIndex", frameIndex);
	}
	int isFlipped = falcon.GetInt("__isFlipped__");
	int additionalFrameIndex = 0;
	switch (falcon.GetUInt("__state__")) {
		case 0:
			if (isFlipped > 0)
				additionalFrameIndex = 4;
			else
				additionalFrameIndex = 0;
			break;
		case 2:
			frameIndex = 3;
			if (isFlipped > 0)
				additionalFrameIndex = 20;
			else
				additionalFrameIndex = 16;
			break;
	}
	falcon.SetFrame(frameIndex + additionalFrameIndex);

	ETHEntity @other;
	if (Collide(falcon, other, NamedChooser("hero.ent"))) {
		if (other.GetInt("isHero") > 0)
			other.SetInt("hit", 1);
	}
	
	falcon_lastTime = GetTime();
}

void ETHCallback_falcon(ETHEntity @falcon) {
	if (falcon_lastTime == 0)
		falcon_lastTime = GetTime();
	if (FalconIsNew(@falcon))
		return;
	FalconUpdateState(@falcon);
}

void ETHCallback_falcon_smoke_left(ETHEntity @thisEntity) {
	FalconSmoke(thisEntity);
}

void ETHCallback_falcon_smoke_right(ETHEntity @thisEntity) {
	FalconSmoke(thisEntity);
}

void FalconSmoke(ETHEntity @thisEntity) {
	if (thisEntity.CheckCustomData("startTime") == DT_NODATA)
		thisEntity.SetInt("startTime", GetTime());
	int startTime = thisEntity.GetInt("startTime");
	int time = GetTime();
	int delta = time - startTime;
	if (delta > 200) {
		ETHEntity @other;
		if (Collide(thisEntity, other, NamedChooser("hero.ent"))) {
			if (other.GetInt("isHero") > 0)
				other.SetInt("hit", 1);
		}
		if (delta > smokeTime)
			DeleteEntity(thisEntity);
	}
}
