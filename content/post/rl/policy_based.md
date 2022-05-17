---
title: Policy-based Method of RL
comments: true
toc: true
tags:
description: 本文学习 RL 的 Policy-based Method
categories:
    - rl
date: 2020-12-17 16:35:39
tags:
---

Policy function 𝜋(𝑎|𝑠) 用来指导 agent 去运动，它接受一个状态 s 作为输入，输出所有动作的概率，agent 从所有动作中采样选取一个动作 a 执行。

Can we directly learn a policy function 𝜋(𝑎|𝑠)?

-   If there are only a few states and actions, then yes, we can.
-   Draw a table (matrix) and learn the entries.
-   What if there are too many (or infinite) states or actions?

## Policy Network 𝜋(𝑎|𝑠;𝛉)

近似函数常用的是线性回归和神经网络。

Policy network: Use a neural net to approximate 𝜋(𝑎|𝑠;𝛉).

-   Use policy network 𝜋(𝑎|𝑠;𝛉) to approximate 𝜋(𝑎|𝑠;𝛉).
-   𝛉: trainable parameters of the neural net

$\sum_{a \in \mathcal{A}} \pi\left(\left.a\right|{s} ; \boldsymbol{\theta}\right)=1$

## State-value function

$V_{\pi}\left(s_{t}\right)=\mathbb{E}_{A}\left[Q_{\pi}\left(s_{t}, A\right)\right]=\sum_{a} \pi\left(a \mid s_{t}\right) \cdot Q_{\pi}\left(s_{t}, a\right)$

### Approximate state-value function

-   Approximate policy function $\pi(a|s_{t})$ by policy network $\pi(a|s_{t};\theta)$.
-   Approximate value function $V_{\pi}\left(s_{t}\right)$ by: $V\left(s_{t} ; \boldsymbol{\theta}\right)=\sum_{a} \pi\left(a \mid s_{t} ; \boldsymbol{\theta}\right) \cdot Q_{\pi}\left(s_{t}, a\right)$

Policy-based learning: Learn 𝛉 that maximizes $J(\boldsymbol{\theta})=\mathbb{E}_{S}[V(S ; \boldsymbol{\theta})]$

Policy gradient ascent to improve 𝛉:

-   Observe state s
-   Update policy by: $\theta \leftarrow \theta + \beta \cdot \frac{\partial V(s;\theta)}{\partial \theta}$
-   Policy gradient: $\frac{\partial V(s;\theta)}{\partial \theta}$

## Policy gradient

![form_1](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/image/20201216104659.png)

![form_2](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/image/20201216104712.png)

### Calculate Policy Gradient for Discrete Actions

![discrete_action](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/image/20201216105014.png)

### Calculate Policy Gradient for Continuous Actions

![continuous_action](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/image/20201216105826.png)

### Update policy network using policy gradient

![algorithm](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/image/20201216110804.png)

Two Options:

![options](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/image/20201216133540.png)

## Summary

![summary](https://blog-1259556217.cos.ap-chengdu.myqcloud.com/image/20201216133836.png)
