```
██████╗ ███████╗██╗   ██╗██╗   ██╗██████╗      ██████╗ ██████╗ ███████╗███╗   ███╗ ██████╗ ███████╗
██╔══██╗██╔════╝██║   ██║██║   ██║██╔══██╗    ██╔════╝██╔═══██╗██╔════╝████╗ ████║██╔═══██╗██╔════╝
██████╔╝█████╗  ██║   ██║██║   ██║██████╔╝    ██║     ██║   ██║███████╗██╔████╔██║██║   ██║███████╗
██╔══██╗██╔══╝  ╚██╗ ██╔╝██║   ██║██╔═══╝     ██║     ██║   ██║╚════██║██║╚██╔╝██║██║   ██║╚════██║
██║  ██║███████╗ ╚████╔╝ ╚██████╔╝██║         ╚██████╗╚██████╔╝███████║██║ ╚═╝ ██║╚██████╔╝███████║
╚═╝  ╚═╝╚══════╝  ╚═══╝   ╚═════╝ ╚═╝          ╚═════╝ ╚═════╝ ╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚══════╝
```
# Initial Setup
# Before you start
This is intended to be a **technology demo** setup to run hardware accelerated content on AWS g5 NVIDIA A10G Tensor Core GPU Hardware accelerated instances https://aws.amazon.com/ec2/instance-types/g5/

# Requirements
These scripts must be run on a AWS EC2 g5 Nvidia A10 instance type (tested on g5.xlarge) running Ubuntu 20.04 (HVM).

# What is included?
Among the other packages these scripts will automagically install:
- Nvidia driver v470
- Nvidia CUDA v11.4
- Docker version 20.10.11, build dea9396
- Nvidia Container Toolkit
- GLX/Vulkan
- Apache Guacamole

# Installation
SSH into your EC2 box, and run the following:
```bash
git clone https://github.com/nrydevops/revup_cosmos.git
cd revup_cosmos/setup/
sudo su
source setup.sh
```
Keep in mind that:
- The initial setup installations will reboot the machine once done.

# RevUp COSMOS cloud desktop

MATE Desktop container designed for Kubernetes supporting OpenGL GLX and Vulkan for NVIDIA GPUs with WebRTC and HTML5, providing an open source remote cloud graphics or game streaming platform. Spawns its own fully isolated X Server instead of using the host X server, therefore not requiring `/tmp/.X11-unix` host sockets or host configuration.

# Launch COSMOS
```
cd revup_cosmos/cosmos_launch
```
```
docker run --gpus 1 -it --net=host -e TZ=UTC -e SIZEW=1920 -e SIZEH=1080 -e REFRESH=60 -e DPI=96 -e CDEPTH=24 -e VIDEO_PORT=DFP -e PASSWD=mypasswd -e WEBRTC_ENCODER=nvh264enc -e BASIC_AUTH_PASSWORD=mypasswd -p 8080:8080 ghcr.io/ehfd/nvidia-glx-desktop:latest
```
For Docker this will be sufficient (the container must only be used in unprivileged mode, use `--tmpfs /dev/shm:rw` for a slight performance improvement)
# Additional details

Container startup could take some time at first launch as it automatically installs NVIDIA drivers compatible with the host.

Wine, Winetricks, and PlayOnLinux are bundled by default. Comment out the section where it is installed within `Dockerfile` if the user wants to remove them from the container.

There are two web interfaces that can be chosen in this container, the first being the default [selkies-gstreamer](https://github.com/selkies-project/selkies-gstreamer) WebRTC HTML5 interface, and the second being the fallback [noVNC](https://github.com/novnc/noVNC) WebSocket HTML5 interface. The noVNC interface can be enabled by setting `NOVNC_ENABLE` to `true`. While the noVNC interface does not support audio forwarding, it can be useful for troubleshooting the selkies-gstreamer WebRTC interface or using this container with low bandwidth environments. When using the noVNC interface, all environment variables related to the selkies-gstreamer WebRTC interface are ignored, with the exception of `BASIC_AUTH_PASSWORD`. As with the selkies-gstreamer WebRTC interface, the noVNC interface password will be set to `BASIC_AUTH_PASSWORD`, and use `PASSWD` by default if not set.

The container requires host NVIDIA GPU driver versions of at least **450.80.02**, with the corresponding container toolkit runtime to be also configured on the host for allocating GPUs. All Maxwell or later generation GPUs in the consumer, professional, or datacenter lineups will not have significant issues running this container, although the selkies-gstreamer high performance NVENC backend may not be available (see the next paragraph). Kepler GPUs are untested and likely does not support the NVENC backend, but can be mostly functional using the software acceleration fallback.

The high performance NVENC backend for the selkies-gstreamer WebRTC interface is only supported in GPUs that is listed as supporting `H.264 (AVCHD)` under the `NVENC - Encoding` section of NVIDIA's [Video Encode and Decode GPU Support Matrix](https://developer.nvidia.com/video-encode-and-decode-gpu-support-matrix-new). If your GPU is not listed as supporting `H.264 (AVCHD)`, add the environment variable `WEBRTC_ENCODER` with the value `x264enc` in your container configuration for falling back to software acceleration, which also has a very good performance depending on your CPU.

The username is `user` in both the container user account and the web authentication prompt. The environment variable `PASSWD` is the password of the container user account, and `BASIC_AUTH_PASSWORD` is the password for the HTML5 interface authentication prompt. If `ENABLE_BASIC_AUTH` is set to `true` for selkies-gstreamer (not required for noVNC) but `BASIC_AUTH_PASSWORD` is unspecified, the HTML5 interface password will default to `PASSWD`.
> NOTES: Only one web browser can be connected at a time with the selkies-gstreamer WebRTC interface. If the signaling connection works, but the WebRTC connection fails, read the [Using a TURN Server](#using-a-turn-server) section.
