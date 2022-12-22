//======================================================================================================
// Game state class
//======================================================================================================

class DXGameState
{
	private int bugsKilled;
	private int coinsCollected;
	private int totalBugsKilled;
	private int totalCoinsCollected;
	private int currentLevel;
	private uint levelTime;
	private uint currentLevelTime;
	private uint startLevelTime;
	private bool hidden;	
	private ETHEntity @timerClock;
	private ETHEntity @bugIcon;
	private ETHEntity @coinIcon;
	private ETHEntity @bugIconAnimate;
	private ETHEntity @coinIconAnimate;
	
	private DXEventTimer animTimerCoin;
	private DXEventTimer animTimerBug;
	private DXEventTimer animTimerTimer;
	private int timerAlarmSeconds;
	
	vector2 timerTextboxSize;
	vector2 timerTextOffset;
	vector2 coinIconOffset;
	vector2 coinTextOffset;
	vector2 coinTextboxSize;
	vector2 bugIconOffset;
	vector2 bugTextOffset;
	vector2 bugTextboxSize;
	
	DXSoundSample@	currentMusic;
	
	DXGameState() {
		timerTextboxSize = vector2(70.0f, 20.0f);
		timerTextOffset = vector2(10.0f, 8.0f);
		coinIconOffset = vector2(10.0f, 0.0f);
		coinTextOffset = vector2(10.0f, 10.0f);
		coinTextboxSize = vector2(70.0f, 20.0f);
		bugIconOffset = vector2(10.0f, 0.0f);
		bugTextOffset = vector2(20.0f, 10.0f);
		bugTextboxSize = vector2(70.0f, 20.0f);
		timerAlarmSeconds = 30;
		hidden = false;
		@currentMusic = null;
		KillItems();
	}
	
	DXSoundSample@ GetCurrentMusic() {
		return currentMusic;
	}
	void SetCurrentMusic(DXSoundSample@ val) {
		if (currentMusic !is null) {
			if (currentMusic.IsPlaying)
				currentMusic.Stop();
		}
		@currentMusic = val;
	}
	
	int BugsKilled() {
		return bugsKilled;
	}

	int CoinsCollected() {
		return coinsCollected;
	}

	void AttachToScene() {
		KillItems();
		
		animTimerCoin.Reset(false);
		animTimerBug.Reset(false);
		animTimerTimer.Reset(false);
		
		ETHEntity @timer = SeekEntity("dx_scene_timer.ent");
		if (timer !is null) {
			levelTime = timer.GetUInt("time") * 1000;
			currentLevelTime = levelTime;
			if (levelTime > 0)
				AddEntity("dx_timer_clock.ent", vector3(0, 0, 0), timerClock);
		}
		else {
			levelTime = 0;
			currentLevelTime = 0;
		}
		startLevelTime = GetTime();
		
		@coinIcon = PlaceCoinIcon();
		@bugIcon = PlaceBugIcon();
		
		Hide(hidden);
	}
	void ResetLevelStats() {
		bugsKilled = 0;
		coinsCollected = 0;
	}
	ETHEntity @PlaceCoinIcon() {
		string coinName = GetLevelDescString("CoinEntity");
		if ( (coinName == "") || (coinName == "none") ) {
			coinName = "cscoin";
		}
		ETHEntity @coin;
		coinName += ".ent";
		
		AddEntity(coinName, vector3(0, 0, 0), coin);
		coin.SetLayerDepth(0.99f);
		coin.SetInt("LayerValid", 1);
		coin.SetInt("Freeze", 1);
		return coin;
	}
	ETHEntity @PlaceBugIcon() {
		ETHEntity @bug;
		AddEntity("bug_icon.ent", vector3(0, 0, 0), bug);
		bug.SetLayerDepth(0.99);
		bug.SetInt("Freeze", 1);
		return bug;
	}
	void OnCoinCollected(int amount = 1) {
		coinsCollected += amount;
		if (coinIcon !is null) {
			animTimerCoin.SetState(1);
			animTimerCoin.SetEvent(2, 300);
			if (coinIconAnimate is null) {
				@coinIconAnimate = PlaceCoinIcon();
				coinIconAnimate.SetLayerDepth(coinIconAnimate.GetLayerDepth() + 0.01f);
			}
		}
		
	}
	void OnBugKilled(int amount = 1) {
		bugsKilled += amount;
		if (bugIcon !is null) {
			animTimerBug.SetState(1);
			animTimerBug.SetEvent(2, 300);
			if (bugIconAnimate is null) {
				@bugIconAnimate = PlaceBugIcon();
				bugIconAnimate.SetLayerDepth(bugIconAnimate.GetLayerDepth() + 0.01f);
			}
		}
	}
	void OnFinishLevel() {
		totalBugsKilled += bugsKilled;
		totalCoinsCollected += coinsCollected;
	}
	void Render() {
		if (hidden)
			return;
		if (levelTime > 0) {
			RenderTimerItems();
		}
		RenderCoinItems();
		RenderBugItems();
	}
	void Update() {
		if (levelTime != 0) {
			currentLevelTime = GetTime() - startLevelTime;
			if (currentLevelTime >= levelTime)
				GameOver();
		}
		if (UpdateScaleAnimation(animTimerCoin, coinIconAnimate))
			@coinIconAnimate = null;
		if (UpdateScaleAnimation(animTimerBug, bugIconAnimate))
			@bugIconAnimate = null;
	}
	void Hide(bool bHide) {
		hidden = bHide;
		if (timerClock !is null)
			timerClock.Hide(hidden);
		if (coinIcon !is null)
			coinIcon.Hide(hidden);
		if (bugIcon !is null)
			bugIcon.Hide(hidden);
	}
	void KillItems() {
		@timerClock = null;
		@coinIcon = null;
		@bugIcon = null;
	}
	bool UpdateScaleAnimation(DXEventTimer @timer, ETHEntity @icon) {
		timer.Update();
		float fScale, fAlpha;
		switch (timer.GetState()) {
		case 0:
			break;
		case 1:
			fScale = 1 + timer.GetEventDelta() * 1;
			fAlpha =  1 - timer.GetEventDelta();
			icon.SetScale(vector2(fScale, fScale));
			icon.SetAlpha(fAlpha);
			break;
		case 2:
			DeleteEntity(icon);
			timer.SetState(0);
			return true;
		}
		return false;
	}
	void RenderTimerItems() {
		vector2 camPos = GetCameraPos();
		vector2 scrSize = GetScreenSize();
		vector2 clockSize = timerClock.GetSize();
		vector2 clockPos(floor(camPos.x + scrSize.x - timerTextboxSize.x - clockSize.x * 0.5), floor(camPos.y + clockSize.y * 0.5 + timerTextboxSize.y * 0.5));
		vector2 textPos(floor(scrSize.x - timerTextboxSize.x + timerTextOffset.x), floor(timerTextboxSize.y * 0.5 + timerTextOffset.y));
		
		timerClock.SetPositionXY(clockPos);
		
		string levelTimeSecs = int((levelTime - currentLevelTime) / 1000);
		if (currentLevelTime >= levelTime)
				levelTimeSecs = 0; 

		DrawText(textPos, levelTimeSecs, "Verdana20_shadow.fnt", ARGB(255,255,255,255));
	}
	void RenderCoinItems() {
		vector2 camPos = GetCameraPos();
		vector2 scrSize = GetScreenSize();
		vector2 iconSize = coinIcon.GetSize();
		vector2 pivot = coinIcon.GetPivotAdjust();
		vector2 iconPos(camPos.x + coinIconOffset.x + iconSize.x * 0.5f, camPos.y + iconSize.y * 0.5f + coinIconOffset.y + coinTextboxSize.y * 0.5);
		vector2 textPos(iconSize.x + coinIconOffset.x + coinTextOffset.x, coinTextboxSize.y * 0.5 + coinTextOffset.y);
		
		coinIcon.SetPositionXY(iconPos);
		if (coinIconAnimate !is null)
			coinIconAnimate.SetPositionXY(iconPos);
		
		string levelCoins = "X " + coinsCollected;

		DrawText(textPos, levelCoins, "Verdana20_shadow.fnt", ARGB(255,255,255,255));
	}
	void RenderBugItems() {
		vector2 camPos = GetCameraPos();
		vector2 scrSize = GetScreenSize();
		vector2 iconSize = coinIcon.GetSize();
		vector2 pivot = coinIcon.GetPivotAdjust();
		vector2 iconPos(camPos.x + scrSize.x * 0.5 + bugIconOffset.x - iconSize.x * 0.5f - bugTextboxSize.x * 0.5, camPos.y + iconSize.y * 0.5f + bugIconOffset.y + bugTextboxSize.y * 0.5);
		vector2 textPos(scrSize.x * 0.5 - bugTextboxSize.x * 0.5 + bugTextOffset.x, bugTextboxSize.y * 0.5 + bugTextOffset.y);
		
		bugIcon.SetPositionXY(iconPos);
		if (bugIconAnimate !is null)
			bugIconAnimate.SetPositionXY(iconPos);
	
		string levelBugs = "X " + bugsKilled;

		DrawText(textPos, levelBugs, "Verdana20_shadow.fnt", ARGB(255,255,255,255));
	}
	void SetCurrentLevel(int level) {
		currentLevel = level;
	}
	int GetCurrentLevel() {
		return currentLevel;
	}
	
	
};
