# inception


Every running container on a Docker node has a runc instance managing it.

the higher-level runtime is called containerd. containerd does a lot more than runc. It manages the entire lifecycle of a container, including pulling images, creating network interfaces, and managing lower-level runc instances.

the Docker daemon (dockerd) sits above containerd and performs higher-level tasks such as; exposing the
Docker remote API, managing images, managing volumes, managing networks, and more...
A major job of the Docker daemon is to provide an easy-to-use standard interface that abstracts the lower levels.

Docker Desktop is a packaged product from Docker, Inc. It runs on 64-bit versions of Windows 10 and Mac, and it’s easy to download and install.

• the Opsperspective
• the Devperspective
In the Ops Perspective section, we’ll download an image, start a new container, log in to the new container, run a command inside of it, and then destroy it.
In the Dev Perspective section, we’ll focus more on the app. We’ll clone some app-code from GitHub, inspect a Dockerfile, containerize the app, run it as a container.

# The Ops Perspective
When you install Doer, you get two major components:
• theDockerclient
• theDockerdaemon(sometimescalledthe“Dockerengine”)
the daemon implements the runtime, API and everything else required to run Doer.
In a default Linux installation, the client talks to the daemon via a local IPC/Unix soet at /var/run/docker.sock.

# Images
It’s useful to think of a Docker image as an object that contains an OS filesystem, an application, and all application dependencies. If you work in operations, it’s like a virtual maine template. A virtual maine template is essentially a stopped virtual maine. In the Doer world, an image is effectively a stopped container. If you’re a developer, you can think of an image as a class.
Run the docker image ls command on your Doer host. $ docker image ls
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
Now that we have an image pulled locally, we can use the docker container run command to laun a container
from it.

$ docker container run -it ubuntu:latest /bin/bash
root@6dc20d508db0:/#

-it flags swit your shell into the terminal of the container — you are literally
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

First, if you do not specify an image tag aer the repository name, Doer will assume you are referring to the
image tagged as latest. If the repository doesn’t have an image tagged as latest the command will fail.

Pulling images from an unofficial repository is essentially the same — you just need to prepend the repository
name with a Doer Hub username or organization name.

$ docker image pull nigelpoulton/tu-demo:v2
//This will pull the image tagged as `v2`
//from the `tu-demo` repository within the `nigelpoulton` namespace

# Filtering the output of docker image ls

$ docker image ls --filter dangling=true
Docker currently supports the following filters:
• dangling: Accepts true or false, and returns only dangling images (true), or non-dangling images (false).
• before: Requires an image name or ID as argument, and returns all images created before it.
• since: Same as above, but returns images created aer the specified image.
• label: Filters images based on the presence of a label or label and value. e docker image ls command
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











































































































