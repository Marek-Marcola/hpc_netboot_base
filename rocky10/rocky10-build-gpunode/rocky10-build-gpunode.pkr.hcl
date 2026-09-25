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

  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b","-e","{ 'p':[dkms] }"]
    playbook_file    = "${var.os_anpb}/playbooks/001500-linux_admin/yum_install.yml"
  }
  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b"]
    playbook_file    = "${var.os_anpb}/playbooks/008310-dkms/dkms_postinstall.yml"
  }

  provisioner "shell" {
    execute_command = "echo '${var.os_pass}'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    expect_disconnect = true
    pause_before      = "10s"
    timeout           = "10s"
    inline = [
      "set -x",
      "V=$(curl ${var.os_dopt} ${var.os_durl}/sw/nvidia/cuda_toolkit/version.txt|grep ^cuda-repo-rhel10:|tail -1|awk '{print $2}')",
      "curl ${var.os_dopt} -o /tmp/f.rpm ${var.os_durl}/sw/nvidia/cuda_toolkit/cuda-repo-rhel10-$V.x86_64.rpm",
      "rpm -ih /tmp/f.rpm",
      "rm -fv /tmp/f.rpm",
      "dnf -y install cuda-toolkit",
      "dnf -y install kernel-devel-matched",
      "dkms --version",
      "dnf -y install nvidia-open",
      "dkms status",
      "tree --noreport -F /usr/lib/modules/$(uname -r)/extra",
      "dnf -y install nvidia-fabricmanager",
      "dnf -y remove cuda-repo-rhel10*",
      "dnf clean all",
      "systemctl disable nvidia-fabricmanager",
      "chmod a+r /boot/vmlinuz-*",
      "chmod a+r /boot/initramfs-*",
      "[[ -f /usr/local/cuda/version.json ]] && jq .cuda /usr/local/cuda/version.json"
    ]
  }

  provisioner "ansible" {
    user             = "${var.os_user}"
    extra_arguments  = ["-e","h=default","-e","ansible_ssh_pass=${var.os_pass}","-b"]
    playbook_file    = "${var.os_anpb}/playbooks/904112-nvidia_cuda/nvidia_postinstall.yml"
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
