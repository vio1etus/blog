# 环境配置

## tensorflow

Note: GPU support is available for Ubuntu and Windows with CUDA®-enabled cards.

### tf 1.x

tensorflow==1.15 is The final version of TensorFlow 1.x which support Python 3.5–3.7
For TensorFlow 1.x（which means for releases 1.15 and older）, CPU and GPU packages are separate.

```shell
pip install tensorflow==1.15 # Release for CPU-only
pip install tensorflow-gpu==1.15 # Release with GPU support (Ubuntu and Windows)
```

> tensorflow-gpu 1.12.0 is available for Python 64-bit 2.7, 3.3, 3.4, 3.5, 3.6 for Linux, Python 64-bit 3.5 and 3.6 for w64. Not available for 32-bit Python, not available for Python 3.7. tensorflow-gpu 1.13.1 is the 1st one available for Python 3.7 64-bit.

### tf 2.x

Support Python 3.6-3.8 according to [the official page](https://www.tensorflow.org/install/pip)(**Note**: NOT verified by myself)

```shell
pip install tensorflow
```

A smaller CPU-only package is also available:

```
pip install tensorflow-cpu
```

tensorflow 最新版本支持信息，可查看 [Install TensorFlow with pip](https://www.tensorflow.org/install/pip)

## 参考资料

> 1. [how to install tensorflow version 1.12.0 with pip](https://stackoverflow.com/questions/55877398/how-to-install-tensorflow-version-1-12-0-with-pip)
> 2. [Install TensorFlow with pip](https://www.tensorflow.org/install/pip)
