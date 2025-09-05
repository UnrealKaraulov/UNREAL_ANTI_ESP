[🇷🇺 Читать на русском](README_RU.md)

# 🚫 UNREAL ANTI‑ESP PLUGIN v3.42

Multi‑layer protection against Sound ESP and wallhack cheats for CS 1.6 / HLDS servers based on **AMX Mod X + ReAPI**.  
The plugin intercepts and modifies game sounds, generates fake audio events, hides weapon events, and uses distance‑based volume attenuation to mislead cheats.

---

## 📋 Requirements

- **AMX Mod X** 1.9+ (latest build recommended)
- **ReAPI** (≥ 5.24.3.0, some features ≥ 5.26.3.24)
- **WHBlocker** (with built‑in ESP protection disabled)
- **FakeMeta** module
- **XS** module
- `<easy_cfg>` (included in archive)
- Write access to `addons/amxmodx/configs/plugins/` and `sound/`
- FastDL for distributing sounds to clients

---

## 📦 Installation

1. **Compile the plugin**
   - Place `anti_esp.sma` into `addons/amxmodx/scripting/`
   - Ensure `scripting/include/` contains:
     - `reapi.inc`
     - `fakemeta.inc`
     - `xs.inc`
     - `easy_cfg.inc`
   - Compile:
     ```bash
     amxxpc anti_esp.sma -o anti_esp.amxx
     ```
     Place the compiled `.amxx` into `addons/amxmodx/plugins/`

2. **Enable the plugin**
   - Add to `addons/amxmodx/configs/plugins.ini`:
     ```
     anti_esp.amxx
     ```

3. **Configure WHBlocker**
   - In `whblocker.ini` disable built‑in ESP protection:
     ```
     esp = 0
     sndinvis = 0
     sndchan = 0
     sndfake = 0
     sndrange = 8192
     sndpickup = 1600
     sndshuff = 1.0
     sndmove = 0
     ```

4. **Restart the server**
   - On first run the plugin will create:
     - `unreal_anti_esp.cfg.ini` in `configs/plugins/`
     - Folders and sounds in `sound/`
   - Upload new sounds to FastDL

---

## ⚙️ Configuration

File: `addons/amxmodx/configs/plugins/unreal_anti_esp.cfg.ini`

### [general]

| Parameter | Default | Description |
|-----------|---------|-------------|
| `fake_path` | `player/pl_step5.wav` | Path to fake sound (similar to original) |
| `missing_path` | `player/pl_step0.wav` | Path to non‑existent sound for ESP crash |
| `send_missing_sound` | `true` | Send non‑existent sound |
| `enable_fake_sounds` | `1` | 0 — off, 1 — around all, 2 — around player |
| `ent_classname` | `idyti_cmgrptft` | Fake entity classname |
| `repeat_channel_mode` | `false` | Reuse channels if needed |
| `more_random_mode` | `false` | Randomize volume/attenuation |
| `reinstall_with_new_sounds` | `false` | Reinstall with new random sounds |
| `max_ents_for_sounds` | `14` | Entity limit for fake sounds |
| `crack_old_esp_box` | `true` | Break old ESP cheats |
| `volume_range_based` | `true` | Distance‑based volume |
| `volume_range_dist` | `64.0` | Distance for volume calc |
| `cut_off_sound_dist` | `1500.0` | Cut sounds beyond distance |
| `cut_off_sound_vol` | `0.001` | Cut sounds below volume |
| `replace_sound_for_all_ents` | `false` | Compatibility mode (deprecated) |
| `antiesp_for_bots` | `true` | Enable for bots |
| `hide_weapon_events` | `0` | 0 — off, 1 — emulate, 2 — hide |
| `USE_ORIGINAL_SOUND_PATHS` | `false` | Keep original sound paths |
| `USE_ORIGINAL_ENTITY_AND_CHANNEL` | `false` | Keep original entities/channels |
| `process_all_sounds` | `true` | Process all sounds |
| `DEBUG_DUMP_ALL_SOUNDS` | `false` | Log all sounds (do not enable!) |

---

### [sounds]

| Parameter | Example | Description |
|-----------|---------|-------------|
| `sounds` | `2` | Number of replaced sounds |
| `sound_1_default` | `player/pl_step1.wav` | Original sound |
| `sound_1_replace` | `pl_shell/635d336ccd9613572966288888737dc7.wav` | Replacement sound |

---

## 🔑 Key Features

- Sound file name obfuscation
- Fake sound generation
- Distance‑based volume attenuation
- Weapon event hiding
- Breaks old ESP cheats
- Bot support
- Auto‑generates sounds on first run

---

## ⚠️ Recommendations

- Do not use outdated anti‑ESP plugins alongside this
- Ensure no other plugins spawn entities near players that reveal positions
- On low‑end servers, monitor load and FPS after installation
- `[sounds]` section should have at least **47** sounds for max protection

---

## 📞 Support
[Telegram](https://t.me/karaul0v)

---

**Free for all use**
