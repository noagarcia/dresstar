# Dress lika a Star: Retrieving Fashion Products from Videos
MATLAB code for "Dress lika a Star: Retrieving Fashion Products from Videos" paper.

## Prerequisites 
- [MATLAB][1]
- [OpenCV][2] (3.3.0)
- [mexopencv][3]


## Usage
- Add mexopencv MEX functions within MATLAB:

``` matlab
addpath('/path/to/mexopencv');
addpath('/path/to/mexopencv/opencv_contrib');
```

- Add some videos to ```/path/to/videos``` folder
- Training. Run ```training.m``` to extract features and create the kdtree.

``` matlab
videoDir = 'Demo/Videos/';
dataDir  = 'Demo/Data/';
training(videoDir, dataDir);
```

- Testing. Run ```query2frame.m``` to match a query image with a dataset frame.

## Demo
You can play with our demo.

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
