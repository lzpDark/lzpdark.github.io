---
layout: post
title: "jvm stack and heap"
date: 2024-05-18
categories: jvm
---

# what is jvm stack and heap

when Java program is running in JVM as process,  `stack` and `heap` are part of area in memory.

- each thread has its own `stack`, in which is frame contains execution ops and variables (may be references to object instances).
- `heap` is shared memory among threads, it's allocated when JVM start. Allocated object is stored in this area.





# Reference

- JVM spec: https://docs.oracle.com/javase/specs/jvms/se17/html/jvms-2.html
- java-stack-heap: https://www.baeldung.com/java-stack-heap