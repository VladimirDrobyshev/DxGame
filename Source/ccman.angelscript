
uint ccman_lastTime = 0;
const uint ccman_numFrames = 4;

void ccmanInitialize(ETHEntity @ccman) {
	ccman.SetUInt("__movingDir__", 0);		// 0 - left, 1 - right
	ccman.SetUInt("__state__", 0);			// 0 - on ground, 1 - jumping
	ccman.SetInt("__firing__", 0);
	ccman.SetUInt("__fireTime__", 0);
	ccman.SetInt("__frame__", 0);
	ccman.SetInt("__frameTime__", 0);
	ccman.SetInt("__changeDirTime__", 0);
	ccman.SetFloat("__jumpForce__", 0);
	ccman.SetInt("__isFlipped__", 0);
	ccman.SetFloat("__range__", 200);
	ccman.SetVector2("__initPosition__", ccman.GetPositionXY());
	
	if (ccman.CheckCustomData("Speed") == DT_NODATA)
		ccman.SetUInt("Speed", 500);
	if (ccman.CheckCustomData("FireInterval") == DT_NODATA)
		ccman.SetUInt("FireInterval", 500);
	ccmanUpdateState(@ccman);
}

bool ccmanIsNew(ETHEntity @ccman) {
	if (ccman.GetInt("isInitialized") == 0) {
		ccmanInitialize(@ccman);
		ccman.SetInt("isInitialized", 1);
		return true;
	}
	return false;
}
void ccmanFire(ETHEntity @ccman) {
	bool flipped = (ccman.GetInt("__isFlipped__") > 0);
	vector3 pos;
	if (flipped)
		pos = ccman.GetPosition() + vector3(30, -83, 0.5);
	else	
		pos = ccman.GetPosition() + vector3(-20, -83, 0.5);
	ETHEntity @fireBall = null;
	AddEntity("ccman_fireball.ent", pos, fireBall);
	if (fireBall !is null)
	{
		if (flipped)
			fireBall.SetFloat("dirX", 1);
		else
			fireBall.SetFloat("dirX", -1);
		fireBall.SetFloat("dirY", 0);
		fireBall.SetFloat("speed", 250.0f);
	}
	
	ETHEntity@ hero = FindHero();
	
	DXSoundSample@ fire = GetGameSound("ccman_fire.wav");
	if (fire !is null) {
		float vol = max(0.0f, min(1 - abs(hero.GetPositionXY().x - pos.x) / 5000, 1.0f));
		fire.Play(vol);
	}
}
void ccmanUpdateState(ETHEntity @ccman)
{
	vector3 ccmanPos = ccman.GetPosition();
	ETHEntity @hero = SeekEntity("hero.ent");
	uint delta = GetTime() - ccman_lastTime;
	uint speed = ccman.GetUInt("Speed");
	if (hero !is null)
	{
		vector3 heroPos = hero.GetPosition();
		if ((heroPos.x - ccmanPos.x) < 0)
		{
			if (ccman.GetInt("__isFlipped__") == 1)
			{
				//ccman.SetFlippedX(true);
				ccman.SetInt("__isFlipped__", 0);
			}
		}
		else
		{
			if (ccman.GetInt("__isFlipped__") == 0)
			{
				//ccman.SetFlippedX(false);
				ccman.SetInt("__isFlipped__", 1);
			}
		}
	}
	ccman.AddToUInt("__fireTime__", delta);
	if (ccman.GetUInt("FireInterval") <= ccman.GetUInt("__fireTime__"))
	{
		if (rand(0, 1) == 1)
		{
			ccmanFire(@ccman);
			ccman.SetInt("__firing__", 300);
		}
		ccman.SetUInt("__fireTime__", 0);
		
	}
	else
	{
		if (ccman.GetInt("__firing__") > 0)
			ccman.AddToInt("__firing__", -delta);
	}
	ccman.AddToInt("__frameTime__", delta * speed / 100);
	ccman.AddToInt("__changeDirTime__", delta * speed / 1000);
	if (ccman.GetInt("__frameTime__") > 1000)
	{
		ccman.SetInt("__frameTime__", 0);
		int curFrame = ccman.GetInt("__frame__");
		curFrame++;
		if (curFrame >= ccman_numFrames)
			ccman.SetInt("__frame__", 0);
		else
			ccman.SetInt("__frame__", curFrame);
	}
	
	if (ccman.GetInt("__changeDirTime__") > 1000)
	{
		ccman.SetInt("__changeDirTime__", 0);
		ccman.SetUInt("__movingDir__", rand(0, 1));
	}
	
	uint animBase = (ccman.GetInt("__firing__") > 0) ? ( (ccman.GetInt("__isFlipped__") > 0) ? 12 : 8 ) : ( (ccman.GetInt("__isFlipped__") > 0) ? 4 : 0 );
	
	ccman.SetFrame(animBase + ccman.GetInt("__frame__"));

	if ( (ccman.GetUInt("__state__") == 0) && (rand(0, 80) == 80) )
	{
		ccman.SetUInt("__state__", 1);
		ccman.SetFloat("__jumpForce__", 6);
	}
	// Position
	vector3 storePosition = ccman.GetPosition();
	if (ccman.GetUInt("__state__") == 0)
	{
		uint movingDir = ccman.GetUInt("__movingDir__");
		float toGo = float(ccman.GetUInt("Speed")) * float(delta) / 10000;
		if (movingDir == 0)
			ccman.AddToPosition(vector3(-toGo, 0, 0));
		else
			ccman.AddToPosition(vector3(toGo, 0, 0));
	}
	else
	{
		ccman.AddToFloat("__jumpForce__", -(float(delta) * 0.005f));
		float force = ccman.GetFloat("__jumpForce__");
		ccman.AddToPosition(vector3(0, -force, 0));
	}
	
	ETHEntity @other;
	
	if (abs(ccman.GetPositionXY().x - ccman.GetVector2("__initPosition__").x) >= ccman.GetFloat("__range__"))
		ccman.SetPosition(storePosition);
	
	if (Collide(ccman, other, NamedChooser("dx_ccman_block.ent")))
		ccman.SetPosition(storePosition);
	
	if (Collide(ccman, other, NamedChooser("hero.ent")))
		other.SetInt("hit", 1);
	
	if (CollideStatic(ccman))
		ccman.SetUInt("__state__", 0);
	
	ccman_lastTime = GetTime();
}


void ETHCallback_ccman(ETHEntity @ccman)
{
	if (ccman_lastTime == 0)
		ccman_lastTime = GetTime();
	
	if (ccmanIsNew(@ccman))
		return;
		
	ccmanUpdateState(@ccman);
}

void ETHCallback_ccman_fireball(ETHEntity @thisEntity)
{
	float dirX = thisEntity.GetFloat("dirX");
	float dirY = thisEntity.GetFloat("dirY");
	const float speed = UnitsPerSecond(thisEntity.GetFloat("speed"));
	thisEntity.AddToPositionXY(vector2(dirX,dirY)*speed);
	
	vector3 pos = thisEntity.GetPosition();
	if (pos.x < 0) {
		DeleteEntity(thisEntity);
		return;
	}
	
	ETHEntity @hit;
	if (CollideDynamic(thisEntity, hit)) {
		if (hit.GetInt("isHero") > 0) {
			vector3 pos = thisEntity.GetPosition();
			AddEntity("explosion.ent", pos, 100);
			@thisEntity = DeleteEntity(thisEntity);
			hit.SetInt("hit", 1);		
		}
	}
	
	if (CollideStatic(thisEntity, hit)) {
		vector3 pos = thisEntity.GetPosition();
		AddEntity("explosion.ent", pos, 100);
		@thisEntity = DeleteEntity(thisEntity);
	}
}

