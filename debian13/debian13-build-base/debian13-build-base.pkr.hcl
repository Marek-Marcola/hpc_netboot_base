build {
  name = "build.${var.os_dist}-${var.os_ver}-${var.os_id}"

  sources = ["source.qemu.vm-install"]

  provisioner "shell" {
    execute_command = "echo '${var.os_pass}'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    inline = [
      "set -x",
      "mkdir -p /version.d",
      "F=/version.d/version-${var.os_dist}-${var.os_ver}-${var.os_id}.txt",
      "echo info.date = $(date +%Y-%m-%d_%H:%M:%S) > $F",
      "echo info.name = ${var.os_dist}-${var.os_ver}-${var.os_id} >> $F",
      "echo info.from = ${var.os_dist}-${var.os_ver}-${var.os_from} >> $F"
    ]
  }

  provisioner "shell" {
    execute_command = "echo '${var.os_pass}'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    inline = [
      "set -x",
      "touch /etc/apt/sources.list",
      "sed -i.b$(date +%y%m%d) -e 's/^deb/#deb/' /etc/apt/sources.list",
      "F=/etc/apt/sources.list.d/debian-${var.os_ver}.list",
      "echo deb [trusted=yes] http://${var.os_web}/sw/linux/debian/${var.os_ver}/x86_64/dvd01/ trixie main non-free-firmware > $F",
      "echo deb [trusted=yes] http://${var.os_web}/sw/linux/debian/${var.os_ver}/x86_64/dvd02/ trixie main >> $F",
      "echo deb [trusted=yes] http://${var.os_web}/sw/linux/debian/${var.os_ver}/x86_64/dvd03/ trixie main >> $F",
      "echo deb [trusted=yes] http://${var.os_web}/sw/linux/debian/${var.os_ver}/x86_64/dvd04/ trixie main >> $F",
      "echo deb [trusted=yes] http://${var.os_web}/sw/linux/debian/${var.os_ver}/x86_64/dvd05/ trixie main >> $F",
      "echo deb [trusted=yes] http://${var.os_web}/sw/linux/debian/${var.os_ver}/x86_64/dvd06/ trixie main >> $F",
      "echo deb [trusted=yes] http://${var.os_web}/sw/linux/debian/${var.os_ver}/x86_64/dvd07/ trixie main >> $F",
      "echo deb [trusted=yes] http://${var.os_web}/sw/linux/debian/${var.os_ver}/x86_64/dvd08/ trixie main >> $F",
      "echo deb [trusted=yes] http://${var.os_web}/sw/linux/debian/${var.os_ver}/x86_64/dvd09/ trixie main >> $F",
      "echo deb [trusted=yes] http://${var.os_web}/sw/linux/debian/${var.os_ver}/x86_64/dvd10/ trixie main >> $F",
      "echo deb [trusted=yes] http://${var.os_web}/sw/linux/debian/${var.os_ver}/x86_64/dvd11/ trixie main >> $F",
      "echo deb [trusted=yes] http://${var.os_web}/sw/linux/debian/${var.os_ver}/x86_64/dvd12/ trixie main >> $F",
      "echo deb [trusted=yes] http://${var.os_web}/sw/linux/debian/${var.os_ver}/x86_64/dvd13/ trixie main >> $F",
      "echo deb [trusted=yes] http://${var.os_web}/sw/linux/debian/${var.os_ver}/x86_64/dvd14/ trixie main >> $F",
      "echo deb [trusted=yes] http://${var.os_web}/sw/linux/debian/${var.os_ver}/x86_64/dvd15/ trixie main >> $F",
      "cat /etc/os-release"
    ]
  }

  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b"]
    playbook_file    = "${var.os_anpb}/playbooks/999202-bdev/bdev_postinstall_image.yml"
  }

  provisioner "shell-local" {
    inline = [
      "set -x",
      "echo ${var.os_date} > ${var.os_out}/${var.os_dist}-${var.os_ver}-${var.os_id}/${var.os_dist}-${var.os_ver}-x86_64.date"
    ]
  }

  post-processors {
    post-processor "checksum" {
      checksum_types = ["sha1"]
      output = "${var.os_out}/${var.os_dist}-${var.os_ver}-${var.os_id}/${var.os_dist}-${var.os_ver}-x86_64.txt"
    }
  }
}
