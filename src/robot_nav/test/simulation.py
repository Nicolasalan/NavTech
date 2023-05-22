#! /usr/bin/env python3

from std_srvs.srv import Empty
from gazebo_msgs.msg import ModelState 

import unittest
import rospy
import rostest

import os

PKG = 'robot_nav'
NAME = 'simulation'

print("\033[92mSimulation Unit Tests\033[0m")

class TestROS(unittest.TestCase):

     def setUp(self):
          rospy.init_node('test_sim_node', anonymous=True) 

          # Create service proxies
          self.reset = rospy.ServiceProxy('gazebo/reset_simulation', Empty)
          self.reset_proxy = rospy.ServiceProxy("/gazebo/reset_world", Empty)
          self.pause = rospy.ServiceProxy("/gazebo/pause_physics", Empty)
          self.unpause = rospy.ServiceProxy("/gazebo/unpause_physics", Empty)
          self.set_state = rospy.Publisher("gazebo/set_model_state", ModelState, queue_size=10)

     def test_reset_simulation(self):
          # Call the reset simulation service
          success = self.reset.call()
          # Check that the service call was successful
          self.assertTrue(success, "Failed to reset simulation")
     
     def test_reset_world(self):
          # Call the reset simulation service
          success = self.reset_proxy.call()
          # Check that the service call was successful
          self.assertTrue(success, "Failed to reset world")
        
     def test_pause_physics(self):
          # Call the pause physics service
          success = self.pause.call()
          # Check that the service call was successful
          self.assertTrue(success, "Failed to pause physics")
          
     def test_unpause_physics(self):
          # Call the unpause physics service 
          success = self.unpause.call()
          # Check that the service call was successful
          self.assertTrue(success, "Failed to unpause physics")

if __name__ == '__main__':
    rostest.rosrun(PKG, NAME, TestROS)