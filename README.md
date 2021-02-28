# qgis-server
QGIS Server Docker Container

# Taken from the QGIS Server documentation pages
URL: https://docs.qgis.org/3.16/en/docs/server_manual/containerized_deployment.html#aws-usecase

# To Install
docker build -f Dockerfile -t qgis-server ./

# Create a Docker Network
docker network create qgis

# Creates a qgis server docker container and adds to the newly-created network. The parameters:
-d: run in the background

–rm: remove the container when it is stopped

–name: name of the container to be created

–net: (previously created) sub network

–hostname: container hostname, for later referencing

-v: local data directory to be mounted in the container

-p: host/container port mapping

-e: environment variable to be used in the container
# The command
docker run -d --rm --name qgis-server --net=qgis --hostname=qgis-server -v $(pwd)/data:/data:ro -p 5555:5555 -e "QGIS_PROJECT_FILE=/data/osm.qgs" qgis-server
              
# Create NGINX Container with latest stable 1.18.0
docker run -d --rm --name nginx --net=qgis --hostname=nginx -v $(pwd)/nginx.conf:/etc/nginx/conf.d/default.conf:ro -p 8080:80 nginx:1.18

# Test at IP address/domain, port 8080 
http://example.com:8080/qgis-server/?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetCapabilities
