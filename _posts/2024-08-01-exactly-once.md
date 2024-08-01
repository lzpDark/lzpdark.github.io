---
layout: post
title: "Exactly Once"
date: 2024-08-01
categories: mq
---

# Exactly Once

for message queue system, message is generated from producer to queue and will be consumed by
consumer. there's 3 delivery semantics:
- at least once. (message is delivered once or more)
- at most once. (message is ignored or just once)
- exactly once. (?? it depends on how to define this term, though we expect this is message is only delivered once.)

basically, `exactly-once` is application level guarantee, inside it's implemented by:
- at least once
- retry with idempotent
- transaction support

but, if there's outside system or non-deterministic system, `exactly-once` is not support. for example:
- how to send email exactly once
- if the consumer's result depends on outside system but the result is time sensitive (that is the system is non-deterministic), retry would introduce in incorrect result

some essays:
- [official doc about delivery semantics](https://kafka.apache.org/documentation/#semantics)
- [Exactly-Once Semantics Are Possible: Here’s How Kafka Does It](https://www.confluent.io/blog/exactly-once-semantics-are-possible-heres-how-apache-kafka-does-it/)
- [You Cannot Have Exactly-Once Delivery](https://bravenewgeek.com/you-cannot-have-exactly-once-delivery/)
- [At most once, at least once, exactly once](https://blog.bytebytego.com/p/at-most-once-at-least-once-exactly)

some talk about exactly once:
- https://news.ycombinator.com/item?id=34986995
- https://news.ycombinator.com/item?id=15602841