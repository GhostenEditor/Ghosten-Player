# Ghosten Player

<img src="assets/images/logo.png" width="200" alt="Logo"/>

<span style="font-size: 2em">📽️</span> Available for **Android Phone** • **Android TV** • **Windows[^1]** • **Mac[^1]
** !

[下载](https://github.com/GhostenEditor/Ghosten-Player/releases/latest)

一款同时适配Android TV和Android Phone的视频播放器，同时支持云播放(阿里云盘和Webdav)和本地播放，支持刮削影视的元信息，界面简洁纯净，操作简单

[^1]: 开发中

## 预览 [^2]

<details open>
<summary><h3 style="display: inline">TV 截图</h3></summary>

<table>
<tr>
<td><img src="https://github.com/user-attachments/assets/52fac788-9a1d-40b0-8fef-2f40f58cc2e3" alt="TV Screenshot 1" width="700"/></td>
<td><img src="https://github.com/user-attachments/assets/432ea6d3-9c68-4d4c-9a9c-bbfed2718e3c" alt="TV Screenshot 2" width="700"/></td>
</tr>
<tr>
<td><img src="https://github.com/user-attachments/assets/f410b30f-f117-4787-8cbd-48fdef6969c8" alt="TV Screenshot 3" width="700"/></td>
<td><img src="https://github.com/user-attachments/assets/14d0eedd-bcc9-4ebf-a5e6-0b281022c7d6" alt="TV Screenshot 4" width="700"/></td>
</tr>
<tr>
<td><img src="https://github.com/user-attachments/assets/ad46187e-26af-4d72-8230-307a53e5de59" alt="TV Screenshot 5" width="700"/></td>
<td><img src="https://github.com/user-attachments/assets/413dd82a-26e3-429f-af08-e8571dd71e87" alt="TV Screenshot 6" width="700"/></td>
</tr>
<tr>
<td><img src="https://github.com/user-attachments/assets/a5407788-78e8-41b3-b65c-c053bf7a16bd" alt="TV Screenshot 7" width="700"/></td>
<td><img src="https://github.com/user-attachments/assets/8d74c2c5-a20e-49bd-9a82-377802a61c55" alt="TV Screenshot 8" width="700"/></td>
</tr>
</table>

</details>

<hr>

<details open>
<summary><h3 style="display: inline">Android Phone 截图</h3></summary>
<table>
<tr>
<td><img src="https://github.com/user-attachments/assets/752acb8d-a69c-414d-aa43-1fa6779948ee" alt="Mobile Screenshot 1" width="315"/></td>
<td><img src="https://github.com/user-attachments/assets/345a95fe-9564-4277-b926-26c7a6cdb992" alt="Mobile Screenshot 2" width="315"/></td>
<td><img src="https://github.com/user-attachments/assets/592806e9-8418-40c0-9a64-961ecd88046f" alt="Mobile Screenshot 3"  width="315"/></td>
<td><img src="https://github.com/user-attachments/assets/00a31c22-e290-40f9-9999-05f1c4d46246" alt="Mobile Screenshot 4" width="315"/></td>
</tr>
<tr>
<td><img src="https://github.com/user-attachments/assets/977589e7-f4f2-4822-b376-bb7c6cd8d76f" alt="Mobile Screenshot 5" width="315"/></td>
<td><img src="https://github.com/user-attachments/assets/4dd3f893-6f93-4df3-982e-01fb5bc23899" alt="Mobile Screenshot 6" width="315"/></td>
<td><img src="https://github.com/user-attachments/assets/5d9ce0d5-2fb2-4d48-8681-b4999ce1895a" alt="Mobile Screenshot 7" width="315"/></td>
<td><img src="https://github.com/user-attachments/assets/9ed1a1be-b670-48a5-bfbb-face69aab70a" alt="Mobile Screenshot 8" width="315"/></td>
</tr>
</table>

</details>

[^2]: 预览中的影视媒体仅作为展示用

## Features

1. 支持 **Android TV** 和 **Android Phone** (桌面端开发中)
2. [支持 **阿里云盘**、**Webdav** 和 **本地文件** 播放](#添加账号)
3. 纯本地运行，无需后端服务支持 [^3]
4. [支持跳过片头/片尾](#跳过片头片尾)
5. 支持视频轨道选择
6. 支持**内嵌字幕**和**外置字幕**播放[^4]
7. [支持**文件下载**和**边下边播**](#文件下载)
8. [支持网盘文件的整理](#整理文件信息)
9. **多账号登录**
10. 支持中英双语(英文翻译可能不太准确，欢迎指正)
11. [支持手机端辅助TV端输入](#tv端辅助输入)
12. 浅色和深色模式
13. [Hls直播观看](#添加直播源)
14. [支持**DLNA投屏**](#dlna投屏)
15. 软件体积小 (≈ 15 MB)
16. [设备间的数据同步](#数据同步)
17. [自动更新](#自动更新)
18. 客户端串联[^1]

[^3]: 网盘由网盘提供商提供服务支持，与本项目无关

[^4]: 外置字幕支持xml、vtt、ass、srt格式

## 第三方服务调用

|                                                               服务                                                                | 用途         |
|:-------------------------------------------------------------------------------------------------------------------------------:|------------|
| <img width="160" src="https://img.alicdn.com/imgextra/i3/O1CN01qcJZEf1VXF0KBzyNb_!!6000000002662-2-tps-384-92.png" alt="阿里云盘"/> | 获取阿里云盘内的资源 |
|                   <img width="160" src="https://files.readme.io/29c6fee-blue_short.svg" alt="The Movie DB"/>                    | 刮削媒体信息     |

## 安全性

本项目不提供任何的后端服务，用户信息皆存在本地，第三方网络服务调用如下：

1. Aliyun_Open，用于阿里云盘数据的获取
2. Webdav, 由使用者自行配置，数据安全性由用户自行考虑
3. Themoviedb, 用于刮削影视的配体信息

由于本项目还未进行严格的测试，考虑的数据安全问题，暂不支持网盘文件的删除操作，需自行进入网盘删除

## 格式支持

Android平台采用的是Androidx Media3播放器，附带FFmpeg的音频解码和AV1视频解码器(可自行设置)，格式编码的支持情况由硬件设备和系统版本决定，详情亲参考
_**[Media3文档](https://developer.android.google.cn/media/media3/exoplayer/supported-formats?hl=zh-cn)**_，经测试：

1. Redmi K40 Android 13: 主流的视频文件均能正常解码，部分音频无法解码，可使用FFmpeg正常解码
2. Mi TV Android 9: 主流的视频文件均能正常解码，部分音频无法解码，可使用FFmpeg正常解码，HDR视频无法播放
3. 由于开发者手边没有支持杜比视界的设备，因此未进行测试，理论上Media3是支持的

## 使用说明

### 安装

手机端至 [**Releases页**](https://github.com/GhostenEditor/Ghosten-Player/releases) 自行下载安装，TV端可以使用U盘或当贝市场进行安装

### 添加账号

进入设置 → 账号管理，点击加号按钮，进入登录页面。

选择需要登录的网盘类型

#### 阿里云盘

阿里云盘使用aliyun_open提供的接口进行文件操作，使用`refresh_token`获取`access_token`鉴权

|   | 表单项       | 说明                                                                                                                                                                                                                                                                                                 |
|---|-----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1 | 刷新令牌      | 考虑到服务器的维护成本，本项目暂不考虑分发`refresh_token`，需自行准备，可申请阿里云盘开发账号自行分发，或使用第三方分发的`refresh_token`，比如 <a href="https://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html#%E5%88%B7%E6%96%B0%E4%BB%A4%E7%89%8C"><img src="https://alist.nn.ci/logo.svg" width="24" style="vertical-align: -4px"/><b>AList</b></a> |
| 2 | OAuth令牌链接 | 通常分发`refresh_token`的供应商会提供对应的刷新接口地址，如果由开发者账号(也就是有客户端ID和密码)，可使用阿里云盘的鉴权接口[https://openapi.alipan.com/oauth/access_token](https://openapi.alipan.com/oauth/access_token)                                                                                                                              |
| 3 | 客户端ID     | 仅开发者账号提供                                                                                                                                                                                                                                                                                           |
| 4 | 客户端密码     | 仅开发者账号提供                                                                                                                                                                                                                                                                                           |

<img alt="Alipan Login Page" src="https://github.com/user-attachments/assets/9ff33bea-9084-4e7b-b17c-3884827b7055" width="315"/>

#### Webdav

填写Webdav对应的IP端口，输出账号密码，提交后完成登录。注：目前仅支持Basic编码登录

<img alt="Webdav Login Page 1" src="https://github.com/user-attachments/assets/febf8fdf-1883-45e5-be3d-a96672746e54" width="315"/>

### 添加资源

进入 **设置** → **电视剧** / **电影目录设置** → **点击 + 号** → **选择账号(或添加账号，或选择本地目录)** → **选择资源目录
**

资源目录应为以下结构

- 电视剧目录
    - TV Series 1
        - Season 1
            - Episode 1
            - Episode 2
        - Season 2
            - Episode 1
            - Episode 2
    - TV Series 2
        - Episode 1
        - Episode 2


- 电影目录
    - Movie Folder
        - Movie1
    - Movie Folder
        - Movie2
    - Movie 3

### 跳过片头片尾

电视剧支持对 **电视剧**，**季**，**单集** 设置跳过片头片尾，也可以在播放器中设置(会作用于当前季)

<img alt="Playlist Create Page" src="https://github.com/user-attachments/assets/ec99ec5b-42fd-4476-9fbb-0996f73feb75" width="315"/>

### 整理文件信息

该功能将会使用刮削到的媒体信息用于移动和重命名网盘中的文件(不会进行删除操作)，整理规则如下:

- 电视剧目录
    - TV Series (2024)
        - Season 1
            - Episode 1
            - Episode 2
        - Season 2
            - Episode 1
            - Episode 2
    - TV Series 2
        - Episode 1
        - Episode 2


- 电影目录
    - Movie Folder
        - Movie1
    - Movie Folder
        - Movie2
    - Movie 3

### 添加直播源

目前仅支持m3u格式的hls直播源，建议使用 [https://github.com/fanmingming/live](https://github.com/fanmingming/live)
和 [https://github.com/iptv-org/iptv](https://github.com/iptv-org/iptv) 两个开源的直播源项目

进入直播页面，点击加号，输入直播源名称和地址即可

<img alt="Playlist Create Page" src="https://github.com/user-attachments/assets/eb733e2f-8c42-4fab-89eb-c28f854ada70" width="315"/>

如遇到无法播放问题，可先尝试刷新直播源

<img alt="Playlist Refresh Page" src="https://github.com/user-attachments/assets/0eb7da46-1f83-4f9e-bf97-2f5059a98345" width="315"/>

### DLNA投屏

手机端点击投屏按钮，应用会自行搜索局域网下支持DLNA投屏的设备，选择设备即可使用投屏功能[^5]

<img alt="Playlist Refresh Page" src="https://github.com/user-attachments/assets/9b14ab56-abc6-42ed-90bd-a4ad908893a0" width="315"/>

[^5]: 手机端仅作为媒体服务器的角色，能否正常播放取决于投屏端是否支持该编码格式

### 数据同步

可以通过蓝牙连接的方式，将一台设备的媒体数据同步到另一台设备上，通常用于在手机端完成登录等操作后，同步到TV端，以简化TV端的编辑流程

### TV端辅助输入

由于TV端使用遥控器输入链接、账号密码等信息不便，可在TV端点击辅助输入按钮，然后使用手机(需在用以局域网下)
扫描二维码进入网页，手机端编辑的文本，会推送到TV端聚焦的文本框内

### 自动更新

https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/c6ce89c9-52b4-45bb-8361-eb0c59a00707

### 文件下载

Todo

### DNS

本项目使用themoviedb的API刮削媒体信息，大陆的用户可能由于DNS污染导致themoviedb无法访问，不同的地区和不同网络供应商可能情况不同。可先找到可用的IP地址，然后进入设置->
其他设置-> DNS，添加对应的域名和IP即可。如果找不到能够PING通的IP，那就只能通过其他方式解决网络问题了，本项目不提供解决方案。

## 常见问题

### 播放卡顿

播放卡顿通常是网络卡顿造成的，而网络卡顿通常是以下几个原因

1. 网络带宽不够
2. 播放设备硬件过时，尤其是TV端，很多TV用的是百兆网卡，亲测小米电视在WiFi模式下，网速跑满2MB/s，有线模式可达到10MB/s
3. 如使用阿里云盘，则有可能是阿里云盘限速导致[^6]
4. 其他网络问题

[^6]: 截至文档编写前，阿里云盘在未开通三方应用权益包时，会限速至512kb/s

### 画面或声音缺失

本项目Android端使用的是media3播放器，外加FFmpeg和AV1的拓展解码器，绝大多数视频都可流畅播放，对于H.265编码的视频则由硬件设备和Android的版本而定。可尝试到设置 →
播放设置 → 拓展解码器 修改其选项。

<img alt="Player Settings Page" src="https://github.com/user-attachments/assets/dd92474c-ffbe-4444-a89a-474f7b1cd68c" width="315"/>

### 刮削媒体信息超时

详见DNS部分

### 数据重置

若遇到数据问题，可通过数据重置功能尝试是否解决

### 应用闪退

1. 极少数的视频文件会使media3抛出异常导致应用闪退，暂未找到修复方法

## 权限说明

### Android

<table>
<thead>
<tr><th>权限名</th><th>权限用途</th><th>是否必须</th></tr>
</thead>
<tbody>
<tr><td>INTERNET</td><td>获取网络数据</td><td rowspan="3">是</td></tr>
<tr><td>ACCESS_NETWORK_STATE</td><td rowspan="2">播放媒体文件</td></tr>
<tr><td>WAKE_LOCK</td></tr>
<tr><td>REQUEST_INSTALL_PACKAGES</td><td>自动更新</td><td rowspan="10">否</td></tr>
<tr><td>BLUETOOTH_ADVERTISE</td><td rowspan="3">使用蓝牙同步数据</td></tr>
<tr><td>BLUETOOTH_CONNECT</td></tr>
<tr><td>BLUETOOTH_SCAN</td></tr>
<tr><td>BLUETOOTH</td><td rowspan="4">使用蓝牙同步数据 (SDK <= 30)</td></tr>
<tr><td>BLUETOOTH_ADMIN</td></tr>
<tr><td>ACCESS_COARSE_LOCATION</td></tr>
<tr><td>ACCESS_FINE_LOCATION</td></tr>
<tr><td>WRITE_EXTERNAL_STORAGE</td><td rowspan="2">文件下载和读取本地媒体文件 (SDK <= 32)</td></tr>
<tr><td>READ_EXTERNAL_STORAGE</td></tr>
</tbody>
</table>

## 版本适配

Android 6+

## Todos

- [ ] 音乐播放器
- [ ] 保存媒体信息至文件(nfo)
- [ ] 桌面端(Developing)
- [ ] 应用串联

## 声明

本项目仅作为个人学习使用

本项目不提供任何的内容资源，若出现任何内容侵权行为皆与本项目开发人员无关
