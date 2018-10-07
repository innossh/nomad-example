job "default-service" {
  datacenters = ["dc1"]
  type = "service"

  group "default-service" {
    count = 1

    restart {
      interval = "1m"
      attempts = 2
      delay    = "15s"
      mode     = "fail"
    }
    reschedule {
      delay          = "30s"
      delay_function = "exponential"
      max_delay      = "1h"
      unlimited      = true
    }

    task "default-service" {
      driver = "docker"

      config {
        image = "python:3.7.0-alpine3.7"
        command = "python3"
        args = [
          "-c",
          "from datetime import datetime; now = datetime.utcnow(); print(now); raise Exception('Failed at ' + str(now))"
        ]
      }

      resources {
        memory = 16
      }
    }
  }
}
