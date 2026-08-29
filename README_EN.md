<a href="https://github.com/GhostenEditor/Ghosten-Player">
  <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://socialify.git.ci/GhostenEditor/Ghosten-Player/image?custom_description=Available+for+%F0%9F%93%B1+Android+Phone+%E2%80%A2+%F0%9F%93%BA+Android+TV+%EF%BC%81&description=1&font=Source+Code+Pro&forks=1&issues=1&logo=https%3A%2F%2Fgithub.com%2FGhostenEditor%2FGhosten-Player%2Fraw%2Fmain%2Fassets%2Fcommon%2Fimages%2Flogo.png&name=1&pattern=Plus&pulls=1&stargazers=1&theme=Dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://socialify.git.ci/GhostenEditor/Ghosten-Player/image?custom_description=Available+for+%F0%9F%93%B1+Android+Phone+%E2%80%A2+%F0%9F%93%BA+Android+TV+%EF%BC%81&description=1&font=Source+Code+Pro&forks=1&issues=1&logo=https%3A%2F%2Fgithub.com%2FGhostenEditor%2FGhosten-Player%2Fraw%2Fmain%2Fassets%2Fcommon%2Fimages%2Flogo.png&name=1&pattern=Plus&pulls=1&stargazers=1" />
   <img alt="Star History Chart" src="https://socialify.git.ci/GhostenEditor/Ghosten-Player/image?custom_description=Available+for+%F0%9F%93%B1+Android+Phone+%E2%80%A2+%F0%9F%93%BA+Android+TV+%EF%BC%81&description=1&font=Source+Code+Pro&forks=1&issues=1&logo=https%3A%2F%2Fgithub.com%2FGhostenEditor%2FGhosten-Player%2Fraw%2Fmain%2Fassets%2Fcommon%2Fimages%2Flogo.png&name=1&pattern=Plus&pulls=1&stargazers=1" />
  </picture>
</a>

![android 6.0 or above](https://img.shields.io/badge/android-6.0_or_above-purple?logo=android) 
[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/GhostenEditor/Ghosten-Player/release.yml?logo=github&label=android%20build)](https://github.com/GhostenEditor/Ghosten-Player/actions/workflows/release.yml)
[![GitHub Release](https://img.shields.io/github/v/release/GhostenEditor/Ghosten-Player)](https://github.com/GhostenEditor/Ghosten-Player/releases/latest)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/GhostenEditor/Ghosten-Player/total)

English | [中文](./README.md)

**Ghosten Player** is a video player compatible with both 📱**Android Phone** and 📺**Android TV**, with future support for Windows and macOS under development. It integrates media resources, automatically scrapes metadata, supports IPTV playback, and elegantly builds your personal media library. With a clean interface and rich features, it works out of the box.

---  

If this project helps you, please give it a 🌟**Star**.

The project is currently maintained with passion. Consider [sponsoring](#sponsor) to support its continuous development. Your support is the greatest motivation for me to keep maintaining it (′･ω･`)

## Features

- **Automatic metadata scraping**
  - [themoviedb](https://www.themoviedb.org)
  - nfo
- **Clients**
    - Android Phone & Pad
    - Android TV
    - Windows (Under Development)
    - macOS (Under Development)
- **Cloud Storage Support**
    - [Aliyun Drive](https://www.alipan.com), [Quark Cloud Drive](https://pan.quark.cn), WebDAV, and local media files
  - [Emby](https://emby.media) & [Jellyfin](https://jellyfin.org)
    - Resolution switching (Aliyun Drive)
    - Multi-account login
    - File management for cloud storage
    - Download & stream while downloading
    - Multi-thread network acceleration
- **IPTV**
    - Channel switching
    - Auto-grouping
    - EPG program schedule
- **Player**
    - Gesture controls (double-tap to play/pause/skip, volume/brightness adjustment, zoom, seek, long-press for speed control, etc.)
    - Skip intro/outro
    - Embedded & external subtitles support[^2]
    - Playback speed control
    - Video track selection
    - DLNA casting
    - Custom subtitle styles
- **UI**
    - Bilingual (Chinese & English)
    - Light & dark themes
    - Phone-assisted input for TV
    - Customizable UI scaling
  - Customized buttons on TV
- **Others**
    - Runs locally, no backend required[^1]
    - Small app size (≈ 15 MB)
  - External USB device reading
    - Cross-device data sync
    - Built-in search
    - Auto-update

[^1]: Cloud storage services are provided by third-party providers and are unrelated to this project.  
[^2]: External subtitle formats: XML, VTT, ASS, SRT.

## Installation

Download the latest version from [Releases](https://github.com/GhostenEditor/Ghosten-Player/releases/latest). Choose the APK based on your device's architecture (see table below).

**Note:** Starting from v1.6.0, mobile and TV versions are packaged separately and are **not interchangeable**.

| Architecture / Client | Phone/Pad                                      | TV                                          |  
|-----------------------|------------------------------------------------|---------------------------------------------|  
| arm64-v8a             | `app-arm64-v8a-release.apk`<br/>(Most devices) | `app-arm64-v8a-tv-release.apk`              |  
| armeabi-v7a           | `app-armeabi-v7a-release.apk`<br/>(Low-end devices) | `app-armeabi-v7a-tv-release.apk`<br/>(Most TVs) |  

## Compatibility

Android 6.0+

## Demo
[https://ghosteneditor.github.io/Ghosten-Player](https://ghosteneditor.github.io/Ghosten-Player)

**Note:** The demo is for preview purposes only. Some features are limited due to web restrictions and may not reflect the latest release. Check [Releases](https://github.com/GhostenEditor/Ghosten-Player/releases/latest) for the full version.

> Use **Chrome** or **Edge** on desktop for the best demo experience. Mobile browsers may have compatibility issues.

## Preview [^3]

### TV Screenshots

<div style="display: flex;">  
<img src="https://github.com/user-attachments/assets/11e2e8c6-ee09-479d-97ce-55b8c328a69d" alt="TV Screenshot 1" width="48%"/>  
<img src="https://github.com/user-attachments/assets/06126725-a87c-468a-8b4e-61fe91f3b5b6" alt="TV Screenshot 2" width="48%"/>  
</div>  
<div style="display: flex;">  
<img src="https://github.com/user-attachments/assets/841093d0-b803-4b63-93a7-70fc75f97c32" alt="TV Screenshot 3" width="48%"/>  
<img src="https://github.com/user-attachments/assets/ca811ddf-fb65-4c3b-9505-94509a4f1fec" alt="TV Screenshot 4" width="48%"/>  
</div>  
<div style="display: flex;">  
<img src="https://github.com/user-attachments/assets/d320a145-3fd4-453f-a541-9e19e580d1d5" alt="TV Screenshot 5" width="48%"/>  
<img src="https://github.com/user-attachments/assets/45cb240a-a921-46c2-a2ce-c31e5709656a" alt="TV Screenshot 6" width="48%"/>  
</div>  
<div style="display: flex;">  
<img src="https://github.com/user-attachments/assets/9a34cfa9-27b7-457e-b2ab-18b014dd57c9" alt="TV Screenshot 7" width="48%"/>  
<img src="https://github.com/user-attachments/assets/a43ec774-3ad1-4387-bb04-68a040bca288" alt="TV Screenshot 8" width="48%"/>  
</div>  

### Android Phone Screenshots

<div style="display: flex;">  
<img src="https://github.com/user-attachments/assets/19b41deb-f959-4008-b1ed-859c6399a04a" alt="Mobile Screenshot 1" width="24%"/>  
<img src="https://github.com/user-attachments/assets/f9fb8a0c-e233-49d0-8451-f7d154e1643e" alt="Mobile Screenshot 2" width="24%"/>  
<img src="https://github.com/user-attachments/assets/456dc7b9-2bcd-492a-ae14-f9d69b481ebe" alt="Mobile Screenshot 3" width="24%"/>  
<img src="https://github.com/user-attachments/assets/65215d01-12be-417f-8b96-f35d2a272373" alt="Mobile Screenshot 4" width="24%"/>  
</div>  
<div style="display: flex;">  
<img src="https://github.com/user-attachments/assets/5487f5de-d97d-4a5e-8461-5e6ca80f4864" alt="Mobile Screenshot 5" width="24%"/>  
<img src="https://github.com/user-attachments/assets/c9e73ce6-ce33-4644-a49b-db534a8d4c91" alt="Mobile Screenshot 6" width="24%"/>  
<img src="https://github.com/user-attachments/assets/2d9c0993-7611-47ab-9ed7-6f490f56b3b1" alt="Mobile Screenshot 7" width="24%"/>  
<img src="https://github.com/user-attachments/assets/ab981465-4077-4b6a-a276-49716b03f9fa" alt="Mobile Screenshot 8" width="24%"/>  
</div>  

[^3]: Media content in previews is for demonstration only.

## Documentation

For user guides and FAQs, visit the [Wiki](https://github.com/GhostenEditor/Ghosten-Player/wiki). If you encounter bugs or have suggestions, feel free to open an [Issue](https://github.com/GhostenEditor/Ghosten-Player/issues). Responses are prioritized! 😊

### Wiki Contents

- **Guides**
  - [Add Accounts](https://github.com/GhostenEditor/Ghosten-Player/wiki/添加账号)
  - [Add Resources](https://github.com/GhostenEditor/Ghosten-Player/wiki/添加资源)
  - [TV Remote Control](https://github.com/GhostenEditor/Ghosten-Player/wiki/TV端操作方式)
  - [DLNA Casting](https://github.com/GhostenEditor/Ghosten-Player/wiki/DLNA投屏)
  - [Multi-thread Acceleration](https://github.com/GhostenEditor/Ghosten-Player/wiki/多线程网络加速)
  - [Data Sync](https://github.com/GhostenEditor/Ghosten-Player/wiki/数据同步)
  - [Organize Files](https://github.com/GhostenEditor/Ghosten-Player/wiki/整理文件信息)
  - [File Downloads](https://github.com/GhostenEditor/Ghosten-Player/wiki/文件下载)
  - [Add IPTV Sources](https://github.com/GhostenEditor/Ghosten-Player/wiki/添加直播源)
  - [Skip Intro/Outro](https://github.com/GhostenEditor/Ghosten-Player/wiki/跳过片头片尾)
- **Troubleshooting**
  - [WebDAV Errors](https://github.com/GhostenEditor/Ghosten-Player/wiki/Webdav报错)
  - [Metadata Scraping Problems](https://github.com/GhostenEditor/Ghosten-Player/wiki/刮削媒体信息相关问题)
  - [App Crashes](https://github.com/GhostenEditor/Ghosten-Player/wiki/应用闪退)
  - [Playback Lag](https://github.com/GhostenEditor/Ghosten-Player/wiki/播放卡顿)
  - [Data Errors](https://github.com/GhostenEditor/Ghosten-Player/wiki/数据错误)
  - [Missing Video/Audio](https://github.com/GhostenEditor/Ghosten-Player/wiki/画面或声音缺失)
- [Permissions](https://github.com/GhostenEditor/Ghosten-Player/wiki/应用权限)
- [Data Security](https://github.com/GhostenEditor/Ghosten-Player/wiki/数据安全)
- [Supported Formats](https://github.com/GhostenEditor/Ghosten-Player/wiki/格式支持)

## Roadmap

Development priorities (in order):

- [x] Mobile & player UI improvements
- [x] Add search functionality
- [x] IPTV program list support
- [ ] Save metadata to NFO files
- [ ] Add danmaku (bullet comments) support
- [ ] Integrate MPV player for legacy codecs
- [ ] Publish to Google Play
- [ ] Add FTP/SMB protocol support
- [ ] Desktop clients (Under Development)
- [x] Fix DLNA casting compatibility
- [ ] Client interconnectivity

## Sponsor

If you find this project useful, consider buying me a ☕ **coffee** to keep the development alive!

[Sponsor list](./sponsor_list.txt)

<img src="https://github.com/user-attachments/assets/1aa84d31-095f-4529-b531-77d242d07a3c" alt="Sponsor" width="240"/>  

## Star History

<a href="https://github.com/GhostenEditor/Ghosten-Player">  
 <picture>  
   <source media="(prefers-color-scheme: dark)" srcset="https://star-history.dera.page/svg?repos=GhostenEditor/Ghosten-Player&type=Date&theme=dark" />  
   <source media="(prefers-color-scheme: light)" srcset="https://star-history.dera.page/svg?repos=GhostenEditor/Ghosten-Player&type=Date" />  
   <img alt="Star History Chart" src="https://star-history.dera.page/svg?repos=GhostenEditor/Ghosten-Player&type=Date" />  
 </picture>  
</a>  

## Disclaimer

- This project is for **personal learning purposes only**.
- **No media content** is provided by this project. Any copyright infringement issues are unrelated to the developers.
- Use at your own risk. The developers are not responsible for potential issues such as account bans, download throttling, etc.
