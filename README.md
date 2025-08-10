# QuantumultX_config
**Make Quantumult X Great Again!!!**

+ 最小化规则树，減少内存占用 (不到一万条规则，和其他模版动辄三五万条相比大幅精简)
+ 优先 DoQ / DoH ，防运营商作妖
+ Apple 域名优化、腾讯系优化
+ Wechat EU 优化
+ 拦截 PCDN ，优化国内体验
+ 去追蹤器、去广告
+ 融合各家模版之长，去芜存菁
+ 适用 iPhone 、iPad 、Apple TV
+ Telegram 按 DC 地区分流
+ 按地域分流而非服务分流
+ 能稳定直连的尽量直连
+ 仰赖 DNS 分流提升体验 **(建议搭配可信 DNS 效果更佳)**
+ 适用机场 + 代理链玩家
+ 优化 web3 体验
+ (optional) 使用家宽 IP + 代理链解锁对 IP 纯净度要求高的服务 **(请自备)**
+ (optional) Apple 服务补完
+ (optional) [iRingo](https://nsringo.github.io/) 解锁 Apple News Siri **(由于 ios26 大量采用 [`countryd`](https://github.com/orgs/NSRingo/discussions/63)，建议[停留在 ios18](https://ai.id64.com/apple/zuzhi/index.html)以免不测)**


## 架构
### DNS 优化

### 远程分流规则
```
# 去追踪器和部分 app 广告
NoMalwares REJECT → 补充规则
Privacy REJECT → Elysian-Realme/FuGfConfig/FuckRogueSoftwareRules 规则，内含大部分常见软件的 httpdns、追踪、广告资源
RejectNoDrop REJECT → Sukka 整理的 reject-no-drop 规则，内含大部分国产软件的 pcdn trackers
# Apple 域名
AppleIntelligence 代理 → Apple 官方文档提供的相关域名
iCloudPrivateRelay 代理 → Sukka 整理的 IPR 规则
AppleCN 直连 → Sukka 整理的云上贵州域名
AppleCDN 直连 → Sukka 整理的苹果在中国有备案和 CDN 的域名
AppleNoChinaCDN 代理 → Elysian-Realme 整理的苹果无法直连的域名
AppleServices 直连 → Sukka 整理的苹果其他服务域名
# 直连部分
EmailDirect 策略 → 由于多数机场会封锁 SMTP，建议直连以免影响第三方客户端邮件发送
SteamCN 直连 → blackmatrix7/SteamCN 规则
MicrosoftCDN 直连 → Sukka 整理的微软在中国有备案和 CDN 的域名
MicrosoftDirect 策略 → Elysian-Realme 整理的微软服务域名，直连效果看脸，需要直连微软服务的再用这个，其他情况不必启用
OneDrive 直连 → blackmatrix7/OneDrive 规则
Bilibili 策略 → 解锁 B 站港澳台资源用
Wechat 策略
Xiaohongshu 策略
Domestic 直连 → Sukka 整理的大陆网站域名
# Web3
Web3 解锁 → forked from szkane/ClashRuleSet; modified by enriquephl
# 流媒体与各种解锁
UnbanAirport 解锁 → 机场审计不让你上的网站
Line 策略 → 比微信还烂的聊天软件，对节点要求高
AIPlatforms 解锁 → Sukka 整理的各大 LLM 平台域名
InstagramUnblock 解锁 → 解锁 IG 版权音频
MediaCDNExtra 策略 → 优化 CDN
Spotify 代理 → Spotify 不需要特别解锁，放在前面修正流媒体解锁规则；blackmatrix7/Spotify 规则
Youtube 策略 → blackmatrix7/YouTube 规则
StreamingHK 解锁 → Sukka 整理的香港地区流媒体域名
ForeignMedia 解锁 → sve1r 提供的流媒体域名列表
```

### 本地分流规则


## 去广告、去追踪器

### (optional) 远程覆写规则
```ini
https://raw.githubusercontent.com/fmz200/wool_scripts/main/QuantumultX/rewrite/rewrite.snippet, tag=NoAdvertising, update-interval=172800, opt-parser=false, enabled=true
```

### 远程分流规则
```ini
https://raw.githubusercontent.com/enriquephl/QuantumultX_config/main/filters/NoMalwares.conf, tag=NoMalwares, force-policy=reject, inserted-resource=true, enabled=true
https://raw.githubusercontent.com/Elysian-Realme/FuGfConfig/main/ConfigFile/QuantumultX/FuckRogueSoftwareRules.conf, tag=Privacy, force-policy=reject, inserted-resource=true, enabled=true
https://raw.githubusercontent.com/SukkaLab/ruleset.skk.moe/master/List/non_ip/reject-no-drop.conf, tag=RejectNoDrop, force-policy=reject, opt-parser=true, enabled=true
```

## Apple 域名

> *iCloudPrivateRelay 代理 (用 Apple TV 当软路由者适用)   
> AppleCN 直连   
> AppleCDN 直连   
> AppleNoChinaCDN 代理   
> AppleServices 直连

### 远程分流规则
```ini
;https://raw.githubusercontent.com/SukkaLab/ruleset.skk.moe/master/List/domainset/icloud_private_relay.conf, tag=iCloudPrivateRelay, force-policy=proxy, opt-parser=true, enabled=true
https://raw.githubusercontent.com/SukkaLab/ruleset.skk.moe/master/List/non_ip/apple_cn.conf, tag=AppleCN, force-policy=direct, opt-parser=true, enabled=true
https://raw.githubusercontent.com/SukkaLab/ruleset.skk.moe/master/List/non_ip/apple_cdn.conf, tag=AppleCDN, force-policy=direct, opt-parser=true, enabled=true
https://raw.githubusercontent.com/Elysian-Realme/FuGfConfig/main/ConfigFile/QuantumultX/Apple/AppleNoChinaCDNRules.conf, tag=AppleNoChinaCDN, force-policy=proxy, enabled=true
https://raw.githubusercontent.com/SukkaLab/ruleset.skk.moe/master/List/non_ip/apple_services.conf, tag=AppleServices, force-policy=direct, opt-parser=true, enabled=true
```

### 本地分流规则
```nasm
host-suffix, cdn-apple.com, direct
```

## (optional) Apple 补完计画

> 1. 解锁 Apple Intelligence   
> 2. 解锁 Apple News、Siri 海外功能、罗盘经纬度等国际 iOS 特性   
> 3. 使用代理连接 iCloud 闸道 (Gateway) 使 Apple 判断成外区用户，減少中国特征   
> 4. 屏蔽更新提示

### 策略组
```ini
static=iCloud, direct, HK, JP, SG, TW, US, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Color/iCloud.png
static=LocationServices, direct, proxy, EU, HK, JP, SG, TW, US, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Color/Find_My.png
static=News, US, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Color/Apple_News.png
```

### 远程覆写规则
```ini
https://github.com/NSRingo/GeoServices/releases/latest/download/iRingo.Location.snippet, tag=iRingoLocation, update-interval=172800, opt-parser=false, enabled=true
https://github.com/NSRingo/Siri/releases/latest/download/iRingo.Siri.snippet, tag=iRingoSiri, update-interval=172800, opt-parser=false, enabled=true
https://github.com/NSRingo/News/releases/latest/download/iRingo.News.snippet, tag=iRingoNews, update-interval=172800, opt-parser=false, enabled=true
https://github.com/NSRingo/TV/releases/latest/download/iRingo.TV.snippet, tag=iRingoTV, update-interval=172800, opt-parser=false, enabled=true
```
需搭配 mitm 使用。

### 远程分流规则
```ini
https://raw.githubusercontent.com/enriquephl/QuantumultX_config/main/snippets/AppleExtra.snippet, tag=AppleExtra, enabled=true
; 用 chatgpt 节点解锁 apple intelligence
https://raw.githubusercontent.com/enriquephl/QuantumultX_config/main/filters/AppleIntelligence.conf#via=0, tag=AppleIntelligence, force-policy=TW_ISP, update-interval=172800, opt-parser=true, enabled=true
```
<details>

<summary>原理</summary>

+ 屏蔽更新提示
```nasm
host, xp.apple.com, reject
host, gdmf.apple.com, reject
host, mesu.apple.com, reject
```

+ 解锁非国行设备 apple intelligence 在国内使用，请用支持 ChatGPT 的节点。
```nasm
host, apple-relay.apple.com, TW_ISP, via-interface=%TUN%
host, apple-relay.cloudflare.com, TW_ISP, via-interface=%TUN%
```

+ 地区判定为外区 (需搭配对应的 `LocationServices` 策略组)
```nasm
host-suffix, ls.apple.com, LocationServices
host-suffix, gs-loc.apple.com, LocationServices
```

+ iCloud Gateway (需搭配对应的 `iCloud` 策略组)
```nasm
host, gateway.icloud.com, iCloud
```
此规则仅影响 iCloud CDN 分配和 iCloud 同步，实际 iMessage / FaceTime 内容传输仍会直连。推荐使用 `🇭🇰HK / 🇯🇵JP / 🇸🇬SG / 🇹🇼TW` 节点或 `🇨🇳直连`，`🇨🇳直连／🇭🇰HK` 时会分配香港节点，其余会分配对应地区节点。用 `🇺🇸US` 节点会分配西雅图 CDN，此时 iCloud 同步会很慢，若不是要看 Apple News 不建议使用美国节点连接。

</details>


## Bilibili 港澳台内容

### DNS 规则
```nasm
server = /*.hdslb.com/system
server = /*.bilivideo.com/system
server = /*.bilibili.com/system
```

### 策略组
```ini
static=Bilibili, direct, HK, TW, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Color/bilibili.png
```

### 远程分流规则
```ini
https://raw.githubusercontent.com/enriquephl/QuantumultX_config/main/snippets/Bilibili.snippet, tag=Bilibili, enabled=true
```

## 解锁 Instagram Licensed Audio

请用家宽落地节点解锁，可用代理链。

### 远程分流规则
```ini
https://raw.githubusercontent.com/enriquephl/QuantumultX_config/main/filters/InstagramUnblock.conf#via=0, tag=InstagramUnblock, force-policy=TW_ISP, update-interval=172800, opt-parser=true, enabled=true
```

## Web3

### 远程分流规则
```ini
https://raw.githubusercontent.com/enriquephl/QuantumultX_config/main/ClashRuleSet/Clash/Web3.list#via=0, tag=Web3, force-policy=TW_ISP, update-interval=172800, opt-parser=true, enabled=true
```

## 微信 / Weixin / WeChat

### DNS 规则
```nasm
server = /*.wechat.com/system
server = /*.weixin.com/system
server = /*.weixin.qq.com/system
server = /*.weixin.qq.com.cn/system
server = /*.qpic.cn/system # 公众号
server = /*.qlogo.cn/system # 公众号
```

### 策略组
```ini
static=WeChat, direct, HK, SG, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/WeChat.png
```

### 远程分流规则

需搭配 `WeChat` 策略组，推荐 `🇭🇰HK` 或 `🇸🇬SG` 节点。

```ini
https://raw.githubusercontent.com/enriquephl/QuantumultX_config/main/snippets/Wechat.snippet, tag=Wechat, enabled=true
```

## Adguard Desktop

### 本地分流规则
```nasm
host, local.adguard.org, reject
```
reject 会使 `local.adguard.org` 返回 127.0.0.1 正常运作。

## Telegram Group
https://t.me/technologyshare

## Acknowledgement
+ [SukkaW/Surge](https://github.com/SukkaW/Surge/)
+ [Orz-3/QuantumultX](https://github.com/Orz-3/QuantumultX)
+ [KOP-XIAO/QuantumultX](https://github.com/KOP-XIAO/QuantumultX)
+ [Koolson/Qure](https://github.com/Koolson/Qure)
+ [sve1r/Rules-For-Quantumult-X](https://github.com/sve1r/Rules-For-Quantumult-X)
+ [Elysian-Realme/FuGfConfig](https://github.com/Elysian-Realme/FuGfConfig)
+ [szkane/ClashRuleSet](https://github.com/szkane/ClashRuleSet)
+ [fmz200/wool_scripts](https://github.com/fmz200/wool_scripts)
+ [VirgilClyne/iRingo](https://github.com/VirgilClyne/iRingo)
+ [mack-a/v2ray-agent](https://github.com/mack-a/v2ray-agent)
+ [Silentely/AdBlock-Acceleration](https://github.com/Silentely/AdBlock-Acceleration)
+ [czghf/z11y22AD](https://github.com/czghf/z11y22AD)
+ [tomtoms/txt](https://github.com/tomtoms/txt)
+ [LittleRey/clash-yaml](https://github.com/LittleRey/clash-yaml)
+ [CLannadZSY/Quantumult_X](https://github.com/CLannadZSY/Quantumult_X)
+ [ppproxy/4surge](https://github.com/ppproxy/4surge)
+ [infinitytec/blocklists](https://github.com/infinitytec/blocklists)
+ [axtyet/Luminous](https://github.com/axtyet/Luminous)
+ [Lky777/MWCP](https://github.com/Lky777/MWCP)
+ [haixinn/loon](https://github.com/haixinn/loon)
+ [qq5460168/Who520](https://github.com/qq5460168/Who520)
+ [celenityy/BadBlock](https://github.com/celenityy/BadBlock)
+ https://www.rclogs.com/2024/05/telegram-dc-iprules