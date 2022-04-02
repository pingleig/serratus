#!/bin/bash
set -eu
ssh -i ~/Downloads/pem/serratus.pem -Nf -L 3000:localhost:3000 -L 9090:localhost:9090 ec2-user@ec2-3-215-88-150.compute-1.amazonaws.com
ssh -i ~/Downloads/pem/serratus.pem -Nf -L 8000:localhost:8000 -L 5432:localhost:5432 ec2-user@ec2-52-7-226-160.compute-1.amazonaws.com
echo "Tunnels created:"
echo "    localhost:3000 = grafana"
echo "    localhost:9090 = prometheus"
echo "    localhost:5432 = postgres"
echo "    localhost:8000 = scheduler"