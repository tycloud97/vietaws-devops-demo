#!/bin/bash
apt-get update
apt-get install -y ruby
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/releases/codedeploy-agent_1.0-1.1597_all.deb
mkdir codedeploy-agent_1.0-1.1597_ubuntu20
dpkg-deb -R codedeploy-agent_1.0-1.1597_all.deb codedeploy-agent_1.0-1.1597_ubuntu20
sed 's/2.0/2.7/' -i ./codedeploy-agent_1.0-1.1597_ubuntu20/DEBIAN/control
dpkg-deb -b codedeploy-agent_1.0-1.1597_ubuntu20
dpkg -i codedeploy-agent_1.0-1.1597_ubuntu20.deb
systemctl start codedeploy-agent
systemctl enable codedeploy-agent