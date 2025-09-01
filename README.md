# 🚀 Irys CLI Manager: Your Ultimate Devnet Power Tool!

![Irys CLI Manager Banner](https://picsum.photos/seed/irys/1200/400?blur=2&grayscale)  
*Empower your Irys interactions with ease – Install, Upload, Fund, and Manage like a pro! Built by Aashish for devs, creators, and airdrop enthusiasts. 💖*

---

## 🌟 Quick Start: Launch in One Command!

Dive right in with this simple terminal magic:  
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/HustleAirdrops/irys-cli-node-one-command/main/menu.sh)
```  
*Pro Tip: Run on a fresh VPS or local machine for best results. No daily maintenance needed – it's a lightweight CLI!*

---

## 🎮 The Sleek Interactive Dashboard

Once launched, greet the vibrant menu:  
```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                  IRYS CLI MANAGER BY AASHISH – POWERED BY xAI 💖                           │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
1. 🛠️ Install IRYS CLI – Set up in seconds!
2. ⬆️ Upload Files – Videos, Images, Automated Magic!
3. 💸 Add Funds – Fuel your wallet effortlessly.
4. 📊 Check Balance – Stay on top of your ETH.
5. ⚙️ View/Change Config – Tweak settings anytime.
6. ❌ Exit – See you next time!
```

Navigate with numbers – intuitive, fast, and fun! Submenus for uploads keep things organized and clutter-free.

---

## 🔧 Core Features: What Makes It Shine

This tool streamlines your Irys devnet workflow. Here's the breakdown, smooth and step-by-step:

### 1. 🛠️ Install IRYS CLI  
   - **One-Time Setup:** Auto-installs Irys CLI + dependencies (Node.js, ffmpeg, etc.).  
   - **Config Magic:** Prompts for Private Key (0x optional), RPC URL, and Wallet Address – saved securely in `~/.irys_config.json`.  
   - **Faucet Time:** Claim free Sepolia ETH to get started:  
     - 🌐 [PK910 Sepolia Faucet](https://sepolia-faucet.pk910.de/)  
     - ☁️ [Google Cloud Sepolia Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)  
     - 🤖 [Telegram Faucet Bot](https://t.me/Faucet_Trade_bot)  
   - *Why Sepolia?* It's Ethereum's testnet (Chain ID: 11155111). Grab RPC from [Chainlist.org](https://chainlist.org/chain/11155111).  
   - **Usage Tip:** Run once; CLI persists for future use. No "running node" – just command-line power!

### 2. ⬆️ Upload Files – Effortless & Smart  
   Submenu pops up: Videos or Images? Choose your adventure!  
   - **📹 Video Uploads:**  
     Sources include YouTube (yt-dlp search), Pixabay/Pexels (API-powered), or Manual (.mp4 from home/pipe folder).  
     - Enter target size (MB) – Script downloads, concatenates, duplicates, or trims to match!  
     - Cost Estimate: ~0.0012 ETH per 100 MB. Balance check built-in.  
     - API Keys: Free from [Pixabay Docs](https://pixabay.com/api/docs/) or [Pexels API](https://www.pexels.com/api/) – Saved securely.  
   - **📸 Image Uploads:**  
     Picsum for random gems (customize size, grayscale, blur) or Manual (.jpg/.png/etc.).  
   - **Post-Upload Perks:** Details saved in `~/irys_file_details.json` (ID, links). Auto-cleanup for non-manual files. Retries on fails!  
   - *Eye-Candy:* Progress bars, emojis, and logs in `~/irys_script.log` for transparency.

### 3. 💸 Add Funds  
   - Prompt for ETH amount – Deposits instantly to your Irys devnet wallet via private key/RPC.  
   - *Tip:* Start small (0.001 ETH) for testing. Faucets keep it free!

### 4. 📊 Check Balance  
   - Instant ETH readout on devnet. Perfect before big uploads!

### 5. ⚙️ View/Change Config  
   - View masked Private Key, RPC, Wallet. Update any – No restarts needed!

### 6. ❌ Exit  
   - Clean shutdown. Ctrl+C anytime for graceful exit.

*Smart Handling:* Video processing uses ffmpeg/moviepy (auto-installs if missing). Retries uploads 3x. Everything logged!

---

## ❓ Quick Q&A: Your Doubts, Demolished!

| Question | Answer |
|----------|--------|
| **Daily Runs Needed?** | Nope! One-time install. Run script only when uploading/funding. CLI stays ready. |
| **Uninstall Everything?** | Easy one-liner: `rm -rf ~/irys_venv ~/.irys_config.json ~/irys_script.log ~/irys_file_details.json ~/.pixabay_api_key ~/.pexels_api_key ~/video_downloader.py ~/pixabay_downloader.py ~/pexels_downloader.py && sudo npm uninstall -g @irys/cli`. Backup first! |
| **Upload Size Mismatch?** | Script smartly merges/trims – Try broader queries if short. Manual for precision. |
| **Balance/RPC Errors?** | Low funds? Claim faucets. RPC issues? Update via menu (try new from Chainlist). Logs help debug. |
| **API Key Troubles?** | Free sign-ups linked above. Invalid? Delete file & re-enter. Check quotas. |

Not here? Logs in `~/irys_script.log` or hit support!

---

## 🔍 Pro Tips for Peak Performance
- **Balance First:** Always check (option 4) – Avoid "Insufficient balance" surprises.  
- **Faucet Strategy:** Rotate faucets if rate-limited. Sepolia ETH is free but limited.  
- **Query Power:** For uploads, use "nature 4k" or "random hd" for rich results.  
- **Security:** Never share private key. Config is local & secure.  
- **Logs & Debug:** Everything in `~/irys_script.log` – Your troubleshooting buddy!

---

## 💬 Support & Community
- **Direct Help:** Telegram [@Legend_Aashish](https://t.me/Legend_Aashish)  
- **Updates & Guides:** Join [@Hustle_Airdrops](https://t.me/Hustle_Airdrops) for videos, tips, and airdrops!  
- **GitHub:** Star [HustleAirdrops/Irys-CLI-Manager](https://github.com/HustleAirdrops) – Contribute or report issues.  

*Join the hustle – More tools coming soon! 🚀*  

---  

Made with 💖 by Aashish – Redesigned for max vibe! 😎
