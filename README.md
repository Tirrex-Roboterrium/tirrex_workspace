## Installation

### Create workspace

You need to install `vcstool`. You can install it using pip:
```
pip install vcstool
```

Then you can execute a script to clone all the ROS packages and download the gazebo models.
From the root of this project, execute:
```
./scripts/create_ws
```

### Compiling using docker

It is possible to build a docker image that install ROS2 and all the dependencies of the packages.
You first need to install a recent version of docker compose by [following the instruction on the
docker documentation](https://docs.docker.com/compose/install/linux/).
Then you can build the image and compile the workspace using the following command (from the root of
this project):
```
docker compose up compile --build
```

## Running

To start graphical applications, you have to enable connection to the host server X:
```
xhost +local:docker
```
Then, you can run the default roslaunch command by executing:
```
docker compose up
```

You can save time by avoiding recompiling using the following command:
```
docker compose up --no-deps demo
```
