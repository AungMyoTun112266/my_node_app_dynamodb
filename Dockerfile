# # Use the official Node.js image as the base image
# FROM node:18-slim

# # Set the working directory inside the container
# WORKDIR /usr/src/app

# # Copy package.json and package-lock.json to the working directory
# COPY package*.json ./

# # Install dependencies
# RUN npm install

# # Copy the rest of the application code to the working directory
# COPY . .

# # Build the TypeScript code
# RUN npm run build

# # Expose the port the app runs on
# # EXPOSE 5000

# # Define the command to run the application
# CMD ["dist/handler.handler"]


# Use AWS Lambda Node.js 18 base image
FROM public.ecr.aws/lambda/nodejs:18

# Copy project files to the container
COPY . .

# Install dependencies
RUN npm install

# Build the TypeScript project
RUN npm run build

# Set the CMD to point to the Lambda handler in the dist folder
CMD ["dist/handler.handler"]