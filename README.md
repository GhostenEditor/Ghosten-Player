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

中文 | [English](./README_EN.md)

Ghosten Player 是一款同时适配 📱**Android Phone** 和 📺**Android TV** 的视频播放器(未来将支持 Windows 和 macOS)。整合影视资源，自动刮削媒体信息，支持IPTV播放，优雅打造私人影视库。 界面简洁，功能丰富，开箱即用。

---

如果项目对您有帮助，就请给颗🌟Star吧。

项目处于用爱发电阶段，请考虑[赞助](#赞助)支持项目持续维护。您的支持是我维护的最大动力(′･ω･`)

QQ群 1033449405

## Features

- 自动刮削媒体信息
  - [themoviedb](https://www.themoviedb.org)
  - nfo
- 客户端
    - Android Phone 和 Android Pad
    - Android TV
    - Windows (开发中)
    - Macos (开发中)
- 网盘支持
    - 支持[阿里云盘](https://www.alipan.com)、[夸克网盘](https://pan.quark.cn)、Webdav和本地媒体文件
  - 支持[Emby](https://emby.media)和[Jellyfin](https://jellyfin.org)
    - 清晰度切换(阿里云盘)
    - 多账号登录
    - 网盘文件查看和管理
    - 文件下载和边下边播
    - 多线程网络加速
- IPTV
    - 线路切换
    - 自动分组
    - 节目时间表EPG
- 播放器
    - 手势操作(双击播放/暂停/快进/快退，音量/亮度调节，画面缩放，拖动快进，长按倍速等)
    - 跳过片头/片尾
    - 播放内嵌字幕和外置字幕[^2]
    - 倍速播放
    - 视频轨道选择
    - DLNA投屏
    - 自定义字幕样式
- UI
    - 中英双语
    - 浅色和深色模式
    - 支持手机端辅助TV端输入
    - 自定义界面大小
  - TV端自定义按键
- 其他
    - 纯本地运行，无需后端服务支持 [^1]
    - 软件体积小 (≈ 15 MB)
    - 设备间的数据同步
    - 站内搜索
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

## Demo
[https://ghosteneditor.github.io/Ghosten-Player](https://ghosteneditor.github.io/Ghosten-Player)

Demo仅作展示用，部分功能受Web限制，并非完整版。Demo可能更新不及时，详情以 [Releases](https://github.com/GhostenEditor/Ghosten-Player/releases/latest)
最新版为准

> 注: 请使用桌面端的Chrome或Edge浏览器查看demo，移动端可能存在兼容问题

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
，如果遇到Bug或者有应用优化建议，欢迎提 [Issue](https://github.com/GhostenEditor/Ghosten-Player/issues)，我会在第一时间回复😊

### Wiki目录

- 使用说明
  - [添加账号](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E6%B7%BB%E5%8A%A0%E8%B4%A6%E5%8F%B7)
  - [添加资源](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E6%B7%BB%E5%8A%A0%E8%B5%84%E6%BA%90)
  - [TV端操作方式](https://github.com/GhostenEditor/Ghosten-Player/wiki/TV%E7%AB%AF%E6%93%8D%E4%BD%9C%E6%96%B9%E5%BC%8F)
  - [DLNA投屏](https://github.com/GhostenEditor/Ghosten-Player/wiki/DLNA%E6%8A%95%E5%B1%8F)
  - [多线程网络加速](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E5%A4%9A%E7%BA%BF%E7%A8%8B%E5%8A%A0%E9%80%9F)
  - [数据同步](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E6%95%B0%E6%8D%AE%E5%90%8C%E6%AD%A5)
  - [整理文件信息](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E6%95%B4%E7%90%86%E6%96%87%E4%BB%B6%E4%BF%A1%E6%81%AF)
  - [文件下载](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E6%96%87%E4%BB%B6%E4%B8%8B%E8%BD%BD)
  - [添加直播源](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E6%B7%BB%E5%8A%A0%E7%9B%B4%E6%92%AD%E6%BA%90)
  - [跳过片头片尾](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E8%B7%B3%E8%BF%87%E7%89%87%E5%A4%B4%E7%89%87%E5%B0%BE)
- 常见问题
  - [Webdav报错](https://github.com/GhostenEditor/Ghosten-Player/wiki/Webdav%E6%8A%A5%E9%94%99)
  - [刮削媒体信息相关问题](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E5%88%AE%E5%89%8A%E5%AA%92%E4%BD%93%E4%BF%A1%E6%81%AF%E7%9B%B8%E5%85%B3%E9%97%AE%E9%A2%98)
  - [应用闪退](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E5%BA%94%E7%94%A8%E9%97%AA%E9%80%80)
  - [播放卡顿](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E6%92%AD%E6%94%BE%E5%8D%A1%E9%A1%BF)
  - [数据错误](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E6%95%B0%E6%8D%AE%E9%94%99%E8%AF%AF)
  - [画面或声音缺失](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E7%94%BB%E9%9D%A2%E6%88%96%E5%A3%B0%E9%9F%B3%E7%BC%BA%E5%A4%B1)
- [权限说明](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E5%BA%94%E7%94%A8%E6%9D%83%E9%99%90)
- [数据安全](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E6%95%B0%E6%8D%AE%E5%AE%89%E5%85%A8)
- [格式支持](https://github.com/GhostenEditor/Ghosten-Player/wiki/%E6%A0%BC%E5%BC%8F%E6%94%AF%E6%8C%81)

## Roadmap

按照以下顺序进行开发

- [x] 移动端UI以及播放器UI调整
- [x] 增加搜索功能
- [x] IPTV增加节目列表
- [ ] 保存媒体信息至文件(nfo)
- [ ] 增加弹幕功能
- [ ] 整合MPV播放器，兼容老旧的音视频格式
- [ ] 应用上架Google Play
- [ ] 增加ftp和smb协议的支持
- [ ] 桌面端(Developing)
- [x] DLNA投屏的兼容问题
- [ ] 客户端串联

## 赞助

如果觉得此项目有用，可以考虑赞助我喝杯 ~~奶茶~~ 咖啡 ☕

[赞赏列表](./sponsor_list.txt)

<img src="https://github.com/user-attachments/assets/1aa84d31-095f-4529-b531-77d242d07a3c" alt="Sponsor" width="240"/>

## Star History

<a href="https://github.com/GhostenEditor/Ghosten-Player">
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
