# Ghosten Player

一款适配Android TV的视频播放器，同时支持云播放(阿里网盘和Webdav)和本地播放，能刮削影视的没信息，界面简洁优美

## 预览

<details open>
<summary><h3 style="display: inline">TV 截图</h3></summary>

<table>
<tr>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/b03ae410-e15a-41de-ac2a-859a437cd6a9" alt="TV Screenshot 1" width="700"/></td>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/650965f7-0f7b-4b8f-b10f-24d07c27887e" alt="TV Screenshot 2" width="700"/></td>
</tr>
<tr>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/b94c8ec3-7089-4045-a739-5b76b6c1ed00" alt="TV Screenshot 3" width="700"/></td>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/da8543a2-a6fe-405f-8aae-a0ee6bbd892f" alt="TV Screenshot 4" width="700"/></td>
</tr>
<tr>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/77fbe9b1-2836-4089-9783-d7a3403cb5fc" alt="TV Screenshot 5" width="700"/></td>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/7a5b53dd-0a03-4ef4-adba-a70dbcce5ab7" alt="TV Screenshot 6" width="700"/></td>
</tr>
<tr>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/66636ad9-bba6-4eab-a9b5-7d68adc49406" alt="TV Screenshot 7" width="700"/></td>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/b9931e8e-f947-44ee-891c-78e5fffb4580" alt="TV Screenshot 8" width="700"/></td>
</tr>
</table>

</details>

<hr>

<details open>
<summary><h3 style="display: inline">Android Phone 截图</h3></summary>
<table>
<tr>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/7b3a5748-e0ef-4e38-901e-dd81e724c8d9" alt="Mobile Screenshot 1" width="315"/></td>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/82c8759e-a1d6-47f0-bfee-1cfeac1963af" alt="Mobile Screenshot 2" width="315"/></td>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/f2383842-d920-4d63-a280-91dc5c95b40a" alt="Mobile Screenshot 3"  width="315"/></td>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/de735930-5fbe-4525-9e08-9cba06bf08c9" alt="Mobile Screenshot 4" width="315"/></td>
</tr>
<tr>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/28c116ba-a5eb-4700-9a47-8b6474b2d31d" alt="Mobile Screenshot 5" width="315"/></td>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/c186dfcf-7c4b-41b9-977c-49bd1e114642" alt="Mobile Screenshot 6" width="315"/></td>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/f88f1260-1387-4c59-99b1-4d317bf57d93" alt="Mobile Screenshot 7" width="315"/></td>
<td><img src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/744fb665-b3a8-4e9f-a527-e34b28cdeaae" alt="Mobile Screenshot 8" width="315"/></td>
</tr>
</table>

</details>

## Features

1. 支持 **Android TV** 和 **Android Phone** (Windows版开发中)
2. 支持 **阿里网盘**、**Webdav** 和 **本地文件** 播放
3. 纯本地运行，无需后端服务支持
4. 支持跳过片头/片尾
5. 支持视频轨道选择
6. 支持mkv**内嵌字幕**的播放
7. 支持**下载**到本地播放
8. 支持网盘文件的整理
9. **多账号登录**
10. 支持中英双语(英文翻译可能不太准确，欢迎指正)
11. 浅色和深色模式
12. Hls直播观看
13. Small installer (≈ 15 MB)
14. 设备间的数据同步
15. 自动更新

## 第三方服务调用

|                                                               服务                                                                | 用途         |
|:-------------------------------------------------------------------------------------------------------------------------------:|------------|
|                   <img width="160" src="https://files.readme.io/29c6fee-blue_short.svg" alt="The Movie DB"/>                    | 刮削媒体信息     |
| <img width="160" src="https://img.alicdn.com/imgextra/i3/O1CN01qcJZEf1VXF0KBzyNb_!!6000000002662-2-tps-384-92.png" alt="阿里云盘"/> | 获取阿里云盘内的资源 |

## 安全性

本项目不提供任何的后端服务，因此用户信息皆存在本地，网络请求仅调用以下服务

1. Aliyun_Open，用于阿里网盘数据的获取
2. Webdav, 由使用者自行配置，数据安全性由用户自行考虑
3. Themoviedb, 用于刮削影视的配体信息

由于本项目还未进行严格的测试，考虑的数据安全问题，暂不支持网盘文件的删除操作，需自行进入网盘删除

## 格式支持

Android平台采用的是Androidx Media3播放器，附带FFmpeg的音频解码和AV1视频解码器(可自行设置)
，格式编码的支持情况由硬件设备和系统版本决定，详情亲参考 _**[Media3文档
](https://developer.android.google.cn/media/media3/exoplayer/supported-formats?hl=zh-cn)**_
，经测试：

1. Redmi K40 Android 14: 主流的视频文件均能正常解码，部分音频无法解码，可使用FFmpeg正常解码
2. Mi TV Android 9: 主流的视频文件均能正常解码，部分音频无法解码，可使用FFmpeg正常解码，HDR视频无法播放

建议：

## 使用说明

### 安装

可以使用U盘或当贝市场进行安装

### 添加账号

进入设置 → 账号管理，点击加号按钮，进入登录页面(TV端会弹出二维码，使用手机扫描即可)。

选择需要登录的网盘类型

#### 阿里云盘

阿里云盘使用aliyun_open提供的接口进行文件操作，使用`refresh_token`获取`access_token`鉴权

|   | 表单项       | 说明                                                                                                                                                                                                                                                                                   |
|---|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1 | 刷新令牌      | 本项目暂不分发`refresh_token`，需自行准备，可申请阿里云盘开发账号自行分发，或使用第三方分发的`refresh_token`，比如 <a href="https://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html#%E5%88%B7%E6%96%B0%E4%BB%A4%E7%89%8C"><img src="https://alist.nn.ci/logo.svg" width="24" style="vertical-align: -4px"/><b>AList</b></a> |
| 2 | OAuth令牌链接 | 通常分发`refresh_token`的供应商会提供对应的刷新接口地址，如果由开发者账号(也就是有客户端ID和密码)，可使用阿里云的鉴权接口[https://openapi.alipan.com/oauth/access_token](https://openapi.alipan.com/oauth/access_token)                                                                                                                 |
| 3 | 客户端ID     | 仅开发者账号提供                                                                                                                                                                                                                                                                             |
| 4 | 客户端密码     | 仅开发者账号提供                                                                                                                                                                                                                                                                             |

点击提交后返回刷新页面即可，TV端在登录成功后会自动刷新页面

<img alt="Alipan Login Page" src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/298a98d1-03fa-4a8d-9e69-8c7fdef4fa20" width="315"/>

#### Webdav

填写Webdav对应的IP端口，点击提交后会弹出输出账号密码的弹窗，提交后完成登录。注：目前仅支持Basic编码登录

<table>
<tr>
<td><img alt="Webdav Login Page 1" src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/f6c16a28-857c-4c39-b4a6-888a5f17459f" width="315"/></td>
<td><img alt="Webdav Login Page 2" src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/bb3493fd-7bfb-4630-8c3e-e20d28faa21f" width="315"/></td>
</tr>
</table>

### 添加资源

进入 **设置** → **电视剧** / **电影目录设置** → **点击 + 号** → **选择账号(或添加账号，或选择本地目录)** → **选择资源目录**

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

<img alt="Playlist Create Page" src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/fb35fb42-714c-4d30-a4dc-1b4a56a1cfb1" width="315"/>

如遇到无法播放问题，可先尝试刷新直播源

<img alt="Playlist Refresh Page" src="https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/ee8c29b3-bd97-4341-863b-9b94d13c7ce6" width="315"/>


### 数据同步

### 自动更新



https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/c6ce89c9-52b4-45bb-8361-eb0c59a00707



### 文件下载

### DNS

## 常见问题

### 播放卡顿

播放卡顿通常是网络卡顿造成的，而网络卡顿通常是以下几个原因

1. 网络带宽不够
2. 播放设备硬件过时，尤其是TV端，很多TV用的是百兆网卡，亲测小米电视在WiFi模式下，网速跑满2MB/s，有线模式可达到10MB/s
3. 如使用阿里云盘，则有可能是阿里云盘限速导致
4. 其他网络问题

### 画面或声音缺失

本项目Android端使用的是media3播放器，外加FFmpeg和AV1的拓展解码器，绝大多数视频都可流畅播放，对于H.265编码的视频则由硬件设备和Android的版本而定。可尝试到设置->
播放设置->拓展解码器 修改其选项。

![Player Settings Page](https://github.com/GhostenEditor/Ghosten-Player/assets/121630113/3888db3a-4a10-47c7-8d1a-ce6f2be9c977)

### 刮削媒体信息超时

本项目使用themoviedb的API刮削媒体信息，大陆的用户可能由于DNS污染导致themoviedb无法访问，不同的地区和不同网络供应商可能情况不同。可先找到可用的IP地址，然后进入设置->
其他设置->DNS，添加对应的域名和IP即可。如果找不到能够PING通的IP，那就只能通过其他方式解决网络问题了，本项目不提供解决方案。

### 数据重置

若遇到数据问题，可通过数据重置功能尝试是否解决

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
<tr><td>REQUEST_INSTALL_PACKAGES</td><td>自动更新</td><td rowspan="12">否</td></tr>
<tr><td>BLUETOOTH_ADVERTISE</td><td rowspan="3">使用蓝牙同步数据</td></tr>
<tr><td>BLUETOOTH_CONNECT</td></tr>
<tr><td>BLUETOOTH_SCAN</td></tr>
<tr><td>BLUETOOTH</td><td rowspan="4">使用蓝牙同步数据 (SDK <= 30)</td></tr>
<tr><td>BLUETOOTH_ADMIN</td></tr>
<tr><td>ACCESS_COARSE_LOCATION</td></tr>
<tr><td>ACCESS_FINE_LOCATION</td></tr>

<tr><td>POST_NOTIFICATIONS</td><td rowspan="4">下载媒体文件和自动更新的安装包</td></tr>
<tr><td>RECEIVE_BOOT_COMPLETED</td></tr>
<tr><td>FOREGROUND_SERVICE</td></tr>
<tr><td>FOREGROUND_SERVICE</td></tr>
</tbody>
</table>

## Todos

- [ ] 音乐播放器
- [ ] 外置字幕
- [ ] 保存媒体信息至文件(nfo)
- [ ] 投屏
- [ ] Windows平台(Developing)
- [ ] Mac平台(Developing)

## 声明

本项目仅作为个人学习使用

本项目不提供任何的内容资源，若出现任何内容侵权行为皆与本项目开发人员无关
