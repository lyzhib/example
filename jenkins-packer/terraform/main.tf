terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = "ajetmbs3831or9bpsbnp"
  folder_id                = "b1gbobia866m35q0ad9v"
}

data "yandex_compute_image" "nginx_image" {
  family    = "debian-11-nginx"
  folder_id = "b1gbobia866m35q0ad9v"
}

data "yandex_compute_image" "django_image" {
  family    = "debian-11-django"
  folder_id = "b1gbobia866m35q0ad9v"
}

resource "yandex_compute_instance" "nginx" {
  count       = 3
  name        = "yc-nginx-instance-${count.index}"
  hostname    = "yc-nginx-instance-${count.index}"
  description = "yc-nginx-instance-${count.index} of my cluster"
  zone        = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "${data.yandex_compute_image.nginx_image.id}"
      type     = "network-nvme"
      size     = "30"
    }
  }


  network_interface {
    subnet_id = "e2lim4qvuhjn0qko593a"
    nat       = true
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/root/.ssh/id_ed25519.pub")}"
    user-data = "${file("boostrap/metadata.yaml")}"
  }

  labels = {
    node_id = "${count.index}"
  }
}

resource "yandex_compute_instance" "django" {
  count       = 3
  name        = "yc-django-instance-${count.index}"
  hostname    = "yc-django-instance-${count.index}"
  description = "yc-django-instance-${count.index} of my cluster"
  zone        = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "${data.yandex_compute_image.django_image.id}"
      type     = "network-nvme"
      size     = "30"
    }
  }


  network_interface {
    subnet_id = "e2lim4qvuhjn0qko593a"
    nat       = false
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/root/.ssh/id_ed25519.pub")}"
    user-data = "${file("boostrap/metadata.yaml")}"
  }

  labels = {
    node_id = "${count.index}"
  }
}

locals {
  nginx_ips = {
    internal = ["${yandex_compute_instance.nginx.*.network_interface.0.ip_address}"]
    external = ["${yandex_compute_instance.nginx.*.network_interface.0.nat_ip_address}"]
  }
  django_ips = {
    internal = ["${yandex_compute_instance.django.*.network_interface.0.ip_address}"]
    external = ["${yandex_compute_instance.django.*.network_interface.0.nat_ip_address}"]
  }
}
