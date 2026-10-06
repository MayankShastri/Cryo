---
name: tts-voice-pipeline
description: Setup TTS + RVC pipeline for character voice synthesis using Genshin Impact voice datasets.
---
### Purpose
To create a working pipeline that converts text to speech, then applies RVC to match a character's voice (e.g., Kamisato Ayaka), using Genshin voice data.

### Dataset Details: simon3000/genshin-voice

- **Size**: ~346GB (75 parquet files, ~4.5GB each)
- **Total lines**: 654,252
- **Languages**: Chinese (zh), English(US), Japanese (ja), Korean (ko)
- **Features**: audio, transcription, language, speaker, inGameFilename

### Filtering for Ayaka English Lines

Use exact feature values:
```python
ayaka_en = df[
    (df['speaker'].str.strip() == 'Kamisato Ayaka') & 
    (df['language'].str.strip() == 'English(US)')
]
```

**Estimate**: ~1,636 lines, ~800MB–1.6GB of audio files.

### Pipeline Options

1. **Full TTS Training** (requires 600GB+ dataset):
   - Download full dataset
   - Filter Ayaka English lines
   - Train/finetune TTS model
   - Time: 1–2 weeks active dev + 4–10 days GPU

2. **RVC Voice Conversion** (current approach):
   - Generate English speech with lightweight TTS (e.g., edge-tts)
   - Feed audio into Ayaka RVC model
   - Output: Ayaka-voiced English speech

3. **Adapter Fine-tuning** (if you have 1+ hour of Ayaka recordings):
   - Start with pre-trained TTS (e.g., VITS)
   - Fine-tune with your recordings
   - Time: 1–3 days

### Pitfalls

- The `simon3000/genshin-voice` dataset is too large to download for quick testing — consider the smaller `hanamizuki-ai/genshin-voice-v3.5-mandarin` (~17GB) for prototype work.
- RVC models require a base TTS output — they don't generate speech from text directly.
- 6GB VRAM is tight for training — use CPU + minimal GPU offloading.

### References

- `references/extract_ayaka_english.py` — Script to filter and extract Ayaka English lines from the dataset.
