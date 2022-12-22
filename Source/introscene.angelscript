//======================================================================================================
// Intro scenes utilites file
//======================================================================================================
ETHEntityArray pieces;
ETHEntityArray piecesGame;

uint intro_startTime;
uint intro_lastTime;
uint intro_step;
uint intro_presentTime;
uint intro_gameTime;
uint intro_timeOut;
const uint intro_numIntros = 2;
uint intro_number;

void SwitchToIntroScene(int number = 0) {
	intro_number = number;
	string suffix = "";
	if (number > 0)
		suffix = number;
	LoadScene("scenes\\intro" + suffix + ".esc", "InitIntroScene", "LoopIntroScene");
}
void RandomizePieces(ETHEntityArray @pieces, int timeLow, int TimeHigh) {
	for (uint index = 0; index < pieces.size(); index++) {
		ETHEntity @piece = pieces[index];
		
		vector3 pos = piece.GetPosition();
		piece.SetVector3("targetPosition", pos);
		piece.SetPosition(GetRandomOffscreenPosition());
		piece.SetVector3("startPosition", piece.GetPosition());
		piece.SetFloat("targetTime", float(rand(timeLow, TimeHigh)));
	}
}
void InitIntroScene() {
	intro_startTime = GetTime();
	intro_lastTime = intro_startTime;
	intro_presentTime = 3000;
	intro_gameTime = 3000;
	intro_timeOut = 3000;
	intro_step = 0;
	
	pieces.clear();
	piecesGame.clear();
	
	gameState.Hide(true);
	
	GetEntityArray("dx_letter_point.ent", pieces);
	GetEntityArray("dx_letter_point_1.ent", piecesGame);
	
	RandomizePieces(@pieces, 2000, intro_presentTime);
	RandomizePieces(@piecesGame, 2000, intro_gameTime);
	
	CommonSceneInit();
	
	DXSoundSample@ music = GetGameSound("intro.ogg");
	if (@music != gameState.GetCurrentMusic()) {
		gameState.SetCurrentMusic(music);
		if (music !is null) {
			music.Loop(true);
			music.Play();
			music.SetVolume(1.0f);
		}
	}
}
void LoopIntroScene() {
	uint time = GetTime();
	uint iDelta = time - intro_lastTime;
	float fDelta = float(iDelta);
	uint iSceneTime = time - intro_startTime;
	float fSceneTime = float(iSceneTime);
	
	switch (intro_step)
	{
	case 0:
		if (iSceneTime > intro_presentTime)
			intro_step = 1;

		for (uint index = 0; index < pieces.size(); index++) {
			ETHEntity @piece = pieces[index];
		
			vector3 startPos = piece.GetVector3("startPosition");
			vector3 targetPos = piece.GetVector3("targetPosition");
			vector3 dir = targetPos - startPos;
			float f = fSceneTime / piece.GetFloat("targetTime");
			
			f = sqrt(sqrt(sqrt(f)));
		
			if (f >= 1.0f)
				piece.SetPosition(targetPos);
			else
				piece.SetPosition(startPos + dir * f);
		}
		if (intro_step == 1)
			intro_startTime = time;
		break;
	case 1:
		if (piecesGame.size() == 0) {
			intro_step = 2;
			break;
		}
		
		if (iSceneTime > intro_gameTime)
			intro_step = 2;
		
		for (uint index = 0; index < piecesGame.size(); index++) {
			ETHEntity @piece = piecesGame[index];
		
			vector3 startPos = piece.GetVector3("startPosition");
			vector3 targetPos = piece.GetVector3("targetPosition");
			vector3 dir = targetPos - startPos;
			float f = fSceneTime / piece.GetFloat("targetTime");
			
			f = sqrt(sqrt(sqrt(f)));
			
			if (f >= 1.0f)
				piece.SetPosition(targetPos);
			else
				piece.SetPosition(startPos + dir * f);
		}
		if (intro_step == 2)
			intro_startTime = time;
		break;
	case 2:
		if (iSceneTime > intro_timeOut) {
			intro_number++;
			if (intro_number >= intro_numIntros)
				SwitchToDisclaimerScene();
			else
				SwitchToIntroScene(intro_number);
		}
		break;
	}
		
	intro_lastTime = time;
	
	CommonSceneUpdate();
}
