//======================================================================================================
// Sound utilites
//======================================================================================================

class DXSoundSample {
	private string name;
	private bool music;
	
	DXSoundSample() {
		name = "dummy";
		music = false;
	}
	DXSoundSample(string sampleName, bool isMusic = false) {
		name = sampleName;
		music = isMusic;
	}
	void set_Name(string val) {
		name = val;
		Reload();
	}
	string get_Name() {
		return name;
	}
	string get_FullName() {
		return "soundfx\\" + name;
	}
	bool get_IsMusic() {
		return music;
	}
	bool get_IsLoaded() {
		if (this.IsDummy)
			return false;
		return SampleExists(this.FullName);
	}
	bool get_IsDummy() {
		return (name == "dummy");
	}
	bool get_IsPlaying() {
		if (this.IsDummy)
			return false;
		return IsSamplePlaying(this.FullName);
	}
	void Reload() {
		if (this.IsDummy || this.IsLoaded)
			return;
		if (music)
			LoadMusic(this.FullName);
		else
			LoadSoundEffect(this.FullName);
	}
	void Play() {
		if (this.IsDummy)
			return;
		PlaySample(this.FullName);
	}
	void Play(float vol) {
		Play();
		SetVolume(vol);
	}
	void Loop(bool loop) {
		if (this.IsDummy)
			return;
		LoopSample(this.FullName, loop);
	}
	void Stop() {
		if (this.IsDummy)
			return;
		StopSample(this.FullName);
	}
	void Pause() {
		if (this.IsDummy)
			return;
		PauseSample(this.FullName);
	}
	void SetVolume(float vol) {
		if (this.IsDummy)
			return;
		SetSampleVolume(this.FullName, vol);
	}
	void SetPan(float pan) {
		if (this.IsDummy)
			return;
		SetSamplePan(this.FullName, pan);
	}
}

array<DXSoundSample@>	gameSounds;

void InitGameSounds() {
	gameSounds.insertLast(DXSoundSample("evilmuah.wav"));
	gameSounds.insertLast(DXSoundSample("hero_jump.wav"));
	gameSounds.insertLast(DXSoundSample("bug_kill.wav"));
	gameSounds.insertLast(DXSoundSample("coin_collect.wav"));
	gameSounds.insertLast(DXSoundSample("bonus_pick.wav"));
	gameSounds.insertLast(DXSoundSample("bonus_spawn.wav"));
	gameSounds.insertLast(DXSoundSample("bonus_lost.wav"));
	gameSounds.insertLast(DXSoundSample("ccman_fire.wav"));
	gameSounds.insertLast(DXSoundSample("hero_fire.wav"));
	gameSounds.insertLast(DXSoundSample("complete_counter.wav"));
	gameSounds.insertLast(DXSoundSample("main_theme.ogg", true));
	gameSounds.insertLast(DXSoundSample("game_over.ogg", true));
	gameSounds.insertLast(DXSoundSample("intro.ogg", true));
	gameSounds.insertLast(DXSoundSample("level8_theme.ogg", true));
	gameSounds.insertLast(DXSoundSample("level9_theme.ogg", true));
	gameSounds.insertLast(DXSoundSample("level10_theme.ogg", true));
	gameSounds.insertLast(DXSoundSample("level_intro.ogg", true));
	gameSounds.insertLast(DXSoundSample("man_blya.wav"));
}

void ReloadGameSounds() {
	for (uint i = 0; i < gameSounds.length(); i++) {
		DXSoundSample@ sample = gameSounds[i];
		sample.Reload();
	}
}

DXSoundSample@ GetGameSound(string name) {
	for (uint i = 0; i < gameSounds.length(); i++) {
		DXSoundSample@ sample = gameSounds[i];
		if (sample.Name == name)
			return sample;
	}
	return null;
}