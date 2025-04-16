# 1st stage: Build the Vite app
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy dependencies and install
COPY package*.json ./
RUN npm install

# Copy source code and build the app
COPY . .
RUN npm run build

# 2nd stage: Serve the built app using a minimal Python HTTP server
FROM python:3.11-alpine

# Set working directory
WORKDIR /app

# Copy the build output from the builder stage
COPY --from=builder /app/dist ./dist

# Expose the port the app will be served on
EXPOSE 8080

# Start the Python HTTP server
CMD ["python3", "-m", "http.server", "8080", "--directory", "dist"]
