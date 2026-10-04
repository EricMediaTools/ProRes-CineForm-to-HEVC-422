# RTX 50XX-Series (Blackwell) & Newer Broadcast Video Transcoder

> ### 📥 Quick Download (For Non-Tech Users)
> **You do NOT need a GitHub account, Git, or any coding tools.**
> 1. Look near the top-right of this page for the green **`<> Code`** button.
> 2. Click it, then click **`Download ZIP`**.
> 3. Extract the ZIP file anywhere on your computer.
> 4. Move **`ProRes_to_HEVC_Broadcast_422_v1.1.bat`** to your Desktop (or right-click it and create a desktop shortcut).
> 5. **How to Use:** Select your video files in Windows File Explorer and **drag and drop them directly onto the `.bat` file icon**.
>
> *(Alternatively, click directly on `ProRes_to_HEVC_Broadcast_422_v1.1.bat` in the file list above, then click the **Download raw file** button on the far right).*

---

### 🎯 Intended Use: Archiving Working Masters & Saving Drive Space
This tool is built for a specific post-production reality: **shrinking massive working masters (Apple ProRes, Avid DNxHR, GoPro CineForm) down by up to 10× into long-term archive files while remaining visually lossless.**

* **The Reality of Production Storage:** In an ideal world, every studio and editor would keep uncompressed camera raw and ProRes masters forever. In the real world, storage is finite, RAID arrays fill up, and holding onto terabytes of delivered client projects becomes unsustainable. This tool prevents you from having to trash project footage entirely just to reclaim drive space.
* **Built Specifically for Timeline Relinking:** Unlike standard web encoders that rename files or strip vital tracks, this utility offers a dedicated **Clean Archive Mode**:
  * It maintains the **exact original filename** and file extension (`.mov`).
  * It keeps your uncompressed 24-bit PCM multi-track audio bit-for-bit intact without re-encoding.
  * It carries over embedded timecode tracks (`tmcd`) and camera metadata.
  * It automatically organizes renders into an `_Archived` subfolder so you can reconnect an entire offline sequence in **DaVinci Resolve** or **Adobe Premiere Pro** with a single click if a client ever requests a recut down the road.

---

## Why Use This Instead of HandBrake?

* **HandBrake drops your color to 4:2:0:** Standard consumer tools like HandBrake silently convert your footage to 4:2:0 chroma subsampling in the background. If you shoot 10-bit 4:2:2, you lose half your color data before you even edit or punch in.
* **True 10-bit 4:2:2 Hardware Encoding:** NVIDIA's 9th-Gen NVENC engine (found on RTX 50-series GPUs and newer) supports native 10-bit 4:2:2. This script bypasses consumer limitations to deliver true broadcast-tier intermediates.
* **Lossless Multi-Track Audio Passthrough:** Retains your pristine 24-bit uncompressed PCM audio, multi-channel surround, polyphonic lavs, and timecode untouched—no low-bitrate AAC downmixing or sync offsets.
* **Hardware Speed:** Encodes 4K and 8K footage at 30 to 100+ FPS directly on your GPU silicon without bogging down your NLE render queue.

---

## Supported Source Formats

Drag and drop any of these master files directly onto the script:
* **Apple ProRes** (Proxy, LT, 422, 422 HQ, 4444)
* **GoPro CineForm** (10-bit YUV and 12-bit RGB Filmscan)
* **Avid DNxHD / DNxHR** (LB, SQ, HQ, HQX 10-bit, 444)
* **Topaz Video AI Upscales** (ProRes/H.265 intermediate masters)

---

## 3-Minute Setup Guide (Only Done Once)

This tool uses a free, industry-standard engine called **FFmpeg** to talk directly to your GPU.

### Step 1: Install FFmpeg
* **Option A (Fastest via Windows Terminal):** Open PowerShell or Command Prompt and run:
  `winget install Gyan.FFmpeg`
* **Option B (Manual Download):**
  1. Download the **"ffmpeg-release-essentials.zip"** from Gyan.dev (https://www.gyan.dev/ffmpeg/builds/).
  2. Extract the ZIP folder. Inside, you will see a folder named `bin` containing `ffmpeg.exe`.
  3. Move that extracted folder to your main drive so its path is simply: `C:\ffmpeg\bin`

### Step 2: Add FFmpeg to Windows PATH (If using Option B)
1. In your Windows search bar, type **"environment variables"** and press **Enter**.
2. Click the **Environment Variables...** button at the bottom right.
3. Under the top section (*User variables*), select **Path** and click **Edit...**.
4. Click **New**, type `C:\ffmpeg\bin`, and click **OK** on all windows.

### Step 3: Download the Script
1. Download **`ProRes_to_HEVC_Broadcast_422_v1.1.bat`** from this repository.
2. Place it anywhere convenient (your **Desktop** is ideal).

---

## How to Use It (Everyday Workflow)

1. Open your footage folder in Windows File Explorer.
2. Select one or more video files (supports 1 clip or 100+ clips in a single batch).
3. **Drag and drop the files directly onto the `.bat` file icon.**
4. A command prompt window will open.

### 🔁 "Smart Cache" Feature (1-Click Repeat)
* **First Run:** The script walks you through the 5 setup options below and automatically saves your choices to a local `.hevc_last_settings.ini` configuration file.
* **Subsequent Runs:** The tool displays your previously used settings. Simply press **[Enter]** to immediately start encoding without re-answering the prompts, or type **`N`** to modify your settings.

```text
======================================================================
  ProRes to HEVC Broadcast 422 - v1.1
======================================================================

[PREVIOUS CONFIGURATION DETECTED]
  - Chroma Subsampling : 4:2:2 (Broadcast Master / rext)
  - Scene Tuning       : People / Interviews (Smooth Skin)
  - Quality Target     : Master Grade (QP 15)
  - Container Format   : .MOV (PCM Lossless Copy)
  - Output Destination : _Archived subfolder with exact original filename

----------------------------------------------------------------------
  Press [ENTER] to reuse these settings
  - OR -
  Type [N] and press Enter to choose new settings
----------------------------------------------------------------------
```

---

## ⚙️️ Menu Options Breakdown

### [1] Chroma Subsampling:
* **`1` - 4:2:2 (Recommended):** Uses the HEVC `rext` profile (`p210le`). Preserves color resolution for broadcast masters, ProRes 422 HQ, and camera log recordings. Essential for preventing color banding in skies, gradients, and secondary color keys.
* **`2` - 4:2:0:** Uses standard `main10` (`p010le`). Half color resolution. Ideal for client review screeners or uploads to YouTube/Vimeo where storage footprint is the priority.
* **`3` - 4:4:4:** Uses `rext` (`yuv444p16le`). Full color resolution. Best for screen recordings, GUI captures, text, and heavy 2D motion graphics.

### [2] Subject / Scene Type:
* **`1` - People / Interviews / Cinematic:** Disables spatial AQ (`-spatial_aq 0 -temporal_aq 1`). Eliminates edge-enhancement ringing, preventing blotchy textures or harsh contouring on smooth skin tones.
* **`2` - Mechanical / High Detail / Aviation:** Enables spatial AQ (`-spatial_aq 1 -temporal_aq 1`). Optimizes the quantization matrix to retain high-frequency edges like airplane rivets, wire fences, foliage, water spray, and fine mechanical textures.

### [3] Visual Quality / File Size Tier:
Rather than using variable bitrates (VBR) that can choke on complex motion, this tool uses hardware Constant Quantization Parameter (CQP):
* **`1` - Master Grade (QP 15):** Visually lossless master tier. High bitrate retention that holds up to heavy NLE punch-ins and reframing.
* **`2` - Balanced (QP 18):** Near-master quality with an ~80–90% space reduction compared to original ProRes files.
* **`3` - Delivery / Archival (QP 22):** Highly compressed, lightweight files for internal review and long-term deep storage.

### [4] Output Container Format:
* **`1` - MOV Container (Lossless PCM Copy):** Copies all multi-track uncompressed PCM audio channels bit-for-bit without re-encoding (`-c:a copy`). **Always pick MOV if your source files are ProRes/CineForm and you plan to relink in an NLE.**
* **`2` - MP4 Container (AAC 320 kbps):** Transcodes audio to high-bitrate AAC. MP4 does not natively support uncompressed linear PCM. Choose MP4 for web distribution, mobile playback, and smart TVs.

### [5] File Naming and Output Strategy:
* **`1` - Clean Archive for NLE Relinking (Recommended):**
  * Writes into an `_Archived` subfolder created inside your media directory.
  * Leaves the base filename identical (e.g., `Scene01_Take01.mov`).
  * Guarantees seamless 1-click batch relinking in DaVinci Resolve and Adobe Premiere Pro.
* **`2` - Standalone Export (Side-by-Side):**
  * Saves files directly into the source folder alongside the original media.
  * Appends `_422_Master` to prevent naming collisions.

---

## 🎬 How to Relink Footage in Premiere Pro & DaVinci Resolve

When you are ready to shelve a finished project to free up drive space:

1. Run your project footage through this tool using **Option 1 (MOV)** and **Option 1 (Clean Archive Mode)**.
2. Verify the transcoded files in the `_Archived` subfolder.
3. Delete or offline the massive original ProRes files.
4. Reconnect your sequence:

### In Adobe Premiere Pro:
1. Premiere will flag your media as "Offline."
2. In the **Link Media** window, select the first missing clip and click **Locate**.
3. Browse into the **`_Archived`** subfolder, select the matching clip, and click **OK**.
4. Premiere will auto-relink every remaining clip in the sequence because the filename, audio channel layout, and timecode tracks match 1:1.

### In DaVinci Resolve:
1. In the Media Pool, right-click your root footage bin -> select **Relink Selected Clips** (or **Change Source Folder**).
2. Point Resolve to the **`_Archived`** folder.
3. Resolve reconnects the timeline immediately based on matching timecode and embedded reel metadata.

---

## 🖥️ Supported Graphics Cards (Full Hardware Compatibility)

This tool requires an NVIDIA GPU featuring **9th-Generation NVENC or newer** to enable native hardware 10-bit 4:2:2 Range Extensions (`rext`).

### Desktop GPUs:
* **NVIDIA GeForce RTX 5090**
* **NVIDIA GeForce RTX 5080**
* **NVIDIA GeForce RTX 5070 Ti**
* **NVIDIA GeForce RTX 5070**
* **NVIDIA GeForce RTX 5060 Ti**
* **NVIDIA GeForce RTX 5060**
* *All future NVIDIA GeForce RTX 60-series and subsequent generations.*

### Laptop & Mobile GPUs:
* **RTX 5090 Laptop GPU**
* **RTX 5080 Laptop GPU**
* **RTX 5070 Laptop GPU**
* **RTX 5060 Laptop GPU**

### Professional / Workstation GPUs:
* **NVIDIA RTX Blackwell Generation Workstation Cards** (RTX 5000 Ada successors / B-series enterprise GPUs)

> **Note for Older Cards (RTX 40-series, 30-series, 20-series):**  
> Earlier NVIDIA architectures (Ada Lovelace, Ampere, Turing) physically lack 4:2:2 hardware silicon. While this script will execute, older GPUs will reject the 4:2:2 profile or fall back to 4:2:0. True hardware 10-bit 4:2:2 requires an RTX 50-series card or newer.

---

## 🛠️ Technical Pipeline Reference

For those curious about the underlying FFmpeg engine flags:

```cmd
ffmpeg -hide_banner -hwaccel cuda -i "input.mov" ^
  -map 0:v:0 -map 0:a? -map 0:d? -map_metadata 0 ^
  -c:v hevc_nvenc -preset p7 -tune hq -profile:v rext -pix_fmt p210le ^
  -rc constqp -qp 15 -spatial_aq 0 -temporal_aq 1 ^
  -tag:v hvc1 -c:a copy "_Archived/input.mov"
```

* `-map 0:v:0 -map 0:a? -map 0:d?`: Maps the primary video stream, all audio channels (lavs, booms, scratch tracks), and data/timecode streams without dropping tracks.
* `-map_metadata 0`: Retains camera manufacturer metadata, reel names, and creation timestamps.
* `-preset p7 -tune hq`: Forces NVIDIA's highest-quality multi-pass hardware encoding mode.
* `-tag:v hvc1`: Flags the HEVC bitstream with Apple's `hvc1` codec tag so files play natively in macOS Finder, QuickTime Player, and iOS devices without third-party codec packs.
