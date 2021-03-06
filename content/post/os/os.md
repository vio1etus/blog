---
title: 操作系统知识点小结
comments: true
toc: true
tags:
description: 操作系统课程知识点总结
summary: 操作系统课程知识点总结
categories:
    - os
date: 2020-01-09 15:15:55
---

## OS

操作系统的功能：处理机管理、内存管理、文件管理、设备管理、提供的用户接口（人机交互）

操作系统核心使用的同步技术：

1. 原子操作
2. 信号量
3. 自旋锁
4. 关中断

## 用户态和内核态的转换

### a.系统调用

这是用户进程主动要求切换到内核态的一种方式，用户进程通过系统调用申请操作系统提供的服务程序完成工作。

而系统调用的机制其核心还是使用了多少操作系统为用户特别开放的一个中断来实现，例如 Linux 的 ine 80h 中断。

### b.异常

当 CPU 在执行运行在用户态的程序时，发现了某些事件不可知的异常，这是会触发由当前运行进程切换到处理此
异常的内核相关程序中，也就到了内核态，比如缺页异常, 除 0 异常

### c.外围设备的中断

当外围设备完成用户请求的操作之后，会向 CPU 发出相应的中断信号，这时 CPU 会暂停执行下一条将要执行的指令
转而去执行中断信号的处理程序，如果先执行的指令是用户态下的程序，那么这个转换的过程自然也就发生了有用户态到内核态的切换。比如**硬盘读写**操作完成，系统会切换到硬盘读写的中断处理程序中执行后续操作等。比如：IO 中断：读写内存数据。

### 总结

**系统调用的本质其实也是中断**，**相对于外围设备的硬中断，这种中断称为软中断**。从触发方式和效果上来看，这三种切换方式是完全一样的，都相当于是执行了一个中断响应的过程。但是从触发的对象来看，**系统调用是进程主动请求切换的，而异常和硬中断则是被动的。**

### 进程的描述与控制

1. 如果选择题说“进程是操作系统进行调度和资源分配的基本单位。”， 那看题目情景，可以先看别的选项。

2. 进程的两个基本元素是程序代码和与代码相关的数据集。

    进程（的实体）由程序、数据和进程控制块（PCB）三部分组成。

3. 一定会引起进程切换的：

    - 时间片结束

    - 从磁盘存取数据

    - 进程被换出到 swap 分区

        进程切换一定会涉及模式切换（需要系统调用），模式切换不一定涉及进程切换。

4. 线程是独立调度和分派（dispatch）的单位，进程是资源分配（allocation）/ 拥有（own）的单位

5. 操作系统中，进程与程序的重要区别之一是进程有状态而程序没有。

    进程是一个“执行中的程序”，所以进程是有状态的，而程序只是一个静态的概念，并不存在状态。

6. 一个程序被同时执行多次，系统就会创建多个进程。因此，一个程序可以被多个进程执行。

    一个进程也可以同时执行多个程序。

    进程与程序并不是一一对应的。

7. 创建新进程的情况：

    1. 新的批处理作业

    2. 交互登录

    3. 为提供服务而由操作系统创建

    4. 由现有进程派生

        引起创建进程的事件：

        1、用户登录

        2、作业调度

        3、提供服务（用户程序提出请求）

        4、应用请求（基于应用进程的需求）

        设备分配只需要分配相应的端口，有事件发生时进行中断即可，不需要额外的进程管理。

8. 进程的高级通信机制：

    共享存储器系统、消息传递、管道通信

9. 进程控制块信息分为三类：

    1. 进程标识信息
    2. 处理机状态信息
    3. 进程控制信息

10. 在进程的整个生命周期内，系统总是通过 PCB 对进程进行控制和管理。

## 进程调度

1. 基于抢占策略进程调度算法：

    时间片轮转（时间片用尽）

    最短剩余时间 SRT： 在 SPN 中增加了抢占的策略

    多级反馈队列优先：抢占（时间片用尽）

2. 做大题一般求平均周转时间以及平均带权周转时间时，画表格

    假设有 n 个进程，则画一个 （n + 3）列的表格。多出的列分别为：算法、时间名称（到达时间、服务时间、完成时间、周转时间、带权周转时间）、平均

    每个算法对应三行：完成时间、周转时间、带权周转时间。

3. 最高响应比优先 HRRN 解决了长作业死等问题

    长作业由于得不到服务，等待的时间会不断增加，因此比值变大，最终在竞争中赢了短进程。

4. 进程调度算法：六种

    FCFS （First Come First Serve）、RR（Round Robin）、SPN（STF）（Short Process / Task Next/First）、SRT（Short Remaining Time）、HRRN（High Response Rate Next）、FB。

5. 能从一种状态转变为 3 种状态的是：Runnig 执行状态。

## 并发：死锁与饥饿

### 死锁

1. 8 个资源， K 个进程竞争，每个进程至少需要 3 个资源，最多多少个进程不发生死锁，最少多少个进程发生死锁？

    (3-1) \* K + 1 ≤ 8 → k = 3, 因此最多 3 台进程不发生死锁, 最少 4 台进程发生死锁。

    **_扩展_**：

    n 个资源， K 个进程竞争，每个进程至少需要 num_per 个资源，最多多少个进程不发生死锁，最少多少个进程发生死锁？

    (num_per - 1) \* K + 1 ≤ n → 因此最多 k 台进程不发生死锁， 最少 k+1 台进程发生死锁。

2. 通常不采用从非死锁进程处抢夺资源的方式解除死锁。

3. 多级反馈队列调度算法能较好地满足各类用户的需求。

4. 任何两个并发进程之间可能存在同步或互斥关系

    我们把异步环境下的一组并发进程因直接制约而互相发送消息、进行互相合作、互相等待，使得各进程按一定的速度执行的过程称为进程间的同步，实际上不是所有的程序间都存在直接制约关系。因此并不是任意两个并发进程都存在同步关系。

    如果两个并发程序为互斥关系，则必定存在临界区，但是实际上不是所有的并发程序之间都存在临界区。因此并不是任意两个并发进程都存在互斥关系。

    综上：任何两个并发进程之间可能存在同步或互斥关系。

5. 实现互斥的方法

    1. 严格轮换
       每个进程每次都从头执行到尾
    2. 屏蔽中断（中断方法）
       刚刚进入临界区时就屏蔽中断，刚要出临界区就打开中断
    3. 专用机器指令
       Test_and_set、test_and_clear 、exchange
    4. 软件方法
    5. 信号量

6. 处理死锁的三种方法

    - 死锁预防

        - 直接死锁预防

            防止循环等待的发生

            循环等待可以通过定义资源类型的线性顺序来预防。

            资源有序分配法：

            资源有序分配法将资源按某种规则对系统中的所有资源统一编号，申请的时候必须按照编号的顺序申请。对进行必须使用的同类资源，必须一次申请；不同类的资源必须按照资源编号顺序申请，这样就破坏了死锁环路。

        - 间接死锁预防

            防止形成死锁的前三个必要条件（互斥、占有且等待、不可抢占）中的任何一个发生。

            互斥：不可能禁止，因为如果需要对资源进行互斥访问，那操作系统就必须支持互斥

            占有且等待：可以要求进程一次性的请求所有的资源，并阻塞这个进程，直到所有请求得到满足。

            不可抢占：

            1. 占有某些资源的进程进一步申请资源时若被拒绝，则该进程必须释放其最初占有的资源，必要时可再次申请这些资源和其他资源。
            2. 一个进程请求当前被另一个进程占有的资源时，操作系统可以抢占另一个进程，要求它释放资源。

    - 死锁避免

        通过一定的策略，明智地选择来使得：前三个必要条件无法推出第四个条件（循环等待），从而避免死锁。

        银行家算法

    - 死锁检测

7. 死锁避免算法：银行家算法

    1. 数据结构

        可利用资源向量

        最大需求矩阵 Max：最大需求的情况

        分配矩阵 Allocation ：已分配的情况

        需求矩阵 Need：尚需的资源情况

        Need［i, j］=Max［i, j］-Allocation［i, j］

8. 不适当的进程推进顺序也可能产生死锁。合理的进程推进顺序可以降低死锁出现的可能，但是当四个必要条件存在时，还是有出现死锁的可能；

### 信号量

1. 原语是不可中断的指令序列。

    最大特点是执行过程不可中断。

    用来实现进程同步与互斥的 PV 操作实际上是由一个不可被中断的过程组成的

2. 信号量原子执行的问题，一般情况下通过两种方式解决：

    - 单处理器中在执行 wait() 和 signal() 操作时禁止中断
    - 在多处理器中提供其他加锁机制（如自旋锁）

3. 信号量的功能

    信号量可以用于实现进程间的同步和互斥，可以描述并发进程执行的前趋关系。

4. 除了初始化外，信号量只能通过两个*标准原子操作*：wait() 和 signal()来访问，分别为信号量减一和加一。 说 “ 信号量的值只能通过 wait/signal 来修改” 也是对的

    信号量初值为非负的整数变量

    通常在进程对信号量减 1 之前，无法提前知道该信号量是否会阻塞。只有在信号量减一后小于 0，信号量才会自身阻塞

5. 用 PV 操作实现进程同步，信号量的初值由用户确定

    用 PV 操作实现同步时，一定要根据具体情况来定义信号量和调用 P 操作或 V 操作

6. 设系统有 10 个并发进程，通过 PV 操作原语共享同一临界资源，若该临界资源互斥信号量为 MUTEX，则 MUTEX 的值域为 [ -9, 1 ]。

    用信号量实现进程的互斥，初值一般设为 1，而每个进程执行一次 P 操作后，信号量值减 1。

7. 临界资源与临界区

    - 临界资源是指每次仅允许一个进程访问（必须互斥使用）的资源。

        属于临界资源的硬件有打印机、磁带机等, 软件有消息缓冲队列、变量、数组、缓冲区等。

    - 临界区：进程中访问临界资源的那段代码

    - 同步准则（临界区的使用的原则）：空闲让进、忙则等待、有限等待、让权等待。

        1.空闲让进：临界区空闲时，可以允许一个请求进入临界区的进程立即进入临界区。

        2.忙则等待：当已有进程进入临界区时，其他试图进入临界区的进程必须等待。

        3.有限等待：对请求访问的进程，应保证能在有限时间内进入临界区。

        4.让权等待：当进程不能进入临界区时，应立即释放处理器，防止进程忙等待。

8. 二元信号量可以且只能初始化为 0 或 1。

9. 进程间通信的方式：

    - 信号（signal ）通信机制；

    - 信号量及其原语操作（PV、读写锁、管程）控制的共享存储区（shared memory ）通信机制；

    - 管道（pipeline）提供的共享文件（shared file）通信机制；

    - 信箱和发信/ 收信原语的消息传递（message passing ）通信机制。

        其中前两种通信方式由于交换的信息量少且效率低下，故称为低**级通信机制**，相应地可把发信号/ 收信号及 PV 之类操作称为低级通信原语，仅适用于集中式操作系统。消息传递机制属于**高级通信机制**，共享文件通信机制是消息传递机制的变种，这两种通信机制，既适用于集中式操作系统，又适用于分布式操作系统。

10. 信号量表示当前可用的相关资源数。当信号量 K>0 时，表示还有 K 个相关资源可用；而当信号量 K<0 时，表示有|K|个进程在等待该资源（正在等待解除阻塞的进程数量为 |K| ）

### 管程

1. 管程通过使用条件变量提供对同步的支持，这些条件变量包含在管程中，并且只有管程才能访问。

2. 管程中的局部数据变量只能由管程内定义的过程来进程访问，不能被外部直接访问

3. 当一个进程在管程中执行时，调用管程的其他进程都会被阻塞，这样才能保持同步性

4. 管程中的 wait 和 signal 与型号量不同。

    管程中的 signal() 会重新启动一个悬挂的进程。如果没有进程悬挂，那么操作 signal() 就没有作用；即如同没有执行，这一操作与信号量相关的操作 signal() 不同，后者能影响信号量的状态

## 存储管理

1. 程序的局部性原理

    1. 时间局部性

    2. 空间局部性

2. ”虚拟存储器的地址空间大小 = 内存容量 + 辅存（外存）容量“ 可以看作是对的。

    最大容量取决于 CPU 地址，实际容量取决于内外存之和以及 CPU 地址。

    比如 CPU 寻址是 32 位，那么虚拟内存的最大容量就是 2^32

    比如内存 1M，外存 400M，32 位，那么实际容量就是 min(1+400M, 2^32B)（假设该系统按字节编址）

3. 多级页表注意最外层叫做一级，例如：二级页表的结构如下：
   ![page table](https://raw.githubusercontent.com/violetu/blogimages/master/20200728215319.png)

4. 分段与分页的主要区别

    1. 页是信息的物理单位

        段是信息的逻辑单位，分段的目的是为了能更好的满足用户的需要。

    2. 页的大小固定且由系统决定

        段的大小不固定，决定于用户所编写的程序，通常由编译器在对源程序进行编写时，根据信息的性质来划分。

    3. 页的作业地址空间是一维的，即：单一的线性地址空间

        段的作业地址空间是二维的，程序员在标识一个地址时，既需要给出段名，又需要给出段内地址。

5. 段式管理

    段的长度在运行期间是可以动态变化的。段划分之后，仍然可以改变其在存储空间的大小。

    段有最大长度限制，但是该限制可以在内核特权下修改。

6. 内部碎片与外部碎片

    内部碎片：

    在内存管理中，内部碎片是已经被分配出去的的内存空间大于请求所需的内存空间。

    外部碎片：

    外部碎片是指还没有分配出去，但是由于大小太小而无法分配给申请空间的新进程的内存空间空闲块。

    固定分区存在内部碎片，可变式分区分配会存在外部碎片；

    离散分配

    1. 页式存在**内部碎片**

        将进程分成若干个大小相等的页，将内存分成若干个大小相等的页框，所以进程最后一个页的空间不会被完全占满（因为无法保证进程大小正好整除页的大小），当被放入内存时，最后一页便产生了内部碎片。

    2. 段式存在**外部碎片**

        分段类似于动态分区，跟动态分区的原理区别在分段可以不连续。段的数目和大小都是可变的。为了共享要分段，在段的换入换出时形成外部碎片，比如 5 K 的段换出后，有一个 4 k 的段进来放到原来 5 k 的地方，于是形成 1 k 的外部碎片。（但动态分区不同的是，因为可以不连续，所以两块内存之间如果较大可以继续填充进程，因而只会有较小的外部碎片，动态分区的外部碎片则较大），但是没有内部碎片。

    3. 段页式存在**内部碎片**

        将用户的地址空间分成若干个段，每个段再分成若干个大小固定相等的页，页的长度等于内存中页框的大小，因为分段可以不连续，再者内部被分为若干个页，所以两块进程占据内存之间不存在外部碎片，但是因为内存以页为单位来使用，最后一页往往装不满，于是形成了内部碎片。

        段页式空间浪费小。

        ### [CPU 中的缓存和操作系统中的缓存](https://blog.csdn.net/will130/article/details/49684563)

        引入

        TLB( Translation Lookaside Buffer )转换检测缓冲区是一个内存管理单元,用于改进虚拟地址到物理地址转换速度的缓存，又称为*快表*。

        **_快表_—- Cache 在 OS 中的典型范例**

        在操作系统中，为提供系统的存取速度，在地址映射机制中增加了一个小容器的联想寄存器（相联存储器），即快表。用来存放当前访问最频繁的少数活动页面的页号。

        当用户需要存 / 取数据时，根据数据所在的**逻辑页号**在快表中找到其对应的内存块号，再联系页内地址，形成物理地址。

        如果在快表中没有相应的逻辑页号，则地址映射仍可以通过内存中的页表进行，得到对应 / 空闲块号后必须将该块号填入快表的空闲块中。如果快表中没有空闲块，则根据淘汰算法淘汰某一行，再填入新的页号和块号。

        快表查找内存块的物理地址消耗的时间大大降低了，使得系统效率得到了极大的提高。

        **_高速缓冲存储器(Cache)_ —- Cache 在 CPU 中运用的典型范例**

        高速缓冲存储器（Cache）是位于 CPU 与内存之间的临时存储器，它的容量比内存小但交换速度快。在 Cache 中的数据是内存中的一小部分，但这一小部分是段时间内 CPU 即将访问的。当 CPU 调用大量数据时，就可避开内存直接从 Cache 中调用，从而加快读取速度。由此可见，在 CPU 加入 Cache 是一种高效的解决方案，这样整个内存储器（Cache + 内存）就变成了既有 Cache 的高速度又有内存的大容量的存储系统了。Cache 对 CPU 性能的影响很大，这主要是由 CPU 的数据交换顺序和 CPU 与 Cache 间的带宽引起的。

        cpu 缓存是集成于 cpu 中的双极性的高速存储阵列（比内存要快很多），作用是用来加速 cpu 对高频数据的访问来提高系统性能。

    4. 内存访问次数 / 时间

    5. 虚拟页式存储系统

        快表是一种特殊的高速缓冲存储器（Cache），内容是页表中的一部分或全部内容。 [1]

        在操作系统中引入快表是为了加快地址映射速度。

        在虚拟页式存储管理中设置了快表，作为当前进程页表的 Cache。通常快表处于 MMU 中。

        ![tlb](https://raw.githubusercontent.com/violetu/blogimages/master/20200728215555.png)

    6. 段页式系统

        在没有缓存段表和页表的情况下，为了**获得一条指令或数据，须三次访问内存**。

        1.  第一次访问是**访问内存中的段表**，从中取得页表始址；

        2.  第二次访问是**访问内存中的页表**，从中取出该页所在的物理块号，并将该块号与页内地址一起形成指令或数据的物理地址；

        3.  第三次访问才是真正从第二次访问所得的地址中，**取出指令或数据**

        当已经缓存了段表或页表时，前两次访存过程可以跳过，直接从缓存可取段表或页表，最后进行第三步：去内存取指令和数据。

        所以至多三次，至少一次。

        例题：

    7. 分页存储系统内存有效访问时间

        [有效访问时间](https://blog.csdn.net/yangkuiwu/article/details/53996900)

    8. [操作系统第 5 章习题带答案](https://wenku.baidu.com/view/601c5f0159fafab069dc5022aaea998fcc224023.html?re=view)

        > 在一个具有快表的虚拟页式内存系统中，快表的命中率为 95%，指令和数据的缓存命中率为 75%；访问快表和缓存的时间为 10ns，更新一次快表的时间为 10μs，更新一个缓存块的时间为 20μs。请计算，每条指令的有效访问时间是多少？

        分为两个步骤：查找页表 和 查找数据和指令

        第一步：查找页表

        如果快表命中：10ns

        如果快表未命中：10ns + 10 us

        第二步：查找指令和数据

        如果指令和数据的缓存命中：10 ns

        如果指令和数据的缓存未命中：10ns + 20 us

        综上：

        `95%*10 ns + 5%(10ns + 10 us) + 75%*10ns + 25%( 10ns + 20 us )`

        秒换算

        1 秒(s) ＝ 1000 毫秒(ms)

        1 毫秒(ms)＝ 1000 微秒 (us)

        1 微秒(us)＝ 1000 纳秒 (ns)

        1 纳秒(ns)＝ 1000 皮秒 (ps)

#### 动态分区

1. 首次适配

    首次适配算法不仅是最简单的，而且通常也是最快和最好的。

2. 循环适配 / 下次适配

3. 最佳适配

    最佳适配 通常性能是最差的，与其他算法相比，它需要更频繁地进行内存压缩。

4. 最差适配

    通常情况下，从好到坏：首次适配 ≥ 循环适配 ≥ 最佳适配。

    对内存的利用率从高到低：同上。

    优缺点见课本 p210

#### 驻留集

对于分页式虚拟内存，在准备执行时，操作系统决定读取的该进程的页数，即：决定给特定的进程分配的空间大小（分配的页框个数）。例如：驻留集大小为 2， 则为该进程分配 2 个页框。

1. 在请求分页存储管理中，从主存刚刚移走某一页面后，根据请求又马上调入该页，这种反复调进调出的现象，称为系统颠簸，也叫系统抖动。

2. 可能出现 "抖动" 的存储管理方式：请求分页存储管理、请求段式存储管理、请求段页式存储管理。

    可能出现抖动的，就是存在页面换入换出的，那当然就是虚拟内存中的请求 xxx 存储管理了。

## 设备管理

设备独立性，即应用程序独立于具体使用的物理设备。

为了实现设备独立性而引入了逻辑设备和物理设备这两个概念。

## 磁盘

### 术语

盘片被分成许多扇形的区域,每个区域叫一个扇区。

盘片表面上以盘片中心为圆心,不同半径的同心圆称为磁道。

硬盘中,不同盘片相同半径的磁道所组成的圆柱称为柱面。

磁道与柱面都是表示不同半径的圆,磁盘的柱面数与一个盘面上的磁道数是相等的，在许多场合,磁道和柱面可以互换使用。

每个磁盘有两个面,每个面都有一个磁头,习惯用磁头号来区分，盘面数等于总的磁头数。扇区,磁道(或柱面)和磁头数构成了硬盘结构的基本参数。

这些参数可以得到硬盘的容量,计算公式为:存储容量=磁头数 × 磁道(柱面)数 × 每道扇区数 × 每扇区字节数

### 平均磁盘访问时间

存取时间 = 寻道时间 + 旋转延时

平均磁盘访问时间 = 平均寻道时间 + 平均旋转延时 + 传输时间 + 控制器延时

平均旋转延时 = 旋转一周时间的一半( 平均嘛，就是 \* 1/2)

旋转延迟中，最多旋转１圈，最少不用旋转，平均情况下，需要旋转半圈，所以要除 2，问题就解决了。

如果没有说磁盘传输速度，说了每个磁道的扇区个数，可以用 周期/ 每个磁道的扇区个数 来代替一个扇区的传输时间。

例题一：

> 某磁盘的转速为 10 000 转/分，平均寻道时间是 6 ms，磁盘传输速率是 20 MB/s， 磁盘控制器延迟为 0.2 ms，读取一个 4 KB 的扇区所需的平均时间约（ ）。

解析：

> 根据公式：平均磁盘访问时间 = 平均寻道时间 + 平均旋转延时 + 传输时间 + 控制器延时
> 平均寻道时间：6ms
> 平均旋转延迟：3ms
> 10000 转/分 => 1min/10000 转 = 6ms/转 => 3ms/转
> 传输时间：0.2ms
> `4KB/20MB/s = （0.2 * 2^(-10)）约= （0.2 * 10^(-3)）= 0.2ms`
> 控制器延迟：0.2ms
> 故读取一个 4KB 的扇区所需时间为：6ms+3ms+0.2ms+0.2ms = 9.4ms

例题二：

> 若磁盘转速为 7200 转/分，平均寻道时间为 8ms,每个磁道包含 1000 个扇区，则访问一个扇区的平均延迟时间大约是（）。

解析：

> 存取时间 = 寻道时间 + 延迟时间 + 传输时间。存取一个扇区的平均延迟时间为旋转半周的时间，即为 (60/7200)/2=4.17ms ，传输时间为 (60/7200)/1000=0.01ms ，因此访问一个扇区的平均存取时间为 4.17+0.01+8=12.18ms ，保留一位小数则为 12.2ms 。

例题三：

> 某磁盘每条磁道可存储 10MB 数据，转速为 7200 rpm， 则读取 3MB 数据的传输时间为 2.5 ms。

解析：

```python
> In [17]: （3MB/10MB） * 60/7200
> Out[17]: 0.0025
```

#### 磁盘分配算法

根据磁盘的操作时间，对磁盘调度分为：移臂调度、旋转调度两部分组成。

1. 移臂调度算法

    - 先来先服务（FIFO / FCFS）

    - 最短寻找时间优先/ 最短服务时间优先（SSTF）

        选择使磁头臂从当前位置开始移动最少的 IO 请求。

    - 电梯调度算法（SCAN 算法）

        从移动臂当前位置开始沿着臂的移动方向去选择离当前移动臂最近的那个柱面的访问者，如果沿臂的移动方向无请求访问时，就改变臂的移动方向（掉头）再选择。

    - 单向扫描算法（CSCAN，循环 SCAN）

        当访问到沿某个方向的最后一个磁道时，磁头臂返回到磁盘相反方向末端的磁道，并再次开始扫描。

        SCAN 算法 与 CSCAN 算法

        相同点：最开始都是从当前位置，向移动方向走。

        不同点：到了某个方向的最后一个要访问的磁道之后，前者在当前位置掉头往后走，后者，去到反方向的末端，再开始该方向扫描。

        当移动臂定位后，应该优先选择延迟时间最短的访问者去执行，根据延迟时间来决定执行次序的调度称为旋转调度。

### IO 缓冲

### I/O 缓冲方式

1. 单缓冲

2. 双缓冲

3. 循环缓冲

    > 假设一个计算进程的生命周期为 1 小时，I/O 设备写一个缓冲区需要 10S，计算进程每隔 6S 读一个缓冲区（读缓冲的时间忽略不计）。如果采取预先写缓冲的方式，缓冲区管理采取循环缓冲，要求计算进程不能因为读缓冲区而被阻塞，那么循环缓冲中至少应该有多少个缓冲区？

    解析

    > 由于要求进程（在生命周期内）不能因读缓冲区被阻塞。因此，在 1 小时内，存在下列条件：读的缓冲区个数 ≤ 写的缓冲区个数（当然，要包括预先写的缓冲）。

    计算如下：

    > 预备：1 h =3600 s，可以写 ： 3600 / 10 = 360 个缓冲区。可以读 3600/6 = 600 个缓冲区。又因为预缓冲，所以一开始缓冲区都是满的。 故：600 ≤ 360 + n, 所以：至少应有 240 个缓冲区。

4. 缓冲池

5. SPOOLing 技术

    目的：将一台物理 I／O 设备虚拟为多台逻辑 I／O 设备，同样允许多个用户共享一台物理 I／O 设备。

    在联机情况下实现的同时外围操作称为 SPOOLine， SPOOling 技术

    特点：

    （1）提高了 I／O 的速度。缓和了 CPU 与低速 I／O 设备之间速度不匹配的矛盾。

    （2）将独占设备改造为共享设备。

    （3）实现了虚拟设备功能

    SPOOLing 技术通过把独占设备改造成共享设备，从而提高独占设备的利用率

6. 操作系统中采用缓冲技术的目的是为了增强系统并行操作的能力。

    为了提高 CPU 和设备之间的并行程度。

7. 操作系统采用缓冲技术，能够减少对 CPU 的中断次数，从而提高资源的利用率。

8. 在设备 I/O 中引入缓存技术是为了改善 CPU 与设备 I/O 直接速度不匹配的矛盾。

9. IO 软件层次从上到下依次为: 用户级 IO 软件，与设备无关的操作系统软件，设备驱动程序，中断处理程序，硬件。

    因此，用户程序发出磁盘 IO 请求后，系统的正确处理流程是：

    用户程序 → 系统调用程序 → 设备驱动程序 → 中断处理程序（ → 硬件）

10. 在操作系统中，用户在使用 I/O 设备时，通常采用逻辑设备名

    用户程序提出使用设备申请时，使用系统规定的设备类型号和自己规定的设备相对号（即逻辑设备名）由操作系统进行地址转换，变成系统的设备绝对号（物理设备号）。

11. [I/O 控制方式](https://www.jianshu.com/p/9f39c992b804)

    前三种为操作系统中常见的 I/O 控制方式

    1. 程序直接控制

        (1) CPU 干预频率：很频繁，I/O 操作开始之前、完成之后需要需要 CPU 介入，**并且在等待 I/O 完成的过程中需要 CPU 不断轮询检查。**

        (2) 数据的传送单位：每次读/写一个字。

        (3) 数据流向   读操作（数据输入）：I/O 设备—>CPU—>内存   写操作（数据输出）：内存—>CPU—>I/O 设备   每个字的读/写都需要 CPU 的帮忙。

        (4) 主要优缺点

        优点：实现简单。在读/写指令之后，加上实现循环检查的一系列指令即可（因此才称为“程序直接控制方式”）。

        缺点：**CPU 和 I/O 设备只能串行工作，CPU 需要一直轮询检查，长期处于"忙等"状态，CPU 利用率低。**

    2. 中断驱动 IO

        (1) CPU 干预频率：每次 I/O 操作开始之前、完成之后需要需要 CPU 介入，**等待 I/O 完成的过程中 CPU 可以切换到别的进程执行**。

        (2) 数据的传送单位：每次读/写一个字。

        (3) 数据流向   读操作（数据输入）：I/O 设备—>CPU—>内存   写操作（数据输出）：内存—>CPU—>I/O 设备

        (4) 主要优缺点

        优点：与“程序直接控制方式相比”，在“中断驱动方式”中，I/O 控制器会通过中断信号主动报告 I/O 已完成，CPU 不再需要不停的轮序。**CPU 可以和 I/O 设备并行工作**，CPU 利用效率明显提升。

        缺点：每个字在 I/O 设备和内存之间传输，都需要经过 CPU。而**频繁的中断处理会消耗较多的 CPU 时间。**

        程序控制 IO 和中断驱动 IO ，他们的数据传输过程都需要经过 CPU。且他们二者的数据传送均以字（word）为单位。

    3. 直接存储器访问 DMA

        DMA 控制的寄存器及作用：

        (1) 数据寄存器（**DR**，Data Register）：暂存从设备到内存，或者从内存到设备的数据。

        (2) 内存地址寄存器（**MAR**，Memory Address Register）：在设备向内存输入数据时，MAR 表示输入的数据应该存放到内存的什么位置，在内存向设备输出数据时，MAR 表示要输出的数据放在内存的什么位置。

        (3) 数据计数器（**DC**，Data Counter）：表示剩余要读/写的字节数。

        (4) 命令/状态寄存器（**CR**，Command Register）：用于存放 CPU 发来的 I/O 命令，或设备的状态信息。

        (1) CPU 干预频率：仅在传送一个或多个数据块开始和结束时，才需要 CPU 干预。

        (2) 数据的传送单位：每次读/写**一个或多个块。（注：每次读写的只能是连续的多个块，且这些块读入内存后在内存中也必须是连续的）**

        (3) 数据流向（**不再需要经过 CPU**）  读操作（数据输入）：I/O 设备—>内存   写操作（数据输出）：内存—>I/O 设备

        (4) 主要优缺点

        优点：数据传输以 “块” 为单位，CPU 介入的频率进一步降低。数据的传输不再需要先经过 CPU 再写入内存，数据传输效率进一步增加，CPU 和 I/O 设备的并行性能得到提升。

        缺点：CPU 每发出一条 I/O 指令，只能读/写一个或多个**连续的数据块**。如果要读/写多个离散的块，或者要将数据分别写到不同的内存区域时，CPU 要分别发出多条 I/O 指令，进行多次中断操作。

        采用直接存取法来读写磁盘上的物理记录时，效率最高的是连续结构的文件

    4. 所谓虚拟存储器：是指具有请求调入功能和置换功能，能从逻辑上对内存容量加以扩充的一种存储器系统，其逻辑容量由内存容量和外存容量之和所决定，其运行速度接近于内存速度，而每位的成本却又接近于外存。

        引入和使用虚拟存储器的主要目的提高系统的内存利用率。

    5. **虚拟存储的实现**

        - 请求分页存储管理方式
        - 请求分段系统

    6. IO 通道

        IO 通道的类型

        1. 字节多路通道
        2. 数组选择通道
        3. 数组多路通道

        ![通道]](https://raw.githubusercontent.com/violetu/blogimages/master/20200728220317.png)

        > (1) 通道和 CPU 的区别在于：通道能识别的指令单一，通道没有自己的内存，需要和 CPU 共享内存(通道程序：保存在主存中)。所以说可以把通道看作“低配版的 CPU”。
        > (2) 通道和 DMA 方式的区别：DMA 方式需要 CPU 来控制传输的数据块的大小、传输的位置，而通道方式中的这些信息是由通道控制的。另外，每个 DMA 控制器对应一台设备与内存传递数据，而一个通道可以控制多台设备与内存数据交换。

        通道控制方式分析：

        > (1) CPU 干预频率：极低，通道会根据 CPU 的指示执行相应的通道程序，只有完成一组数据块的读/写后才需要发出中断信号，请求 CPU 干预。
        > (2) 数据的传送单位：每次读/写一组块。
        > (3) 数据流向（不再需要经过 CPU）
        >    读操作（数据输入）：I/O 设备—>内存
        >    写操作（数据输出）：内存—>I/O 设备
        > (4) 主要优缺点
        >    优点：CPU、通道、I/O 设备可并行工作，资源利用率很高。
        >    缺点：实现复杂，需要专门的硬件支持。

        需要 CPU 干预频率从多到少：程序控制 IO → 中断驱动 IO → 直接存储器访问 → IO 通道 → 外围处理机

        通道是一种 I/O 专用处理机。

        计算机系统中能够独立完成输入输出操作的硬件装置，也称为“输入输出处理机”，能接收中央处理机的命令，独立执行通道程序，协助中央处理机控制与管理外部设备。一个独立于 CPU 的专门 I/O 控制的处理机，控制设备与内存直接进行数据交换。

        ![IO ctl](https://raw.githubusercontent.com/violetu/blogimages/master/20200728220408.png)

## 文件系统

1. 文件系统的主要目的是实现对文件的按名存取

2. 文件的存储管理实际上是对外存的管理。

3. 按文件的逻辑结构可分为有结构文件（记录式文件）和无结构文件（流式文件）。而 UNIX、DOS、WINDOWS 系统中的普通文件都是流式文件。

    Windows 和 Unix 这种系统则把结构化留给应用程序。 Windows 和 UNIX 提供了低级文件系统。

4. 从对文件信息的存取次序考虑，存取方法可分为：顺序存取和随机存取两种。磁带上的文件只能顺序存取，磁盘上的文件既可采用顺序方式也可用随机方式存取。

5. 文件的分类

    1. 按用途：系统文件、用户文件、库文件
    2. 源文件、目标文件、可执行文件
    3. 按保护级：只读、读写、执行
    4. 普通文件、目录文件、特殊文件

6. 文件的大小不只受磁盘容量的限制，还受文件系统格式、文件存储结构等的限制。

7. 文件目录是文件控制块的有序集合，而目录文件（即：目录也是文件）是为了实现对文件目录的管理，通常把文件目录以文件形式保存在外存。

8. 从物理结构的优缺点

    1. 顺序结构
       优点
       1、简单：存储与管理都简单，且容易实现。
       2、支持顺序存取和随机存取。
       3、顺序存取速度快。
       4、所需的磁盘寻道次数和寻道时间最少。
       缺点
       1、需要为每个文件预留若干物理块以满足文件增长的部分需要。
       2、不利于文件插入和删除。

    2. 链式结构
       优点
       1、提高了磁盘空间利用率(提高了存储空间的利用率)，不需要为每个文件预留物理块。
       2、有利于文件插入和删除。
       3、有利于文件动态扩充。

        4、在顺序读取时效率较高, 但需要随机存取时效率低下
        缺点
        1、存取速度慢，不适于随机存取。
        2、当物理块间的连接指针出错时，数据丢失。可靠性低
        3、更多的寻道次数和寻道时间。
        4、链接指针占用一定的空间，降低了空间利用率。

    3. 索引结构
       优点
       1、不需要为每个文件预留物理块。
       2、既能顺序存取，又能随机存取。
       3、满足了文件动态增长、插入删除的要求。
       缺点
       1、较多的寻道次数和寻道时间。
       2、索引表本身带来了系统开销。如：内外存空间，存取时间等

        适合随机存取：连续结构、索引结构

        易于文件扩展：链式结构、索引结构

        适合随机存取且文件扩展的：索引结构

        索引文件的优点：允许文件动态修改，可直接对文件进行存取

9. 从系统角度看，文件系统是一个负责文件存储空间的管理机构，文件管理实际是对辅助存储空间的管理。

10. 对顺序文件进行检索时，首先从 FCB 中读出文件的第一个盘块号；而对索引文件进行检索时，应先从 FCB 中读出文件索引表始址。

11. 下面这句话是错误的：顺序文件适于建立在顺序存储设备上，而不适合建立在磁盘上。

    错误原因：

    顺序文件存放在多路存储设备(如磁盘)上时，在多道程序的情况下，由于别的用户可能驱使磁头移向其它柱面，会降低连续存取的速度。顺序文件多用于磁带。

    顺序文件不太适合存储在磁盘上并不是因为它不是顺序存储设备（他是半顺序存储），而是多道程序的事情。

12. 顺序文件必须采用连续分配方式，而链接文件和索引文件则都可采取离散分配方式。

13. 一个采用二级索引文件系统，存取一块盘块信息通常要访问 3 次磁盘。

14. 文件目录项 / 文件控制块 ( FCB ) 是系统管理文件的必须信息结构，是文件存在的唯一标志，打开文件把文件目录项 ( FCB ) 从磁盘拷贝到内存。

15. 设当前工作目录的主要目的是加快文件的索引速度

16. 视频文件属于有结构文件中的定长记录文件，适合用连续分配来组织，连续分配的优点主要有顺序访问容易，顺序访问速度快。为了实现快速随机播放，要保证最短时间查询，不宜选取链式和索引结构。

17. Linux 软连接与硬链接

    通过文件名打开

    ![filename_open](https://raw.githubusercontent.com/violetu/blogimages/master/20200728220539.png)

    软连接与硬链接

    ![hard_soft_principle](https://raw.githubusercontent.com/violetu/blogimages/master/20200728220610.png)

    硬链接

    硬链接是有着相同 inode 号仅文件名不同的文件，因此硬链接存在以下几点特性：

    - 文件有相同的 inode 及 data block；
    - 只能对已存在的文件进行创建；
    - 不能交叉文件系统进行硬链接的创建；
    - 不能对目录进行创建，只可对文件创建；
    - 删除一个硬链接文件并不影响其他有相同 inode 号的文件。

    软链接

    软链接与硬链接不同，若文件用户数据块中存放的内容是另一文件的路径名的指向，则该文件就是软连接。软链接就是一个普通文件，只是数据块内容有点特殊。软链接有着自己的 inode 号以及用户数据块（见 [图 2.](https://www.ibm.com/developerworks/cn/linux/l-cn-hardandsymb-links/index.html#fig2)）。因此软链接的创建与使用没有类似硬链接的诸多限制：

    - 软链接有自己的文件属性及权限等；
    - 可对不存在的文件或目录创建软链接；
    - 软链接可交叉文件系统；
    - 软链接可对文件或目录创建；
    - 创建软链接时，链接计数 i_nlink 直接复制，不会增加；且删除原文件，软连接文件的链接计数不变。（因为链接计数是针对 inode 的，而软连接有自己的文件属性、inode。）
    - 删除软链接并不影响被指向的文件，但若被指向的原文件被删除，则相关软连接被称为死链接（若被指向路径文件被重新创建，死链接可恢复为正常的软链接）。

18. 相对目录

    ../ 表示当前目录上一级
    ../../ 表示当前目录上一级的上一级
    以此类推

    ./  表示当前目录

19. 若文件的索引节点已在内存中，问访问某个文件中某个位置的内容，需要访问的磁盘次数。分情况。

    1. 当要访问的文件位于直接地址时
    2. 当要访问的文件位于一级间接地址时
    3. 当要访问的文件位于二级间接地址时

20. 文件索引，问访问磁盘的个数/次数，不需要转换地址，只需要判断处于：直接索引、一级索引，还是二级索引就可以。直接比较地址的大小。

21. 缺页中断就是要访问的页不在主存，需要操作系统将其调入主存后再进行访问。

    因此，如果题目中没有指出：“开始的 n 个页面已经装入内存”， 那么开始将页面调入主存的那几次也是缺页中断。

    缺页率 = 缺页中断次数 / 访问页面总次数（页面序列的长度）

## 杂项

1. **对程序进行重定位的技术按重定位的时机可分为两种：静态重定位和动态重定位。**

    **静态重定位：**

    **是在目标程序装入内存时，由装入程序对目标程序中的指令和数据的地址进行修改，即把程序的逻辑地址都改成实际的地址。对每个程序来说，这种地址变换只是在装入时一次完成，在程序运行期间不再进行重定位。**

    > 因此，静态重定位后，不可能使用紧缩技术解决碎片问题。

    **优点：是无需增加硬件地址转换机构，便于实现程序的静态连接。在早期计算机系统中大多采用这种方案。**

    **缺点：（1）程序的存储空间只能是连续的一片区域，而且在重定位之后就不能再移动。这不利于内存空间的有效使用。（2）各个用户进程很难共享内存中的同一程序的副本。**

    **动态重定位：**

    **是在程序执行期间每次访问内存之前进行重定位。这种变换是靠硬件地址变换机构实现的。通常采用一个重定位寄存器，其中放有当前正在执行的程序在内存空间中的起始地址，而地址空间中的代码在装入过程中不发生变化。**

    **优点：（1）程序占用的内存空间动态可变，不必连续存放在一处。（2）比较容易实现几个进程对同一程序副本的共享使用。**

    **缺点：是需要附加的硬件支持，增加了机器成本，而且实现存储管理的软件算法比较复杂。**

    **现在一般计算机系统中都采用动态重定位方法。**

    动态重定位在装入作业时，不进行地址转换。

2. 地址重定位指的是：

    1. 作业地址空间和物理地址空间的映射；
    2. 将作业的逻辑地址变换为主存的物理地址；
    3. 将作业的相对地址变换为主存的绝对地址。

3. 实时系统的基本特征：（多 交 可 及 独）

    多路性、交互性、可靠性、及时性、独立性

4. 系统调用是操作系统提供给编程人员的唯一接口。

    程序接口又称应用编程接口，程序接口由一组系统调用（system call）组成，获得操作系统的底层服务，使用或访问系统管理的各种软硬件资源

5. 与硬件有关的操作及过程

    1. 页表机制
    2. 地址变换机构
    3. 缺页中断机构
    4. 时钟管理

6. 现代操作系统具有并发性、共享性、虚拟性、异步性。

    异步性：在多道程序环境下，程序执行过程的不确定性。

7. 中断类型分为如下两大类：

    一、强迫性中断：正在运行的程序所不期望的，来自硬件故障或外部请求。

    1、I/O 中断：来自外部设备通道；

    2、程序性中断：运行程序本身的中断，如 溢出、缺页中断、缺段中断、地址越界。

    3、时钟中断

    4、控制台中断

    5、硬件故障

    二、自愿性中断：用户在编程时要求操作系统提供的服务，使用访管指令或系统调用使中断发生。也称为访管中断。包括执行 I/O，创建进程，分配内存，信号量操作，发送/接收消息

8. 在单处理器系统中，如果同时存在有 12 个进程，则处于就绪队列中的进程数量最多为 11。

    如果双核处理系统中的话，处于就绪队列中的进程数量最多为 10。

    就绪队列中最多的进程数 = 总进程数 - 核数

9. 从用户的观点看，操作系统是用户与计算机硬件之间的接口。

10. 用户与操作系统的接口可以是：

    1. 系统调用
    2. 命令解释与键盘命令
    3. 联机或交互式用户的接口、
    4. 内外部命令
