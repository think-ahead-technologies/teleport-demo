
# - Install certbot
# - Run:
#     certbot certonly --manual --preferred-challenges dns -d "teleport.thinkahead.dev" --config-dir letsencrypt --work-dir letsencrypt --logs-dir letsencrypt --email teleport-on-prem@think-ahead.tech
# - Then deploy this resource with the challenge provided by that command's output.
# resource "scaleway_domain_record" "letsencrypt-challenge" {
#   dns_zone = "thinkahead.dev"
#   name     = "_acme-challenge.teleport"
#   type     = "TXT"
#   data     = "mSEahpICF7XHmjzcMHhfGhkmsXuwWees2zo_SloVq7w"
#   ttl      = 60
# }
