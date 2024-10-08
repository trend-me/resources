ARG PLUGIN_VERSION=3.12.0
ARG BASE_VERSION=3.12

FROM ubuntu:20.04 AS builder

ARG PLUGIN_VERSION

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl
RUN mkdir -p /plugins && \
    curl -fsSL \
    -o "/plugins/rabbitmq_delayed_message_exchange-${PLUGIN_VERSION}.ez" \
    https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/v${PLUGIN_VERSION}/rabbitmq_delayed_message_exchange-${PLUGIN_VERSION}.ez

FROM rabbitmq:${BASE_VERSION}-management-alpine

ARG PLUGIN_VERSION

# Copy plugin from builder stage
COPY --from=builder /plugins/rabbitmq_delayed_message_exchange-${PLUGIN_VERSION}.ez $RABBITMQ_HOME/plugins/

# Set the correct permissions for the .erlang.cookie
RUN chmod 600 /var/lib/rabbitmq/.erlang.cookie

# Enable RabbitMQ delayed message exchange plugin
RUN rabbitmq-plugins enable --offline rabbitmq_delayed_message_exchange

# Stage 1: Build the Go application
FROM golang:1.22 AS build

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go app
RUN go build -o create-queues

# Stage 2: Setup RabbitMQ with Go
FROM rabbitmq:${BASE_VERSION}-management-alpine

# Copy the Go binary from the previous stage
COPY --from=build /app/create-queues /usr/local/bin/create-queues

# Set environment variables for RabbitMQ
ENV RABBITMQ_DEFAULT_USER=rabbit
ENV RABBITMQ_DEFAULT_PASS=rabbit

# Ensure the .erlang.cookie has correct permissions again, as this may be reset
RUN chmod 600 /var/lib/rabbitmq/.erlang.cookie

# Command to start RabbitMQ and the Go application
CMD ["sh", "-c", "rabbitmq-server & create-queues"]