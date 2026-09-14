build {
  name = "build.${var.os_dist}-${var.os_ver}-${var.os_id}"

  sources = ["source.qemu.vm-install"]

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
      "echo Waiting ${var.os_wait} for diag ...",
      "sleep ${var.os_wait}"
    ]
  }

  provisioner "shell" {
    execute_command = "echo '${var.os_pass}'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    inline = [
      "set -x",
      "rpm --import /etc/pki/rpm-gpg/*",
      "yum-config-manager --disable '*' > /dev/null",
      "F=/etc/yum.repos.d/rocky-${var.os_ver}.repo",
      "echo -n > $F",
      "echo [baseos-${var.os_ver}-dvd1] >> $F",
      "echo name=baseos-${var.os_ver}-dvd1 >> $F",
      "echo baseurl=http://${var.os_web}/sw/linux/rocky/${var.os_ver}/x86_64/dvd1/BaseOS >> $F",
      "echo >> $F",
      "echo [appstream-${var.os_ver}-dvd1] >> $F",
      "echo name=appstream-${var.os_ver}-dvd1 >> $F",
      "echo baseurl=http://${var.os_web}/sw/linux/rocky/${var.os_ver}/x86_64/dvd1/AppStream >> $F",
      "echo >> $F",
      "echo [baseos-${var.os_ver}-os] >> $F",
      "echo name=baseos-${var.os_ver}-os >> $F",
      "echo baseurl=http://${var.os_web}/sw/linux/rocky/${var.os_ver}/x86_64/os/BaseOS >> $F",
      "echo >> $F",
      "echo [appstream-${var.os_ver}-os] >> $F",
      "echo name=appstream-${var.os_ver}-os >> $F",
      "echo baseurl=http://${var.os_web}/sw/linux/rocky/${var.os_ver}/x86_64/os/AppStream >> $F",
      "echo >> $F",
      "echo [highavailability-${var.os_ver}-os] >> $F",
      "echo name=highavailability-${var.os_ver}-os >> $F",
      "echo baseurl=http://${var.os_web}/sw/linux/rocky/${var.os_ver}/x86_64/os/HighAvailability >> $F",
      "echo >> $F",
      "echo [crb-${var.os_ver}-os] >> $F",
      "echo name=crb-${var.os_ver}-os >> $F",
      "echo baseurl=http://${var.os_web}/sw/linux/rocky/${var.os_ver}/x86_64/os/CRB >> $F",
      "yum -q clean all"
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
