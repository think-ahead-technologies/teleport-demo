
recreate:
	terraform destroy -auto-approve
	terraform apply -auto-approve

login:
	tsh login --proxy=teleport.thinkahead.dev:443 teleport.thinkahead.dev

tokens: token-node token-db

node-invite.tok token-node:
	tctl tokens add --type=node --format=text | tr -d '\n' >node-invite.tok
.PHONY: node-invite.tok

db-invite.tok token-db:
	tctl tokens add --type=db --format=text | tr -d '\n' >db-invite.tok
.PHONY: db-invite.tok

ssh-db:
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $$(terraform output -raw db-service-ssh)

ssh-server ssh-db-service:
ssh-%:
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$$(terraform output -raw $*-ip)