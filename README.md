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

## Precaution

WARNING: By default, `tensorflow` will try to access the total memory in as many GPUs as possible. With a precaution that this might lead to crashing existing scripts using the GPU, expose only the ones you want to use.

With the warning in mind, allot GPUs that can be used using a resource scheduler like [SLURM](https://slurm.schedmd.com/gres.html). 

TIP: If you do not use any managers, please set `CUDA_VISIBLE_DEVICES` to whichever GPU you want to expose to Tensorflow.

```sh
export CUDA_VISIBLE_DEVICES=0,1
# will expose only GPUs 0 and 1
```
If you want to automate this process specifying only number of GPUs and minimum memory, you can use a simple script or use apps like [mask-gpu](https://pypi.org/project/mask-gpu/)

## Running Jupyter App

Launch an instance

```sh
singularity instance start --nv --bind /your/project:/jupyter tensorflow-1.13.sif my_instance
```

To bind additional folders for convenience, for example, to bind datasets to `/data`, add another

```sh
singularity instance start --nv \
                            --bind /your/project:/jupyter \
                            --bind /your/dataset/location:/data \
                            tensorflow-1.13.sif \
                            my_instance
```

Both `--nv` and `--bind` bindings persist in the instance.

Then run jupyter app on the instance

```sh
singularity run --app jupyter instance://my_instance
```

If you are serving from a remote machine, then do port forwarding in your local machine,
```sh
ssh -NfL localhost:8000:localhost:8888 remote-machine.ip.address
#                     |           |
#   [desired local port]          [remote port where server is running]
```
and get the client running at `localhost:8000` in your local machine.

To stop an instance

```sh
singularity instance stop my_instance
# singularity instance stop -a                       <--- To stop all instances
```

To check server logs realtime, [shell](#running-shell) into the instance and use `tmux`
```sh
tmux ls
tmux a -t <id>
# tmux attach -t 0
```

## Running Python Console

To run an interactive python console

```sh
singularity exec instance://my_instance python   
# singularity exec --nv tensorflow-1.13.sif python   <-- To directly run python on the container
```

## Running Shell

To run the shell

```sh
singularity shell instance://my_instance
# singularity shell --nv tensorflow-1.13.sif          <-- To shell into the container directly
```

## Starting services without instances (not recommended)

WARNING: If you were to do something like this from within a container you would also see the service start, and the web server running. But then if you were to exit the container, the process would continue to run within an unreachable mount namespace. The process would still be running, but you couldn’t easily kill or interface with it. This is a called an orphan process. Singularity instances give you the ability to handle services properly. More on this [here](https://www.sylabs.io/guides/3.0/user-guide/running_services.html).

However, for whatever reason, if you would want to directly run things in the container, follow the steps below:

To start the jupyter notebook server

```sh
singularity run --nv --bind /your/project:/jupyter --app jupyter tensorflow-1.13.sif
```


To run `jupyter notebook` the old-school way (without the app):

```sh
singularity exec --bind /home/username/.jupyter/tmp:/run/user \
                 --bind /home/username/project_folder:/jupyter \
                 --nv \
                 tensorflow-1.13.sif \
                 jupyter notebook \
                 --notebook-dir=/jupyter \
                 --no-browser
```

To kill the notebook server, run the shell and

```sh
ps aufx | grep jupyter
kill <id>
```


## Notes

- When starting services without instances (i.e, when working directly on the container), remember to bind `--nv` and other directories via `--bind` every single time you access the container directly. This is however only needed to be done during launching and not required when accessed via instance.

- `--nv` flag binds native Nvidia libraries to the container and without this flag you will not be able to access the GPUs from inside the container.

- `Jupyter` app will create a temporary folder at `~/.jupyter/tmp` in the host machine (not inside the container!) where notebook tokens and other ephemeral information will be stored. `/tmp` folder is **not** bound for `jupyter` to write temporary info into, as this will lead to writing to host's `/tmp` folder (if container is launched without `--contain` flag) where other users can read resulting in leaking user specific and sensitive information.

- First few lines of the output immediately after starting the server are shown. This is useful for obtaining the token and to check if the server has successfully started. Logs shall be found in `~/.jupyter/tmp` as `output_<yymmdd_HHMMSS>.log`, in addition to what's shown inside `tmux`.

## Licence

Copyright (c) 2019 Saravanabalagi Ramachandran

- Not available for commercial use
- Absolutely no warranty provided

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
