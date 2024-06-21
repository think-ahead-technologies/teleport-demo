
resource "scaleway_domain_record" "letsencrypt-challenge" {
  dns_zone = "thinkahead.dev"
  name     = "_acme-challenge.teleport.thinkahead.dev"
  type     = "TXT"
  data     = var.LETSENCRYPT_DNS_CHALLENGE
  ttl      = 60
}
