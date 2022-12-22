frameTimer characterTimer;

void MoveCharacter(ETHEntity @thisEntity) {
	vector3 v3Dir(0,0,0);
	int dir = thisEntity.GetInt("Direction");
	const uint stride = 200;
	if (dir == 0) {
		thisEntity.SetFrame(characterTimer.Set(0,3,stride),0);
		v3Dir.x +=-1;
	}
	else {
		thisEntity.SetFrame(characterTimer.Set(0,3,stride),1);	
		v3Dir.x += 1;
	}
	vector3 lastPos = thisEntity.GetPosition();
	thisEntity.AddToPosition(v3Dir);
	if (CollideStatic(thisEntity)) {
		thisEntity.SetPosition(lastPos);
		if (dir == 0)
			thisEntity.SetInt("Direction", 1);
		else
			thisEntity.SetInt("Direction", 0);
	}
	MoveVertically(thisEntity);
}


bool IsActive(ETHEntity @thisEntity) {
	DATA_TYPE dataType = thisEntity.CheckCustomData("isActive");
	if (dataType == DT_NODATA) {
		thisEntity.SetInt("isActive", 0);
	}

	int isActive = thisEntity.GetInt("isActive");
	if (isActive > 0)
		return true;
	else {
		vector2 camera = GetCameraPos();
		vector3 position = thisEntity.GetPosition();
		int deltaX = position.x - camera.x;
		vector2 screen = GetScreenSize();
		if (deltaX < screen.x + 20) {
			thisEntity.SetInt("isActive", 1);
			return true;
		}
		else
			return false;
	}
}

void MoveVertically(ETHEntity @thisEntity) {
	float speed = UnitsPerSecond(150.0f);
	
	// Calculate new position by vertical
	float currentVer = thisEntity.GetFloat("verSpeed");
	vector3 verDir(0, currentVer * UnitsPerSecond(9.8f), 0);	
	vector3 lastPos = thisEntity.GetPosition();
	thisEntity.AddToPosition(verDir);
	if (CollideStatic(thisEntity)) {
		thisEntity.SetPosition(lastPos);
		currentVer = 0.0;
	}
	
	//Update Vertical Speed
	currentVer = currentVer + speed;
	if (currentVer > 100.0f)
		DeleteEntity(thisEntity);
	else
		thisEntity.SetFloat("verSpeed", currentVer);
}

vector3 GetRandomOffscreenPosition()
{
	vector2 screen = GetScreenSize();
	vector3 randPos;
	
	if (rand(0, 1) == 0) {
		randPos.x = float(rand(-screen.x, 0));
	}
	else {
		randPos.x = float(rand(screen.x, screen.x * 2));
	}
	
	if (rand(0, 1) == 0) {
		randPos.y = float(rand(-screen.y, 0));
	}
	else {
		randPos.y = float(rand(screen.y, screen.y * 2));
	}
	
	return randPos;
}

//------------------------------------------------------------------------------------------------------
// Level description utility functions
//------------------------------------------------------------------------------------------------------
ETHEntity @g_levelDesc = null;

bool FindLevelDesc() {
	//if (g_levelDesc is null)
	@g_levelDesc = SeekEntity("dx_level_description.ent");
	return (g_levelDesc !is null);
}
string GetLevelDescString(string name) {
	if (FindLevelDesc())
		return g_levelDesc.GetString(name);
	return "";
}
float GetLevelDescFloat(string name) {
	if (FindLevelDesc())
		return g_levelDesc.GetFloat(name);
	return 0.0f;
}
int GetLevelDescInt(string name) {
	if (FindLevelDesc())
		return g_levelDesc.GetInt(name);
	return 0;
}
uint GetLevelDescUInt(string name) {
	if (FindLevelDesc())
		return g_levelDesc.GetUInt(name);
	return 0;
}

//------------------------------------------------------------------------------------------------------
// Hero
//------------------------------------------------------------------------------------------------------
ETHEntity @FindHero() { 
	ETHEntity @hero = SeekEntity("hero.ent");
	if (hero !is null)
		return hero;
	return SeekEntity("hero_big.ent");
}	
void CreateHero()
{
	ETHEntity @hero;
	AddEntity("hero.ent", vector3(150,-500,0.5), hero);		
	Init_hero(hero);
}

//------------------------------------------------------------------------------------------------------
// Common scenes handler
//------------------------------------------------------------------------------------------------------
void CommonSceneInit() {
	gameState.AttachToScene();
	ReloadGameSounds();
}

void CommonSceneUpdate()
{
	gameState.Update();
	UpdateTriggerEntities();
	UpdateDeath();
	
	ETHEntity @hero = FindHero();
	if (hero !is null)
		hero.SetInt("pause", 0);
	
	ETHEntity @back = SeekEntity("dx_background.ent");
	if (back !is null) {
		vector2 pos = GetCameraPos();
		back.SetPosition(vector3(pos.x + 400, 260, -15));
	}	
	
	// Handle keyboard
	ETHInput @input = GetInputHandle();
	if (input.KeyDown(K_ESC)){
		Exit();
	}
	if (input.GetKeyState(K_ALT) == KS_DOWN && input.GetKeyState(K_RETURN) == KS_HIT) {
		if (hero !is null)
			hero.SetInt("pause", 1);
	    SetWindowProperties("DX GAME", 800, 600, !Windowed(), true, PF32BIT);
		if (hero !is null)
			hero.SetInt("pause", 0);
	}
	
	//#if DEBUG
	/* vector3 v3Pos(0,0,0);
	if (hero !is null)
		v3Pos = hero.GetPosition();
	
	const float fFPS = GetFPSRate();
	DrawText(vector2(0,0),  "FPS: " + fFPS + "\n"
							"Scene name: " + GetSceneFileName() + "\n"
							"Hero pos: " + vector3ToString(v3Pos) + "\n"
							"Camera pos: " + vector2ToString(GetCameraPos()),
							"Verdana20.fnt", ARGB(50,255,255,255)); */
	//#endif

	gameState.Render();
}

void StartGame() {
	SwitchToLevelIntro(7);
}

void CompleteLevel(ETHEntity @hero) {
	hero.SetInt("pause", 1);
	
	int level = gameState.GetCurrentLevel();
	
	gameState.OnFinishLevel();
	
	LoadScene("scenes\\LevelComplete" + level + ".esc", "InitLevelCompleteScene", "LevelCompleteSceneUpdate");
	levelCompleteStartTime = GetTime();
}

int levelCompleteStartTime;

void InitLevelCompleteScene() {
	CommonSceneInit();
}

ETHEntity@ complete_man;
DXEventTimer complete_manTimer;

void LevelCompleteSceneUpdate() {
	gameState.Hide(true);
	CommonSceneUpdate();
	
	int time = GetTime();
	int coins;
	int bugs;
	int delta = time - levelCompleteStartTime;
	int needBugs = GetLevelDescInt("PassBugs");
	int needBonus = GetLevelDescInt("PassBonus");
	int actualCoins = gameState.CoinsCollected();
	int actualBugs = gameState.BugsKilled();
	bool coinsComplete = actualCoins >= needBonus;
	bool bugsComplete = actualBugs >= needBugs;
	if (delta < 1000) {
		coins = rand (0, 999);
		bugs = rand (0, 999);
		DXSoundSample@ counter = GetGameSound("complete_counter.wav");
		if (counter !is null)
			counter.Play();
	}
	else {
		coins = actualCoins;
		bugs = actualBugs;
		if(delta > 1500) {
			DrawText(vector2(400, 390), "Need: " + needBonus, "Verdana20_shadow.fnt", ARGB(255, 255, 255, 255));
			DrawText(vector2(400, 450), "Need: " + needBugs, "Verdana20_shadow.fnt", ARGB(255, 255, 255, 255));
			if(delta > 2000) {
				PrintResult(vector2(560, 390), coinsComplete);
				PrintResult(vector2(560, 450), bugsComplete);
				DrawText(vector2(400, 560), "Press ENTER to continue, or ESC to exit", "Verdana20_shadow.fnt", ARGB(255, 255, 255, 255));
				if (coinsComplete && bugsComplete) {
					DrawText(vector2(320, 500), "LEVEL UP!!!", "Verdana30_shadow.fnt", ARGB(255, 100, 100, 255));
					if (complete_man is null) {
						complete_manTimer.Reset(false);
						complete_manTimer.SetEvent(1, 2000);
						AddEntity("dx_man_blya.ent", vector3(850, 480, 0), complete_man);
						complete_man.SetLayerDepth(0.99f);
						DXSoundSample@ sound = GetGameSound("man_blya.wav");
						if (sound !is null)
							sound.Play(1.0f);
					}
					else {
						complete_manTimer.Update();
						if (complete_manTimer.GetState() == 0)
							complete_man.SetPositionXY(vector2(850 - complete_manTimer.GetEventDelta() * 1000, 480));
					}
				}
				else {
					DrawText(vector2(300, 500), "WORK BETTER!!!", "Verdana30_shadow.fnt", ARGB(255, 100, 100, 255));
				}
			}
		}
	}
	DrawText(vector2(280, 390), "" + coins, "Verdana20_shadow.fnt", ARGB(255, 255, 255, 255));
	DrawText(vector2(280, 450), "" + bugs, "Verdana20_shadow.fnt", ARGB(255, 255, 255, 255));
	
	ETHInput @input = GetInputHandle();
	if (input.KeyDown(K_ENTER)) {
		if (coinsComplete && bugsComplete) {
			int level = gameState.GetCurrentLevel();
			if (level == 10) {
				LoadScene("scenes\\Finish.esc", "CommonSceneInit", "FinishSceneUpdate");
				finishTime = GetTime();
			}
			else
				SwitchToLevelIntro(level + 1);
		}
		else
			SwitchToLevel(gameState.GetCurrentLevel());
		
		@complete_man = null;
	}
	if (input.KeyDown(K_ESC))
		Exit();
}
int finishTime;
void FinishSceneUpdate() {
	gameState.Hide(true);
	CommonSceneUpdate();
	
	int delta = GetTime() - finishTime;
	int startHN = 3000;
	float alphaTime = 500;
	if(delta > startHN) {
		ETHEntity @lasVegas = SeekEntity("dx_LasVegas.ent");
		if (delta < startHN + alphaTime) {
			float alpha = (delta - startHN) / alphaTime;
			lasVegas.SetAlpha(1.0 - alpha);
		}
		else {
			int radius = 10;
			float offset = delta / 50.0;
			float x = -radius * sin(offset);
			float y = radius * cos(offset);
			AddLight(vector3(318 + x, 230 + y, 16), vector3(0.0, 0.75, 1.0), 64, false);
			AddLight(vector3(270 + x, 367 + y, 16), vector3(1.0, 0.0, 1.0), 64, false);
			AddLight(vector3(354 + x, 393 + y, 16), vector3(1.0, 0.0, 1.0), 64, false);
			AddLight(vector3(263 + x, 335 + y, 16), vector3(1.0, 1.0, 0.0), 64, false);
			AddLight(vector3(354 + x, 356 + y, 16), vector3(1.0, 1.0, 0.0), 64, false);
			AddLight(vector3(331 + x, 423 + y, 16), vector3(1.0, 1.0, 0.0), 64, false);
			AddLight(vector3(242 + x, 498 + y, 16), vector3(0.7, 0.7, 0.0), 64, false);
			AddLight(vector3(344 + x, 475 + y, 16), vector3(0.0, 1.0, 0.0), 64, false);
			AddLight(vector3(231 + x, 422 + y, 16), vector3(1.0, 1.0, 0.0), 64, false);
			lasVegas.Hide(true);
		}
	}
	
	ETHInput @input = GetInputHandle();
	if (input.KeyDown(K_ESC))
		Exit();
}
void PrintResult(vector2 pos, bool pass) {
	if(pass)
		DrawText(pos, "Success", "Verdana20_shadow.fnt", ARGB(255, 0, 255, 0));
	else
		DrawText(pos, "Fail", "Verdana20_shadow.fnt", ARGB(255, 255, 0, 0));
}
void GameOver() {
	/*ETHEntity @desc = SeekEntity("dx_level_description.ent");
	if (desc != null) {
		string nextScene = "scenes\\" + desc.GetString("DeathScene") + ".esc";		
		LoadScene(nextScene, "", "GameLoop");		
	}
    else 
		Exit();*/
		
	ETHEntity @hero = SeekEntity("hero.ent");
	
	if (hero !is null) {
		if (hero.GetInt("__gameover__")  == 0) {
			SwitchToDeathScene(GetLevelDescInt("Level"));
			hero.SetInt("__gameover__", 1);
		}
	}
	
}

//------------------------------------------------------------------------------------------------------
// Camera related fuctions
//------------------------------------------------------------------------------------------------------
vector2 CenterEntityOnScreen(ETHEntity @entity) {
	vector2 camPos = GetCameraPos();
	vector2 scrSize = GetScreenSize();
	vector2 newPos(camPos.x + scrSize.x / 2.0f, camPos.y + scrSize.y / 2.0f);	
	if (entity !is null) {
		vector2 pivot = entity.GetPivotAdjust();
		newPos += pivot;
		entity.SetPositionXY(newPos);
	}
	return newPos;
}

//------------------------------------------------------------------------------------------------------
// Various automated objects
//------------------------------------------------------------------------------------------------------

void ETHCallback_dx_9_tv(ETHEntity @tv) {
	if (tv.GetInt("isInitialized") == 0) {
		tv.SetInt("lastTime", GetTime());
		tv.SetInt("switchTime", 2000);
		tv.SetInt("isInitialized", 1);
	}
	
	uint delta = GetTime() - tv.GetInt("lastTime");
	
	if (delta > tv.GetInt("switchTime"))
	{
		tv.SetInt("lastTime", GetTime());
		uint frame = tv.GetFrame();
		frame++;
		
		if (frame >= tv.GetNumFrames())
			frame = 0;
			
		tv.SetFrame(frame);
	}
}

//------------------------------------------------------------------------------------------------------
// Event-timer utility class
//------------------------------------------------------------------------------------------------------

class DXEventTimer {
	private uint currentTime;
	private uint startTime;
	private uint eventTime;
	private uint timeFromStart;
	private uint delta;
	private uint state;
	private uint eventState;
	private bool eventTriggered;
	
	DXEventTimer() {
		Reset(false);
	}
	void Reset(bool preserveEvent) {
		currentTime = GetTime();
		startTime = currentTime;
		timeFromStart = 0;
		delta = 0;
		
		if (!preserveEvent)	{
			eventTime = 0;
			eventState = 0;
			state = 0;
			eventTriggered = false;
		}
	}
	void SetEvent(uint evState, uint evTime) {
		eventState = evState;
		eventTime = evTime;
		startTime = GetTime();
		currentTime = startTime;
		eventTriggered = false;
	}
	void Update() {
		uint time = GetTime();
		timeFromStart = time - startTime;
		delta = time - currentTime;
		
		if ( (eventTime != 0) && (timeFromStart >= eventTime) ) {
			state = eventState;
			eventTriggered = true;
			eventTime = 0;
		}
		
		currentTime = time;
	}
	bool IsEventTriggered() {
		return eventTriggered;
	}
	uint GetCurrentTime() {
		return currentTime;
	}
	uint GetStartTime() {
		return startTime;
	}
	uint GetTimeFromStart() {
		return timeFromStart;
	}
	uint GetDelta() {
		return delta;
	}
	uint GetEventTime() {
		return eventTime;
	}
	uint GetState() {
		return state;
	}
	void SetState(uint newState) {
		state = newState;
	}
	float GetEventDelta() {
		if (eventTime == 0)
			return 0;
		return float(timeFromStart) / float(eventTime);
	}
};





