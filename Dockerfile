# Use the official Node.js image as the base image
FROM node:18-slim

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies (including devDependencies for building TypeScript)
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

# Install TypeScript globally
RUN npm install -g typescript

# Build the TypeScript code
RUN npm run build

# Expose the port the app runs on
EXPOSE 5000

# Define the command to run the application
CMD ["node", "dist/server.js"]
