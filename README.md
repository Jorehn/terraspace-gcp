# Terraspace GCP

I did some experimenting with Terraspace and GCP, to be more specific with gke. 

# Prerequisites

First you need to install terraspace (duh) and also a working gcloud command line is needed to get the project up and running. I set up mine with a credential file in  the ~/.gcp folder. This file should contain the key associated with the project in GCP you're planning to use. 
## Deploy

To deploy all the infrastructure stacks:

    terraspace all up

To deploy individual stacks:

    terraspace up gke-cluster # where gke-cluster is app/stacks/gke-cluster

