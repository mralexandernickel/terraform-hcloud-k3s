resource "local_file" "setkubeconfig" {
    content     = templatefile("${path.module}/templates/setkubeconfig", {
      cluster_name = var.cluster_name
      master_ipv4 = var.master_ipv4
    })
    filename = "./setkubeconfig"
    file_permission = "0755"
}

resource "local_file" "unsetkubeconfig" {
    content     = templatefile("${path.module}/templates/unsetkubeconfig", {
      cluster_name = var.cluster_name
    })
    filename = "./unsetkubeconfig"
    file_permission = "0755"

    provisioner "local-exec" {
        when    = destroy
        command = "./unsetkubeconfig"
    }
}

