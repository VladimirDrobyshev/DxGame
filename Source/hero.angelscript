// This function will control the character. The engine automatically assigns this function
// to all entities whose original name equals "jazag.ent".

const int hitTime = 4000;
const vector2 heroCameraOffset(0.0f, 25.0f);

void Init_hero(ETHEntity @thisEntity) {
	thisEntity.SetInt("bonus", 0);
	thisEntity.SetInt("isHero", 1);
	thisEntity.SetFloat("height", 20);
	thisEntity.SetInt("isRace", 0);
	thisEntity.SetInt("isJump", 0);
	thisEntity.SetInt("allowShot", 0);
	thisEntity.SetInt("lifeLevel", 1);
	thisEntity.SetInt("hit", 0);
	thisEntity.SetInt("allowHit", 1);
	thisEntity.SetInt("lastHitTime", 0);
	thisEntity.SetFloat("lastDirX", 1);	
	thisEntity.SetFloat("verSpeed", 100.0f);
	thisEntity.SetInt("pause", 1);	
}



float bugcoll_verSpeed;
int bugcoll_isJump;


bool OnCollideWithBug(ETHEntity @hero, ETHEntity@ suspect) {
	if (bugcoll_isJump > 0)
	{
		if (bugcoll_verSpeed > 0) {
			if (suspect.GetEntityName() == "bug.ent") {
				suspect.SetInt("hit", 1);
				if (suspect.GetInt("isAlive") == 1) {
					return true;
				}
			}
		}
		if (suspect.GetEntityName() == "bonus_box_sensor.ent")
			suspect.SetInt("hit", 1);
	}
	return false;
}

bool CheckCollideWithBug(ETHEntity @thisEntity, float verSpeed, int isJump) {
	bugcoll_verSpeed = verSpeed;
	bugcoll_isJump = isJump;
	return CollideDynamicCallback(thisEntity, @OnCollideWithBug);
}

void CheckCollideWithCoin(ETHEntity @thisEntity) {
	ETHEntity @other;
	if (CollideDynamic(thisEntity, other))
	{
		int isBonus = other.GetInt("IsBonus");
		int bonus = other.GetInt("bonus");
		if  (bonus > 0) {
			if (isBonus > 0) {
				if (other.GetInt("__isSpawning__") == 0) {
					if (other.GetInt("hit") == 0) {
						other.SetInt("hit", 1);
						thisEntity.SetInt("bonus", thisEntity.GetInt("bonus") + bonus);
						gameState.OnCoinCollected();					
					}
				}
			}
			else {
				if (other.GetInt("hit") == 0) {
					other.SetInt("hit", 1);
					thisEntity.SetInt("bonus", thisEntity.GetInt("bonus") + bonus);
					gameState.OnCoinCollected();
				}
			}
		}
		if (other.GetEntityName() == "bonus_shroom.ent") {
			thisEntity.SetInt("lifeLevel", 2);
		}
		if (other.GetEntityName() == "bonus_helmet.ent") {
			thisEntity.SetInt("allowShot", 1);
		}
	}
}

int UpdateCurrentLifeLevel(ETHEntity @thisEntity) {
	int currentLifeLevel = thisEntity.GetInt("lifeLevel");
	if((thisEntity.GetInt("hit")> 0) && (thisEntity.GetInt("allowHit") > 0)) {
		currentLifeLevel  +=- 1;
		thisEntity.SetInt("lifeLevel", currentLifeLevel);
		thisEntity.SetInt("allowHit", 0);
		thisEntity.SetInt("lastHitTime", GetTime());		
		thisEntity.SetInt("allowHit", 0);
		
		if (currentLifeLevel > 0) {
			DXSoundSample@ lostBonus = GetGameSound("bonus_lost.wav");
			if (lostBonus !is null)
				lostBonus.Play();
		}
		
	}
	thisEntity.SetInt("hit", 0);
	
	if(thisEntity.GetInt("allowHit") == 0) {
		int dHitTime = GetTime() - thisEntity.GetInt("lastHitTime");
		int k = dHitTime / 250;
		if ((k % 2) == 0) {
			thisEntity.SetAlpha(0.15f);
		}
		else {
			thisEntity.SetAlpha(1);
		}
		if(dHitTime > hitTime) {
			thisEntity.SetInt("allowHit", 1);
			thisEntity.SetAlpha(1);
		}
	}
	
	return currentLifeLevel;
}

void MoveHero(ETHEntity @thisEntity) {
	const int isRace = thisEntity.GetInt("isRace");
	const int isJump = thisEntity.GetInt("isJump");
	
	ETHInput @input = GetInputHandle();
	float speed = UnitsPerSecond(200.0f);	
	uint stride = 100;
	
	if (isRace > 0) {
		speed *= 1.5f; 
		stride *= 0.75;
	}
	
	int offsetFrame = 0;
	if(thisEntity.GetInt("lifeLevel") > 1)
		offsetFrame = 4;
	
	// Moving
	vector3 horDir(0,0,0);
	if (input.KeyDown(K_LEFT))
	{
		thisEntity.SetFrame(charaTimer.Set(0,3,stride),offsetFrame + 1);	
		horDir.x +=-1;
	}
	if (input.KeyDown(K_RIGHT))
	{
		thisEntity.SetFrame(charaTimer.Set(0,3,stride),offsetFrame);	
		horDir.x += 1;
	}
	             
	if (horDir.x != 0) {
		thisEntity.SetFloat("lastDirX", horDir.x);		
	} 
	
	vector3 lastPos = thisEntity.GetPosition();
	// Calculate new position by horizontal
	vector3 horSpeed = normalize(horDir)*speed;
	thisEntity.AddToPosition(horSpeed);		
	if (CollideStatic(thisEntity)) {
		thisEntity.SetPosition(lastPos);
	}
	
	lastPos = thisEntity.GetPosition();
	// Jump
	if ((input.GetKeyState(K_SPACE) == KS_HIT) && (isJump == 0)) {		
		vector3 testVerDir(0,5,0);
		thisEntity.AddToPosition(testVerDir);
		if (CollideStatic(thisEntity)) {
			float verSpeed = 80.0;
			if(isRace > 0) {
				verSpeed *= 1.53;
			}  
			thisEntity.SetFloat("verSpeed", -verSpeed);
			thisEntity.SetInt("isJump", 1);
			DXSoundSample@ jump = GetGameSound("hero_jump.wav");
			if (jump !is null)
				jump.Play();
		}
		thisEntity.SetPosition(lastPos);
	}	
	
	// Calculate new position by vertical
	float currentVer = thisEntity.GetFloat("verSpeed");
	vector3 verDir(0,currentVer * UnitsPerSecond(9.8f),0);	
	lastPos = thisEntity.GetPosition();
	thisEntity.AddToPosition(verDir);
	
	if(CheckCollideWithBug(thisEntity, currentVer, isJump)) {
		thisEntity.SetPosition(lastPos);
		currentVer = -50;
	}
	
	if (CollideStatic(thisEntity)) {
		thisEntity.SetPosition(lastPos);
		if(currentVer > 0)
			thisEntity.SetInt("isJump", 0);
		currentVer = 0.0;		
	}	
	
	//Update Vertical Speed
	currentVer = currentVer + speed;
	if (currentVer > 100.0f) {
		thisEntity.SetFloat("verSpeed", 100.0f);
	}
	else {
		if (currentVer > 10){
			thisEntity.SetInt("isJump", currentVer);
		}
		thisEntity.SetFloat("verSpeed", currentVer);
	}
	
	vector2 posXY = thisEntity.GetPositionXY();
	if (posXY.y > 1000) {
		GameOver();
	}
}

void ProcessKeyboard(ETHEntity @thisEntity) {
	ETHInput @input = GetInputHandle();
	// Race
	if ((input.GetKeyState(K_S) == KS_DOWN)) {		
		thisEntity.SetInt("isRace", 1 );
	}
	else {
		thisEntity.SetInt("isRace", 0);
	}
	//Shotting	
	if ((input.GetKeyState(K_CTRL) == KS_HIT) && (thisEntity.GetInt("allowShot") > 0))
	{
		ETHEntity @fireBallEnt = null;
		AddEntity("fireball.ent", thisEntity.GetPosition()+vector3(0,-thisEntity.GetFloat("height"),3), fireBallEnt);
		
		if (fireBallEnt !is null) {
			fireBallEnt.SetFloat("dirX", thisEntity.GetFloat("lastDirX"));			
			fireBallEnt.SetFloat("speed", 500.0f);
		}
		
		DXSoundSample@ fire = GetGameSound("hero_fire.wav");
		if (fire !is null)
			fire.Play();
		
	}
}

void UpdateCameraPos(ETHEntity @thisEntity) {
	// Centralizes the character
	vector2 posXY = thisEntity.GetPositionXY();
	vector2 screen = GetScreenSize();
	
	SetCameraPos(vector2(posXY.x - screen.x / 2 - heroCameraOffset.x, -heroCameraOffset.y));
	// cast a weak light over the character to let the player see it even in the dark
	AddLight(thisEntity.GetPosition()+vector3(0, 0,32), vector3(0.35f,0.2f,0.35f), 100.0f, true);
}

frameTimer charaTimer;

void ETHCallback_hero(ETHEntity @thisEntity) {
	if (thisEntity.GetInt("pause") > 0)
		return;
	int currentLifeLevel = UpdateCurrentLifeLevel(thisEntity);
	if (currentLifeLevel < 1) {
		GameOver();
		return;
	}
	
	CheckCollideWithCoin(thisEntity);
	
	MoveHero(thisEntity);
	
	ProcessKeyboard(thisEntity);
	
	UpdateCameraPos(thisEntity);
}

// Animates the fire balls (this callback function will be automatically assigned to all
// fireball.ent entities
void ETHCallback_fireball(ETHEntity @thisEntity)
{
	float dirX = thisEntity.GetFloat("dirX");
	const float speed = UnitsPerSecond(thisEntity.GetFloat("speed"));
	thisEntity.AddToPositionXY(vector2(dirX,0)*speed);
	
	ETHEntity @ent;
	if (CollideDynamic(thisEntity, ent))
	{
		if ((ent.GetEntityName() != "hero.ent") && (ent.GetEntityName() != "hero_big.ent"))
		{
			if (ent.GetInt("isAlive") != 0) {
				ent.SetInt("hit", 1);
				vector3 pos = thisEntity.GetPosition();
				AddEntity("explosion.ent", pos, 0);
				@thisEntity = DeleteEntity(thisEntity);
			}
			return;
		}
	}
	if (CollideStatic(thisEntity, ent))
	{
		vector3 pos = thisEntity.GetPosition();
		AddEntity("explosion.ent", pos, 0);
		@thisEntity = DeleteEntity(thisEntity);
		return;		
	}
}

ETHEntity @fireBallEnemy = null;