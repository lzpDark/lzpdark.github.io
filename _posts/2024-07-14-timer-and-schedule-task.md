---
layout: post
title: "Timer and Schedule task"
date: 2024-07-14
categories: schedule
---

# Timer and Schedule task

#### how timer works in linux kernel?

- [what is Jiffies](https://litux.nl/mirror/kerneldevelopment/0672327201/ch10lev1sec3.html)
- [Real-Time-Clock and System-Timer](https://litux.nl/mirror/kerneldevelopment/0672327201/ch10lev1sec4.html)
- [Timers](https://litux.nl/mirror/kerneldevelopment/0672327201/ch10lev1sec7.html)
    > Timers are stored in a linked list. However, it would be unwieldy for the kernel to either constantly traverse the entire list looking for expired timers, or keep the list sorted by expiration value; the insertion and deletion of timers would then become very expensive. Instead, the kernel partitions timers into five groups based on their expiration value. Timers move down through the groups as their expiration time draws closer. The partitioning ensures that, in most executions of the timer softirq, the kernel has to do little work to find the expired timers. Consequently, the timer management code is very efficient.
- [How Time-Wheels algorithm works](https://paulcavallaro.com/blog/hashed-and-hierarchical-timing-wheels/)

#### how timer works in Java?

`java.util.Timer`:
 - save task in heap,
 - in thread, loop to get 1st task, wait currentTime-taskTime
   - if timeout, execute this task;
   - if wake up by new task, continue loop to get new 1st task...

`java.util.concurrent.ScheduledExecutorService`:
- DelayQueue save delay task
  - order by remaining delay time
  - return null if top task not timeout
- Worker thread loop take task and execute.

#### 3rd party schedule task framework/library

- [example of spring-quartz-schedule](https://www.baeldung.com/spring-quartz-schedule)
- [elastic job](https://shardingsphere.apache.org/elasticjob/)
  - [what if worker node crash while processing job?](https://shardingsphere.apache.org/elasticjob/current/en/features/failover/)