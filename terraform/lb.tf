resource "yandex_lb_target_group" "loadbalancer" {
  name = "lb-group"
  dynamic "target" {
    for_each = yandex_compute_instance.app.*.network_interface.0.ip_address
    content {
      address   = target.value
      subnet_id = var.subnet_id
    }
  }
  #target {
  # address   = yandex_compute_instance.app.network_interface.0.ip_address
  #subnet_id = var.subnet_id
  #}
  #target {
  #address   = yandex_compute_instance.app2.network_interface.0.ip_address
  # subnet_id = var.subnet_id
  #}#
}
resource "yandex_lb_network_load_balancer" "external-lb-test" {
  name = "external-lb-test"
  type = "external"

  listener {
    name        = "my-listener"
    port        = 8080
    target_port = 9292
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.loadbalancer.id

    healthcheck {
      name = "http"
      http_options {
        port = 9292
      }
    }
  }
}