# build-push-docker-image-in-jenkins

## 在本地机器上构建镜像

确保本地机器上有运行 `docker daemon`

1. 在本地机器上运行 `docker registry` 私服
  ```
  docker run -d --name local-docker-registry \
  -p 5000:5000 \
  --restart=always \
  -v ~/docker/local-docker-registry:/var/lib/registry \
  registry
  ```
2. 在 `/etc/docker/daemon.json` 中设置 `insecure-registries`，然后重启 `docker daemon`
    ```
    {
      "insecure-registries":[
        "PRIVATE_REGISTRY:5000"
      ]
    }
    ```
3. 在本地机器上构建镜像
    ```
    docker build -t example-docker-image .
    ```
4. 运行容器
    ```
    docker run --rm example-docker-image
    ```
5. tag 这个镜像
    ```
    docker tag example-docker-image PRIVATE_REGISTRY:5000/example-docker-image
    ```
6. 推送镜像到私服
    ```
    docker push PRIVATE_REGISTRY:5000/example-docker-image
    ```
7. 查看私服上的镜像列表
    ```
    curl http://PRIVATE_REGISTRY:5000/v2/_catalog
    ```
8. 移除本地原有镜像，重新拉取私服镜像，在运行容器
    ```
    docker rmi example-docker-image
    docker pull PRIVATE_REGISTRY:5000/example-docker-image
    docker run --rm PRIVATE_REGISTRY:5000/example-docker-image
    ```
## 在 jenkins 上构建镜像

构建镜像然后推送到 `docker registry` 私服，确保你运行了一个私服，且 `docker daemon` 开启了 remote api。本文的 `docker registry` 私服路径是 `92.168.5.196:5000`

1. 在 jenkins 上安装插件 [docker-build-step](https://wiki.jenkins.io/display/JENKINS/Docker+build+step+plugin)
2. 在 jenkins 上创建job
3. 添加 git 路径 `https://github.com/qyvlik/build-push-docker-image-in-jenkins.git`
4. 按序添加 **Execute Docker command**
    1. **Create/build image**
        - `Build context folder`: `$WORKSPACE`, (docker build 的上下文路径)
        - `Tag of the resulting docker image`: `yh/example-docker-image:latest`, (构建镜像的名称，包括 tag)
        - `Filename of dockerfile`: `Dockerfile`, (构建镜像的 Dockerfile)
        - `Remove intermediate containers after a successful build`: **yes**, (构建成功后是否移除容器)
    2. **Tag image**
        - `Name of the image to tag (repository/image:tag)`: `yh/example-docker-image:latest`, (需要被 tag 的原镜像名)
        - `Target repository of the new tag`: `192.168.5.196:5000/yh/example-docker-image`, (tag 后的镜像名)
        - `The tag to set`: `latest`, ( tag 后镜像的 tag)
    3. **Push image**
        - `Name of the image to push (repository/image)`: `192.168.5.196:5000/yh/example-docker-image`, (需要指定镜像名称)
        - `Tag`: `latest`, (需要指定镜像的 tag)
        - `Docker registry URL`:`192.168.5.196:5000`, (指定私服主机位置)
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
5. 构建此 jenkins job

