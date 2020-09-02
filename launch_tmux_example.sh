#!/bin/bash
#
# tests out the listener node

tmux new-window -tDebug -n "rosdebug"
tmux split-window -b -p 60 -v 'roslaunch latency_testing listener.launch'
tmux select-window -t rosdebug

sleep 2
tmux select-pane -t 3
#tmux split-window -b -v 'rosrun  latency_testing latency_testing_testnode __name:=node1'
tmux split-window -b  -v 'rosrun  latency_testing latency_testing_testnode __name:=node1'
#tmux split-window -b -v "rostopic pub -r 1 /node1/testnode_read  geometry_msgs/PoseStamped '{header: auto, pose: { position: [1,2,3]} }'"
sleep 1
tmux select-pane -t 4
tmux send-keys "rostopic pub -r 1 /node1/testnode_read  geometry_msgs/PoseStamped '{header: auto, pose: { position: [1,2,3]} }'" Enter
