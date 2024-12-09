## Devices configuration

#### Remote controller configuration:

The remote controller can be configured using the `remote_controller.joystick.yaml` file located in
the `devices` directory.
You can specify the type of controller (e.g., `xbox` or `dualshock4`; other joystick types can be
added upon request).
Additionally, you can assign a name to the controller, which will also serve as the ROS2 namespace
under which the driver will launch.

To activate the driver, specify the ROS 2 driver type you want to use to retrieve data from the
joystick.
This includes setting the ROS 2 package, executable, and any desired parameters.
For details on driver options based on joystick type, please refer to the documentation for the
`romea_joystick_bringup` package.
Note that topic remapping for this node are predefined and cannot be changed; the topic provided by
the driver is named `joystick/joy`.
Finally, you can specify whether or not this topic should be added in ROS bag during the demo
recording.

```yaml
name: joystick # name of the joystick
driver:
  package: joy # ros2 driver package 
  executable: joy_node # ros2 node launch
  parameters: # parameters of driver node
    autorepeat_rate: 10.0
    deadzone: 0.1
configuration:
  type: xbox #  joystick type
records:
  joy: true # joy topic will be recorded into bag
```



#### Xsens IMU configuration:

```yaml
name: imu
driver:
  package: xsens_driver #ros2 driver package name
  executable: mtnode.py # node to be launched
  parameters: # node parameters
    device: "/dev/ttyUSB0"
    baudrate: 115200
configuration:
  type: xsens # imu type
  model: mti #imu model
  rate: 100 # rate Hz
geometry:
  parent_link: "base_link" # name of parent link where is located the imu sensor
  xyz: [0.0, 0.0, 0.7] # its position in meters
  rpy: [0.0, 0.0, 0.0] # its orienation in degrees
records:
  data: true # data topic will not be recorded in bag
```



#### Septentrio GPS configuration:

An AsteRx GPS receiver from Septentrio is mounted on rear top of the robot.
To configure this setup, you’ll need to edit the `septentrio.gps.yaml` file located in the `devices`
directory (see example below).

In this file, it is possible to define the gps `type` and `model`, specified here as `septentrio`
and `asterx`, along with its configuration parameters.
For a list of supported types and models, please refer to the `romea_gps_bringup` package
documentation.
Two key settings are required for gps receiver configuration: `rate` and `dual_antenna` (set here to
10 Hz and true, respectively).
These parameters may be optional if the sensor supports only one fixed configuration.
For details on selectable parameters, please consult the specification file for each sensor in the
`config` directory of the `romea_gps_description` package.
You can also specify the gps receiver antenna's position (`geometry.xyz`)  on the mobile base.
This positioning is relative to a "parent link" on the robot’s structure, commonly `base_link` or
`base_footprint`.

Additionally, you can assign a name for the gps receiver, which will also serve as the ROS 2
namespace under which the driver launches.
To activate the driver, specify the ROS 2 driver package, executable, and any required parameters,
note that certain parameters are derived automatically based on the selected configuration.
For specific driver options based on gps receiver type, please refer to the `romea_gps_bringup`
package documentation.
Note that topic remappings for this node are predefined and cannot be modified; the driver publishes
on the fixed topic `gps/name_sentence`, `gps/fix` and`gps/vel` , which is also the topics published
by the simulator.
Lastly, you can specify whether these topics should be recorded in the ROS bag during the demo.

```yaml
name: gps # name of the lidar
driver:
  package: romea_gps_driver #ros2 driver package name
  executable: tcp_client_node  # node to be launched
  parameters: # node parameters
    ip: 192.168.0.50
    nmea_port: 1001
    rtcm_port: 1002
ntrip:
  package: ntrip_client #ros2 driver package name
  executable: ntrip_ros.py # node to be launched
  parameters: # node parameters
    host: caster.centipede.fr
    port: 2101
    username: centipede
    password: centipede
    mountpoint: MAGC
configuration:
  type: drotek  # gps type
  model: f9p # gps model
  rate: 10 # nmea rate Hz
  dual_antenna: true # specify if gps use dual antenna
geometry:
  parent_link: base_link  # name of parent link where is located the gps sensor
  xyz: [0.0, 0.3, 1.5] # its position in meters
records:
  nmea_sentence: true # nmea sentence topic will be recorded in bag
  fix: false # gps_fix topic will not be recorded in bag
  vel: false # vel topic will not be recorded in bag
```



#### LMS151  lidar configuration:

A LMS151 lidar from Sick is mounted at the front of the robot.
To configure this setup, you’ll need to edit the `lms151.lidar.yaml` file located in the `devices`
directory (see example below).

In this file, it is possible to define the lidar `type` and `model`, specified here as `sick` and
`lms151`, along with its configuration parameters.
For a list of supported types and models, please refer to the `romea_lidar_bringup` package
documentation.
Two key settings are required for lidar configuration: `rate` and `resolution` (set here to 50 Hz
and 0.5°, respectively).
These parameters may be optional if the sensor supports only one fixed configuration.
For details on selectable parameters, please consult the specification file for each sensor in the
`config` directory of the `romea_lidar_description` package.
You can also specify the lidar's position (`geometry.xyz`) and orientation (`geometry.rpy`) on the
mobile base.
This positioning is relative to a "parent link" on the robot’s structure, commonly `base_link` or
`base_footprint`.

Additionally, you can assign a name for the lidar, which will also serve as the ROS 2 namespace
under which the driver launches.
To activate the driver, specify the ROS 2 driver package, executable, and any required parameters,
note that certain parameters are derived automatically based on the selected configuration.
For specific driver options based on lidar type, please refer to the `romea_lidar_bringup` package
documentation.
Note that topic remappings for this node are predon efined and cannot be modified; the driver
publishes on the fixed topic `lidar2d/scan` , which is also the topic published by the simulator.
Lastly, you can specify whether the `scan` topic should be recorded in the ROS bag during the demo.

```yaml
name: lidar2d # name of the lidar
driver: 
  package: sick_scan #ros2 driver package name
  executable: sick_generic_caller # node to be launched
  parameters: # node parameters
    hostname: 192.168.1.112 #device ip
    port: 2112 #communication port
configuration: 
  type: sick # lidar type
  model: lms151 # lidar model
  rate: 50 # hz (optional according lidar model)
  resolution: 0.5 # deg (optional according lidar model)
geometry: 
  parent_link: base_link # name of parent link where is located the LIDAR senor
  xyz: [2.02, 0.0, 0.34] # its position in meters
  rpy: [0.0, 0.0, 0.0] # its orienation in degrees
records:
  scan: true # scan topic will be recorded in bag
```



#### Ouster lidar configuration:

An OS1 lidar from Ouster is mounted on the top of the robot.
To configure this setup, you’ll need to edit the `ouster.lidar.yaml` file located in the `devices`
directory (see example below).

In this file, it is possible to define the lidar `type` and `model`, specified here as `ouster` and
`os1_32`, along with its configuration parameters.
For a list of supported types and models, please refer to the `romea_lidar_bringup` package
documentation.
Two key settings are required for lidar configuration: `rate` and `resolution` (set here to 10 Hz
and 0.17578125°, respectively).
These parameters may be optional if the sensor supports only one fixed configuration.
For details on selectable parameters, please consult the specification file for each sensor in the
`config` directory of the `romea_lidar_description` package.
 You can also specify the lidar's position (`geometry.xyz`) and orientation (`geometry.rpy`) on the
 mobile base.
This positioning is relative to a "parent link" on the robot’s structure, commonly `base_link` or
`base_footprint`.

Additionally, you can assign a name for the lidar, which will also serve as the ROS 2 namespace
under which the driver launches.
To activate the driver, specify the ROS 2 driver package, executable, and any required parameters,
note that certain parameters are derived automatically based on the selected configuration.
For specific driver options based on lidar type, please refer to the `romea_lidar_bringup` package
documentation.
Note that topic remappings for this node are predefined and cannot be modified; the driver publishes
on the fixed topic `lidar2d/cloud` , which is also the topic published by the simulator.
Lastly, you can specify whether the `cloud` topic should be recorded in the ROS bag during the demo.

```yaml
name: lidar # name of the lidar
driver: 
  package: ouster_ros #ros2 driver package name
  executable: os_driver # node to be launched
  parameters: # node parameters
    sensor_hostname: '' #device ip automatic detection
configuration: 
  type: ouster # lidar type
  model: os1_32 # lidar model
  rate: 10 # hz (optional according lidar model)
  resolution: 0.17578125 # deg (optional according lidar model)
geometry:
  parent_link: base_link # name of parent link where is located the LIDAR sensor
  xyz: [1.2, 0.0, 1.1] # its position in meters
  rpy: [0.0, 0.0, 0.0] # its orienation in degrees
records: 
  cloud: true # cloud topic will be recorded in bag
```



#### Robot view camera configuration:

A RGB camera has been set above the robot to provide a bird’s-eye view, making it easier to monitor
the robot's activities.
To configure this setup, edit the `robot_view.camera.yaml` file located in the `devices` directory,
as shown in the example below.

In this configuration file, you can define the camera’s `type` and `model`, here specified as `axis`
and `p1346`, along with essential configuration parameters.
For a full list of supported types and models, refer to the `romea_camera_bringup` package
documentation.
Depending on the camera model, several parameters may need to be set, with primary ones including
`resolution`, `frame_rate`, `horizontal_fov`, `vertical_fov`, and `video_format`.
These parameters may be optional if the sensor only supports a fixed configuration or if default
values are available.
For details on selectable parameter, please consult the specification files for each camera in the
`config` directory of the `romea_camera_description` package.
You can also specify the camera's physical location on the robot by setting its position
(`geometry.xyz`) and orientation (`geometry.rpy`) relative to a "parent link" in the robot’s frame,
commonly `base_link` or `base_footprint`.

Additionally, you may assign a unique name for the camera, which also serves as the ROS 2 namespace
under which the driver will be launched.
To activate the driver, specify the ROS 2 driver package, executable, and any required parameters.
Certain parameters may automatically be derived from the selected configuration.
For specific driver options based on camera type, please refer to the `romea_camera_bringup`
package documentation.
Note that topic remapping for this node are predefined and cannot be modified.
The driver publishes data on the fixed topics `robot_view/image_raw` and `robot_view/camera_info`,
which are also used by the simulator.
Finally, you can specify whether these topics should be recorded in the ROS bag during the demo.

```yaml
name: robot_view # name of the camera
driver: 
  package: usb_cam # driver ros2 package
  executable: usb_cam_node_exe # node to be launch
  parameters: # parameter of driver node
    video_device: /dev/video0
configuration: 
  type: axis  #  type of camera
  model: p146  # model of camera
  resolution: 1280x720 # resolution of image provided by camera (optional) default is 1280x720
#  horizontal_fov: 27 # horizontal field of view in degree (optional) default is 27
#  frame_rate: 30 # frame rate in hz (optional) depend of the selected resolution
#  video_format: h264 # output video codec (optional), default h264 
geometry:
  parent_link: base_link # name of parent link where is located the camera sensor
  xyz: [-4.5, 0.0, 2.7] # its position in meters
  rpy: [0.0, 22.0, 0.0] # its orienation in degrees
records:
  camera_info: false # camera info topic will not be recorded in bag
  image_raw: false # image_raw topic will not be recorded in bag
```



#### Realsense camera configuration:

An RGB-D camera, such as the Realsense D435, can be mounted on the mobile base to capture both color
and depth information.
In this example, a D435 camera is mounted on top of the robot.
To configure this setup, edit the `realsense.rgbd_camera.yaml` file located in the `devices`
directory, as shown below.

In this configuration file, you can define the camera’s `type` and `model`, specified here as
`realsense` and `d435`, along with relevant configuration parameters.
For a list of supported types and models, please refer to the `romea_rgbd_camera_bringup` package
documentation.
An RGB-D camera is composed of multiple sensors: an RGB camera, an infrared camera, and a depth
camera.
Each of these sensors can be configured individually by specifying settings like `resolution`,
`frame_rate`, `horizontal_fov`, and `vertical_fov`, etc.
These parameters may be optional if the sensor only supports a fixed configuration or if default
values are available.
In this example, we use the same resolution for all sensors and leave the other parameters at their
default values.
For details on selectable parameters, refer to the specification files for each camera in the
`config` directory of the `romea_rgbd_camera_description` package.
You can also specify the camera's position (`geometry.xyz`) and orientation (`geometry.rpy`) on the
mobile base.
This positioning is relative to a "parent link" in the robot’s structure, commonly `base_link` or
`base_footprint`.

Additionally, you may assign a unique name for the camera, which will also serve as the ROS 2
namespace under which the driver will be launched.
To activate the driver, specify the ROS 2 driver package, executable, and any necessary parameters.
Certain parameters will automatically be derived from the selected configuration.
For specific driver options based on camera type, refer to the `romea_camera_bringup` package
documentation.
Note that topic remapping for this node are predefined and cannot be modified.
By default, the driver publishes on fixed topics such as `camera_info` and `image_raw` for each
camera sensor.
Additionally, the driver publishes a colorized point cloud topic `/rgbd_camera/point_cloud/points`
generated from RGB and depth images.
These topics are also used by the simulator.
Finally, you can choose whether these topics should be recorded in the ROS bag during the demo.

```yaml
name: "rgbd_camera"
driver:
  package: realsense2_camera # driver ros2 package
  executable: realsense2_camera_node # node to be launch
  parameters: # parameter of driver node
    enable_color: true
    spatial_filter.enable: true 
    temporal_filter.enable: true
configuration:
  type: realsense #  type of camera
  model: d435 #  model of camera
  rgb_camera:
    resolution: 1280x720 #resolution of image provided by RGB camera (optional) default is 1280x720
  infrared_camera:
    resolution: 1280x720: #resolution of image provided by infrared camera (optional) default is 1280x720
  depth_camera:
    resolution: 1280x720: #resolution of image provided by deapth camera (optional) default is 1280x720 
geometry:
  parent_link: "base_link" # name of parent link where is located the camera sensor
  xyz: [1.42, 0.0, 1.14] # its position in meters
  rpy: [0.0, 20.0, 0.0] # its orienation in degrees
records:
  rgb/camera_info: false # RGB camera info topic will not be recorded in bag
  rgb/image_raw: true # RGB raw image will be recorded in bag
  depth/camera_info: false # depth camera info topic will not be recorded in bag
  depth/image_raw: true # depth raw_image topic will be recorded in bag
  point_cloud/points: true # point cloud topic will be recorded in bag
```
