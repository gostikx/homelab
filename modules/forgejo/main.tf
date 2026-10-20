module "setup_dirs" {
  source = "../../plugins/setup_dirs"

  ssh_config = var.ssh_config
  dirs = [
    { path = local.data_path, mode = "700", uid = local.user.uid, gid = local.user.gid },
  ]
}

resource "docker_image" "forgejo" {
  name         = "codeberg.org/forgejo/forgejo:16.0.3-rootless"
  keep_locally = true
}

resource "docker_container" "forgejo" {
  depends_on = [module.setup_dirs]

  name    = "forgejo"
  image   = docker_image.forgejo.image_id
  restart = "always"

  user = "${local.user.uid}:${local.user.gid}"

  env = [
    "USER_UID=${local.user.uid}",
    "USER_GID=${local.user.gid}",
  ]

  ports {
    internal = 22
    external = 2222
  }

  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }

  volumes {
    host_path      = local.data_path
    container_path = "/var/lib/gitea"
  }

  healthcheck {
    test         = ["CMD-SHELL", "curl -fsS -o /dev/null http://127.0.0.1:3000/api/healthz || exit 1"]
    start_period = "30s"
    interval     = "10s"
    timeout      = "5s"
    retries      = 5
  }

  wait         = true
  wait_timeout = 120

  networks_advanced {
    name = var.network_name
  }
}
