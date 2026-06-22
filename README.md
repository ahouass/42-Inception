# inception

Every running container on a Docker node has a runc instance managing it.

the higher-level runtime is called containerd. containerd does a lot more than runc.
It manages the entire lifecycle of a container, including pulling images, creating network interfaces, and managing lower-level runc instances.

the Docker daemon (dockerd) sits above containerd and performs higher-level tasks such as; exposing the
Docker remote API, managing images, managing volumes, managing networks, and more...
A major job of the Docker daemon is to provide an easy-to-use standard interface that abstracts the lower levels.

Docker Desktop is a packaged product from Docker, Inc. It runs on 64-bit versions of Windows 10 and Mac, and it’s easy to download and install.

• the Opsperspective
• the Devperspective

In the Ops Perspective section, we’ll download an image, start a new container, log in to the new container, run a command inside of it, and then destroy it.
In the Dev Perspective section, we’ll focus more on the app. We’ll clone some app-code from GitHub, inspect a Dockerfile, containerize the app, run it as a container.

# The Ops Perspective

When you install Docker, you get two major components:

• theDockerclient
• theDockerdaemon(sometimescalledthe“Dockerengine”)

the daemon implements the runtime, API and everything else required to run Docker.
In a default Linux installation, the client talks to the daemon via a local IPC/Unix socket at /var/run/docker.sock.

# Images

It’s useful to think of a Docker image as an object that contains an OS filesystem, an application, and all application dependencies.
If you work in operations, it’s like a virtual machine template.
A virtual machine template is essentially a stopped virtual machine.
In the Docker world, an image is effectively a stopped container.
If you’re a developer, you can think of an image as a class.

Run the docker image ls command on your Docker host.

$ docker image ls
REPOSITORY    TAG        IMAGE ID       CREATED       SIZE

$ docker image pull ubuntu:latest
latest: Pulling from library/ubuntu 50aff78429b1: Pull complete
f6d82e297bce: Pull complete
275abb2c8a6f: Pull complete
9f15a39356d6: Pull complete
fc0342a94c89: Pull complete
Digest: sha256:fbaf303...c0ea5d1212
Status: Downloaded newer image for ubuntu:latest

$ docker images
REPOSITORY TAG IMAGE ID CREATED SIZE
ubuntu latest 1d622ef86b13 16 hours ago 73.9MB

# Containers
Now that we have an image pulled locally, we can use the docker container run command to launch a container
from it.

$ docker container run -it ubuntu:latest /bin/bash
root@6dc20d508db0:/#

-it flags switch your shell into the terminal of the container — you are literally
inside of the new container!

You can attach your shell to the terminal of a running container with the docker container exec command.

$ docker container exec -it <container name> bash
root@6dc20d508db0:/#

$ docker container ls
CONTAINER ID IMAGE          COMMAND         CREATED       STATUS            NAMES
6dc20d508db0 ubuntu:latest  "/bin/bash"     9 mins        Up 9 min          vigilant_borg

$ docker container stop vigilant_borg
vigilant_borg

$ docker container rm vigilant_borg
vigilant_borg

$ docker container ls -a
CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES


# Images

Docker images are typically small because they contain only the code and dependencies needed to run a single application or service.

$ docker image ls

REPOSITORY TAG IMAGE ID CREATED SIZE

$ docker image pull redis:latest

Image registries contain one or more image repositories. In turn, image repositories contain one or more images.

# Pulling images from an official repository :
$ docker image pull <repository>:<tag>
$ docker image pull mongo:4.2.6
$ docker image pull busybox:latest

First, if you do not specify an image tag after the repository name, Docker will assume you are referring to the
image tagged as latest. If the repository doesn’t have an image tagged as latest the command will fail.

Pulling images from an unofficial repository is essentially the same — you just need to prepend the repository
name with a Docker Hub username or organization name.

$ docker image pull nigelpoulton/tu-demo:v2
//This will pull the image tagged as `v2`
//from the `tu-demo` repository within the `nigelpoulton` namespace

# Filtering the output of docker image ls

$ docker image ls --filter dangling=true
Docker currently supports the following filters:
• dangling: Accepts true or false, and returns only dangling images (true), or non-dangling images (false).
• before: Requires an image name or ID as argument, and returns all images created before it.
• since: Same as above, but returns images created after the specified image.
• label: Filters images based on the presence of a label or label and value. the docker image ls command
does not display labels in its output.


# Searching Docker Hub from the CLI

$ docker search alpine

# image Layers
To see the layers of an image is to inspect the image with the docker image inspect command.

$ docker image inspect ubuntu:latest

[
    {
        "Id": "sha256:bd3d4369ae.......fa2645f5699037d7d8c6b415a10",
        "RepoTags": [
            "ubuntu:latest"
        <Snip>
        "RootFS": {
            "Type": "layers",
            "Layers": [
                "sha256:c8a75145fc...894129005e461a43875a094b93412",
                "sha256:c6f2b330b6...7214ed6aac305dd03f70b95cdc610",
                "sha256:055757a193...3a9565d78962c7f368d5ac5984998",
                "sha256:4837348061...12695f548406ea77feb5074e195e3",
                "sha256:0cad5e07ba...4bae4cfc66b376265e16c32a0aae9"
            ]
        }
    }
]


# Sharing image layers

Docker images can share layers, which saves disk space and improves performance. When pulling several tagged images from the same repository (using docker image pull -a), Docker recognizes layers it already has locally and outputs "Already exists" instead of downloading them again.

# Deleting Images

$ docker image rm 02674b9cb179

If the image you are trying to delete is in use by a running container you will not be able to delete it.
Stop and delete any containers before trying the delete operation again.

$ docker image ls -q
bd3d4369aebc
4e38e38c8ce0


# Containers

A container is the runtime instance of an image.

$ docker container run -it ubuntu /bin/bash
the -it flags will connect your current terminal window to the container’s shell.

$ docker container stop
$ docker container start

# Starting a simple container

$ docker container run -it ubuntu:latest /bin/bash

the -it flags make the container interactive and
attach it to your terminal. ubuntu:latest

When you hit Return, the Docker client packaged up the command and POSTed it to the API server running on the Docker daemon.
the Docker daemon accepted the command and searched the Docker host’s local image repository to see if it already had a copy of the requested image.
Once the image was pulled, the daemon instructed containerd and runc to create and start the container.

# Container processes

When we started the Ubuntu container in the previous section, we told it to run the Bash shell (/bin/bash).
This makes the Bash shell the one and only process running inside of the container.

If you’re logged on to the container and type exit, you’ll terminate the Bash process and the container will exit (terminate).
this is because a container cannot exist without its designated main process.
This is true of Linux and Windows containers — killing the main process in the container will kill the container.

Press Ctrl-PQ to exit the container without terminating its main process.
Doing this will place you ba in the shell of your Docker host and leave the container running in the background.
You can use the docker container ls command to view the list of running containers on your system.

It’s important to understand that this container is still running and you can re-attach your terminal to it with the docker container exec command.

$ docker container exec -it 50949b614477 bash
root@50949b614477:/#

As you can see, the shell prompt has changed bach to the container.
If you run the ps -elf command again you will now see two Bash or PowerShell processes.
This is because the docker container exec command created a new Bash or PowerShell process and attached to that.
this means typing exit in this shell will not terminate the container, because the original Bash or PowerShell process will continue running.
Type exit to leave the container and verify it’s still running with a docker container ls. It will still be running.
If you are following along with the examples,
you should stop and delete the container with the following two commands (you will need to substitute the ID of your container).

$ docker container stop 50949b614477
50949b614477

$ docker container rm 50949b614477
50949b614477


# Containers - The commands

• docker container run.
• Ctrl-PQ will detach your shell from the terminal of a container and leave the container running (UP) in the background.
• docker container ls
• docker container exec runs a new process inside of a running container.
• docker container stop
• docker container start
• docker container rm
• docker container inspect


# What is Containerizing?

It’s the process of taking an application and its dependencies and packaging it into a container image so it can run anywhere.
High-level flow: App code + Dockerfile → docker image build → (optional) Push to registry → docker container run.

The Example (Node.js App):

Code: Cloned from github.com/nigelpoulton/psweb.

Dockerfile breakdown (creates a Linux image based on alpine):

FROM alpine – Base layer.

LABEL – Adds maintainer metadata.

RUN apk add nodejs – Installs Node.js (creates a layer).

COPY . /src – Copies app code into the image (creates a layer).

WORKDIR /src – Sets working directory (metadata, not a layer).

RUN npm install – Installs dependencies (creates a layer).

EXPOSE 8080 – Documents the network port (metadata).

ENTRYPOINT ["node", "./app.js"] – Sets the default command (metadata).

Build & Run:

docker image build -t web:latest .                          # Build the image
docker container run -d --name c1 -p 80:8080 web:latest     # Run in background, mapping host port 80 to container port 8080
Push to Docker Hub: Tag with your Docker ID (docker image tag web:latest yourid/web:latest) and docker image push.


# Docker Compose

Docker Compose, which deploys and manages multi-container applications on Doer nodes running in single-engine mode.

docker-compose up is the most common way to bring up a Compose app (we’re calling a multi-container app defined in a Compose file a Compose app). It builds or pulls all required images, creates all required networks and volumes, and starts all required containers.

By default, docker-compose up expects the name of the Compose file to docker-compose.yml. If your Compose file has a different name, you need to specify it with the -f flag. the following example will deploy an application from a Compose file called prod-equus-bass.yml

$ docker-compose -f prod-equus-bass.yml up

##############################

version: "3.8" services:
web-fe: build: .
command: python app.py ports:
- target: 5000 published: 5000
networks:
- counter-net
volumes:
- type: volume
source: counter-vol
        target: /code
  redis:
    image: "redis:alpine"
    networks:
counter-net:
    networks:
        counter-net:
    volumes:
        counter-vol:

##############################

We’ll skip through the basics of the file before taking a closer look. e first thing to note is that the file has 4 top-level keys:
• version
• services
• networks
• volumes

Other top-level keys exist, su as secrets and configs, but we’re not looking at those right now.

• build: . this tells Docker to build a new image using the instructions in the Dockerfile in the current directory (.).
the newly built image will be used in a later step to create the container for this service.

• command: python app.py this tells Docker to run a Python app called app.py as the main app in the
container. the app.py file must exist in the image, and the image must contain Python. the Dockerfile
takes care of both of these requirements.

• ports: Tells Docker to map port 5000 inside the container (-target) to port 5000 on the host (published).
this means that traffic sent to the Docker host on port 5000 will be directed to port 5000 on the container.
the app inside the container listens on port 5000.

• networks: Tells Docker which network to attach the service’s container to. the network should already
exist, or be defined in the networks top-level key. If it’s an overlay network, it will need to have the attachable flag so that standalone containers can be attached to it (Compose deploys standalone containers instead of Docker Services).

• volumes: Tells Docker to mount the counter-vol volume (source:) to /code (target:) inside the container. the counter-vol volume needs to already exist,
or be defined in the volumes top-level key at the bottom of the file.

# DOCKER NETWORK

when you run a container , it creates a virtual interface network (virtual adapter) on the host :

ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 7c:ed:8d:6c:56:d6 brd ff:ff:ff:ff:ff:ff
4: enP9398s1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master eth0 state UP mode DEFAULT group default qlen 1000
    link/ether 7c:ed:8d:6c:56:d6 brd ff:ff:ff:ff:ff:ff
    altname enP9398p0s2
5: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 02:42:8a:d7:64:bc brd ff:ff:ff:ff:ff:ff
6: veth36f4396@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP mode DEFAULT group default                     #container1
    link/ether 5e:c0:16:fc:ed:92 brd ff:ff:ff:ff:ff:ff link-netnsid 0
7: vetha1b6efa@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP mode DEFAULT group default                     #container2
    link/ether 0e:b0:e8:15:c4:12 brd ff:ff:ff:ff:ff:ff link-netnsid 1
8: veth88c41f7@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP mode DEFAULT group default                     #container3
    link/ether ce:e8:d9:67:27:be brd ff:ff:ff:ff:ff:ff link-netnsid 2



and inside each container :

/ # ifconfig

eth0    Link encap:Ethernet  HWaddr EE:FA:E7:91:A9:4F                         #virtual adapter
        inet addr:172.17.0.4  Bcast:172.17.255.255  Mask:255.255.0.0
        UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
        RX packets:13 errors:0 dropped:0 overruns:0 frame:0
        TX packets:3 errors:0 dropped:0 overruns:0 carrier:0
        collisions:0 txqueuelen:0 
        RX bytes:1006 (1006.0 B)  TX bytes:126 (126.0 B)

lo      Link encap:Local Loopback                                             #loopback adapter
        inet addr:127.0.0.1  Mask:255.0.0.0
        inet6 addr: ::1/128 Scope:Host
        UP LOOPBACK RUNNING  MTU:65536  Metric:1
        RX packets:0 errors:0 dropped:0 overruns:0 frame:0
        TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
        collisions:0 txqueuelen:1000 
        RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)


$docker network ls

NETWORK ID     NAME      DRIVER    SCOPE
273fa9ef9a8c   bridge    bridge    local
7c9ce3401904   host      host      local
a56232c7d49d   none      null      local

1. bridge (default network)
Driver: bridge

Purpose: The default network for containers if you don't specify one

Scope: Local (only on this Docker host)

Characteristics:

Containers on this network can communicate with each other using IP addresses

They can not resolve each other's names automatically (unless you use --link which is deprecated)

Containers get IPs like 172.17.0.x

You can expose ports with -p to the host

Example:

bash
```
docker run -d --name web nginx
# This container is on the 'bridge' network
docker run -it alpine sh
# Another container on the bridge network
# They can ping each other by IP but not by name
```

2. host (host network)
Driver: host

Purpose: Removes network isolation, container uses the host's network directly

Scope: Local

Characteristics:

Container shares the host's network stack

No IP mapping needed - ports are exposed directly on the host

No network isolation (less secure)

Better performance (no NAT)

Example:

bash
```
docker run -d --network host nginx
# Nginx will be accessible on localhost:80 directly
# No port mapping needed with -p
Use when: You need maximum performance or your app needs to bind to specific host ports.
```

3. none (null network)
Driver: null

Purpose: Complete network isolation

Scope: Local

Characteristics:

Container has no network interfaces (only loopback 127.0.0.1)

Cannot access external networks

Maximum security isolation

No inbound/outbound network traffic

Example:

bash
```
docker run -d --network none alpine sleep infinity
# Container cannot ping anything or be pinged
# Only localhost works
```

==> Create an isolated network , only containers with each other , can't connect to the internet :
$docker network create --internal mynet <container_name>

if you want to ping a container from inside another container using its name :
--add-host <container_name>:<container_ip>

==> Create a NETWORK :
$docker network create <network_name>

==> Connect a container to a network :
$docker network connect <network_name> <container_name>

==> Disconnect a container to a network :
$docker network disconnect <network_name> <container_name>

# DOCKER STORAGE

































































































































