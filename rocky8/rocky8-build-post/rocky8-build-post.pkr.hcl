build {
  name = "build.${var.os_dist}-${var.os_ver}-${var.os_id}"

  sources = ["source.qemu.vm-upgrade"]

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

  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b"]
    playbook_file    = "${var.os_anpb}/playbooks/001570-rocky8/rocky8_postinstall.yml"
  }
  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b"]
    playbook_file    = "${var.os_anpb}/playbooks/001570-rocky8/rocky8_postinstall_software.yml"
  }
  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b"]
    playbook_file    = "${var.os_anpb}/playbooks/101630-env_module/env_module_postinstall.yml"
  }
  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b"]
    playbook_file    = "${var.os_anpb}/playbooks/001010-backup/bs_install.yml"
  }
  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b"]
    playbook_file    = "${var.os_anpb}/playbooks/001500-linux_admin/readme_postinstall.yml"
  }
  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b"]
    playbook_file    = "${var.os_anpb}/playbooks/008400-wifi/wifi_postinstall.yml"
  }
  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b"]
    playbook_file    = "${var.os_anpb}/playbooks/101523-scm_git/git_postinstall.yml"
  }
  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b"]
    playbook_file    = "${var.os_anpb}/playbooks/101058-gpg/gpg_postinstall.yml"
  }
  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b"]
    playbook_file    = "${var.os_anpb}/playbooks/001500-linux_admin/yum_update.yml"
  }

  provisioner "shell" {
    execute_command = "echo '${var.os_pass}'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    inline = [
      "set -x",
      "yum clean all"
    ]
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
