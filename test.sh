#!/bin/bash
# Trap for smooth exit on Ctrl+C
trap 'echo -e "${RED}Exiting gracefully...${NC}"; exit 0' INT

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# File paths
LOG_FILE="$HOME/irys_script.log"
CONFIG_FILE="$HOME/.irys_config.json"
DETAILS_FILE="$HOME/irys_file_details.json"
VENV_DIR="$HOME/irys_venv"

# Python script paths
VIDEO_DOWNLOADER_PY="$HOME/video_downloader.py"
PIXABAY_DOWNLOADER_PY="$HOME/pixabay_downloader.py"
PEXELS_DOWNLOADER_PY="$HOME/pexels_downloader.py"

show_header() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo "┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐"
    echo "│ ██╗░░██╗██╗░░░██║░██████╗████████╗██╗░░░░░███████╗  ░█████╗░██╗██████╗░██████╗░██████╗░░█████╗░██████╗░░██████╗ │"
    echo "│ ██║░░██║██║░░░██║██╔════╝╚══██╔══╝██║░░░░░██╔════╝  ██╔══██╗██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝ │"
    echo "│ ███████║██║░░░██║╚█████╗░░░░██║░░░██║░░░░░█████╗░░  ███████║██║██████╔╝██║░░██║██████╔╝██║░░██║██████╔╝╚█████╗░ │"
    echo "│ ██╔══██║██║░░░██║░╚═══██╗░░░██║░░░██║░░░░░██╔══╝░░  ██╔══██║██║██╔══██╗██║░░██║██╔══██╗██║░░██║██╔═══╝░░╚═══██╗ │"
    echo "│ ██║░░██║╚██████╔╝██████╔╝░░░██║░░░███████╗███████╗  ██║░░██║██║██║░░██║██████╔╝██║░░██║╚█████╔╝██║░░░░░██████╔╝ │"
    echo "│ ╚═╝░░╚═╝░╚═════╝░╚═════╝░░░░╚═╝░░░╚══════╝╚══════╝  ╚═╝░░╚═╝╚═╝╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝░╚════╝░╚═╝░░░░░╚═════╝░ │"
    echo "└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘"
    echo -e "${YELLOW} 🚀 Pipe Node Manager by Aashish 🚀${NC}"
    echo -e "${YELLOW} GitHub: https://github.com/HustleAirdrops${NC}"
    echo -e "${YELLOW} Telegram: https://t.me/Hustle_Airdrops${NC}"
    echo -e "${GREEN}===============================================================================${NC}"
}

# Function to create Python scripts if they don't exist
create_python_scripts() {
    if [ ! -f "$VIDEO_DOWNLOADER_PY" ]; then
        cat << 'EOF' > "$VIDEO_DOWNLOADER_PY"
import yt_dlp
import os
import sys
import time
import random
import string
import subprocess
import shutil
try:
    from moviepy.editor import VideoFileClip, concatenate_videoclips
    MOVIEPY_AVAILABLE = True
except ImportError:
    MOVIEPY_AVAILABLE = False

def format_size(bytes_size):
    return f"{bytes_size/(1024*1024):.2f} MB"

def format_time(seconds):
    mins = int(seconds // 60)
    secs = int(seconds % 60)
    return f"{mins:02d}:{secs:02d}"

def draw_progress_bar(progress, total, width=50):
    percent = progress / total * 100
    filled = int(width * progress // total)
    bar = '█' * filled + '-' * (width - filled)
    return f"[{bar}] {percent:.1f}%"

def check_ffmpeg():
    return shutil.which("ffmpeg") is not None

def concatenate_with_moviepy(files, output_file):
    if not MOVIEPY_AVAILABLE:
        print("⚠️ moviepy is not installed. Cannot concatenate with moviepy.")
        return False
    try:
        clips = []
        for fn in files:
            if os.path.exists(fn) and os.path.getsize(fn) > 0:
                try:
                    clip = VideoFileClip(fn)
                    clips.append(clip)
                except Exception as e:
                    print(f"⚠️ Skipping invalid file {fn}: {str(e)}")
        if not clips:
            print("⚠️ No valid video clips to concatenate.")
            return False
        final_clip = concatenate_videoclips(clips, method="compose")
        final_clip.write_videofile(output_file, codec="libx264", audio_codec="aac", temp_audiofile="temp-audio.m4a", remove_temp=True, threads=2)
        for clip in clips:
            clip.close()
        final_clip.close()
        return os.path.exists(output_file) and os.path.getsize(output_file) > 0
    except Exception as e:
        print(f"⚠️ Moviepy concatenation failed: {str(e)}")
        return False

def trim_video_to_size(input_file, target_bytes):
    try:
        duration_str = subprocess.check_output(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'default=noprint_wrappers=1:nokey=1', input_file]).decode().strip()
        duration = float(duration_str)
        final_size = os.path.getsize(input_file)
        new_duration = duration * (target_bytes / final_size)
        temp_file = "trimmed_" + input_file
        result = subprocess.run(['ffmpeg', '-i', input_file, '-t', str(new_duration), '-c', 'copy', temp_file], capture_output=True, text=True)
        if result.returncode == 0 and os.path.exists(temp_file) and os.path.getsize(temp_file) > 0:
            os.remove(input_file)
            os.rename(temp_file, input_file)
            print(f"✅ Trimmed video to approximate {format_size(os.path.getsize(input_file))}")
            return True
        else:
            print(f"⚠️ Trim failed: {result.stderr}")
            if os.path.exists(temp_file):
                os.remove(temp_file)
            return False
    except Exception as e:
        print(f"⚠️ Failed to trim: {str(e)}")
        return False

def download_videos(query, output_file, target_size_mb=1000, max_filesize=1100*1024*1024, min_filesize=50*1024*1024):
    ydl_opts = {
        'format': 'best',
        'noplaylist': True,
        'quiet': True,
        'progress_hooks': [progress_hook],
        'outtmpl': '%(title)s.%(ext)s'
    }
    total_downloaded = 0
    total_size = 0
    start_time = time.time()
    downloaded_files = []
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(f"ytsearch20:{query}", download=False)
            videos = info.get("entries", [])
            candidates = []
            for v in videos:
                size = v.get("filesize") or v.get("filesize_approx")
                if size and min_filesize <= size <= max_filesize:
                    candidates.append((size, v))
            if not candidates:
                print("⚠️ No suitable videos found (at least 50MB and up to ~1GB).")
                return
            candidates.sort(key=lambda x: -x[0])  # largest first
            for size, v in candidates:
                if total_size + size <= target_size_mb * 1024 * 1024:
                    total_size += size
                    current_file = len(downloaded_files) + 1
                    print(f"🎬 Downloading video {current_file}: {v['title']} ({format_size(size)})")
                    ydl.download([v['webpage_url']])
                    filename = ydl.prepare_filename(v)
                    if os.path.exists(filename) and os.path.getsize(filename) > 0:
                        downloaded_files.append(filename)
                        total_downloaded += size
                    else:
                        print(f"⚠️ Failed to download or empty file: {filename}")
                        continue
                    elapsed = time.time() - start_time
                    speed = total_downloaded / (1024*1024*elapsed) if elapsed > 0 else 0
                    eta = (total_size - total_downloaded) / (speed * 1024*1024) if speed > 0 else 0
                    print(f"✅ Overall Progress: {draw_progress_bar(total_downloaded, total_size)} "
                          f"({format_size(total_downloaded)}/{format_size(total_size)}) "
                          f"Speed: {speed:.2f} MB/s ETA: {format_time(eta)}")
        if not downloaded_files:
            print("⚠️ No videos found close to 1GB.")
            return
        target_bytes = target_size_mb * 1024 * 1024
        original_files = downloaded_files.copy()
        original_size = total_size
        while total_size < target_bytes * 0.95 and original_size > 0:
            new_files = []
            for fn in original_files:
                new_fn = "dup_" + ''.join(random.choices(string.ascii_letters + string.digits, k=8)) + "_" + os.path.basename(fn)
                shutil.copy(fn, new_fn)
                new_files.append(new_fn)
            downloaded_files += new_files
            total_size += original_size
        if len(downloaded_files) == 1:
            os.rename(downloaded_files[0], output_file)
            downloaded_files = []
        else:
            success = False
            if check_ffmpeg():
                print("🔗 Concatenating videos with ffmpeg...")
                with open('list.txt', 'w') as f:
                    for fn in downloaded_files:
                        f.write(f"file '{fn}'\n")
                result = subprocess.run(['ffmpeg', '-f', 'concat', '-safe', '0', '-i', 'list.txt', '-c', 'copy', output_file], capture_output=True, text=True)
                if result.returncode == 0 and os.path.exists(output_file) and os.path.getsize(output_file) > 0:
                    success = True
                else:
                    print(f"⚠️ ffmpeg concatenation failed: {result.stderr}")
                if os.path.exists('list.txt'):
                    os.remove('list.txt')
            if not success:
                print("🔗 Falling back to moviepy for concatenation...")
                success = concatenate_with_moviepy(downloaded_files, output_file)
            if not success:
                print("⚠️ Concatenation failed. Using first video only.")
                os.rename(downloaded_files[0], output_file)
                downloaded_files = downloaded_files[1:]
        for fn in downloaded_files:
            if os.path.exists(fn):
                os.remove(fn)
        if os.path.exists(output_file) and os.path.getsize(output_file) > 0:
            final_size = os.path.getsize(output_file)
            if final_size > target_bytes:
                trim_video_to_size(output_file, target_bytes)
            print(f"✅ Video ready: {output_file} ({format_size(os.path.getsize(output_file))})")
        else:
            print("⚠️ Failed to create final video file.")
    except Exception as e:
        print(f"⚠️ An error occurred: {str(e)}")
        for fn in downloaded_files:
            if os.path.exists(fn):
                os.remove(fn)
        if os.path.exists('list.txt'):
            os.remove('list.txt')

def progress_hook(d):
    if d['status'] == 'downloading':
        downloaded = d.get('downloaded_bytes', 0)
        total = d.get('total_bytes', d.get('total_bytes_estimate', 1000000))
        speed = d.get('speed', 0) or 0
        eta = d.get('eta', 0) or 0
        print(f"\r⬇️ File Progress: {draw_progress_bar(downloaded, total)} "
              f"({format_size(downloaded)}/{format_size(total)}) "
              f"Speed: {speed/(1024*1024):.2f} MB/s ETA: {format_time(eta)}", end='')
    elif d['status'] == 'finished':
        print("\r✅ File Download completed")

if __name__ == "__main__":
    if len(sys.argv) > 2:
        target_size_mb = int(sys.argv[3]) if len(sys.argv) > 3 else 1000
        download_videos(sys.argv[1], sys.argv[2], target_size_mb=target_size_mb)
    else:
        print("Please provide a search query and output filename.")
EOF
    fi

    if [ ! -f "$PIXABAY_DOWNLOADER_PY" ]; then
        cat << 'EOF' > "$PIXABAY_DOWNLOADER_PY"
import requests
import os
import sys
import time
import random
import string
import subprocess
import shutil
try:
    from moviepy.editor import VideoFileClip, concatenate_videoclips
    MOVIEPY_AVAILABLE = True
except ImportError:
    MOVIEPY_AVAILABLE = False

def format_size(bytes_size):
    return f"{bytes_size/(1024*1024):.2f} MB"

def format_time(seconds):
    mins = int(seconds // 60)
    secs = int(seconds % 60)
    return f"{mins:02d}:{secs:02d}"

def draw_progress_bar(progress, total, width=50):
    percent = progress / total * 100
    filled = int(width * progress // total)
    bar = '█' * filled + '-' * (width - filled)
    return f"[{bar}] {percent:.1f}%"

def check_ffmpeg():
    return shutil.which("ffmpeg") is not None

def concatenate_with_moviepy(files, output_file):
    if not MOVIEPY_AVAILABLE:
        print("⚠️ moviepy is not installed. Cannot concatenate with moviepy.")
        return False
    try:
        clips = []
        for fn in files:
            if os.path.exists(fn) and os.path.getsize(fn) > 0:
                try:
                    clip = VideoFileClip(fn)
                    clips.append(clip)
                except Exception as e:
                    print(f"⚠️ Skipping invalid file {fn}: {str(e)}")
        if not clips:
            print("⚠️ No valid video clips to concatenate.")
            return False
        final_clip = concatenate_videoclips(clips, method="compose")
        final_clip.write_videofile(output_file, codec="libx264", audio_codec="aac", temp_audiofile="temp-audio.m4a", remove_temp=True, threads=2)
        for clip in clips:
            clip.close()
        final_clip.close()
        return os.path.exists(output_file) and os.path.getsize(output_file) > 0
    except Exception as e:
        print(f"⚠️ Moviepy concatenation failed: {str(e)}")
        return False

def trim_video_to_size(input_file, target_bytes):
    try:
        duration_str = subprocess.check_output(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'default=noprint_wrappers=1:nokey=1', input_file]).decode().strip()
        duration = float(duration_str)
        final_size = os.path.getsize(input_file)
        new_duration = duration * (target_bytes / final_size)
        temp_file = "trimmed_" + input_file
        result = subprocess.run(['ffmpeg', '-i', input_file, '-t', str(new_duration), '-c', 'copy', temp_file], capture_output=True, text=True)
        if result.returncode == 0 and os.path.exists(temp_file) and os.path.getsize(temp_file) > 0:
            os.remove(input_file)
            os.rename(temp_file, input_file)
            print(f"✅ Trimmed video to approximate {format_size(os.path.getsize(input_file))}")
            return True
        else:
            print(f"⚠️ Trim failed: {result.stderr}")
            if os.path.exists(temp_file):
                os.remove(temp_file)
            return False
    except Exception as e:
        print(f"⚠️ Failed to trim: {str(e)}")
        return False

def download_videos(query, output_file, target_size_mb=1000):
    api_key_file = os.path.expanduser('~/.pixabay_api_key')
    if not os.path.exists(api_key_file):
        print("⚠️ Pixabay API key file not found.")
        return
    with open(api_key_file, 'r') as f:
        api_key = f.read().strip()
    per_page = 100
    try:
        url = f"https://pixabay.com/api/videos/?key={api_key}&q={query}&per_page={per_page}&min_width=1920&min_height=1080&video_type=all"
        resp = requests.get(url, timeout=10)
        if resp.status_code != 200:
            print(f"⚠️ Error fetching Pixabay API: {resp.text}")
            return
        data = resp.json()
        videos = data.get('hits', [])
        if not videos:
            print("⚠️ No videos found for query.")
            return
        candidates = []
        for v in videos:
            video_url = v['videos'].get('large', {}).get('url') or v['videos'].get('medium', {}).get('url')
            if not video_url:
                continue
            head_resp = requests.head(video_url, timeout=10)
            size = int(head_resp.headers.get('content-length', 0))
            if size >= 50 * 1024 * 1024:
                candidates.append((size, v, video_url))
        if not candidates:
            print("⚠️ No suitable videos found (at least 50MB).")
            return
        candidates.sort(key=lambda x: -x[0])  # largest first
        downloaded_files = []
        total_size = 0
        total_downloaded = 0
        overall_start_time = time.time()
        min_filesize = 50 * 1024 * 1024
        target_bytes = target_size_mb * 1024 * 1024
        for size, v, video_url in candidates:
            remaining = target_bytes - total_size
            if size < min_filesize:
                continue
            if size > remaining:
                continue
            filename = f"pix_{v['id']}_{''.join(random.choices(string.ascii_letters + string.digits, k=8))}.mp4"
            print(f"🎬 Downloading video: {v['tags']} ({format_size(size)})")
            file_start_time = time.time()
            resp = requests.get(video_url, stream=True, timeout=10)
            with open(filename, 'wb') as f:
                downloaded = 0
                for chunk in resp.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)
                        downloaded += len(chunk)
                        percent = downloaded / size * 100 if size else 0
                        elapsed = time.time() - file_start_time
                        speed = downloaded / (1024*1024 * elapsed) if elapsed > 0 else 0
                        eta = (size - downloaded) / (speed * 1024*1024) if speed > 0 else 0
                        print(f"\r⬇️ File Progress: {draw_progress_bar(downloaded, size)} "
                              f"({format_size(downloaded)}/{format_size(size)}) "
                              f"Speed: {speed:.2f} MB/s ETA: {format_time(eta)}", end='')
            print("\r✅ File Download completed")
            file_size = os.path.getsize(filename) if os.path.exists(filename) else 0
            if file_size == 0:
                if os.path.exists(filename):
                    os.remove(filename)
                continue
            total_size += file_size
            total_downloaded += file_size
            downloaded_files.append(filename)
        if not downloaded_files:
            print("⚠️ No suitable videos downloaded.")
            return
        original_files = downloaded_files.copy()
        original_size = total_size
        while total_size < target_bytes * 0.95 and original_size > 0:
            new_files = []
            for fn in original_files:
                new_fn = "dup_" + ''.join(random.choices(string.ascii_letters + string.digits, k=8)) + "_" + os.path.basename(fn)
                shutil.copy(fn, new_fn)
                new_files.append(new_fn)
            downloaded_files += new_files
            total_size += original_size
        if len(downloaded_files) == 1:
            os.rename(downloaded_files[0], output_file)
            downloaded_files = []
        else:
            success = False
            if check_ffmpeg():
                print("🔗 Concatenating videos with ffmpeg...")
                with open('list.txt', 'w') as f:
                    for fn in downloaded_files:
                        f.write(f"file '{fn}'\n")
                result = subprocess.run(['ffmpeg', '-f', 'concat', '-safe', '0', '-i', 'list.txt', '-c', 'copy', output_file], capture_output=True, text=True)
                if result.returncode == 0 and os.path.exists(output_file) and os.path.getsize(output_file) > 0:
                    success = True
                else:
                    print(f"⚠️ ffmpeg concatenation failed: {result.stderr}")
                if os.path.exists('list.txt'):
                    os.remove('list.txt')
            if not success:
                print("🔗 Falling back to moviepy for concatenation...")
                success = concatenate_with_moviepy(downloaded_files, output_file)
            if not success:
                print("⚠️ Concatenation failed. Using first video only.")
                os.rename(downloaded_files[0], output_file)
                downloaded_files = downloaded_files[1:]
        for fn in downloaded_files:
            if os.path.exists(fn):
                os.remove(fn)
        if os.path.exists(output_file) and os.path.getsize(output_file) > 0:
            final_size = os.path.getsize(output_file)
            if final_size > target_bytes:
                trim_video_to_size(output_file, target_bytes)
            print(f"✅ Video ready: {output_file} ({format_size(os.path.getsize(output_file))})")
        else:
            print("⚠️ Failed to create final video file.")
    except Exception as e:
        print(f"⚠️ An error occurred: {str(e)}")
        for fn in downloaded_files:
            if os.path.exists(fn):
                os.remove(fn)
        if os.path.exists('list.txt'):
            os.remove('list.txt')

if __name__ == "__main__":
    if len(sys.argv) > 2:
        target_size_mb = int(sys.argv[3]) if len(sys.argv) > 3 else 1000
        download_videos(sys.argv[1], sys.argv[2], target_size_mb=target_size_mb)
    else:
        print("Please provide a search query and output filename.")
EOF
    fi

    if [ ! -f "$PEXELS_DOWNLOADER_PY" ]; then
        cat << 'EOF' > "$PEXELS_DOWNLOADER_PY"
import requests
import os
import sys
import time
import random
import string
import subprocess
import shutil
try:
    from moviepy.editor import VideoFileClip, concatenate_videoclips
    MOVIEPY_AVAILABLE = True
except ImportError:
    MOVIEPY_AVAILABLE = False

def format_size(bytes_size):
    return f"{bytes_size/(1024*1024):.2f} MB"

def format_time(seconds):
    mins = int(seconds // 60)
    secs = int(seconds % 60)
    return f"{mins:02d}:{secs:02d}"

def draw_progress_bar(progress, total, width=50):
    percent = progress / total * 100
    filled = int(width * progress // total)
    bar = '█' * filled + '-' * (width - filled)
    return f"[{bar}] {percent:.1f}%"

def check_ffmpeg():
    return shutil.which("ffmpeg") is not None

def concatenate_with_moviepy(files, output_file):
    if not MOVIEPY_AVAILABLE:
        print("⚠️ moviepy is not installed. Cannot concatenate with moviepy.")
        return False
    try:
        clips = []
        for fn in files:
            if os.path.exists(fn) and os.path.getsize(fn) > 0:
                try:
                    clip = VideoFileClip(fn)
                    clips.append(clip)
                except Exception as e:
                    print(f"⚠️ Skipping invalid file {fn}: {str(e)}")
        if not clips:
            print("⚠️ No valid video clips to concatenate.")
            return False
        final_clip = concatenate_videoclips(clips, method="compose")
        final_clip.write_videofile(output_file, codec="libx264", audio_codec="aac", temp_audiofile="temp-audio.m4a", remove_temp=True, threads=2)
        for clip in clips:
            clip.close()
        final_clip.close()
        return os.path.exists(output_file) and os.path.getsize(output_file) > 0
    except Exception as e:
        print(f"⚠️ Moviepy concatenation failed: {str(e)}")
        return False

def trim_video_to_size(input_file, target_bytes):
    try:
        duration_str = subprocess.check_output(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'default=noprint_wrappers=1:nokey=1', input_file]).decode().strip()
        duration = float(duration_str)
        final_size = os.path.getsize(input_file)
        new_duration = duration * (target_bytes / final_size)
        temp_file = "trimmed_" + input_file
        result = subprocess.run(['ffmpeg', '-i', input_file, '-t', str(new_duration), '-c', 'copy', temp_file], capture_output=True, text=True)
        if result.returncode == 0 and os.path.exists(temp_file) and os.path.getsize(temp_file) > 0:
            os.remove(input_file)
            os.rename(temp_file, input_file)
            print(f"✅ Trimmed video to approximate {format_size(os.path.getsize(input_file))}")
            return True
        else:
            print(f"⚠️ Trim failed: {result.stderr}")
            if os.path.exists(temp_file):
                os.remove(temp_file)
            return False
    except Exception as e:
        print(f"⚠️ Failed to trim: {str(e)}")
        return False

def download_videos(query, output_file, target_size_mb=1000):
    api_key_file = os.path.expanduser('~/.pexels_api_key')
    if not os.path.exists(api_key_file):
        print("⚠️ Pexels API key file not found.")
        return
    with open(api_key_file, 'r') as f:
        api_key = f.read().strip()
    per_page = 80
    try:
        headers = {'Authorization': api_key}
        url = f"https://api.pexels.com/videos/search?query={query}&per_page={per_page}"
        resp = requests.get(url, headers=headers, timeout=10)
        if resp.status_code != 200:
            print(f"⚠️ Error fetching Pexels API: {resp.text}")
            return
        data = resp.json()
        videos = data.get('videos', [])
        if not videos:
            print("⚠️ No videos found for query.")
            return
        candidates = []
        for v in videos:
            video_files = v.get('video_files', [])
            video_url = None
            for file in video_files:
                if file['width'] >= 1920 and file['height'] >= 1080:
                    video_url = file['link']
                    break
            if not video_url:
                continue
            head_resp = requests.head(video_url, timeout=10)
            size = int(head_resp.headers.get('content-length', 0))
            if size >= 50 * 1024 * 1024:
                candidates.append((size, v, video_url))
        if not candidates:
            print("⚠️ No suitable videos found (at least 50MB).")
            return
        candidates.sort(key=lambda x: -x[0])  # largest first
        downloaded_files = []
        total_size = 0
        total_downloaded = 0
        overall_start_time = time.time()
        min_filesize = 50 * 1024 * 1024
        target_bytes = target_size_mb * 1024 * 1024
        for size, v, video_url in candidates:
            remaining = target_bytes - total_size
            if size < min_filesize:
                continue
            if size > remaining:
                continue
            filename = f"pex_{v['id']}_{''.join(random.choices(string.ascii_letters + string.digits, k=8))}.mp4"
            print(f"🎬 Downloading video: {v['id']} ({format_size(size)})")
            file_start_time = time.time()
            resp = requests.get(video_url, stream=True, timeout=10)
            with open(filename, 'wb') as f:
                downloaded = 0
                for chunk in resp.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)
                        downloaded += len(chunk)
                        percent = downloaded / size * 100 if size else 0
                        elapsed = time.time() - file_start_time
                        speed = downloaded / (1024*1024 * elapsed) if elapsed > 0 else 0
                        eta = (size - downloaded) / (speed * 1024*1024) if speed > 0 else 0
                        print(f"\r⬇️ File Progress: {draw_progress_bar(downloaded, size)} "
                              f"({format_size(downloaded)}/{format_size(size)}) "
                              f"Speed: {speed:.2f} MB/s ETA: {format_time(eta)}", end='')
            print("\r✅ File Download completed")
            file_size = os.path.getsize(filename) if os.path.exists(filename) else 0
            if file_size == 0:
                if os.path.exists(filename):
                    os.remove(filename)
                continue
            total_size += file_size
            total_downloaded += file_size
            downloaded_files.append(filename)
        if not downloaded_files:
            print("⚠️ No suitable videos downloaded.")
            return
        original_files = downloaded_files.copy()
        original_size = total_size
        while total_size < target_bytes * 0.95 and original_size > 0:
            new_files = []
            for fn in original_files:
                new_fn = "dup_" + ''.join(random.choices(string.ascii_letters + string.digits, k=8)) + "_" + os.path.basename(fn)
                shutil.copy(fn, new_fn)
                new_files.append(new_fn)
            downloaded_files += new_files
            total_size += original_size
        if len(downloaded_files) == 1:
            os.rename(downloaded_files[0], output_file)
            downloaded_files = []
        else:
            success = False
            if check_ffmpeg():
                print("🔗 Concatenating videos with ffmpeg...")
                with open('list.txt', 'w') as f:
                    for fn in downloaded_files:
                        f.write(f"file '{fn}'\n")
                result = subprocess.run(['ffmpeg', '-f', 'concat', '-safe', '0', '-i', 'list.txt', '-c', 'copy', output_file], capture_output=True, text=True)
                if result.returncode == 0 and os.path.exists(output_file) and os.path.getsize(output_file) > 0:
                    success = True
                else:
                    print(f"⚠️ ffmpeg concatenation failed: {result.stderr}")
                if os.path.exists('list.txt'):
                    os.remove('list.txt')
            if not success:
                print("🔗 Falling back to moviepy for concatenation...")
                success = concatenate_with_moviepy(downloaded_files, output_file)
            if not success:
                print("⚠️ Concatenation failed. Using first video only.")
                os.rename(downloaded_files[0], output_file)
                downloaded_files = downloaded_files[1:]
        for fn in downloaded_files:
            if os.path.exists(fn):
                os.remove(fn)
        if os.path.exists(output_file) and os.path.getsize(output_file) > 0:
            final_size = os.path.getsize(output_file)
            if final_size > target_bytes:
                trim_video_to_size(output_file, target_bytes)
            print(f"✅ Video ready: {output_file} ({format_size(os.path.getsize(output_file))})")
        else:
            print("⚠️ Failed to create final video file.")
    except Exception as e:
        print(f"⚠️ An error occurred: {str(e)}")
        for fn in downloaded_files:
            if os.path.exists(fn):
                os.remove(fn)
        if os.path.exists('list.txt'):
            os.remove('list.txt')

if __name__ == "__main__":
    if len(sys.argv) > 2:
        target_size_mb = int(sys.argv[3]) if len(sys.argv) > 3 else 1000
        download_videos(sys.argv[1], sys.argv[2], target_size_mb=target_size_mb)
    else:
        print("Please provide a search query and output filename.")
EOF
    fi
}

# Setup virtual environment
setup_venv() {
    if [ ! -d "$VENV_DIR" ]; then
        echo -e "${BLUE}Setting up virtual environment...${NC}"
        python3 -m venv "$VENV_DIR" || { echo -e "${RED}Failed to create venv. Ensure python3-venv is installed.${NC}"; exit 1; }
    fi
    source "$VENV_DIR/bin/activate"
    pip install yt-dlp requests moviepy imageio-ffmpeg > /dev/null 2>&1 || echo -e "${YELLOW}Some packages may not install, but continuing...${NC}"
    deactivate
}

# Load config from JSON
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        PRIVATE_KEY=$(jq -r '.private_key // empty' "$CONFIG_FILE")
        RPC_URL=$(jq -r '.rpc_url // empty' "$CONFIG_FILE")
        WALLET_ADDRESS=$(jq -r '.wallet_address // empty' "$CONFIG_FILE")
    fi
}

# Save config to JSON
save_config() {
    jq -n --arg pk "$PRIVATE_KEY" --arg rpc "$RPC_URL" --arg wa "$WALLET_ADDRESS" \
      '{private_key: $pk, rpc_url: $rpc, wallet_address: $wa}' > "$CONFIG_FILE"
}

# Ask for user details
ask_details() {
    load_config
    if [ -z "$PRIVATE_KEY" ] || [ -z "$RPC_URL" ]; then
        echo -ne "${CYAN}🔑 Enter Private Key (with or without 0x): ${NC}"
        read pk
        PRIVATE_KEY="${pk#0x}"
        echo -ne "${CYAN}🌐 Enter RPC URL: ${NC}"
        read RPC_URL
        save_config
    fi
    if [ -z "$WALLET_ADDRESS" ]; then
        echo -ne "${CYAN}💼 Enter Wallet Address: ${NC}"
        read WALLET_ADDRESS
        save_config
    fi
}

# Install Irys CLI if not installed
install_node() {
    if command -v irys >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Irys CLI is already installed. 🎉${NC}"
        return
    fi
    echo -e "${BLUE}🚀 Installing dependencies and Irys CLI...${NC}"
    sudo apt-get update && sudo apt-get upgrade -y 2>&1 | tee -a "$LOG_FILE"
    sudo apt install curl iptables build-essential git wget lz4 jq make protobuf-compiler cmake gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev screen ufw figlet bc -y 2>&1 | tee -a "$LOG_FILE"
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt install -y nodejs 2>&1 | tee -a "$LOG_FILE"
    sudo npm i -g @irys/cli 2>&1 | tee -a "$LOG_FILE"
    if ! command -v irys >/dev/null 2>&1; then
        echo -e "${RED}❌ Failed to install Irys CLI. Check logs in $LOG_FILE. 😞${NC}"
        return 1
    fi
    ask_details
    echo -e "${YELLOW}⚠️ Please claim faucet for devnet now. 💰${NC}"
    read -p "${YELLOW}Press enter after claiming faucet...${NC}"
    add_fund
}

# Add funds
add_fund() {
    ask_details
    echo -e "${BLUE}💸 Adding funds...${NC}"
    echo -ne "${CYAN}Enter amount in ETH to deposit: ${NC}"
    read eth_amount
    amount=$(awk "BEGIN {printf \"%.0f\n\", $eth_amount * 1000000000000000000}")
    irys fund "$amount" -n devnet -t ethereum -w "$PRIVATE_KEY" --provider-url "$RPC_URL" 2>&1 | tee -a "$LOG_FILE"
}

# Check balance
check_balance() {
    ask_details
    echo -e "${BLUE}📊 Checking balance...${NC}"
    irys balance "$WALLET_ADDRESS" -t ethereum -n devnet --provider-url "$RPC_URL" 2>&1 | tee -a "$LOG_FILE"
}

get_balance_eth() {
    balance_output=$(irys balance "$WALLET_ADDRESS" -t ethereum -n devnet --provider-url "$RPC_URL" 2>&1)
    echo "$balance_output" | grep -oP '(?<=\()[0-9.]+(?= ethereum\))' || echo "0"
}

# Upload file function with submenu
upload_file() {
    ask_details
    source "$VENV_DIR/bin/activate"
    if ! command -v ffmpeg >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️ ffmpeg is not installed. Attempting to install... 🔧${NC}"
        sudo apt update && sudo apt install -y ffmpeg 2>&1 | tee -a "$LOG_FILE"
        if ! command -v ffmpeg >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠️ Failed to install ffmpeg. Continuing without it...${NC}"
        else
            echo -e "${GREEN}✅ ffmpeg installed successfully. 🎥${NC}"
        fi
    fi
    while true; do
        clear
        show_header
        echo -e "${PURPLE}${BOLD}🌟======================= Upload File Submenu =======================🌟${NC}"
        echo -e "${YELLOW}1. 📹 Upload Video${NC}"
        echo -e "${YELLOW}2. 📸 Upload Image${NC}"
        echo -e "${YELLOW}3. 🔙 Back to Main Menu${NC}"
        echo -e "${PURPLE}===================================================================${NC}"
        echo -ne "${CYAN}Select an option: ${NC}"
        read subchoice
        case $subchoice in
            3) deactivate; return ;;
            1) upload_type="video" ;;
            2) upload_type="image" ;;
            *) echo -e "${RED}❌ Invalid option. Try again. 🤦${NC}"; sleep 1; continue ;;
        esac
        source_type=""
        while [ -z "$source_type" ]; do
            clear
            show_header
            if [ "$upload_type" == "video" ]; then
                echo -e "${PURPLE}${BOLD}🌟======================= Video Upload Sources =======================🌟${NC}"
                echo -e "${YELLOW}1. 📹 From YouTube (yt-dlp)${NC}"
                echo -e "${YELLOW}2. 🎥 From Pixabay${NC}"
                echo -e "${YELLOW}3. 📽️ From Pexels${NC}"
                echo -e "${YELLOW}4. 🗂️ Manual Upload (from home or pipe folder)${NC}"
                echo -e "${YELLOW}5. 🔙 Back${NC}"
                echo -e "${PURPLE}===================================================================${NC}"
                echo -ne "${CYAN}Select an option: ${NC}"
                read videosub
                case $videosub in
                    1) source_type="youtube" ;;
                    2) source_type="pixabay" ;;
                    3) source_type="pexels" ;;
                    4) source_type="manual" ;;
                    5) break ;;
                    *) echo -e "${RED}❌ Invalid option. Try again. 🤦${NC}"; sleep 1; continue ;;
                esac
            elif [ "$upload_type" == "image" ]; then
                echo -e "${PURPLE}${BOLD}🌟======================= Image Upload Sources =======================🌟${NC}"
                echo -e "${YELLOW}1. 📸 From Picsum (random placeholder images)${NC}"
                echo -e "${YELLOW}2. 🗂️ Manual Upload (from home or pipe folder)${NC}"
                echo -e "${YELLOW}3. 🔙 Back ⏪${NC}"
                echo -e "${PURPLE}===================================================================${NC}"
                echo -ne "${CYAN}Select an option: ${NC}"
                read imagesub
                case $imagesub in
                    1) source_type="picsum" ;;
                    2) source_type="manual" ;;
                    3) break ;;
                    *) echo -e "${RED}❌ Invalid option. Try again. 🤦${NC}"; sleep 1; continue ;;
                esac
            fi
        done
        if [ -z "$source_type" ]; then continue; fi
        balance_eth=$(get_balance_eth)
        target_size_mb=""
        if [ "$upload_type" == "video" ] || [ "$source_type" == "manual" ]; then
            max_mb=$(awk "BEGIN {print int(($balance_eth / 0.0012) * 100)}")
            echo -e "${YELLOW}Based on your balance (${balance_eth} ETH), you can upload approximately ${max_mb} MB.${NC}"
            if [ "$source_type" != "manual" ]; then
                echo -ne "${CYAN}Enter target file size in MB: ${NC}"
                read target_size_mb
            fi
            if [ -n "$target_size_mb" ]; then
                estimated_cost=$(awk "BEGIN {print ($target_size_mb / 100) * 0.0012}")
                echo -e "${YELLOW}Estimated cost for ${target_size_mb} MB upload: ~${estimated_cost} ETH${NC}"
                echo -e "${YELLOW}Your current balance: ${balance_eth} ETH${NC}"
                if [ "$(awk "BEGIN {if ($balance_eth < $estimated_cost) print 1; else print 0}")" = "1" ]; then
                    echo -e "${RED}⚠️ Insufficient balance. You have approximately ${balance_eth} ETH, but need ~${estimated_cost} ETH.${NC}"
                    read -p "${CYAN}Do you want to continue anyway? (y/n): ${NC}" continue_confirm
                    if [[ ! "$continue_confirm" =~ ^[yY]$ ]]; then
                        return_to_menu
                        continue
                    fi
                fi
            fi
        fi
        case $source_type in
            youtube)
                echo -e "${CYAN}🔍 Enter a search query for the video (e.g., 'random full hd'): ${NC}"
                read query
                echo -e "${BLUE}📥 Downloading video from YouTube... 🎬${NC}"
                random_suffix=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
                output_file="video_$random_suffix.mp4"
                python3 "$VIDEO_DOWNLOADER_PY" "$query" "$output_file" "$target_size_mb" 2>&1 | tee -a "$LOG_FILE"
                ;;
            pixabay)
                API_KEY_FILE="$HOME/.pixabay_api_key"
                if [ -f "$API_KEY_FILE" ]; then
                    api_key=$(cat "$API_KEY_FILE")
                    if [ -z "$api_key" ] || [ ${#api_key} -lt 10 ]; then
                        echo -e "${YELLOW}⚠️ Invalid or empty Pixabay API key found in $API_KEY_FILE.${NC}"
                        rm -f "$API_KEY_FILE" 2>/dev/null
                    fi
                fi
                if [ ! -f "$API_KEY_FILE" ]; then
                    echo -e "${YELLOW}⚠️ Pixabay API key not found. Please provide a valid API key. 🔑${NC}"
                    while true; do
                        echo -e "${CYAN}Enter your Pixabay API key: ${NC}"
                        read api_key
                        if [ -n "$api_key" ] && [ ${#api_key} -ge 10 ]; then
                            break
                        else
                            echo -e "${RED}❌ Invalid API key (empty or too short). Please try again.${NC}"
                        fi
                    done
                    echo "$api_key" > "$API_KEY_FILE"
                    echo -e "${GREEN}✅ Pixabay API key saved to $API_KEY_FILE. 💾${NC}"
                fi
                echo -e "${CYAN}🔍 Enter a search query for the video (e.g., 'nature'): ${NC}"
                read query
                echo -e "${BLUE}📥 Downloading video from Pixabay... 🌟${NC}"
                random_suffix=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
                output_file="video_$random_suffix.mp4"
                python3 "$PIXABAY_DOWNLOADER_PY" "$query" "$output_file" "$target_size_mb" 2>&1 | tee -a "$LOG_FILE"
                ;;
            pexels)
                API_KEY_FILE="$HOME/.pexels_api_key"
                if [ -f "$API_KEY_FILE" ]; then
                    api_key=$(cat "$API_KEY_FILE")
                    if [ -z "$api_key" ] || [ ${#api_key} -lt 10 ]; then
                        echo -e "${YELLOW}⚠️ Invalid or empty Pexels API key found in $API_KEY_FILE.${NC}"
                        rm -f "$API_KEY_FILE" 2>/dev/null
                    fi
                fi
                if [ ! -f "$API_KEY_FILE" ]; then
                    echo -e "${YELLOW}⚠️ Pexels API key not found. Please provide a valid API key. 🔑${NC}"
                    while true; do
                        echo -e "${CYAN}Enter your Pexels API key: ${NC}"
                        read api_key
                        if [ -n "$api_key" ] && [ ${#api_key} -ge 10 ]; then
                            break
                        else
                            echo -e "${RED}❌ Invalid API key (empty or too short). Please try again.${NC}"
                        fi
                    done
                    echo "$api_key" > "$API_KEY_FILE"
                    echo -e "${GREEN}✅ Pexels API key saved to $API_KEY_FILE. 💾${NC}"
                fi
                echo -e "${CYAN}🔍 Enter a search query for the video (e.g., 'nature'): ${NC}"
                read query
                echo -e "${BLUE}📥 Downloading video from Pexels... ✨${NC}"
                random_suffix=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
                output_file="video_$random_suffix.mp4"
                python3 "$PEXELS_DOWNLOADER_PY" "$query" "$output_file" "$target_size_mb" 2>&1 | tee -a "$LOG_FILE"
                ;;
            picsum)  
                width=$((RANDOM % 1921 + 640))    
                height=$((RANDOM % 1081 + 480))
                if (( RANDOM % 2 )); then grayscale="?grayscale"; else grayscale=""; fi
                blur=$((RANDOM % 11))
                if [ $blur -gt 0 ]; then blur_param="&blur=$blur"; else blur_param=""; fi
                seed=$((RANDOM % 10000))
                if [ -n "$seed" ]; then seed_path="/seed/$seed"; else seed_path=""; fi
                url="https://picsum.photos$seed_path/$width/$height$grayscale$blur_param"
                random_suffix=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
                output_file="picsum_$random_suffix.jpg"
                echo -e "${BLUE}📥 Downloading image from Picsum: $url ... 🖼️${NC}"
                curl -L -o "$output_file" "$url" 2>&1 | tee -a "$LOG_FILE"
                ;;
            manual)
                if [ "$upload_type" == "video" ]; then
                    echo -e "${BLUE}🔍 Searching for .mp4 files in $HOME and $HOME/pipe... 🔎${NC}"
                    files=($(find "$HOME" "$HOME/pipe" -type f -name "*.mp4" 2>/dev/null))
                else
                    echo -e "${BLUE}🔍 Searching for image files (.jpg, .png, .gif, .jpeg) in $HOME and $HOME/pipe... 🔎${NC}"
                    files=($(find "$HOME" "$HOME/pipe" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.gif" -o -name "*.jpeg" \) 2>/dev/null))
                fi
                if [ ${#files[@]} -eq 0 ]; then
                    echo -e "${RED}❌ No suitable files found. 😔${NC}"
                    return_to_menu
                    continue
                fi
                echo -e "${YELLOW}Available files:${NC}"
                for i in "${!files[@]}"; do
                    size=$(du -h "${files[i]}" | cut -f1)
                    echo "$((i+1)). ${files[i]} ($size)"
                done
                echo -ne "${CYAN}Select a number: ${NC}"
                read num
                if [[ $num =~ ^[0-9]+$ ]] && [ $num -ge 1 ] && [ $num -le ${#files[@]} ]; then
                    selected="${files[$((num-1))]}"
                    output_file="${selected##*/}"
                    size_mb=$(du -m "$selected" | cut -f1)
                    echo -e "${GREEN}✅ Selected: $selected 🎉${NC}"
                    estimated_cost=$(awk "BEGIN {print ($size_mb / 100) * 0.0012}")
                    echo -e "${YELLOW}Estimated cost for ${size_mb} MB upload: ~${estimated_cost} ETH${NC}"
                    echo -e "${YELLOW}Your current balance: ${balance_eth} ETH${NC}"
                    if [ "$(awk "BEGIN {if ($balance_eth < $estimated_cost) print 1; else print 0}")" = "1" ]; then
                        echo -e "${RED}⚠️ Insufficient balance. You have approximately ${balance_eth} ETH, but need ~${estimated_cost} ETH.${NC}"
                        read -p "${CYAN}Do you want to continue anyway? (y/n): ${NC}" continue_confirm
                        if [[ ! "$continue_confirm" =~ ^[yY]$ ]]; then
                            return_to_menu
                            continue
                        fi
                    fi
                else
                    echo -e "${RED}❌ Invalid selection. 🤦${NC}"
                    return_to_menu
                    continue
                fi
                ;;
        esac
        size_mb=$(du -m "$output_file" | cut -f1 2>/dev/null || echo 0)
        if [ -f "$output_file" ] || [ "$source_type" = "manual" ]; then
            if [ "$source_type" = "manual" ]; then
                file_to_upload="$selected"
            else
                file_to_upload="$output_file"
            fi
            echo -e "${BLUE}⬆️ Uploading file to Irys... 🚀${NC}"
            retries=0
            max_retries=3
            while [ $retries -lt $max_retries ]; do
                attempt=$((retries+1))
                echo -e "${BLUE}📤 Upload attempt ${attempt}/${max_retries}... 🔄${NC}"
                upload_output=$(irys upload "$file_to_upload" -n devnet -t ethereum -w "$PRIVATE_KEY" --provider-url "$RPC_URL" --tags file_name "${output_file%.*}" --tags file_format "${output_file##*.}" 2>&1)
                if [ $? -eq 0 ]; then
                    echo "$upload_output" | tee -a "$LOG_FILE"
                    url=$(echo "$upload_output" | grep -oP 'Uploaded to \K(https?://[^\s]+)')
                    txid=$(basename "$url")
                    if [ -n "$txid" ]; then
                        echo -e "${BLUE}💾 Saving file details to $DETAILS_FILE... 📝${NC}"
                        if [ ! -f "$DETAILS_FILE" ]; then
                            echo "[]" > "$DETAILS_FILE"
                        fi
                        jq --arg fn "$output_file" --arg fid "$txid" --arg dl "$url" --arg sl "$url" \
                           '. + [{"file_name": $fn, "file_id": $fid, "direct_link": $dl, "social_link": $sl}]' \
                           "$DETAILS_FILE" > tmp.json && mv tmp.json "$DETAILS_FILE"
                        if [ $? -eq 0 ]; then
                            echo -e "${GREEN}✅ File details saved successfully. 🎉${NC}"
                        else
                            echo -e "${YELLOW}⚠️ Failed to save file details to $DETAILS_FILE 😞${NC}"
                        fi
                        if [ "$source_type" != "manual" ]; then
                            echo -e "${BLUE}🗑️ Deleting local file... 🧹${NC}"
                            rm -f "$output_file"
                        fi
                        break
                    else
                        echo -e "${YELLOW}⚠️ Failed to extract Transaction ID or URL. 🤔${NC}"
                    fi
                else
                    echo -e "${YELLOW}⚠️ Upload failed: $upload_output${NC}" | tee -a "$LOG_FILE"
                fi
                retries=$((retries+1))
                sleep 5
            done
            if [ $retries -eq $max_retries ]; then
                echo -e "${RED}❌ Upload failed after $max_retries attempts. Check logs in $LOG_FILE. 😔${NC}"
                if [ "$source_type" != "manual" ]; then
                    rm -f "$output_file" 2>/dev/null
                fi
            fi
        else
            echo -e "${YELLOW}⚠️ No file found. Download may have failed or been canceled. 😞${NC}"
        fi
        return_to_menu
    done
    deactivate
}

view_change_config() {
    load_config
    masked_pk="${PRIVATE_KEY:0:6}...${PRIVATE_KEY: -4}"

    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   ⚙️  ${BOLD}Current Irys Config${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "🔑  ${YELLOW}Private Key: ${NC}$masked_pk"
    echo -e "🌐  ${YELLOW}RPC URL:     ${NC}$RPC_URL"
    echo -e "👛  ${YELLOW}Wallet Addr: ${NC}$WALLET_ADDRESS"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

    echo -ne "${CYAN}❓ Do you want to update the config? (y/n): ${NC}"
    read confirm

    if [[ "$confirm" =~ ^[yY]$ ]]; then
        echo -e "\n${BLUE}✏️  Updating Config...${NC}\n"

        echo -ne "${CYAN}🔑 Enter new Private Key (press enter to keep current): ${NC}"
        read new_pk
        if [ -n "$new_pk" ]; then
            PRIVATE_KEY="${new_pk#0x}"
        fi

        echo -ne "${CYAN}🌐 Enter new RPC URL (press enter to keep current): ${NC}"
        read new_rpc
        if [ -n "$new_rpc" ]; then
            RPC_URL="$new_rpc"
        fi

        echo -ne "${CYAN}👛 Enter new Wallet Address (press enter to keep current): ${NC}"
        read new_wa
        if [ -n "$new_wa" ]; then
            WALLET_ADDRESS="$new_wa"
        fi

        save_config
        echo -e "\n${GREEN}✅ Config updated successfully!${NC}\n"
    else
        echo -e "\n${YELLOW}⚠️  No changes made.${NC}\n"
    fi
}

return_to_menu() {
    echo -e "${CYAN}Press enter to return to menu... ⏎${NC}"
    read
}

# Main menu
main_menu() {
    create_python_scripts
    setup_venv
    while true; do
        show_header

        echo -e "${BLUE}${BOLD}======================= IRYS CLI MANAGER BY Aashish 💖 =======================${NC}"
        echo -e "${YELLOW}1. 🛠️ Install IRYS CLI${NC}"
        echo -e "${YELLOW}2. ⬆️ Upload File${NC}"
        echo -e "${YELLOW}3. 💸 Add Fund${NC}"
        echo -e "${YELLOW}4. 📊 Check Balance${NC}"
        echo -e "${YELLOW}5. ⚙️ View/Change Config${NC}"
        echo -e "${YELLOW}6. ❌ Exit${NC}"
        echo -e "${BLUE}=============================================================================${NC}"
        echo -ne "${CYAN}Select an option: ${NC}"
        read choice
        case $choice in
            1) install_node; return_to_menu ;;
            2) upload_file ;;
            3) add_fund; return_to_menu ;;
            4) check_balance; return_to_menu ;;
            5) view_change_config; return_to_menu ;;
            6) echo -e "${GREEN}Goodbye!🎸${NC}"; exit 0 ;;
            *) echo -e "${RED}❌ Invalid option. Try again, champ! 💪${NC}"; sleep 1 ;;
        esac
    done
}

main_menu  
