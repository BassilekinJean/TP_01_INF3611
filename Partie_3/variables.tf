variable "server_ip" {
  description = "L'adresse IP publique de votre VPS"
  type        = string
}

variable "ssh_user" {
  description = "L'utilisateur SSH pour la connexion (généralement root)"
  type        = string
  default     = "root"
}

variable "ssh_private_key_path" {
  description = "Le chemin vers votre clé privée SSH"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "student_group_name" {
  description = "Le nom du groupe étudiant à créer"
  type        = string
  default     = "students-inf-361"
}

variable "source_files_path" {
  description = "Chemin vers le dossier contenant le script et le fichier users (Partie 1)"
  type        = string
  default     = "../Partie_1" # Suppose que ton dossier Partie_3 est à côté de Partie_1
}
