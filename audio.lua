local audio = ...

VOLUME = 0.5

audio.mainMenuMusic = am.load_audio("assets/audio/MainMenuLoop.ogg")

audio.stage1 = am.load_audio("assets/audio/StageTheme2Loop.ogg")

audio.stage2 = am.load_audio("assets/audio/StageThemeLoop.ogg")

audio.stageclear = am.load_audio("assets/audio/stageclear.ogg")

audio.bossstage = am.load_audio("assets/audio/BossThemeLoop.ogg")

audio.menuButtonClick = am.sfxr_synth(68597306)
