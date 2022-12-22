//======================================================================================================
// Levels common scene loading\init routines
//======================================================================================================

void SwitchToLevel(int level) {
	string sceneName = "level" + level + ".esc";
	LoadScene("scenes\\" + sceneName, "InitLevel" + level, "LoopLevel" + level);
	gameState.SetCurrentLevel(level);
}
void SwitchToLevel(string name, int coins, int bugs) {
	LoadScene("scenes\\" + name + ".esc", "CommonLevelInit", "CommonLevelLoop");
	gameState.SetCurrentLevel(7);
	gameState.OnBugKilled(bugs);
	gameState.OnCoinCollected(coins);
}
void CommonLevelInit() {
	CreateHero();
	gameState.ResetLevelStats();
	gameState.Hide(false);
	
	CommonSceneInit();
	
	string musicName = GetLevelDescString("Music");
	if ( (musicName == "") || (musicName == "none") )
		musicName = "main_theme.ogg";
	
	print("setting music (" + musicName + ")");
	DXSoundSample@ music = GetGameSound(musicName);
	gameState.SetCurrentMusic(music);
	if (music !is null) {
		music.Loop(true);
		music.Play();
		music.SetVolume(0.4f);
	}
	
}

void CommonLevelLoop() {
	CommonSceneUpdate();
}


void InitLevel7() {
	CommonLevelInit();
}
void LoopLevel7() {
	CommonLevelLoop();
}


void InitLevel8() {
	CommonLevelInit();
}
void LoopLevel8() {
	CommonLevelLoop();
}

void InitLevel9() {
	CommonLevelInit();
}
void LoopLevel9() {
	CommonLevelLoop();
}

void InitLevel10() {
	CommonLevelInit();
}
void LoopLevel10() {
	CommonLevelLoop();
}