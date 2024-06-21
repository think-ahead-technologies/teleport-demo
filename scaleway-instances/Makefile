

redeploy:
	terraform apply -auto-approve \
		-replace=scaleway_instance_server.teleport-proxy-1 \
		-replace=scaleway_instance_server.teleport-auth-1 \
		-replace=scaleway_instance_server.teleport-tag-1
		-replace=scaleway_instance_user_data.proxy \
		-replace=scaleway_instance_user_data.auth \
		-replace=scaleway_instance_user_data.tag \
		-replace=null_resource.copy-teleport-conf-proxy \
		-replace=null_resource.copy-teleport-conf-auth \
		-replace=null_resource.copy-teleport-conf-tag \
		-replace=null_resource.wait-for-tag \
		-replace=null_resource.restart-auth-server \
		-replace=null_resource.restart-proxy-server \
		-replace=null_resource.wait-for-teleport

ssh-auth ssh-proxy ssh-tag:
ssh-%:
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$$(terraform output -raw $*-ip)

cert-gen:
	./certgen.sh