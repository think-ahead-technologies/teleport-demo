

resource "teleport_role" "developer" {
  version = "v7"
  metadata = {
    name = "developer"
  }

  spec = {
    allow = {
      logins = ["ubuntu", "debian", "{{internal.logins}}"]

      node_labels = {
        key   = ["env"]
        value = ["test"]
      }
    }
  }
}
