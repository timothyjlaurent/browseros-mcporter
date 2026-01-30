---
name: whisper-cpp
description: Fast local speech-to-text using whisper.cpp (C++ implementation of OpenAI Whisper)
user-invocable: true
metadata: {"clawdbot":{"skillKey":"whispercpp","emoji":"🎙️","requires":{"bins":["whisper-cli"]},"primaryBin":"whisper-cli"}}
---

# whisper-cpp

Fast local speech-to-text using whisper.cpp - a C++ implementation of OpenAI Whisper that runs completely offline.

## Setup

1. Install whisper-cpp via Homebrew:
   ```bash
   brew install whisper-cpp
   ```

2. Download a model (if not already present):
   ```bash
   mkdir -p ~/.local/share/whisper
   curl -L -o ~/.local/share/whisper/ggml-base.en.bin \
     "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin"
   ```

## Usage

Transcribe an audio file:
```bash
whisper-cli -m ~/.local/share/whisper/ggml-base.en.bin -f /path/to/audio.wav --language en
```

### Supported formats

whisper-cli works best with WAV files (16kHz, mono). For other formats, convert first:
```bash
ffmpeg -i input.ogg -ar 16000 -ac 1 -c:a pcm_s16le output.wav
```

### Available models

| Model | Size | Speed | Quality |
|-------|------|-------|---------|
| ggml-tiny.en.bin | ~39MB | Fastest | Basic |
| ggml-base.en.bin | ~142MB | Fast | Good |
| ggml-small.en.bin | ~466MB | Medium | Better |
| ggml-medium.en.bin | ~1.5GB | Slow | Best |

Download from: https://huggingface.co/ggerganov/whisper.cpp/tree/main

## Examples

```bash
# Basic transcription
whisper-cli -m ~/.local/share/whisper/ggml-base.en.bin -f audio.wav

# With timestamps
whisper-cli -m ~/.local/share/whisper/ggml-base.en.bin -f audio.wav --output-txt

# Translate to English (for non-English audio)
whisper-cli -m ~/.local/share/whisper/ggml-base.en.bin -f audio.wav --language auto --translate
```

## Notes

- Runs entirely offline - no API keys needed
- Uses CPU by default (GPU acceleration available with CUDA/Metal builds)
- First run loads model into memory (~1-2 seconds for base model)
