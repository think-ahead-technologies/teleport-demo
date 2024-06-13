DEMO_DIR=scaleway-k8s

deploy: deploy-init
	cd $(DEMO_DIR) && terraform apply
deploy-force: deploy-init
	cd $(DEMO_DIR) && terraform apply -auto-approve

deploy-init:
	cd $(DEMO_DIR) && terraform init

destroy-deploy:
	cd $(DEMO_DIR) && terraform destroy
destroy-deploy-force:
	cd $(DEMO_DIR) && terraform destroy -auto-approve

update-config:
	./$(DEMO_DIR)/update-conf.sh