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
+ (optional) Apple 服务干净化
+ (optional) [iRingo](https://nsringo.github.io/) 解锁 Apple News Siri **(由于 ios26 大量采用 [`countryd`](https://github.com/orgs/NSRingo/discussions/63)，建议[停留在 ios18](https://ai.id64.com/apple/zuzhi/index.html)以免不测)**

## 去广告、去追踪器

+ 远程分流规则
```ini
https://raw.githubusercontent.com/Elysian-Realme/FuGfConfig/main/ConfigFile/QuantumultX/FuckRogueSoftwareRules.conf, tag=Privacy, force-policy=reject, inserted-resource=true, enabled=true
https://raw.githubusercontent.com/SukkaLab/ruleset.skk.moe/master/List/non_ip/reject-no-drop.conf, tag=RejectNoDrop, force-policy=reject, opt-parser=true, enabled=true
```

+ 本地分流规则

~~给他们 PR 又不回，只好自己来~~

```nasm
; block line ads
host, a.line.me, reject
host, d.line-scdn.net, reject
host, ad.line-scdn.net, reject
host, linecrs.line-scdn.net, reject
host, crs-event.line.me, reject
host, crs-hometab-event.line.me, reject
host, uts-front.line-apps.com, reject
; reddit trackers
host, w3-reporting.reddit.com, reject
host, w3-reporting-nel.reddit.com, reject
; block pcdn trackers
host, tp2p.kg.qq.com, reject
host, sd-gl.xinqiucc.com, reject
host, xpis-mob-xcdn.youku.com, reject
```

## Apple 干净化

+ 远程分流规则
```
*iCloudPrivateRelay 代理 (用 Apple TV 当软路由者适用)
AppleCN 直连
AppleCDN 直连
AppleNoChinaCDN 代理
AppleServices 直连
```

### 本地分流规则

+ (optional) 屏蔽更新提示
```nasm
host, xp.apple.com, reject
host, gdmf.apple.com, reject
```

+ (optional) 地区判定为外区 (需搭配对应的 `LocationServices` 策略组)
```nasm
host-suffix, ls.apple.com, LocationServices
```

+ (optional) iCloud Gateway
```nasm
host, gateway.icloud.com, iCloud
```

此规则仅影响 iCloud CDN 分配和 iCloud 同步，实际 iMessage / Facetime 内容传输仍会直连。推荐使用 `🇭🇰HK / 🇯🇵JP / 🇸🇬SG / 🇹🇼TW` 节点或 `🇨🇳直连`，`🇨🇳直连／🇭🇰HK` 时会分配香港节点，其余会分配对应地区节点。用 `🇺🇸US` 节点会分配西雅图 CDN，此时 iCloud 同步会很慢，若不是要看 Apple News 不建议使用美国节点连接。

## Bilibili 港澳台内容

+ 策略组
```ini
static=Bilibili, direct, HK, TW, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Color/bilibili.png
```

+ 本地分流规则
```nasm
host, data.bilibili.com, direct
host, mall.bilibili.com, direct
host, api.vc.bilibili.com, direct
host-suffix, bilibili.com, Bilibili
```

## 解锁 Instagram Licensed Audio

请用家宽落地节点解锁，可用代理链。

+ 本地分流规则
```nasm
host-suffix, instagram.com, TW_ISP, via-interface=%TUN%
host-suffix, threads.com, TW_ISP, via-interface=%TUN%
host-suffix, threads.net, TW_ISP, via-interface=%TUN%
host, web.facebook.com, TW_ISP, via-interface=%TUN%
host, graph.facebook.com, TW_ISP, via-interface=%TUN%
host, gateway.facebook.com, TW_ISP, via-interface=%TUN%
; cdn 对家宽无要求，可用高速大流量节点
host-suffix, fbcdn.net, JP # 或者 proxy
host-suffix, cdninstagram.com, JP # 或者 proxy
```

## Web3

+ 远程分流规则
```ini
https://raw.githubusercontent.com/szkane/ClashRuleSet/main/Clash/Web3.list#via=0, tag=Web3, force-policy=TW_ISP, update-interval=172800, opt-parser=true, enabled=true
```

## 微信 / Weixin / WeChat 相关

+ DNS 规则
```nasm
server = /*.wechat.com/system
server = /*.weixin.com/system
server = /*.weixin.qq.com/system
server = /*.weixin.qq.com.cn/system
```

+ 策略组
```ini
static=WeChat, direct, HK, SG, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/WeChat.png
```

+ 本地分流规则

需搭配 `WeChat` 策略组，推荐 `🇭🇰HK` 或 `🇸🇬SG` 节点。

```nasm
host, dns.wechat.com, reject
host, sgminorshort.wechat.com, proxy
host-suffix, wechat.com, WeChat
ip-asn, 132203, direct
```

## Adguard Desktop

+ 本地分流规则
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
+ https://www.rclogs.com/2024/05/telegram-dc-iprules