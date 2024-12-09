## Robot control

#### Base control:

The mobile base control system operates via a ROS2 controller node called
`/robot/base/mobile_base_controller`. 
The name `robot` may change depending on the robot name.
To command the robot's movement, simply publish messages into the
`/robot/controller/cmd_two_axle_steering` topic using the
`romea_mobile_base_msgs/msg/TwoAxleSteeringCommand` message type.
This message includes the following parameters:	

``` 
float64 longitudinal_speed # linear speed of robot
float64 front_steering_angle # virtual front steering angle
float64 rear_steering_angle # virtual rear steering angle
```

When multiple algorithms send control commands, a command multiplexer is required to establish
priority between them.
In our provided example, both the teleoperation node (`/robot/base/teleop`) and the path-following
(`/robot/path_following`) node send commands to the controller through the multiplexer node
(`/robot/base/cmd_mux`).
As shown in the [configuration file](robot_configuration) of these nodes, the teleoperation node has
a priority of 100, while the path-following node has a priority of 10. This means that teleoperation
commands will take precedence over path-following commands.

![base_control](media/base_control_graph.jpg)

The multiplexer operates by subscribing and unsubscribing topics through the services
`/robot/base/cmd_mux/subscribe` and `/robot/base/cmd_mux/unsubscribe`.
For instance, if you have an additional command node called `robot/foo` that publishes on
`/robot/foo/cmd_two_axle_steering` topic, you can make the multiplexer listen to this new command by
calling the `subscribe` service as shown below:

```bash
docker compose run --rm bash
ros2 service call /robot/base/cmd_mux/unsubscribe romea_cmd_mux_msgs/msg/unsubscribe
ros2 service call /robot/base/cmd_mux/subscribe romea_cmd_mux_msgs/srv/Subscribe "{topic: /foo/cmd_two_axle_sterring, priority: 50, timeout: 0.1}"
ros2 node info /robot/base/cmd_mux
exit
```

In this configuration, the multiplexer will now listen to `/foo/cmd_two_axle_steering` (as seen
below), with a priority higher than the path-following commands but lower than the teleoperation
commands.

```bash
/robot/base/cmd_mux
  Subscribers:
    /clock: rosgraph_msgs/msg/Clock
    /foo/cmd_two_axle_sterring: romea_mobile_base_msgs/msg/TwoAxleSteeringCommand
    /parameter_events: rcl_interfaces/msg/ParameterEvent
    /robot/base/teleop/cmd_two_axle_steering: romea_mobile_base_msgs/msg/TwoAxleSteeringCommand
    /robot/path_following/cmd_two_axle_steering: romea_mobile_base_msgs/msg/TwoAxleSteeringCommand
  Publishers:
    /diagnostics: diagnostic_msgs/msg/DiagnosticArray
    /parameter_events: rcl_interfaces/msg/ParameterEvent
    /robot/base/controller/cmd_two_axle_steering: romea_mobile_base_msgs/msg/TwoAxleSteeringCommand
    /rosout: rcl_interfaces/msg/Log
  Service Servers:
    /robot/base/cmd_mux/describe_parameters: rcl_interfaces/srv/DescribeParameters
    /robot/base/cmd_mux/get_parameter_types: rcl_interfaces/srv/GetParameterTypes
    /robot/base/cmd_mux/get_parameters: rcl_interfaces/srv/GetParameters
    /robot/base/cmd_mux/list_parameters: rcl_interfaces/srv/ListParameters
    /robot/base/cmd_mux/set_parameters: rcl_interfaces/srv/SetParameters
    /robot/base/cmd_mux/set_parameters_atomically: rcl_interfaces/srv/SetParametersAtomically
    /robot/base/cmd_mux/subscribe: romea_cmd_mux_msgs/srv/Subscribe
    /robot/base/cmd_mux/unsubscribe: romea_cmd_mux_msgs/srv/Unsubscribe
  Service Clients:

  Action Servers:

  Action Clients: 
```
