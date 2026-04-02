#!/bin/bash
VERSION="0.2"
REPO="leschweuzh/specchio-webapp"

echo "Building version $VERSION..."
if sudo docker build --no-cache -t specchio-webapp:$VERSION .; then
    echo "Build successful. Tagging and pushing..."
    
    sudo docker tag specchio-webapp:$VERSION $REPO:$VERSION
    sudo docker tag specchio-webapp:$VERSION $REPO:latest
    
    sudo docker push $REPO:$VERSION
    sudo docker push $REPO:latest
    
    echo "Done! Version $VERSION is now live on Docker Hub."
else
    echo "Build failed. Check your Dockerfile or build context."
    exit 1
fi