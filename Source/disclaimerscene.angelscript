//======================================================================================================
// Disclaimer scenes utilites file
//======================================================================================================
ETHEntity @diss_cursorA;
ETHEntity @diss_cursorB;
ETHEntity @diss_pressEnter;

uint diss_startTime;
uint diss_lastTime;
uint diss_timeOut;
uint diss_state;

void SwitchToDisclaimerScene() {
	LoadScene("scenes\\disclaimer.esc", "InitDisclaimerScene", "LoopDisclaimerScene");
}
void InitDisclaimerCursor(ETHEntity @cursor) {
	if (cursor !is null) {
		cursor.SetInt("visible", 1);
		cursor.SetInt("time", 0);
		cursor.SetInt("lastTime", 0);
		cursor.SetInt("switchTime", 500);
		cursor.SetInt("enabled", 1);
	}
}
void InitDisclaimerScene() {
	diss_startTime = GetTime();
	diss_lastTime = diss_startTime;
	diss_timeOut = 5000;
	diss_state = 0;
	@diss_cursorA = null;
	@diss_cursorB = null;
	@diss_pressEnter = null;
	
	gameState.Hide(true);
	
	ETHEntityArray cursors;
	GetEntityArray("dx_disclaimer_cursor.ent", cursors);
	
	for (uint i = 0; i < cursors.size(); i++) {
		ETHEntity @cursor = cursors[i];
		
		if (cursor.GetInt("Order") > 0)
			@diss_cursorB = cursor;
		else
			@diss_cursorA = cursor;
	}
	
	InitDisclaimerCursor(diss_cursorA);
	InitDisclaimerCursor(diss_cursorB);
	
	@diss_pressEnter = SeekEntity("dx_disclaimer_bottom.ent");
	
	if (diss_pressEnter !is null)
		diss_pressEnter.Hide(true);
	if (diss_cursorB !is null) {
		diss_cursorB.Hide(true);
		diss_cursorB.SetInt("enabled", 0);
	}
}
void LoopDisclaimerScene() {
	uint time = GetTime();
	uint iDelta = time - diss_lastTime;
	float fDelta = float(iDelta);
	uint iSceneTime = time - diss_startTime;
	float fSceneTime = float(iSceneTime);
	ETHInput @input = GetInputHandle();
	
	switch (diss_state) {
	case 0:
		if (iSceneTime > diss_timeOut) {
			if (diss_cursorA !is null){
				diss_cursorA.SetInt("enabled", 0);
				diss_cursorA.Hide(true);
			}
			if (diss_cursorB !is null) {
				diss_cursorB.SetInt("enabled", 1);
				diss_cursorB.Hide(false);
			}
			if (diss_pressEnter !is null)
				diss_pressEnter.Hide(false);
			diss_state = 1;
		}
		break;
	case 1:
		if (input.KeyDown(K_ENTER)){
			StartGame();
		}
		break;
	}
	
	diss_lastTime = time;
	
	CommonSceneUpdate();
}
void ETHCallback_dx_disclaimer_cursor(ETHEntity @cursor){
	if (cursor.GetInt("enabled") == 0)
		return;
	uint time = GetTime();
	uint delta = time - cursor.GetInt("lastTime");
	cursor.AddToInt("time", delta);
	if (cursor.GetInt("time") > cursor.GetInt("switchTime")){
		cursor.SetInt("time", 0);
		if (cursor.IsHidden())
			cursor.Hide(false);
		else
			cursor.Hide(true);
	}
	cursor.SetInt("lastTime", time);
}
