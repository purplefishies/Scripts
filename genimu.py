#!/usr/bin/env python

import rospy
from std_msgs.msg import String
from sensor_msgs.msg import Imu
from geometry_msgs.msg import Quaternion
import argparse

def process_args():
    parser = argparse.ArgumentParser(description="An Imu generator")
    parser.add_argument("-i", "--imu", help="IMU  to publish", action='store',dest='imu',type=float, nargs='*',default=[0,0,0,1] )
    parser.add_argument("-r", "--rate",help="Rate to publish imu",default=10,type=int,)
    parser.add_argument("-t", "--topic",help="Topic to publish on ",type=str,default="/dji_sdk/imu")
    
    args  = parser.parse_args()
    
    return args



def talker(args):
    pub = rospy.Publisher(args.topic, Imu, queue_size=10)
    rospy.init_node('talker', anonymous=True)
    rate = rospy.Rate(args.rate) # 10hz
    while not rospy.is_shutdown():
        msg = Imu()
        msg.orientation = Quaternion(0,0,0,1)
        msg.header.stamp = rospy.get_rostime()
        pub.publish(msg)
        rate.sleep()

if __name__ == '__main__':
    args = process_args()

    try:
        talker(args)
    except rospy.ROSInterruptException:
        pass


