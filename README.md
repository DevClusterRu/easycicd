# EasyCICD
EasyCICD is a tool for quickly deploying your applications in a Docker Swarm environment. Please read the instructions below and you will be able to automate your deployment in a couple of minutes

#### Install

1. Clone the repository to your folder
2. Run the install.sh file

The tool is ready for using!


#### System settings

Before use, you need to configure the system settings

1. You need to have [Docker](https://docs.docker.com/engine/install/ubuntu/) installed and initialize the [Docker swarm](https://docs.docker.com/engine/reference/commandline/swarm_init/).
2. You must have your docker registry and be [authorized](https://docs.docker.com/engine/reference/commandline/login/) in it. 
You can use any docker registry, not necessarily on DockerHub. It is important that you are permanently logged in there. 
If you are using AWS Elastic Container Registry, authorization there works within 24 hours. I solved this problem by periodically calling the authorization token through Crontab
3. EasyCICD uses git pull requests, i.e. you must either use public repositories, or permanently log in to git, or (preferably) use git ssh. In any case, a git pull... request in the terminal should not ask for a username and password

#### Usage

#### Prepare your application repository

You can run any applications through EasyCICD, but it is important that each of them has 2 files in the root directory:

* deploy.yml
* Dockerfile

The Dockerfile contains the usual instructions for building your container, while the deploy.yml file defines the deployment options

##### Dockerfile example:
```
FROM golang:1.18-alpine as builder
WORKDIR /app
COPY . .
RUN go mod download
RUN go build -o /main main.go

FROM alpine:3
COPY --from=builder main /bin/main

EXPOSE 9999

ENTRYPOINT ["/bin/main"]
```

##### deploy.yml example:

```
version: '3.4'
services:
  swarm:
    image: 00000000001.dkr.ecr.us-east-2.amazonaws.com/webserver
    deploy:
      replicas: 1
      update_config:
        parallelism: 1
        delay: 1s
        order: start-first
      restart_policy:
        condition: on-failure
    ports:
      - 9999:9999
    command: ["/bin/main"]
```
**!important! don't change service name! It should be "swarm"**


Now we have to do the following:

1. Clone your project into easycicd/projects folder
2. Switch branch to production (if you don't have - make it)
3. Double check that you are on a branch called production (only this branch is tracked)
4. Execute **systemctl restart cicd**
5. Check easycicd/main.log file. You should see something like 
```
->Create configuration...
Tracked ---> WebserverExample
The metrics are available at: localhost:9096/metrics
```
where "WebserverExample" - name of your repository

That's all. Now EasyCICD keeps track of the production branch and any change to it will result in a rebuild and restart of your project.

Note. If you just want to restart your project, you can of course use the docker swarm commands, but you can also just push to the production branch - this is often faster in fact

**Thank you for your interest in EasyCICD, I will be glad to see your comments and suggestions**
