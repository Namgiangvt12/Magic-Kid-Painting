import numpy as np
import wave
import struct
import math
import os

SAMPLE_RATE = 44100

def save_wav(filename, samples, sample_rate=SAMPLE_RATE):
    # Normalize to -1.0 to 1.0, leave -1 dB headroom
    max_val = np.max(np.abs(samples))
    if max_val > 0:
        samples = samples / max_val * 0.9
    
    # 16-bit PCM
    int_samples = (samples * 32767).astype(np.int16)
    
    out_dir = os.path.dirname(filename)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)
        
    with wave.open(filename, 'w') as w:
        w.setnchannels(1)  # Mono for SFX, smaller footprint
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        w.writeframes(int_samples.tobytes())
    print(f"Generated: {filename} ({len(samples)/sample_rate:.2f}s)")

def generate_pop(filename):
    # Bubble pop: pitch sweep from 400Hz up to 1300Hz, quick pop envelope
    duration = 0.12
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), False)
    # Rapid pitch up then slight relax
    freq = 380 + 950 * (t / duration) ** 0.6
    phase = 2 * np.pi * np.cumsum(freq) / SAMPLE_RATE
    env = np.exp(-t * 32) * (1 - np.exp(-t * 200))
    # Add subtle hollow body resonance
    samples = np.sin(phase) * env + 0.3 * np.sin(phase * 2) * env * np.exp(-t * 40)
    save_wav(filename, samples)

def generate_tap(filename):
    # Tactile wood/plastic click
    duration = 0.05
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), False)
    click = np.random.uniform(-1, 1, len(t)) * np.exp(-t * 400)
    body = np.sin(2 * np.pi * 750 * t) * np.exp(-t * 120)
    samples = 0.6 * click + 0.7 * body
    save_wav(filename, samples)

def generate_color_select(filename):
    # Warm marimba chime note (C5 - 523.25 Hz)
    duration = 0.4
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), False)
    f0 = 523.25
    h1 = np.sin(2 * np.pi * f0 * t) * np.exp(-t * 8)
    h2 = 0.35 * np.sin(2 * np.pi * f0 * 2.75 * t) * np.exp(-t * 16) # Inharmonic chime strike
    h3 = 0.15 * np.sin(2 * np.pi * f0 * 4 * t) * np.exp(-t * 24)
    strike = np.random.uniform(-1, 1, len(t)) * np.exp(-t * 180) * 0.2
    samples = (h1 + h2 + h3 + strike) * (1 - np.exp(-t * 300))
    save_wav(filename, samples)

def generate_brush(filename):
    # Soft pastel / brush paper swoosh
    duration = 0.22
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), False)
    noise = np.random.uniform(-1, 1, len(t))
    # Soft bell envelope for stroke
    env = np.sin(np.pi * (t / duration)) ** 1.8
    # Simple low-pass smoothing
    kernel = np.ones(15) / 15
    smooth_noise = np.convolve(noise, kernel, mode='same')
    swoosh = np.sin(2 * np.pi * (320 + 120 * np.sin(2 * np.pi * 3 * t)) * t) * 0.2
    samples = (smooth_noise * 0.8 + swoosh) * env
    save_wav(filename, samples)

def generate_bucket(filename):
    # Liquid splash / bloop drop
    duration = 0.28
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), False)
    freq = 900 * np.exp(-t * 14) + 380
    phase = 2 * np.pi * np.cumsum(freq) / SAMPLE_RATE
    env = np.exp(-t * 15) * (1 - np.exp(-t * 120))
    sub_ripple = 0.3 * np.sin(2 * np.pi * 650 * t) * np.exp(-t * 25)
    samples = np.sin(phase) * env + sub_ripple
    save_wav(filename, samples)

def generate_undo(filename):
    # Bouncy boing / rewind chirp
    duration = 0.22
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), False)
    freq = 700 - 320 * (t / duration) + 60 * np.sin(2 * np.pi * 18 * t)
    phase = 2 * np.pi * np.cumsum(freq) / SAMPLE_RATE
    env = (1 - t / duration) ** 1.5 * (1 - np.exp(-t * 80))
    samples = np.sin(phase) * env + 0.2 * np.sin(phase * 2) * env
    save_wav(filename, samples)

def generate_redo(filename):
    # Upward chirpy pop
    duration = 0.18
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), False)
    freq = 420 + 400 * (t / duration) ** 0.8
    phase = 2 * np.pi * np.cumsum(freq) / SAMPLE_RATE
    env = (1 - t / duration) * (1 - np.exp(-t * 100))
    samples = np.sin(phase) * env
    save_wav(filename, samples)

def generate_eraser(filename):
    # Two quick rubber swishes
    duration = 0.26
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), False)
    noise = np.random.uniform(-1, 1, len(t))
    kernel = np.ones(20) / 20
    smooth = np.convolve(noise, kernel, mode='same')
    env1 = np.exp(-((t - 0.06) / 0.04) ** 2)
    env2 = 0.8 * np.exp(-((t - 0.17) / 0.04) ** 2)
    samples = smooth * (env1 + env2)
    save_wav(filename, samples)

def generate_sparkle(filename):
    # Magical fairy chime arpeggio: E5, G#5, B5, E6, G#6, B6
    duration = 0.9
    samples = np.zeros(int(SAMPLE_RATE * duration))
    notes = [659.25, 830.61, 987.77, 1318.51, 1661.22, 1975.53]
    delays = [0.0, 0.08, 0.16, 0.24, 0.32, 0.40]
    
    for f, d in zip(notes, delays):
        start_idx = int(d * SAMPLE_RATE)
        sub_len = len(samples) - start_idx
        if sub_len <= 0:
            continue
        t_sub = np.linspace(0, sub_len / SAMPLE_RATE, sub_len, False)
        # Crystal bell with overtones
        bell = (np.sin(2 * np.pi * f * t_sub) +
                0.4 * np.sin(2 * np.pi * f * 2.0 * t_sub) +
                0.2 * np.sin(2 * np.pi * f * 3.0 * t_sub))
        env = np.exp(-t_sub * 7) * (1 - np.exp(-t_sub * 200))
        samples[start_idx:] += bell * env * 0.35
        
    save_wav(filename, samples)

def generate_save(filename):
    # Camera snap + sweet chime
    duration = 0.65
    samples = np.zeros(int(SAMPLE_RATE * duration))
    t = np.linspace(0, duration, len(samples), False)
    
    # Camera click (shutter blade sounds)
    click1 = np.random.uniform(-1, 1, len(t)) * np.exp(-t * 250) * 0.7
    t2 = np.maximum(0, t - 0.06)
    click2 = np.random.uniform(-1, 1, len(t)) * np.exp(-t2 * 200) * (t > 0.06) * 0.6
    
    # Sweet completion chime (F#5: 739.99 Hz, B5: 987.77 Hz)
    t_chime = np.maximum(0, t - 0.12)
    chime1 = np.sin(2 * np.pi * 739.99 * t_chime) * np.exp(-t_chime * 9) * (t > 0.12) * 0.4
    t_chime2 = np.maximum(0, t - 0.24)
    chime2 = np.sin(2 * np.pi * 987.77 * t_chime2) * np.exp(-t_chime2 * 6) * (t > 0.24) * 0.5
    
    samples = click1 + click2 + chime1 + chime2
    save_wav(filename, samples)

def generate_praise_yay(filename):
    # Sweet uplifting praise chime: C5 - E5 - G5 - C6
    duration = 1.1
    samples = np.zeros(int(SAMPLE_RATE * duration))
    notes = [523.25, 659.25, 783.99, 1046.50]
    times = [0.0, 0.14, 0.28, 0.42]
    
    for f, d in zip(notes, times):
        start = int(d * SAMPLE_RATE)
        sub_len = len(samples) - start
        t_sub = np.linspace(0, sub_len / SAMPLE_RATE, sub_len, False)
        chime = (np.sin(2 * np.pi * f * t_sub) + 0.3 * np.sin(2 * np.pi * f * 2 * t_sub))
        env = np.exp(-t_sub * 4.5) * (1 - np.exp(-t_sub * 100))
        samples[start:] += chime * env * 0.35
        
    save_wav(filename, samples)

def generate_fanfare(filename):
    # Celebratory completion fanfare:
    # C major (C4, E4, G4) -> F major (C4, F4, A4) -> G major (D4, G4, B4) -> C5 burst (C4, G4, C5, E5) with sparkle
    duration = 2.8
    samples = np.zeros(int(SAMPLE_RATE * duration))
    
    def add_chord(notes, start_time, chord_dur):
        start = int(start_time * SAMPLE_RATE)
        n_samples = int(chord_dur * SAMPLE_RATE)
        if start + n_samples > len(samples):
            n_samples = len(samples) - start
        t_sub = np.linspace(0, n_samples / SAMPLE_RATE, n_samples, False)
        
        chord_wave = np.zeros(n_samples)
        for f in notes:
            # Brass + organ warmth: fundamental + 2nd, 3rd, 4th harmonics
            tone = (np.sin(2 * np.pi * f * t_sub) +
                    0.5 * np.sin(2 * np.pi * f * 2 * t_sub) +
                    0.3 * np.sin(2 * np.pi * f * 3 * t_sub) +
                    0.15 * np.sin(2 * np.pi * f * 4 * t_sub))
            chord_wave += tone
            
        env = (1 - np.exp(-t_sub * 60)) * np.exp(-t_sub * (1.8 / chord_dur))
        samples[start:start+n_samples] += chord_wave * env * 0.25
        
    # Progression
    add_chord([261.63, 329.63, 392.00], 0.0, 0.45)        # C maj
    add_chord([261.63, 349.23, 440.00], 0.45, 0.45)       # F maj
    add_chord([293.66, 392.00, 493.88], 0.90, 0.55)       # G maj
    add_chord([261.63, 392.00, 523.25, 659.25], 1.45, 1.35) # C5 triumphant hold
    
    # Add sparkle bursts at the end (fireworks/confetti sparkle)
    sparkle_times = [1.5, 1.7, 1.9, 2.1]
    sparkle_freqs = [1318.51, 1567.98, 1760.00, 2093.00]
    for st, sf in zip(sparkle_times, sparkle_freqs):
        s_start = int(st * SAMPLE_RATE)
        s_len = int(0.5 * SAMPLE_RATE)
        if s_start + s_len > len(samples):
            s_len = len(samples) - s_start
        t_s = np.linspace(0, s_len / SAMPLE_RATE, s_len, False)
        spark = np.sin(2 * np.pi * sf * t_s) * np.exp(-t_s * 8)
        samples[s_start:s_start+s_len] += spark * 0.25
        
    save_wav(filename, samples)

def generate_bgm(filename):
    # Cheerful, sweet, soothing BGM for kids:
    # 16-second loop, 108 BPM (quarter note ~ 0.555s)
    # Pentatonic melody on marimba + soft pizz bass + gentle shaker
    bpm = 108.0
    quarter = 60.0 / bpm
    total_beats = 32 # 8 bars of 4/4 = ~17.77 seconds
    total_duration = total_beats * quarter
    samples = np.zeros(int(SAMPLE_RATE * total_duration))
    
    # 1. Warm bass pizzicato on beat 1 and 3 of each bar
    bass_notes = [
        130.81, 130.81, # Bar 1: C3
        174.61, 174.61, # Bar 2: F3
        164.81, 164.81, # Bar 3: E3 / G3
        196.00, 196.00, # Bar 4: G3
        130.81, 130.81, # Bar 5: C3
        174.61, 174.61, # Bar 6: F3
        196.00, 196.00, # Bar 7: G3
        130.81, 130.81, # Bar 8: C3
    ]
    for i, f in enumerate(bass_notes):
        beat_time = i * (quarter * 2) # Every 2 beats
        start = int(beat_time * SAMPLE_RATE)
        dur = quarter * 1.8
        n_samples = int(dur * SAMPLE_RATE)
        if start + n_samples > len(samples):
            n_samples = len(samples) - start
        t_b = np.linspace(0, n_samples / SAMPLE_RATE, n_samples, False)
        # Warm rounded triangle/sine bass
        bass = np.sin(2 * np.pi * f * t_b) + 0.3 * np.sin(2 * np.pi * f * 2 * t_b)
        env = np.exp(-t_b * 3.5) * (1 - np.exp(-t_b * 60))
        samples[start:start+n_samples] += bass * env * 0.35

    # 2. Gentle marimba / music box melody
    # Melody sequence: (beat_offset, freq, length_in_quarters)
    # C5=523.25, D5=587.33, E5=659.25, G5=783.99, A5=880.0, C6=1046.5
    C5, D5, E5, G5, A5, C6 = 523.25, 587.33, 659.25, 783.99, 880.00, 1046.50
    G4, A4 = 392.00, 440.00
    
    melody = [
        # Bar 1 (C)
        (0.0, C5, 1), (1.0, E5, 1), (2.0, G5, 1.5), (3.5, E5, 0.5),
        # Bar 2 (F)
        (4.0, A5, 1), (5.0, G5, 1), (6.0, E5, 2),
        # Bar 3 (E/Am)
        (8.0, D5, 1), (9.0, E5, 1), (10.0, D5, 1), (11.0, C5, 1),
        # Bar 4 (G)
        (12.0, D5, 1.5), (13.5, E5, 0.5), (14.0, D5, 2),
        # Bar 5 (C)
        (16.0, C5, 1), (17.0, E5, 1), (18.0, G5, 1.5), (19.5, A5, 0.5),
        # Bar 6 (F)
        (20.0, C6, 1), (21.0, A5, 1), (22.0, G5, 2),
        # Bar 7 (G)
        (24.0, A5, 1), (25.0, G5, 1), (26.0, E5, 1), (27.0, D5, 1),
        # Bar 8 (C resolution)
        (28.0, C5, 3)
    ]
    
    for beat, f, length in melody:
        start = int(beat * quarter * SAMPLE_RATE)
        dur = length * quarter
        n_samples = int(dur * 1.5 * SAMPLE_RATE) # Allow slight ring out
        if start + n_samples > len(samples):
            n_samples = len(samples) - start
        t_m = np.linspace(0, n_samples / SAMPLE_RATE, n_samples, False)
        # Marimba mallet: fundamental + clear 2nd overtone + strike
        marimba = (np.sin(2 * np.pi * f * t_m) +
                   0.3 * np.sin(2 * np.pi * f * 2.75 * t_m) +
                   0.1 * np.sin(2 * np.pi * f * 4 * t_m))
        env = np.exp(-t_m * 4.0) * (1 - np.exp(-t_m * 120))
        samples[start:start+n_samples] += marimba * env * 0.38
        
    # 3. Soft rhythmic percussion (shaker / brush tap on beats)
    for b in range(total_beats):
        start = int(b * quarter * SAMPLE_RATE)
        p_len = int(0.08 * SAMPLE_RATE)
        if start + p_len > len(samples):
            break
        t_p = np.linspace(0, p_len / SAMPLE_RATE, p_len, False)
        # High passed noise pulse
        pulse = np.random.uniform(-1, 1, p_len) * np.exp(-t_p * 70)
        # Accent on beat 2 and 4
        vol = 0.08 if (b % 2 == 1) else 0.04
        samples[start:start+p_len] += pulse * vol

    # Loop fade-in / fade-out smoothing for seamless looping (50ms)
    fade_len = int(0.05 * SAMPLE_RATE)
    fade_in = np.linspace(0, 1, fade_len)
    fade_out = np.linspace(1, 0, fade_len)
    samples[:fade_len] *= fade_in
    samples[-fade_len:] *= fade_out

    save_wav(filename, samples)

def main():
    target_dir = os.path.join("assets", "audio")
    os.makedirs(target_dir, exist_ok=True)
    
    generate_pop(os.path.join(target_dir, "pop.wav"))
    generate_tap(os.path.join(target_dir, "tap.wav"))
    generate_color_select(os.path.join(target_dir, "color_select.wav"))
    generate_brush(os.path.join(target_dir, "brush.wav"))
    generate_bucket(os.path.join(target_dir, "bucket.wav"))
    generate_undo(os.path.join(target_dir, "undo.wav"))
    generate_redo(os.path.join(target_dir, "redo.wav"))
    generate_eraser(os.path.join(target_dir, "eraser.wav"))
    generate_sparkle(os.path.join(target_dir, "sparkle.wav"))
    generate_save(os.path.join(target_dir, "save.wav"))
    generate_praise_yay(os.path.join(target_dir, "praise_yay.wav"))
    generate_fanfare(os.path.join(target_dir, "fanfare.wav"))
    generate_bgm(os.path.join(target_dir, "bgm_cheerful.wav"))
    print("All audio files successfully generated!")

if __name__ == "__main__":
    main()
