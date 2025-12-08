terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "null" {}

resource "null_resource" "deploy_user_script" {

  # On définit comment Terraform se connecte au serveur
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    host        = var.server_ip
  }

  # Étape 1 : Copie du script Bash vers le serveur
  provisioner "file" {
    source      = "${var.source_files_path}/create_users.sh"
    destination = "/tmp/create_users.sh"
  }

  # Étape 2 : Copie du fichier users.txt vers le serveur
  provisioner "file" {
    source      = "${var.source_files_path}/users.csv"
    destination = "/tmp/users.csv"
  }

  # Étape 3 : Exécution du script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/create_users.sh",
      # On va dans /tmp pour que le script trouve users.txt juste à côté
      "cd /tmp && ./create_users.sh ${var.student_group_name}"
    ]
  }

  # Astuce : Permet de relancer le script si les fichiers changent
  triggers = {
    script_hash = filemd5("${var.source_files_path}/create_users.sh")
    users_hash  = filemd5("${var.source_files_path}/users.csv")
  }
}
