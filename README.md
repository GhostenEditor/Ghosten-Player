![Ghosten-Player](https://socialify.git.ci/GhostenEditor/Ghosten-Player/image?custom_description=Available+for+%F0%9F%93%B1+Android+Phone+%E2%80%A2+%F0%9F%93%BA+Android+TV+%EF%BC%81&description=1&font=Source+Code+Pro&forks=1&issues=1&logo=https%3A%2F%2Fgithub.com%2FGhostenEditor%2FGhosten-Player%2Fraw%2Fmain%2Fassets%2Fcommon%2Fimages%2Flogo.png&name=1&pattern=Plus&pulls=1&stargazers=1&theme=Auto)

<div align="center">

![android 6.0 or above](https://img.shields.io/badge/android-6.0_or_above-purple?style=for-the-badge&logo=android)
[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/GhostenEditor/Ghosten-Player/release.yml?logo=github&style=for-the-badge&label=android%20build)](https://github.com/GhostenEditor/Ghosten-Player/actions/workflows/release.yml)
[![GitHub Release](https://img.shields.io/github/v/release/GhostenEditor/Ghosten-Player?style=for-the-badge)](https://github.com/GhostenEditor/Ghosten-Player/releases/latest)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/GhostenEditor/Ghosten-Player/total?style=for-the-badge)

</div>

Ghosten Player 是一款同时适配📱 Android Phone 和 📺 Android TV 的视频播放器。整合影视资源，自动刮削媒体信息，支持IPTV播放，优雅打造私人影视库。
界面简洁，功能丰富，开箱即用。

---

喜欢或者对您有用的话就给颗🌟Star吧，您的支持是我维护的最大动力(′･ω･`)

## Features

- 自动刮削媒体信息
- 客户端
    - Android Phone 和 Android Pad
    - Android TV
    - Windows (开发中)
    - Macos (开发中)
- 网盘支持
    - 支持阿里云盘、夸克网盘、Webdav和本地媒体文件
    - 多账号登录
    - 网盘文件查看和管理
    - 文件下载和边下边播
    - 多线程网络加速
- IPTV
    - 内置IPTV源，不定时更新
    - 线路切换
    - 自动分组
    - 节目时间表 (开发中)
- 播放器
    - 手势操作(双击播放/暂停，音量/亮度调节，画面缩放，拖动快进等)
    - 跳过片头/片尾
    - 播放内嵌字幕和外置字幕[^2]
    - 倍速播放
    - 视频轨道选择
    - DLNA投屏
- UI
    - 中英双语
    - 浅色和深色模式
    - 支持手机端辅助TV端输入
- 其他
    - 纯本地运行，无需后端服务支持 [^1]
    - 软件体积小 (≈ 15 MB)
    - 设备间的数据同步
    - 自动更新

[^1]: 网盘由网盘供应商提供服务支持，与本项目无关

[^2]: 外置字幕支持xml、vtt、ass、srt格式

## 安装

[Releases](https://github.com/GhostenEditor/Ghosten-Player/releases/latest) 根据设备的架构自行选择安装包，安装包选择见下表

自v1.6.0版本后，移动端和TV端分开打包，且不能混用

| 架构 / 客户端    | Phone/Pad                                      | TV                                          |
|-------------|------------------------------------------------|---------------------------------------------|
| arm64-v8a   | app-arm64-v8a-release.apk<br/>适合大部分设备，手机多数为此架构 | app-arm64-v8a-tv-release.apk                |
| armeabi-v7a | app-armeabi-v7a-release.apk<br/>适合部分配置较低的设备    | app-armeabi-v7a-tv-release.apk<br/>TV多数为此架构 |

## 版本适配

Android 6+

## 预览 [^3]

### TV 截图

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

### Android Phone 截图

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

[^3]: 预览中的影视媒体仅作为展示用

## 其他说明

使用说明和常见问题解决方案详见 [Wiki](https://github.com/GhostenEditor/Ghosten-Player/wiki)
，如果遇到Bug或者有应用优化建议，欢迎提 [Issue](https://github.com/GhostenEditor/Ghosten-Player/issues)，我会在第一时间回复
😊

## Roadmap

按照以下顺序进行开发

- [x] 移动端UI以及播放器UI调整
- [ ] 增加搜索功能，包括语音搜索
- [ ] IPTV增加节目列表
- [ ] 增加弹幕功能
- [ ] 整合MPV播放器，兼容老旧的音视频格式
- [ ] 应用上架Google Play
- [ ] 增加ftp和smb协议和emby的支持
- [ ] 保存媒体信息至文件(nfo)
- [ ] 桌面端(Developing)
- [ ] DLNA投屏的兼容问题
- [ ] 客户端串联

## 赞助

如果觉得此项目有用，可以考虑赞助我喝杯 ~~奶茶~~ 咖啡 ☕

<img src="https://github.com/user-attachments/assets/1aa84d31-095f-4529-b531-77d242d07a3c" alt="Sponsor" width="240"/>

## Star History

<a href="https://star-history.com/#GhostenEditor/Ghosten-Player&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=GhostenEditor/Ghosten-Player&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=GhostenEditor/Ghosten-Player&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=GhostenEditor/Ghosten-Player&type=Date" />
 </picture>
</a>

## 声明

本项目仅作为个人学习使用

本项目不提供任何的内容资源，若出现任何内容侵权行为皆与本项目开发人员无关

在使用本程序之前，你应了解并承担相应的风险，包括但不限于账号被ban，下载限速等，与本程序无关
