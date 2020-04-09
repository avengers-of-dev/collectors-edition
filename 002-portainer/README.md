# nginx lessons learned
This subfolder contains everything about [portainer](https://www.portainer.io/) and how to managa econtainers in different environments. I mainly focus on plain Docker (in my lab environment running on a QNAP NAS) and Kubernetes (running as AKS). But there is also a bit Docker in Swarm mode on a Ubuntu VM.

# how to use it
Portainer is coll for managing your containers in various environments and get an idea whats going on. But first of all you have to deploy it and hopefully that would be the last time you are using `docker-compose up -d` or `kubectl apply -f`.

## docker portainer
I'm using my QNAP NAS here as lab environment. Please take care about the network settings, which are pretty messed up on a QNAP when you want to have propper DNS and service discovery.

## docker swarm portainer
Nothing special here. See the respective yaml.

## docker kubernetes portainer
Also not much special, only the external facing webfrontend will only work if you have traefik deployed as ingress controller. I will explain this in a later example here too. I'm also using azure file for data persistance instead of volumes. I guess Il'' describe that too soon in an example.