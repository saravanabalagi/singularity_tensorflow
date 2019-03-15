# Singularity Tensorflow
This library provides various tensorflow containers forked from docker://tensorflow/tensorflow for development purposes.
The containers are set to contain the following primary pip packages for development:
- opencv-python
- imshowtools
- imageio
- imutils
- sklearn
- scikit-image
- jupyter_contrib_nbextensions
- keras

## Building Containers

To build containers from the definition files:

```
sudo singularity build tensorflow-1.13.sif tensorflow-1.13.def
```

## Usage

To run `jupyter notebook`:

```
singularity exec --bind /home/username/.jupyter/tmp:/run/user --bind /home/username/project_folder:/jupyter --nv tensorflow-1.13.sif jupyter notebook --notebook-dir=/jupyter --no-browser
```

To run the shell:

```
singularity shell --nv tensorflow-1.13.sif
```

## Notes

`--nv` flag binds native Nvidia libraries to the container and without this flag you will not be able to access the GPUs from inside the container.

## Licence

Copyright (c) 2019 Saravanabalagi Ramachandran

- Not available for commercial use
- Absolutely no warranty provided

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
