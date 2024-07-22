package main

import (
	"fmt"
	"github.com/trend-me/golang-rabbitmq-lib/rabbitmq"
)

func main() {
	fmt.Println("Creating RabbitMQ queues")
	conn := rabbitmq.Connection{}
	err := conn.Connect("rabbit", "rabbit", "rabbitmq", "5672")
	if err != nil {
		panic(err)
	}

	queuesNames := []string{
		"ai-prompt-builder",
		"ai-requester",
		"ai-callback",
	}
	for _, q := range queuesNames {
		queue := rabbitmq.NewQueue(&conn, q, rabbitmq.ContentTypeJson, true, true, true)
		err = queue.Connect()
		if err != nil {
			fmt.Println("Error connecting to queue")
			panic(err)
		}
	}

	defer func(conn *rabbitmq.Connection) {
		err := conn.Close()
		if err != nil {
			fmt.Println("Error closing connection")
			panic(err)
		}
	}(&conn)

	fmt.Println("Created RabbitMQ queues")

}
