# RTX 50XX-Series (Blackwell) & Newer Broadcast Video Transcoder

> ### 📥 Quick Download (For Non-Tech Users)
> **You do NOT need a GitHub account or any coding tools.**
> 1. Look near the top-right of this page for the green **`<> Code`** button.
> 2. Click it, then click **`Download ZIP`**.
> 3. Extract the ZIP on your computer.
> 4. Move **`Broadcast_Mezzanine_Compressor_RTX50.bat`** to your Desktop then select your video files and drag them over thise ".bat" file.
>
> *(Alternatively, click directly on `Broadcast_Mezzanine_Compressor_RTX50.bat` in the file list above, then click the **Download raw file** button on the far right).*

---


A simple, tool where you drag-and-drop your videos onto the .bat icon that compresses massive camera originals and editing masters (**Apple ProRes**, **GoPro CineForm**, and **Avid DNxHR**) into high-efficiency **10-bit 4:2:2, 4:4:4, or 4:2:0 HEVC** files using your NVIDIA graphics card.

No command-line typing or coding knowledge required.

---

## Why Use This Instead of HandBrake?

* **HandBrake drops your color to 4:2:0:** Standard consumer tools like HandBrake silently convert your footage to 4:2:0 chroma subsampling in the background. If you shoot 10-bit 4:2:2, you lose half your color data before you even edit or punch in.
* **True 10-bit 4:2:2 Hardware Encoding:** NVIDIA's 9th-Gen NVENC engine (found on RTX 50-series GPUs and newer) supports native 10-bit 4:2:2. This script bypasses consumer limitations to deliver true broadcast-tier intermediates.
* **Lossless Audio Passthrough:** Retains your pristine 24-bit uncompressed PCM audio, multi-channel surround, and timecode untouched—no low-bitrate AAC compression.
* **Hardware Speed:** Encodes 4K and 8K footage at 30 to 100+ FPS directly on your GPU silicon.

---

## Supported Source Formats

Drag and drop any of these master files directly onto the script:
* **Apple ProRes** (Proxy, LT, 422, 422 HQ, 4444)
* **GoPro CineForm** (10-bit YUV and 12-bit RGB Filmscan)
* **Avid DNxHD / DNxHR** (LB, SQ, HQ, HQX 10-bit, 444)
* **Topaz Video AI Upscales** (ProRes/H.265 masters)

---

## 3-Minute Setup Guide (Only Done Once)

This tool uses a free, industry-standard engine called **FFmpeg** to talk directly to your GPU. 

### Step 1: Install FFmpeg
1. Download the **"ffmpeg-release-essentials.zip"** from [Gyan.dev](https://www.gyan.dev/ffmpeg/builds/).
2. Extract the ZIP folder. Inside, you will see a folder named `bin` containing `ffmpeg.exe`.
3. Move that extracted folder to your main drive so its path is simply:
   `C:\ffmpeg\bin`

### Step 2: Add FFmpeg to Windows PATH
1. In your Windows search bar, type **"environment variables"** and press **Enter**.
2. Click the **Environment Variables...** button at the bottom right.
3. Under the top section (*User variables*), select **Path** and click **Edit...**.
4. Click **New**, type `C:\ffmpeg\bin`, and click **OK** on all windows.

### Step 3: Download the Script
1. Download **`Broadcast_Mezzanine_Compressor_RTX50.bat`** from this repository.
2. Place it anywhere convenient (your **Desktop** is ideal).

---

## How to Use It (Everyday Workflow)

1. Open your footage folder in Windows File Explorer.
2. Select one or more video files.
3. **Drag and drop the files directly onto the `.bat` file icon.**
4. A black window will open with three quick questions. Type your number and press **Enter**:

```text
[1] Choose Chroma Subsampling:
    1. 4:2:2 (Editing & Broadcast Intermediate - Recommended)
    2. 4:2:0 (Web Delivery, YouTube, Smallest File Size)
    3. 4:4:4 (Full Chroma - VFX, Screen Capture, Heavy Color Grading)

[2] Choose Subject / Scene Type:
    1. People / Interviews / Cinematic (Softens face banding, protects skin tones)
    2. Mechanical / High Detail / Aviation (Sharp edges, rivets, fine textures)

[3] Choose Visual Quality / File Size Tier:
    1. Master Grade (QP 15 - Nearly lossless, best for 4K punch-ins)
    2. Balanced (QP 18 - Great quality, ~40% smaller files)
    3. Delivery / Archival (QP 22 - Smallest footprint for review copies)
