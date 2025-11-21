---
layout: post
title: "记录一次【奇怪】的http代理问题"
date: 2025-11-21
categories: network
---

# “奇怪”的http代理问题
又是一次经典的“奇怪”问题，结果是人为的低级错误：输错密码！

## 背景
有三台机器【本地客户端机器】 【代理服务器】 【目标服务器】，本地客户端机器没办法直接连接目标服务器，所以要借助代理服务器做http代理。
其中本地客户端机器部署的代理客户端是shadowrocket，协议是http(s) proxy协议；目标服务器是gost代理的http代理服务。

## 问题
通过浏览器和curl访问目标服务器遇到错误：
```shell
curl -i https://google.com
# curl: (35) LibreSSL/3.3.6: error:1404B42E:SSL routines:ST_CONNECT:tlsv1 alert protocol version                                                                                               
```

# 解决过程
- 用其他客户端机器测试发现可以通过代理服务器访问目标服务器，排除代理服务器问题和目标服务问题。
- 用curl和其他浏览器测试发现都有问题，说明不是浏览器或者curl配置问题。
- 检查了本地机器的时区配置也没问题。
- 使用其他的代理客户端gost，测试可以访问目标服务器```curl -x http://localhost:port https://google.com ```,说明和shadowrocket有关系。
- 在shadowrocket配置http proxy服务器是密码错误。

# 额外知识
- 本地机器如果只启用gost并配置http_proxy/https_proxy，此时ping作为icmp协议是不会受proxy影响的，nc作为tcp协议也不受proxy影响，curl和浏览器作为http应用层会受到影响。

- 当本地机器通过shadowrocket配置了http-proxy服务器后，实际情况是ping和nc也受到了影响，之前不能连接的服务器可以连接了。所以shadowrocket除了配置http_proxy应该还做了其他的工作？并且icmp和tcp协议似乎不受到代理服务器的密码限制。

- 本地机器抓包看到的tls握手流程没问题，不过这里握手是本地机器和代理服务器之间的握手，可以猜测当代理服务器转发https请求到目标服务器的时候握手是受到“代理服务错误密码”影响导致tls握手出问题了，被认为tls版本问题？
- 在代理服务器一端同时抓包观察: 只看到和客户端机器交互，都没有看到从代理服务器请求目标服务器的数据包。抓包命令是```tcpdump -i any -w tes.pcap```

