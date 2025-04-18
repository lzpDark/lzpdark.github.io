---
layout: post
title: "业务和消息怎么保证一致成功或失败"
date: 2025-04-17
categories: rabbitmq, amqp, transaction
---

# 业务和消息怎么保证一致成功或失败

## 场景

某部分业务操作数据库，再发消息到消息队列，其他服务会消费消息并做对应业务处理。

## 问题

### 不希望消息丢失

为了做到这个需要三个保证：

- 发送端至少发消息成功一次。
- broker端要持久化保存消息。
- 消费端处理消息成功后 ，再ack，保证不漏处理消息。
  - [配置consumer-timeout防止有unack阻塞消息](https://www.rabbitmq.com/docs/consumers#acknowledgement-timeout)


### 不希望数据库和消息队列不一致

比如：

- 数据库操作成功 + 消息发送失败
- 数据库操作失败 + 消息发送成功

我希望都能成功或者都失败。

这是分布式事务问题，包括两个子事务：

1. 数据库事务 

2. 消息队列事务

## 方案

我查到两个方案

### - 本地消息表

【去哪儿】开源的消息队列[qmq](https://github.com/qunarcorp/qmq/blob/master/docs/cn/transaction.md) 根据本地消息表来处理。

1. 数据库除了业务表还有一个消息表。

2. 在一个本地事务里同时操作业务和插一条记录到消息表。

3. 发送消息成功后删除消息表里对应的记录，这里可以异步操作+定时扫描消息下表发送消息。

### - 回查接口

[rocketmq](https://rocketmq.apache.org/zh/docs/featureBehavior/04transactionmessage)通过回查接口来处理

![](https://rocketmq.apache.org/zh/assets/images/transflow-0b07236d124ddb814aeaf5f6b5f3f72c.png)

### - 最大努力通知

这个方案一般用于服务之间的事务，比如短信通知。

A服务：1.本地创建业务记录。 2. 调用短信服务

短信服务成功后调用A服务的回调接口：3. 更新业务记录状态。 这一步会有重试，但是没办法保证一定调用成功A服务的回调接口

如果说通知允许丢失那到此也不用额外做什么处理了。

假如不允许通知丢失的话，业务上需要再加一个定期任务做补偿：1.扫描业务记录； 2.从短信服务查询是否成功了； 3. 调A服务更新任务状态。

[参考这篇文章介绍](https://www.cnblogs.com/yuhushen/p/15530168.html)

