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

```sh
sudo singularity build tensorflow-1.13.sif tensorflow-1.13.def
```

## Usage

To see all the apps
```sh
singularity apps tensorflow-1.13.sif
```

To access help section of a particular app

```sh
singularity run-help --app jupyter tensorflow-1.13.sif
```

### Jupyter App

To start the jupyter notebook server

```sh
singularity run --nv --bind /your/project:/jupyter --app jupyter tensorflow-1.13.sif
```

To bind additional folders for convenience, for example, to bind datasets to `/data`, add another

```sh
--bind /your/dataset/location:/data
```

To run `jupyter notebook` the old-school way:

```sh
singularity exec --bind /home/username/.jupyter/tmp:/run/user \
                 --bind /home/username/project_folder:/jupyter \
                 --nv \
                 tensorflow-1.13.sif \
                 jupyter notebook \
                 --notebook-dir=/jupyter \
                 --no-browser
```

### Python Console

To run an interactive python console

```sh
singularity exec --nv tensorflow-1.13.sif python
```

### Running Shell

To run the shell

```sh
singularity shell --nv tensorflow-1.13.sif
```

## Notes

`--nv` flag binds native Nvidia libraries to the container and without this flag you will not be able to access the GPUs from inside the container.

`Jupyter` app will create a temporary folder at `~/.jupyter/tmp` in the host machine (not inside the container!) where notebook tokens and other ephemeral information will be stored. We decided not to write in `/tmp` folder as this will lead to writing to `/tmp` folder (if container is launched without `--contain` flag) where other users can read leaking user specific and sensitive information.

## Licence

Copyright (c) 2019 Saravanabalagi Ramachandran

- Not available for commercial use
- Absolutely no warranty provided

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
