locals {
  title  = replace(title(var.name), " ", "-")
  name   = var.env == null ? title(local.title) : format("%s-%s", title(local.title), title(var.env))
}

resource "null_resource" "touch" {
  # Used to refresh the outputs in the state without changing infrastructure
  triggers = {
    how_many_fingers = "2" # changing this triggers outputs to be updated
  }
}