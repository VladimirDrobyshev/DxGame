//======================================================================================================
// Level intros
//======================================================================================================
const uint lvlint_defaultDelay = 3000;
const uint lvlint_defaultFadeIn = 3000;
const uint lvlint_defaultFadeOut = 3000;
uint lvlint_delay;
uint lvlint_fadeIn;
uint lvlint_fadeOut;
int lvlint_level;
ETHEntity@ lvlint_fader;
DXEventTimer lvlint_eventTimer;

void SwitchToLevelIntro(int level) {
	lvlint_delay = 0;
	lvlint_fadeIn = 0;
	lvlint_fadeOut = 0;
	lvlint_level = level;
	
	LoadScene("scenes\\introscene_lvl" + level + ".esc", "InitLevelIntro" + level, "LoopLevelIntro" + level);
}

void CommonInitLevelIntro() {
	if (lvlint_delay == 0)
		lvlint_delay = lvlint_defaultDelay;
	if (lvlint_fadeIn == 0)
		lvlint_fadeIn  = lvlint_defaultFadeIn;
	if (lvlint_fadeOut == 0)
		lvlint_fadeOut = lvlint_defaultFadeOut;
	
	AddEntity("dx_hero_death_dark.ent", vector3(0, 0, 0), lvlint_fader);
	
	lvlint_fader.SetLayerDepth(0.98);
	lvlint_fader.SetAlpha(1.0f);
	lvlint_eventTimer.Reset(false);
	lvlint_eventTimer.SetEvent(1, lvlint_fadeIn);
	
	CommonSceneInit();
	
	gameState.Hide(true);
	
	DXSoundSample@ music = GetGameSound("level_intro.ogg");
	if (@music != gameState.GetCurrentMusic()) {
		gameState.SetCurrentMusic(music);
		if (music !is null) {
			music.Loop(true);
			music.Play();
			music.SetVolume(1.0f);
		}
	}
	
}

void CommonLoopLevelIntro() {
	lvlint_eventTimer.Update();
	switch (lvlint_eventTimer.GetState()) {
	case 0:
		lvlint_fader.SetAlpha(1 - lvlint_eventTimer.GetEventDelta());
		break;
	case 1:
		if (lvlint_eventTimer.IsEventTriggered()) {
			lvlint_eventTimer.SetEvent(2, lvlint_delay);
			lvlint_fader.Hide(true);
		}
		break;
	case 2:
		if (lvlint_eventTimer.IsEventTriggered()) {
			lvlint_eventTimer.SetEvent(3, lvlint_fadeOut);
			lvlint_fader.Hide(false);
		}
		else
			lvlint_fader.SetAlpha(lvlint_eventTimer.GetEventDelta());
		break;
	case 3:
		if (lvlint_eventTimer.IsEventTriggered()) {
			SwitchToLevel(lvlint_level);
		}
		break;
	}
}

void InitLevelIntro7() {
	CommonInitLevelIntro();
}
void LoopLevelIntro7() {
	CommonLoopLevelIntro();
}

void InitLevelIntro8() {
	CommonInitLevelIntro();
}
void LoopLevelIntro8() {
	CommonLoopLevelIntro();
}

void InitLevelIntro9() {
	CommonInitLevelIntro();
}
void LoopLevelIntro9() {
	CommonLoopLevelIntro();
}

void InitLevelIntro10() {
	CommonInitLevelIntro();
}
void LoopLevelIntro10() {
	CommonLoopLevelIntro();
}