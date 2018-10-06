job "default-batch" {
  datacenters = ["dc1"]
  type = "batch"

  group "default-batch" {
    count = 1

    restart {
      attempts = 15
      delay    = "15s"
      interval = "168h"
      mode     = "fail"
    }
    reschedule {
      attempts       = 1
      interval       = "24h"
      unlimited      = false
      delay          = "5s"
      delay_function = "constant"
    }

    task "default-batch" {
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
