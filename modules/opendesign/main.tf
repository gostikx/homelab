module "setup_dirs" {
  source = "../../plugins/setup_dirs"

  ssh_config = var.ssh_config

  dirs = [
    { path = local.stack_path, mode = "700" },
    { path = local.data_path, mode = "700" },
  ]
}

resource "docker_image" "opendesign" {
  name         = "ghcr.io/nexu-io/od:0.24.1"
  keep_locally = true
}

module "upload_opendesign_dockerfile" {
  source = "../../plugins/upload_files"

  ssh_config  = var.ssh_config
  local_path  = "${path.module}/Dockerfile"
  remote_path = "${local.stack_path}/Dockerfile"

  triggers_replace = { dockerfile = filesha256("${path.module}/Dockerfile") }

  commands = [
    "chmod 600 ${local.stack_path}/Dockerfile"
  ]

  depends_on = [module.setup_dirs]
}

resource "terraform_data" "build_opendesign_image" {
  depends_on = [module.upload_opendesign_dockerfile]

  triggers_replace = {
    dockerfile = filesha256("${path.module}/Dockerfile")
  }

  connection {
    type        = "ssh"
    host        = var.ssh_config.host
    port        = var.ssh_config.port
    user        = var.ssh_config.user
    private_key = file(var.ssh_config.key)
  }

  provisioner "remote-exec" {
    inline = [
      "docker build -t ${local.opendesign_image} ${local.stack_path}"
    ]
  }
}

resource "docker_container" "opendesign" {
  depends_on = [
    module.setup_dirs,
    terraform_data.build_opendesign_image,
  ]

  name    = "opendesign"
  image   = local.opendesign_image
  restart = "always"

  user = "1001:1001"

  env = [
    "NODE_ENV=production",
    "NODE_OPTIONS=--max-old-space-size=192",
    "OPEN_DESIGN_RUNTIME=cloud",
    "OD_BIND_HOST=0.0.0.0",
    "OD_PORT=7456",
    "OD_WEB_PORT=7456",
    "OD_API_TOKEN=${var.od_api_token}",
  ]

  tmpfs = {
    "/tmp" = "size=64m,mode=1777"
  }

  memory = 1024

  memory_swap = 2048

  ulimit {
    name = "nproc"
    soft = 256
    hard = 256
  }

  security_opts = [
    "no-new-privileges:true"
  ]

  volumes {
    host_path      = local.data_path
    container_path = "/app/.od"
  }

  ports {
    external = 7456
    internal = 7456
  }

  networks_advanced {
    name = var.network_name
  }

  healthcheck {
    test         = ["CMD", "node", "-e", "fetch('http://127.0.0.1:7456/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]
    start_period = "10s"
    interval     = "10s"
    timeout      = "5s"
    retries      = 5
  }

  wait         = true
  wait_timeout = 60

  lifecycle {
    replace_triggered_by = [terraform_data.build_opendesign_image]
  }
}
