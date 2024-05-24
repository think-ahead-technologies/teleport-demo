
deploy: deploy-init
	cd terraform-servers && terraform apply
deploy-force: deploy-init
	cd terraform-servers && terraform apply -auto-approve

deploy-init:
	cd terraform-servers && terraform init

redeploy-servers: destroy-deploy-force deploy-force

destroy-deploy:
	cd terraform-servers && terraform destroy
destroy-deploy-force:
	cd terraform-servers && terraform destroy -auto-approve



configure:
	cd terraform-teleport && terraform apply

configure-init:
	cd terraform-teleport && terraform init