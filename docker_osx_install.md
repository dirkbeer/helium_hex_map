# Installing and configuring Docker-OSX on Ubuntu 22.04

1. Install docker [for Ubuntu 22.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04)

2. Install docker-compose  [for Ubuntu 22.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-22-04)

3. Run the docker image, install macOS Sonoma (or later version if available)

```yaml
# docker-compose.yml
version: '3.8'
 services:
   docker-osx:
     image: sickcodes/docker-osx:sonoma
     container_name: docker_osx_container
     devices:
       - /dev/kvm
     ports:
       - "50922:10022"
     volumes:
       - /tmp/.X11-unix:/tmp/.X11-unix
     environment:
       - DISPLAY=${DISPLAY:-:0.0}
     stdin_open: true
     tty: true
 ```
```bash
docker-compose up -d
```

4. Install mac OS

4.1 Open Disk Utility, select the biggest disk, Erase (you can specify a name for the disk, e.g. "macOS"

4.2 Reinstall Mac OS to that disk

4.3 Optimize OSX [link](https://github.com/sickcodes/osx-optimizer)
