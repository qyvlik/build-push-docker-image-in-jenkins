# build-push-docker-image-in-jenkins

build-push-docker-image-in-jenkins

## run on local machine

Make sure there is docker deamon run on your local machine.

1. start a private docker registry in local machine
    ```
    docker run -d --name local-docker-registry \
    -p 5000:5000 \
    --restart=always \
    -v ~/docker/local-docker-registry:/var/lib/registry \
    registry
    ```
2. set the `insecure-registries` in the `/etc/docker/daemon.json`, and restart the docker deamon
    ```
    {
      "insecure-registries":[
        "PRIVATE_REGISTRY:5000"
      ]
    }
    ```
3. build image in local machine
    ```
    docker build -t example-docker-image .
    ```
4. run container by local image on local machine
    ```
    docker run --rm example-docker-image
    ```
5. tag image
    ```
    docker tag example-docker-image PRIVATE_REGISTRY:5000/example-docker-image
    ```
6. push image
    ```
    docker push PRIVATE_REGISTRY:5000/example-docker-image
    ```
7. look the docker private registry
    ```
    curl http://PRIVATE_REGISTRY:5000/v2/_catalog
    ```
8. run container by private registry image on local machine
    ```
    docker rmi example-docker-image
    docker pull PRIVATE_REGISTRY:5000/example-docker-image
    docker run --rm PRIVATE_REGISTRY:5000/example-docker-image
    ```

## run on jenkins

Build image and push image into private docker registry, make sure you have a running private docker registry, and the docker daemon have open the remote api.

here the private docker registry url is `192.168.5.196:5000`

1. install the jenkins plugin: `[docker-build-step](https://wiki.jenkins.io/display/JENKINS/Docker+build+step+plugin)`
2. create a new jenkins job
3. add git url `https://github.com/qyvlik/build-push-docker-image-in-jenkins.git`
4. add the **Execute Docker command**
    1. **Create/build image**
        - `Build context folder`: `$WORKSPACE`
        - `Tag of the resulting docker image`: `yh/example-docker-image:latest`
        - `Filename of dockerfile`: `Dockerfile`
        - `Remove intermediate containers after a successful build`: **yes**
    2. **Tag image**
        - `Name of the image to tag (repository/image:tag)`: `yh/example-docker-image:latest`
        - `Target repository of the new tag`: `192.168.5.196:5000/yh/example-docker-image`
        - `The tag to set`: `latest`
    3. **Push image**
        - `Name of the image to push (repository/image)`: `192.168.5.196:5000/yh/example-docker-image`
        - `Tag`: `latest`
        - `Docker registry URL`:`192.168.5.196:5000`
    4. **Stop container(s) by image ID**
        - `Image ID`: `192.168.5.196:5000/yh/example-docker-image:latest`
    5. **Remove container(s)**
        - `Container ID(s)`: `example-docker-image`
        - `Ignore if not found`: **yes**
    6. **Create container**
        - `Image name`: `192.168.5.196:5000/yh/example-docker-image:latest`
        - `Container name`: `example-docker-image`
    7. **Start container(s)**
        - `Container ID(s)`: `example-docker-image`
5. run jenkins build



