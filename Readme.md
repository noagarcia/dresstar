# Dress like a Star: Retrieving Fashion Products from Videos
MATLAB code for "Dress like a Star: Retrieving Fashion Products from Videos" paper.
This version of the code is not optimized to run efficiently.

## Prerequisites 
- [MATLAB][1]
- [OpenCV][2] (3.3.0)
- [mexopencv][3]


## Usage
1. Add mexopencv MEX functions to MATLAB path:

``` matlab
addpath('/path/to/mexopencv');
addpath('/path/to/mexopencv/opencv_contrib');
```

2. Training. Run ```training.m``` to extract features and create the model.

``` matlab
videoDir = '/path/to/videos';
dataDir  = '/path/to/data';
training(videoDir, dataDir);
```

3. Testing. Run ```query2frame.m``` to match a query image with a dataset frame.

``` matlab
query = imread('/path/to/query.png');
dataDir  = '/path/to/data';
query2frame(query, dataDir);
```

## Demo
We have developed a small GUI demo in MATLAB for Unix systems. To play with it run the ```demo_gui.m``` code.

![alt text](https://github.com/noagarcia/dresstar/blob/master/Demo/demo.png?raw=true)


## Citation
This code is the MATLAB's implementation of the paper "Dress lika a Star: Retrieving Fashion Products from Videos" published in the [Proceedings of the Computer Vision for Fashion Workshop][4] at ICCV 2017.

````
@InProceedings{GarciaICCVW2017,
author    = {Noa Garcia and George Vogiatzis},
title     = {Dress like a Star: Retrieving Fashion Products from Videos},
booktitle = {Proceedings of the International Conference on Computer Vision Workshops (ICCVW)},
year      = {2017},
}
````

[1]: https://www.mathworks.com/products/matlab/
[2]: http://opencv.org/
[3]: https://github.com/kyamagu/mexopencv
[4]: https://sites.google.com/zalando.de/cvf-iccv2017/
