---
layout: post
title: "抓包：ping localhost/127.0.0.1/普通域名"
date: 2025-11-12
categories: network
---

# 抓包：ping localhost/127.0.0.1/普通域名
我打算抓包icmp包，使用命令
```tcpdump -i 网口名 icmp```
这里的网口名不知道是哪个，需要查看网口名有哪些：
```
ip a
# 或者
ifconfig
```
同时查看网络走哪个网口的规则：
```
ip r
# 或者
route -n
# 或者
tcpdump -i 网口名 # 看有没有流量
```

我的机器网口有`docker0, enp1s0, lo`三个，其中网络默认走的enp1s0，所以抓包命令是`tcpdump -i enp1s0`

新终端执行：
- ```ping localhost```,然而并没有看到抓的icmp包。
- ```ping 127.0.0.1```,也看不到抓包信息
- ```ping google.com```能看到抓包信息，说明tcpdump命令抓包没问题。


进一步查询后知道，lo网络接口全名`回环接口(loopback interface)`, ping 127.0.0.1时数据包不会通过物理网络接口卡(NIC)而是在
内核的虚拟环路中运行了一圈，也就是从上层（应用层或者传输层）传到下层（网络层）后立即被路由回上层。

所以localhost和127.0.0.1的icmp包不会被抓到,于是我实验一下，改为使用```tcpdump -i lo icmp```抓包，新终端执行：
- ```ping localhost```,然而并没有看到抓的icmp包。
- ```ping 127.0.0.1```,能看到抓包信息

所以为什么localhost的icmp包还是抓不到？
可能影响localhost解析的地方还有```/etc/hosts```文件，查了一下果然localhost被配置为```::1 localhost```,所以tcpdump没有抓到包，改为
执行``` tcpdump -i lo `icmp or icmp6` ```, 新终端执行：
- ```ping localhost```, 抓到包
- ```ping 127.0.0.1```, 抓到包

