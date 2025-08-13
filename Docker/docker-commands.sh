## Create simple docker container and push it to GCR
    nano server.js

    var http = require('http');
    var handleRequest = function(request, response) {
    response.writeHead(200);
    response.end("Hello World!");
    }
    var www = http.createServer(handleRequest);
    www.listen(8080);

# test: 
    node server.js

    nano Dockerfile

    FROM node:6.9.2
    EXPOSE 8080
    COPY server.js .
    CMD node server.js

    docker build -t gcr.io/PROJECT_ID/hello-node:v1 .

# test: 
    docker run -d -p 8080:8080 gcr.io/PROJECT_ID/hello-node:v1
    curl http://localhost:8080
    docker ps
    docker stop

    gcloud auth configure-docker
    docker push gcr.io/PROJECT_ID/hello-node:v1



