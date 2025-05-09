group "default" {
    targets = ["ubuntu-ssh"]
}

target "ubuntu-ssh" {
    context = "./"
    dockerfile = "Dockerfile"
    tags = [
      "enzo2346/ubuntu-ssh:latest"
    ]
}
