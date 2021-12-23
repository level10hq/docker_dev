# docker_dev

Dockerfile and friends for EKS interaction

## Instructions

The docker-compose file will mount user''s `.aws` directory

1. ```bash
   make interactive
   ```
2. ```
   make set-kubeconfig
   ```
3. run `kubectl` commands or use the IDE below to connect to the cluster control plane

## Kubernetes Destop IDE

[Lens](https://k8slens.dev/)

## Jobs:

[Kubernetes Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)

[job patterns](https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-patterns)

[Parallelism Using Expansion](https://kubernetes.io/docs/tasks/job/parallel-processing-expansion/)
