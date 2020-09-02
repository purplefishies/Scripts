#!/usr/bin/env python

# Converts the IMU to unity
#
import rosbag

with rosbag.Bag('output.bag', 'w') as outbag:
    for topic, msg, t in rosbag.Bag('IMU_other.bag').read_messages():
        if topic == "/dji_sdk/imu":
            msg.orientation.x = 0
            msg.orientation.y = 0
            msg.orientation.z = 0
            msg.orientation.w = 1
            outbag.write(topic, msg)




            
