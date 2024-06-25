---
layout: post
title: "MongoDB学习整理"
date: 2024-06-25
categories: mongodb
---

# MongoDB学习整理
[TOC]


## 想解决什么问题？目标是什么？

有一些场景下不需要强一致性，而是需要：

1. 更强的可用性。
2. 更好的可扩展性，一台机器不够，需要大量的机器扩展。

mongodb作为文档数据库在解决这个问题。

- 它将数据以document为单位存储，每个document是一个json格式的数据；

- document组成collection，代表着一类数据。其中collection没有强schema定义，可以存储结构不完全一样的数据，又应用层来处理结构不一致。

## 有什么优势和劣势？

优势

- 高可用

- 高可扩展

- 没有schema，schema改动不需要dba支持，足够灵活

劣势

- 缺少强一致性。（最新的版本已经支持Trancation，这一条还满足吗？）
- 如果数据的使用场景比较灵活，可能按照document的方式存储在某些场景下会放大读写，影响性能。这时候更建议使用关系型数据库。



## 有哪些场景？

- Aggregate模型（开发中的领域模型，代表着要处理的某种问题，和实际业务相关，比如管理用户可能会定义一个User结构的模型）比较确定，这种情况下存储在mongodb的document更直接简单，避免了关系型数据库的table和实际的模型的转换。
- 为了扩展以支持海量数据，关系型数据库的扩展比较复杂，需要应用层做更多的工作。
- 对ACID没有强要求，希望在一致性/可用性/持久性上做调优，比如牺牲一定的一致性获得更强的可用性。



## 核心组成是什么？

- mongod

- router

- config server

## 底层有哪些关键实现？

分片是怎么做的？

- range sharding, 基于索引创建，数据会根据数据范围被自动路由到不同的分片。
- hash sharding，基于hash索引创建，根据hash值路由到不同的分片。
- zone sharding，管理员自定义zone以及zone在哪些机器，再定义规则‘哪些数据路由到哪些zone’

## 有哪些类似技术，对比它们。

TODO

## 实践(不保证是最佳实践)

#### 分片怎么做？

对saas系统来说，数据都是以organization为单位，所以可以根据organizationId来做sharding。

#### 备份和恢复怎么做？

[pbm](https://docs.percona.com/percona-backup-mongodb/index.html) is used to backup and restore, the data is stored in s3.



## 引用

- [Read the fucking manual](https://www.mongodb.com/docs/manual/)
- [use cases of companies using MongoDB](http://mongodb.com/customers)
- [What the Heck Are Document Databases?](https://learn.microsoft.com/en-us/archive/msdn-magazine/2011/november/data-points-what-the-heck-are-document-databases)
- [MongoDB Multi-Data Center Deployments](https://www.mongodb.com/resources/products/capabilities/mongodb-multi-data-center-deployments)

