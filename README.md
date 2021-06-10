## P4runtime in action!

### Setup

For this tutorial you have access to three tools to work with:

* P4 compiler ([source](https://github.com/p4lang/p4c))
* P4Runtime-enabled Mininet ([source](https://github.com/opennetworkinglab/p4mn-docker))
* IPython shell for P4Runtime ([source](https://github.com/p4lang/p4runtime-shell))

We use Mininet to create simple topology with 2 hosts and a switch. The P4Runtime Shell is used as the controller role. It uses gRPC to connect the controller and the switch. After P4Runtime Shell starts, it will install specified P4 program to the switch through the gRPC connection.

![network](blobs/network.png)

#### 1. Compile P4 switch definition

Start P4 compiler shell:

```
docker-compose run compiler bash
```

This docker has attached a `./configs` directory as its volume. You can find there necessary dependencies for network configuration. Compile `setup_switch.p4`:

```
cd configs

p4c --target bmv2 --arch v1model --p4runtime-files p4info.txt setup_switch.p4 
```

As an output, it will generate few files with definition of our testing switch. Later, we will launch the P4 Runtime Shell, using the p4info.txt and setup_switch.json files generated.

#### 2. Launching the Mininet Environment

Start a Mininet environment that supports the P4 Runtime in docker environment. Note that at boot time, the `--arp` and `--mac` options allow you to do things like ping tests without ARP processing. Below command will create a simple topology for our exercise:

```
docker-compose run mininet --arp --topo single,2 --mac
```

After successful creation, docker will switch into an interactive mode, you can check built topology and host configs by executing:

```
mininet> net

mininet> h1 ifconfig h1-eth0
```

#### 3. Connecting P4 Runtime Shell to Mininet

Start P4 Runtime Shell. Make sure to connect properly to your mininet server running in the background from step #2. You can find the server id by running `sh ifconfig` in the mininet terminal:

```
docker-compose run shell --grpc-addr <MININET SERVER IP>:50001 --device-id 1 --election-id 0,1 --config /tmp/configs/p4info.txt,/tmp/configs/setup_switch.json
```

Let's display the preset tables (created in `./configs/setup_swish.p4` file) to confirm that it works:

```
P4Runtime sh >>> tables 

P4Runtime sh >>> tables["MyIngress.ether_addr_table"] 
```

Congratulations, your setup is finished.