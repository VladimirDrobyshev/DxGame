//======================================================================================================
// Death scenes utilites file (lives <= 0)
//======================================================================================================


class DXDeathItems {
	private ETHEntity @entDeath;
	private ETHEntity @entDarkness;
	private uint mode;
	private vector2 deathStart;
	private vector2 deathEnd;
	private float deathScaleFactor;
	
	
	void PlaceItems(uint withMode) {
		mode = withMode;
		KillItems();
		switch (mode) {
		case 0:
			AddEntity("dx_hero_death_add.ent", vector3(0, 0, 0), entDeath);
			AddEntity("dx_hero_death_dark.ent", vector3(0, 0, 0), entDarkness);
			entDeath.SetInt("isAnimated", 1);
			entDeath.SetInt("animInterval", 80);
			entDeath.SetInt("animLastTime", GetTime());
			entDeath.SetInt("animTime", 0);
			entDarkness.SetLayerDepth(0.98);
			Update(0);
			break;
		case 1:
			AddEntity("dx_hero_death_add.ent", vector3(0, 0, 0), entDeath);
			deathStart = CenterEntityOnScreen(entDeath);
			deathScaleFactor = 130.0f / float(entDeath.GetSize().y);
			deathEnd = GetCameraPos() + vector2(entDeath.GetSize().x * 0.5f * deathScaleFactor, entDeath.GetSize().y * 0.5f * deathScaleFactor);
			break;
		}
	}
	void Update(float delta) {
		vector2 camPos = GetCameraPos();
		vector2 scrSize = GetScreenSize();
		
		switch (mode) {
		case 0:
			if (entDarkness != null) {
				entDarkness.SetPosition(vector3(camPos.x, 75, 100));
				entDarkness.SetAlpha(delta);
			}
			break;
		case 1:
			if (entDeath !is null) {
				float lDelta = pow(delta, 3);
				
				vector2 deathDir = deathEnd - deathStart;
				deathDir *= lDelta;
				entDeath.SetPositionXY(deathStart + deathDir);
				float scale = deathScaleFactor + (1 - deathScaleFactor) * (1 - lDelta);
				entDeath.SetScale(vector2(scale, scale));
				entDeath.SetAngle(lDelta * 359.9);
			}
			break;
		}
	}
	void KillItems() {
		@entDeath = null;
		@entDarkness = null;
	}
}

DXEventTimer dsc_eventTimer;
DXDeathItems dsc_deathItems;
int dsc_deathLevel;
const uint deathItemsTime = 5000;
const uint deathSceneInitTime = 1500;
string dsc_music;

void SwitchToDeathScene(int level) {
	dsc_deathLevel = level;
	dsc_eventTimer.Reset(false);
	dsc_eventTimer.SetState(1);
	dsc_eventTimer.SetEvent(2, deathItemsTime);
	dsc_deathItems.PlaceItems(0);
	DXSoundSample@ muah = GetGameSound("evilmuah.wav");
	if (muah !is null)
		muah.Play();
	
	dsc_music = ""; // Pase music change here

	if (dsc_music == "")
		dsc_music = "game_over.ogg";
	
	DXSoundSample@ music = GetGameSound(dsc_music);
	gameState.SetCurrentMusic(music);
	if (music !is null) {
		music.Loop(true);
		music.Play();
		music.SetVolume(1.0f);
	}

}
void LoadDeathScene() {
	string sceneName = GetLevelDescString("DeathScene");
	if ((sceneName == "") || (sceneName == "none"))
		sceneName = "deathscene_lvl" + dsc_deathLevel + ".esc";
	LoadScene("scenes\\" + sceneName, "InitDeathSceneLvl" + dsc_deathLevel, "LoopDeathSceneLvl" + dsc_deathLevel);
	dsc_deathItems.KillItems();
}

//------------------------------------------------------------------------------------------------------
// Called from current game-level scene
//------------------------------------------------------------------------------------------------------
void UpdateDeath() {
	if (dsc_eventTimer.GetState() == 0)
		return;
	dsc_eventTimer.Update();
	if (dsc_eventTimer.IsEventTriggered())
		LoadDeathScene();
	dsc_deathItems.Update(dsc_eventTimer.GetEventDelta());
}
void ProcessKeyboard() {
	ETHInput @input = GetInputHandle();
	if ((input.GetKeyState(K_ENTER) == KS_DOWN)) {		
		dsc_deathItems.KillItems();
		dsc_eventTimer.Reset(false);
		SwitchToLevel(dsc_deathLevel);
	}
	if ((input.GetKeyState(K_ESC) == KS_DOWN)) {		
		Exit();
	}
}
//------------------------------------------------------------------------------------------------------
// Level-independent
//------------------------------------------------------------------------------------------------------
void InitDeathScene() {
	dsc_deathItems.PlaceItems(1);
	dsc_eventTimer.SetEvent(3, deathSceneInitTime);
	
}
void LoopDeathScene() {
	ProcessKeyboard();
	dsc_eventTimer.Update();
	if (dsc_eventTimer.IsEventTriggered()) {
		dsc_deathItems.Update(1.0);
		DrawText(vector2(150, 20), "You are dead now\nPress 'ENTER' to restart the level or 'ESC' to exit", "Verdana20.fnt", ARGB(255,255,255,255));
	}
	else
		dsc_deathItems.Update(dsc_eventTimer.GetEventDelta());
}
//------------------------------------------------------------------------------------------------------
// Level-dependent
//------------------------------------------------------------------------------------------------------
void InitDeathSceneLvl7() {
	InitDeathScene();
}
void LoopDeathSceneLvl7() {
	LoopDeathScene();
}

void InitDeathSceneLvl8() {
	InitDeathScene();
}
void LoopDeathSceneLvl8() {
	LoopDeathScene();
}

void InitDeathSceneLvl9() {
	InitDeathScene();
}
void LoopDeathSceneLvl9() {
	LoopDeathScene();
}

void InitDeathSceneLvl10() {
	InitDeathScene();
}
void LoopDeathSceneLvl10() {
	LoopDeathScene();
}
//------------------------------------------------------------------------------------------------------
// Animations
//------------------------------------------------------------------------------------------------------
void ETHCallback_dx_hero_death_add(ETHEntity@ ent) {
	if (ent.GetInt("isAnimated") == 1) {
		uint time = GetTime();
		ent.AddToInt("animTime", time - ent.GetInt("animLastTime"));
		if (ent.GetInt("animTime") > ent.GetInt("animInterval")) {
			ent.SetInt("animTime", 0);
			ent.SetInt("isDown", (ent.GetInt("isDown") == 0) ? 1 : 0);
		}
		ent.SetInt("animLastTime", time);
	
		CenterEntityOnScreen(ent);
		if (ent.GetInt("isDown") == 0)
			ent.SetPositionXY(ent.GetPositionXY() + vector2(0.0f, 10.0f));
		else 
			ent.SetPositionXY(ent.GetPositionXY() + vector2(0.0f, -10.0f));
	}
}

