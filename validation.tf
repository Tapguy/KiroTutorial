# Validation checks to ensure configuration consistency
resource "null_resource" "validation" {
  count = length(local.validation_errors) > 0 ? 1 : 0
  
  provisioner "local-exec" {
    command = "echo 'Validation errors: ${join(", ", local.validation_errors)}' && exit 1"
  }
}