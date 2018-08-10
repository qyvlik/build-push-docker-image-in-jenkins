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

~~## run on jenkins~~

~~build image and push image into private docker registry, make sure you have a running private docker registry, and the docker daemon have open the remote api.~~

~~1. install the jenkins plugin: ``~~

