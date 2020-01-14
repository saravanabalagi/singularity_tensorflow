# Singularity Tensorflow
This library contains definitions for building tensorflow singularity containers bootstrapped from docker://tensorflow/tensorflow for development purposes. The containers also contain essential pip packages for computer vision, deep learning and visualization. Please refer to the individual def file to see included apt and PyPi packages.

## Build

Build a singularity image (.sif) from the definition file (.def) on your own machine:

```sh
cd src
sudo singularity build tf2.sif tf2.def                          # tf2 (no notebook or lab)
```

Once `tf2.sif` is built, you can then build with jupyter support using one of the following:
```
sudo singularity build jupyter_tf2.sif jupyter.def              # jupyter (only notebook)
sudo singularity build jupyter_tf2.sif jupyterlab.def           # jupyterlab (contains both notebook and lab)
```

## Copy

Copy the singularity image (.sif) to the Server Machine:

```sh
scp your_machine:~/singularity_images/tf2.sif ~/singularity_images/
#scp source destination
```

Note that this requires authentication to your machine, it's strongly recommended to setup ssh key access so you can directly run the above command.

## Launch Instance

SSH into the server and run,

```
cd ~/singularity_images
singularity instance start --nv \
                            --contain \
                            --home $HOME \
                            --bind ~/Projects/Python:/projects \
                            --bind /data:/data \
                            tf2.sif \
                            tf2
```

Change the arguments appropriately:
- `tf2.sif`: Singularity Image file location 
- `tf2`: Instance Name
- `--bind directory_in_host:location_inside_container`: The directory `~/Projects/Python` present on the host machine will be mapped to `/projects` inside the singularity image.
- You can add may `--bind`s to bind more directories on the host to the container.
- `--home directory_in_host`: Special bind command maps the directory to `~` inside the singularity image.

To stop and unmount a single instance, or to stop and unmount all instances, use
```
singularity instance stop instance://tf2
singularity instance stop -a
```
For more details, see [singularity docs](https://sylabs.io/guides/3.0/user-guide/).

## Run

Make sure have launched an instance and the instance is running before you run anything in that instance in the Server Machine.
```sh
singularity instance list
```

#### Precaution

WARNING: By default, `tensorflow` will try to access the total memory in as many GPUs as possible. With a precaution that this might lead to crashing existing scripts using the GPU, expose only the ones you want to use.

With the warning in mind, allot GPUs that can be used using a resource scheduler like [SLURM](https://slurm.schedmd.com/gres.html). 

TIP: If you do not use any managers, please set `CUDA_VISIBLE_DEVICES` to whichever GPU you want to expose to Tensorflow.

```sh
export CUDA_VISIBLE_DEVICES=0,1
# will expose only GPUs 0 and 1
```
If you want to automate this process specifying only number of GPUs and minimum memory, you can use a simple script or use apps like [mask-gpu](https://pypi.org/project/mask-gpu/)


### Run Python Console

To run an interactive python console

```sh
singularity exec instance://my_instance python   
```

### Run Shell

To run the shell

```sh
singularity shell instance://my_instance
```

### Run Scripts

To run a long running script,

```
singularity shell instance://my_instance                      # Singularity Prompt: Singularity tf2.sif:~> 
tmux                                                          # Tmux Window: name@server:~$
export CUDA_VISIBLE_DEVICES=0,1
python some_folder/some_long_python_script.py
Ctrl+B Ctrl+D                                                 # Singularity Prompt: Singularity tf2.sif:~> 
exit                                                          # Server Prompt: name@server:~$
```

To check progress/output,
```
singularity shell instance://my_instance                      # Singularity Prompt: Singularity tf2.sif:~> 
tmux ls                                                       # Lists all tmux windows
tmux a -t <window_number>                                     # Tmux Window: name@server:~$
# do stuff
# Ctrl+B [ to start scrolling
# Page-Up/Down, Up/Down/Left/Right to navigate
# q to exit scrolling mode
Ctrl+B Ctrl+D to exit tmux                                    # Singularity Prompt: Singularity tf2.sif:~> 
exit                                                          # Server Prompt: name@server:~$
```

### Run Jupyter Server

#### Mount and Start Server
 ```
singularity run --app jupyter instance://jupyter 0,1
```
This jupyter server will use only GPUs 0 and 1. Change appropriately.

#### Checking running Servers, Tokens and Server Logs
```
singularity run --app jupyter_servers instance://jupyter
singularity run --app jupyter_logs instance://jupyter
```
`jupyter_logs` app will take you inside [tmux](https://github.com/tmux/tmux/wiki) (detached screen). 
- To exit, use <kbd>Ctrl</kbd>+<kbd>B</kbd>, then <kbd>D</kbd>
- To switch tabs, use <kbd>Ctrl</kbd>+<kbd>B</kbd>, then <kbd>N</kbd>

#### Port Forwarding

You may want to edit the notebook remotely in your machine. To do so, start the jupyter notebook server using above instructions and run the following command in your machine:

```sh
ssh -NfL localhost:8000:localhost:8888 remote-machine.ip.address
#                     |           |
#   [desired local port]          [remote port where server is running]
```
Then run `localhost:8000` in a browser on your machine to view/edit the notebooks. This command forwards the port 8000 in your machine to the server's port 8888.

### Kill Processes

Similar to killing processes on your own machine, just shell into the instance and kill the desired process.

```
singularity shell instance://my_instance    # Singularity Prompt: Singularity tf2.sif:~> 
ps aufx                                     # Lists all running processes
kill <PID>
```

## Starting services without instances (not recommended)

WARNING: If you were to do something like this from within a container you would also see the service start, and the web server running. But then if you were to exit the container, the process would continue to run within an unreachable mount namespace. The process would still be running, but you couldn’t easily kill or interface with it. This is a called an orphan process. Singularity instances give you the ability to handle services properly. More on this [here](https://www.sylabs.io/guides/3.0/user-guide/running_services.html).

However, for whatever reason, if you would want to directly run things in the container:

```sh
singularity shell --nv tf2.sif
singularity exec --nv tf2.sif python
singularity exec --nv tf2.sif command_to_execute
```

To run `jupyter notebook` the old-school way (without the app):

```sh
singularity exec --bind /home/username/.jupyter/tmp:/run/user \
                 --bind /home/username/project_folder:/jupyter \
                 --nv \
                 tf2_jupyter.sif \
                 jupyter notebook --notebook-dir=/jupyter --no-browser
```

## Notes

- `--nv` flag binds native Nvidia libraries to the container and without this flag you will not be able to access the GPUs from inside the container.

- If container is launched without `--contain` flag, `/tmp` folder will be linked to host's `/tmp` folder (where other users have read permissions) resulting in leaking user specific and sensitive information.

- `Jupyter` app will create a temporary folder at `~/.container/jupyter` (check `CONTAINER_RUNTIME_DIR` env variable in the definition file) or `~/.jupyter` in the host machine (not inside the container!) where notebook tokens and other ephemeral information will be stored. 

- When starting services without instances (i.e, when working directly on the singularity image), remember to bind `--nv` and other directories via `--bind` every single time. Not applicable when running on launched instances.

## Licence

Copyright (c) 2019 Saravanabalagi Ramachandran

- Not available for commercial use
- Absolutely no warranty provided

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
