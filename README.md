## Installation

### Create workspace

You need to install `vcstool`. You can install it using pip:
```
pip install vcstool
```

Clone this project and go to the root:
```
git clone https://github.com/FiraHackathon/fira_tirrex_workspace.git
cd fira_tirrex_workspace
```

Then you can execute a script to clone all the ROS packages and download the gazebo models:
```
./scripts/create_ws
```

### Compiling

#### Create docker image and compile

A docker image is available to install ROS2 and all the dependencies of the packages.
You first need to install a recent version of docker compose by [following the instruction on the
docker documentation](https://docs.docker.com/compose/install/linux/).
Then you can build the image and compile the workspace using the following command (from the root of
this project):
```
docker compose up compile --build
```


## Running

You can run the default demo simulation by executing:
```
docker compose up
```
This command will start the default docker services named `compile` and `demo`.
The `compile` service execute the `colcon build` command.
The `demo` service is started when the `compile` service exits successfully and execute
`ros2 launch fira_tirrex_demo demo.launch.py`.

### Running a challenge

All the following commands must be run from the root of this project.

The available docker service are the following:

* `demo` (that starts `demo.launch.py`)
* `challenge1` (that starts `challenge1.launch.py`)
* `challenge2` (that starts `challenge2.launch.py`)
* `challenge3` (that starts `challenge3.launch.py`)

They are defined in the file [`docker/compose.yml`](docker/compose.yml).
You can add your own services if you want to easily execute specific commands in the docker
environment.

To execute a specific challenge. You can replace `challenge1` by one the previous services and run
```
docker compose up challenge1
```

You can save time by avoiding recompiling using `--no-deps` and you can lighten terminal output
using `run` instead of `up`
```
docker compose run --rm --no-deps challenge1
```

### Run other commands in docker

If you want to execute a specific command, it is possible tu specify it after `docker compose run`.
For example, to manually launch `demo.launch.py` you can execute:
```
docker compose run --rm --no-deps demo ros2 launch fira_tirrex_demo demo.launch.py
```
Every ros command is available.
For example, it is possible to do `ros2 topic list` by executing
```
docker compose run --rm --no-deps demo ros2 topic list
```

It is also possible to open a shell on the docker to run several commands
```
docker compose run --rm --no-deps demo bash
```
The option `--rm` allows to automatically delete the container when the command finishes.


## Architecture of the workspace

Here is a brief presentation of the main directories:

* `build` contains the files generated by the compilation step
* `docker` contains the configuration files for docker
* `gazebo` contains the downloaded gazebo models that are too large to be versioned
* `install` contains the shared files and executables of the ROS packages
* `log` contains the logged information of the compilation
* `scripts` contains some useful tools to prepare the workspace
* `src` contains all the cloned ROS packages

### How the docker image works

The docker image corresponds to an Ubuntu 22.04 image with a complete installation of ROS2 Humble
and all the dependencies of the ROS2 packages of this workspace.
The image is built from the [Dockerfile](docker/Dockerfile) and can be edited to add other ubuntu or
pip packages.

When a docker service is started, this workspace is mounted as a volume inside the docker
container and the ROS commands are run using your own Linux user.
This makes using the tools in docker similar to using them directly.
This means that, if you have ROS Humble on your host system, you should be able to direclty run ros2
commands without using docker commands.

### ROS packages for the tirrex

In the `src` directory, the packages are organized in several sub-folders:

* `romea_core` contains all packages that are independant of ROS
* `romea_ros2` contains all ROS2 packages (in several sub-folders)
* `third_party` contains packages that are not written by our team

For more details about this packages, read their README.

## Updating

All the ROS packages may evolve during the tirrex.
You can update them by using the command
```
vcs pull -nw6
```

Some projects may fail to update.
This may be due to local modifications.
You have to manually handle this projects.
However, it is possible to stash your local changes on every project before updating by running
```
vcs custom -nw6 --args pull --rebase --autostash 
```

If you want to update projects and re-download the gazebo models, you can re-run the installation
script
```
./scripts/create_ws
```
