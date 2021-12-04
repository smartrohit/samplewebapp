# samplewebapp
ASP.NET Web application deployment on Azure Kubernetes Services

Azure Kubernetes Services:

Agenda:
	- ASP.NET Web application deployment on Azure Kubernetes Services
		through Azure DevOps CI/CD

Flow:

- ASP.NET Web application creation
	- DockerFile creation
- Push changes in Azure Repos (Along with DockerFile)
- Build and Push Image (ACR Repository)
- Deploy (AKS)
	- Creation of deployment.yml and service.yml files

Commands:

// This will allow to track new POD creation

kubectl get pods --watch

// We will then install the kubectl tool

az aks install-cli --install-location=./kubectl

// This allows kubectl to connect to the Kubernetes cluster

az aks get-credentials --resource-group devopsmela-rg --name devopsmelaAKS 

Pre-defined Variables:

$(Pipeline.Workspace)
	- The local path on the agent where all folders for a given build pipeline are created.

ASP.NET CORE Deployment Series:https://www.youtube.com/watch?v=KceoqTcf4Lk&list=PLNNeqe21-U0PJGMvVuG8XKEZSrr8aJiz7

AWS DevOps: https://www.youtube.com/watch?v=j7xjHBNi85g&t=347s

Azure Service Connection: https://www.youtube.com/watch?v=18BhQicsRao&t=604s

Website: https://devopsmela.in

Instagram: @DevOpsMela






