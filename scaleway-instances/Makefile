

redeploy:
	-terraform taint scaleway_instance_server.teleport-proxy-1
	-terraform taint scaleway_instance_server.teleport-auth-1
	-terraform taint scaleway_instance_server.teleport-tag-1
	-terraform state rm scaleway_instance_user_data.proxy \
		scaleway_instance_user_data.auth \
		scaleway_instance_user_data.tag \
		null_resource.copy-teleport-conf-proxy \
		null_resource.copy-teleport-conf-auth \
		null_resource.copy-teleport-conf-tag
	terraform apply -auto-approve

ssh-auth ssh-proxy ssh-tag:
ssh-%:
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$$(terraform output -raw $*-ip)

cert-gen:
	./certgen.sh