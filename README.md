## P4runtime in action!

# Table of Contents

1. [Setup](#1-setup)
2. [Exercise overview](#2-exercise-overview)
2. [What is P4Runtime](#3-what-is-p4runtime)
2. [Action](#4-action)

### 1. Setup

For this tutorial you have access to three dockerized tools to work with:

* P4 compiler ([source](https://github.com/p4lang/p4c))
* P4Runtime-enabled Mininet ([source](https://github.com/opennetworkinglab/p4mn-docker))
* IPython shell for P4Runtime ([source](https://github.com/p4lang/p4runtime-shell))

We use Mininet to create simple topology with 2 hosts and a switch. The P4Runtime Shell is used as the controller role. 
It uses gRPC to connect the controller and the switch. 
After P4Runtime Shell starts, it will install specified P4 program to the switch through the gRPC connection.

![network](blobs/network-diagram.png)

#### 1.1. Compile P4 switch definition

Start P4 compiler shell:

```
docker-compose run compiler
```

This docker has attached a `./configs` directory as its volume. 
You can find there necessary dependencies for network configuration. 
Compile `setup_switch.p4`:

```
cd configs

p4c --target bmv2 --arch v1model --p4runtime-files p4info.txt setup_switch.p4 
```

As an output, it will generate few files with definition of our testing switch. 
Later, we will launch the P4 Runtime Shell, using the p4info.txt and setup_switch.json files generated.

#### 1.2. Launch the Mininet Environment

Start a Mininet environment that supports the P4 Runtime in docker environment. 
Note that at boot time, the `--arp` and `--mac` options allow you to do things like ping tests without ARP processing. 
Below command will create a simple topology for our exercise:

```
docker-compose run mininet --arp --topo single,2 --mac
```

After successful creation, docker will switch into an interactive mode, you can check built topology and host configs by executing:

```
mininet> net

mininet> h1 ifconfig h1-eth0
```

Make sure to leave that mininet server running in the background.

#### 1.3. Connect P4 Runtime Shell to Mininet

Start P4 Runtime Shell. 
Make sure to connect properly to your mininet server running in the background from step *1.2*. 
You can find the server id by running `sh ifconfig` in the mininet terminal:

```
docker-compose run shell --grpc-addr <MININET SERVER IP>:50001 --device-id 1 --election-id 0,1 --config /tmp/configs/p4info.txt,/tmp/configs/setup_switch.json
```

Let's display the preset tables (created in `./configs/setup_swish.p4` file) to confirm that it works:

```
P4Runtime sh >>> tables 

P4Runtime sh >>> tables["MyIngress.ether_addr_table"] 
```

Congratulations, your setup is finished.

#### 1.4 Automated setup

For future works, to make your life easier, you can use this oneliners to automate the setup of above steps:

```
docker-compose -f docker-compose.automated.yml run mininet

docker-compose -f docker-compose.automated.yml run shell
```

Confirm the results by running:

```
P4Runtime sh >>> tables 

P4Runtime sh >>> tables["MyIngress.ether_addr_table"] 
```

### 2. Exercise overview

The exercise's goal is to enable connectivity between two hosts via a P4 runtime table definition. 
After setting up a based mininet network, switch tables are empty, which blocks all data request coming in and out from hosts. 
With a use of P4 Runtime interactive shell we will try to update tables definitions to allow traffic between hosts. 
This exercise is a simple use case to understand how to interact with switched with a help of P4 runtime api.

### 3. What is P4Runtime?

It is a control protocol for P4-defined data planes. 
It simplifies management of a P4 switch `Data plane`, which decreases necessary configuration and dependencies for traffic control. 
The P4Runtime API is a control plane specification for controlling the data plane elements of a device defined or described by a P4 program. 
Below figure represents the P4Runtime Architecture. The device or target to be controlled is at the bottom, and one or more controllers is shown at the top. 
A role defines a grouping of P4 entities.

![P4 runtime architecture](blobs/p4runtime-architecture.svg)

The P4Runtime API defines the messages and semantics of the interface between the client(s) and the server. 
The API is specified by the p4runtime.proto Protobuf file.
It is the responsibility of target implementers to instrument the server.
The controller can access the P4 entities which are declared in the P4Info metadata. 
The P4Info structure is defined by p4info.proto, another Protobuf file available as part of the standard.

We are recommending to watch this short explanation of P4 and P4 runtime workflow. 
It gives great understanding of concepts behind the API and helps to go through the prepared exercises without doubts:

[![youtube video](https://img.youtube.com/vi/KRx92qSLgo4/0.jpg)](https://www.youtube.com/watch?v=KRx92qSLgo4)

### 4. Action!

Let's get hands dirty and set up our first switch table. 
