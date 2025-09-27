#!/usr/bin/env python3
import sys
from pathlib import Path
import time
from pydub import AudioSegment

if len(sys.argv) == 2:
    file = sys.argv[1]
    text = sys.stdin.read().strip()
elif len(sys.argv) >= 3:
    file = Path(sys.argv[1])
    text = ' '.join(sys.argv[2:])
else:
    print(f"usage: {0} <file> [text]")
    exit(1)

seconds_per_char = 0.025

char_sleep_time = seconds_per_char * len(text)
extra_sleep_time = sum(0.2 for char in text[:-1] if char in ".?!")
duration_ms = int((char_sleep_time + extra_sleep_time) * 1000)

silence = AudioSegment.silent(duration=duration_ms)
silence.export(file, format=file.suffix[1:] or "mp3")
