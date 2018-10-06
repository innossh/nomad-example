# nomad-example

## Getting started

### Starting a job

```console
$ vagrant up

$ vagrant ssh -c "nomad run /vagrant/jobs/<job_name>.nomad"
```

### Jobs

- default-service.nomad
  - A service job with default restart and reschedule configurations
- default-batch.nomad
  - A batch job with default restart and reschedule configurations
- default-batch-periodic.nomad
  - A periodic batch job with default restart and reschedule configurations
- default-batch-periodic-overlap.nomad
  - A periodic batch job with default restart and reschedule configurations, and overlap is allowed

### Confirmation

The nomad UI http://localhost:4646/ is very helpful.

Or you can check the status with the "status" and "logs" commands as below.

```console
$ vagrant ssh

# for non periodic job
$ nomad status default-batch
$ nomad logs `nomad status default-batch | grep -A 2 Allocations | tail -1 | cut -f1 -d' '`

# for periodic job
$ nomad status default-batch-periodic
$ nomad logs $(nomad status $(nomad status default-batch-periodic | grep -A 2 Previously | tail -1 | cut -f1 -d' ') | grep -A 2 Allocations | tail -1 | cut -f1 -d' ')
```

### Stopping a job

```console
$ vagrant ssh -c "nomad stop <job_name>"

$ vagrant destroy
```
