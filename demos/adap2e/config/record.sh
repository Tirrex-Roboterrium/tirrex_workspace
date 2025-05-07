#!/bin/bash
cd -- $(dirname "$ROS_LOG_DIR")
ros2 bag record \
  -e "/tf|.*/vehicle_controller/odom|.*/joint_states|.*/imu/data|.*/imu|.*/nmea_sentence|.*/fix|.*/filtered_odom|.*/joy|.*/battery_status|.*/points"
  # -e ".*/odom[^/]*" \
  # -e ".*/odometry" \
  # -e ".*/joint_states" \
  # -e ".*/imu/data" \
  # -e ".*/nmea_sentence" \
  # -e ".*/fix" \
  # -e ".*/filtered_odom" \
  # -e ".*/joy" \
  # -e ".*/battery_status"
