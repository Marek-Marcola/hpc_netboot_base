build {
  name = "build.${var.os_dist}-${var.os_ver}-${var.os_id}"

  sources = ["source.qemu.vm-upgrade"]

  provisioner "shell" {
    execute_command = "echo '${var.os_pass}'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    inline = [
      "set -x",
      "mkdir -pv /version.d",
      "F=/version.d/version-${var.os_dist}-${var.os_ver}-${var.os_id}.txt",
      "echo info.date = $(date +%y-%m-%d_%H:%M:%S) > $F",
      "echo info.name = ${var.os_dist}-${var.os_ver}-${var.os_id} >> $F",
      "echo info.from = ${var.os_dist}-${var.os_ver}-${var.os_from} >> $F"
    ]
  }
  provisioner "shell" {
    execute_command = "echo '${var.os_pass}'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    inline = [
      "set -x",
      "echo Diag wait for ${var.os_wait} ...",
      "sleep ${var.os_wait}"
    ]
  }
}
