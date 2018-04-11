# gke_ingress_redirect
Lightweight container with redirect with hsts support that returns 200 for 10.0.0.0/8 (GKE internal) requests

This is a container image we use internally to redirect paths/domains on our GKE clusters when using Google Cloud Engine Ingress. It allows to pass a `REDIRECT` env variable with the target domain.

See nginx-boot.sh for details on how the config is generated and the variables available.
