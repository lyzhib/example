resource "yandex_vpc_network" "network" {
  name = "yc-auto-network"
}

resource "yandex_vpc_subnet" "subnet" {
  count          = "${var.cluster_size > length(var.zones) ? length(var.zones) : var.cluster_size}"
  name           = "yc-auto-subnet-${count.index}"
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.network.id}"
  v4_cidr_blocks = ["192.168.0.0/24"]
}

locals {
  subnet_ids = yandex_vpc_subnet.subnet.*.id
}
