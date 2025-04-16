FROM golang:1.23.7-alpine

# Enable CGO
# This is required for the sqlite3 driver to work
ENV CGO_ENABLED = 1

# Download C toolchain
RUN apk add --no-cache \
    gcc \
    musl-dev \
    sqlite-dev


# Install the flare interpreter
RUN go install github.com/flarelang/flare@a7e58cd

# Copy the flare config file
COPY flare.yaml .

# Download flare packages
RUN flare download

# Copy the source files
COPY . .

# Seed the database
RUN flare run migrate/migrate.fl

EXPOSE 3000

# Start the app
CMD ["flare", "start"]