# Challenge 1: generate the best path

The aim of this challenge is to generate a robot path that passes through all the predefined
waypoints and cover the different fields in the shortest possible time.
There is a start and finish point, as well as several other unordered waypoints, so you have to find
an order that minimizes the travel time.
You also have to take into account the initial pose of the robot in the trajectory because the robot
does not spawn on the start point but some meters before.
Each field that you have to cover are defined using 4 waypoints that corresponds to the first and
the last row in the field.
A map of the static obstacles is provided to simplify path calculation.
We evaluate the result by checking the validated waypoints, the covered fields and by measuring the
time between the first and last validation of the waypoints.

### The path format

The generated path must be in the [TIARA trajectory
format](https://github.com/Romea/romea-ros-path-tools/blob/main/doc/tiara_format.md).
Some tools are provided in the [`romea_path_tools`](https://github.com/Romea/romea-ros-path-tools)
to visualize, convert or generate paths in this format.


### The provided list of waypoints and fields

All data are supplied as a JSON file that contains:

* the start point
* the end point
* the waypoints (unordered)
* the fields (that contains 4 waypoints)

Here is an example of the provided JSON file:

```json
{
  "origin": [ 46.339159, 3.433923, 279.18 ],
  "start": [ 46.340282, 3.43516, 280.01, 95.605, 125.406, 0.829 ],
  "end": [ 46.340240, 3.434987, 280.12, 81.974, 120.239, 0.939 ],
  "waypoints": [
    [ 46.340372, 3.434846, 280.34, 71.11, 134.93, 1.15 ],
    [ 46.340449, 3.435779, 279.67, 142.92, 143.50, 0.48 ],
    [ 46.340442, 3.434945, 280.35, 78.75, 142.64, 1.16 ],
  ],
  "fields": [
    {
      "type": "vineyard",
      "row_distance": 2.0,
      "points": [
        [ 46.340254, 3.435572, 279.64, 127.00, 121.76, 0.45 ],
        [ 46.340206, 3.435390, 279.77, 112.97, 116.46, 0.59 ],
        [ 46.340156, 3.435417, 279.65, 115.09, 110.85, 0.47 ],
        [ 46.340203, 3.435600, 279.52, 129.12, 116.15, 0.34 ]
      ]
    },
    {
      "type": "crops",
      "row_distance": 1.5,
      "points": [
        [ 46.340899, 3.435863, 280.30, 149.39, 193.53, 1.11 ],
        [ 46.340772, 3.435929, 280.06, 154.45, 179.40, 0.88 ],
        [ 46.340787, 3.435983, 280.06, 158.63, 181.07, 0.87 ],
        [ 46.340914, 3.435917, 280.29, 153.57, 195.20, 1.11 ]
      ]
    }
  ]
}
```

Description of the fields of the JSON file:
* __`origin`__: the `[latitude, longitude, height]` (in WGS84) of the (0,0,0) point in the local
East-North-Up (ENU) coordinates system used by the gazebo simulator and the localization node (its
frame ID is `map`)
* __`start`__: the first waypoint of the trajectory and the point used to start the timer
* __`end`__: the last waypoint of the trajectory and the point used to stop the timer
* __`waypoints`__: the unordered list of waypoints that the robot have to pass through
* __`fields`__: the list of fields that the robot have to cover

A waypoint is a list of 6 columns: `[latitude, longitude, height, x, y, z]` that correspond to the
WGS84 coordinates (in degrees) and the ENU coordinates (in meters, in the `map` frame) of the point.

A element of `fields` contains the following elements:
* __`type`__: this value can be `vineyard` or `crops`
* __`row_distance`__: the distance (in meters) between the rows to cover
* __`points`__: a list of 4 waypoints where the first 2 points correspond to the begining and the
end of the first row, and the last 2 points for begining and the end of the last one.

A first list of waypoints is available in the package `fira_hackathon_gazebo`:
[`data/challenge1_waypoints_01.json`](https://github.com/FiraHackathon/fira_hackathon_gazebo/blob/main/data/challenge1_waypoints_01.json).
The waypoints are also defined in a `.csv` file that contains less information but is easier to
parse.
There is also a `.geojson` file containing all the point data, and allows you to easily visualize
the points on online map such as [geojson.io](https://geojson.io/#map=17.58/46.340178/3.435183) but
it seems that there is a little offset between the simulated world and the real one.

The files provided are just examples used to develop the path generation program.

The first version of the file contains only the waypoints that the robot must pass through.
A second version including waypoints defining the boundaries of the working area will be provided to you shortly.
This next version will be provided with an explanation of the different elements constituting a waypoint.

The file used for evaluation will be different from the example here.


### The provided map of obstacles

The map of obstacles is supplied as a ROS
[OccupancyGrid](https://docs.ros2.org/foxy/api/nav_msgs/msg/OccupancyGrid.html) message.
It is published by a `map_server` node of the
[nav2_map_server](https://github.com/ros-planning/navigation2/blob/humble/nav2_map_server/README.md)
package.
The map is published in the `/map` topic when the node is activated and is also available on request
by using the `/map_server/map` service.

The map is also also available as YAML (`data/challenge1_map.yaml`) and PNG
(`data/challenge1_map.png`) files in the
[`fira_hackathon_gazebo`](https://github.com/FiraHackathon/fira_hackathon_gazebo/tree/main) package.


### The initial robot pose

The robot is spawned at a specific position and orientation in the world.
The generated path must take into account this pose and lead the robot to first waypoint.
This pose is published at runtime by the localization node in the
`/robot/localisation/filtered_odom` topic.
It is also available in the configuration file
[`cfg_chal1/robots/robot/base.yaml`](https://github.com/FiraHackathon/fira_hackathon_demo/blob/main/cfg_chal1/robots/robot/base.yaml)
of the [`fira_hackathon_demo`](https://github.com/FiraHackathon/fira_hackathon_demo) package.
It corresponds to the following values (it is an example):
```yaml
simulation:
  initial_xyz: [93.962, 117.368, 0.78]
  initial_rpy: [0.0, 0.0, 0.344]
```
where the `initial_xyz` corresponds to the position (in meters) in the `map` frame and `initial_rpy`
corresponds to the euler angles roll, pitch and yaw (in radian) of the robot orientation.


### The evaluation method

You can use any path following node or the default one at any speed.
The ranking of participants in this challenge will be calculated based on:
* The percentage of traversable surface area within the plot covered by the robot
* The number of waypoints validated
* The travel time between the first and last validation
* The number and time of collisions with crops

__For information:__
A waypoint is validated when the robot origin (the center of the rear axle) passes within 20 cm of
the waypoint.
The time limit is 15 minutes.
