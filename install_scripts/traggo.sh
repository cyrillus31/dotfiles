#!/bin/bash

sudo docker run -p localhost:3030:3030 -v /opt/traggo/data:/opt/traggo/data traggo/server:latest -d
