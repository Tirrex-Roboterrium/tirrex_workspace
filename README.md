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

#### Temporary step for INRAE users

The current version of the file containing all the git projects use irstea ssh URLs instead of github
https URLs.
Then, it is necessary to configure the [irstea](https://gitlab.irstea.fr/-/profile/keys) and
[github](https://github.com/settings/keys) servers to connect [using your ssh key](https://docs.github.com/en/github-ae@latest/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).
After that, you also need to add it to the ssh agent to allow docker to clone the repositories.
You can do that by executing
```
eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519
```
after replacing `~/.ssh/id_ed25519` by the correct private key file.

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

To start graphical applications, you have to enable connection to the X server:
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

If you want to execute a specific command, it is possible tu specify it using `docker compose run`.
For example, to manually launch `demo.launch.py` you can execute:
```
docker compose run --rm -it --no-deps demo ros2 launch fira_hackathon_demo demo.launch.py
```
It is also possible to open a shell on the docker if you want:
```
docker compose run --rm -it --no-deps demo bash
```
The option `--rm` allows to automatically delete the container when the command finish and `-it`
allows to make it more interactive.
