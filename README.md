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
In the Dev Perspective section, we’ll focus more on the app. We’ll clone some app-code from GitHub, inspect a Doerfile, containerize the app, run it as a container.

The Ops Perspective
When you install Doer, you get two major components:
• theDockerclient
• theDockerdaemon(sometimescalledthe“Doerengine”)
the daemon implements the runtime, API and everything else required to run Doer.
In a default Linux installation, the client talks to the daemon via a local IPC/Unix soet at /var/run/docker.sock.

Images
It’s useful to think of a Doer image as an object that contains an OS filesystem, an application, and all application dependencies. If you work in operations, it’s like a virtual maine template. A virtual maine template is essentially a stopped virtual maine. In the Doer world, an image is effectively a stopped container. If you’re a developer, you can think of an image as a class.
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

