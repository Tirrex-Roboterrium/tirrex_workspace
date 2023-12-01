## Installation

### Create workspace

You need to install `vcstool`. You can install it using pip:
```
pip install vcstool
```

Clone this project and go to the root:
```
git clone https://github.com/FiraHackathon/fira_hackathon_workspace.git
cd fira_hackathon_workspace
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
`ros2 launch fira_hackathon_demo demo.launch.py`.

### Running a challenge

The available docker service are the following:

* `demo` (that starts `demo.launch.py`)
* `challenge1` (that starts `challenge1.launch.py`)
* `challenge2` (that starts `challenge2.launch.py`)
* `challenge3` (that starts `challenge3.launch.py`)

They are defined in the file [`docker/compose.yml`](docker/compose.yml).
You can add your own services if you want to easily execute specific commands in the docker
environment.

All the commands must be run from the root of this project.

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
docker compose run --rm --no-deps demo ros2 launch fira_hackathon_demo demo.launch.py
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
The option `--rm` allows to automatically delete the container when the command finished.
