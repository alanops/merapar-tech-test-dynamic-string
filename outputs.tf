output "invoke_url" {
  value       = aws_apigatewayv2_api.http.api_endpoint
  description = "Public URL of the service"
}

output "api_endpoints" {
  value = {
    default = aws_apigatewayv2_api.http.api_endpoint
  }
  description = "API endpoint"
}
