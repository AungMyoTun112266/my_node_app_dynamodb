docker build -t my-node-app .
docker run --env-file .env -p 5000:5000 my-node-app