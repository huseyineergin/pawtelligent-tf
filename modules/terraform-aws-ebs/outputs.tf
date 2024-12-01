output "id" {
  description = "The volume ID"
  value       = try(aws_ebs_volume.this.id, null)
}

output "arn" {
  description = "The volume ARN"
  value       = try(aws_ebs_volume.this.arn, null)
}