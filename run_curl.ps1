$headers = @{
    "Content-Type" = "application/json"
}

$connectorName = "postgresql-financial-conn"
$baseUrl = "http://localhost:8093/connectors"

$config = @{
    "connector.class" = "io.debezium.connector.postgresql.PostgresConnector"
    "topic.prefix" = "cdc"
    "database.user" = "postgres"
    "database.dbname" = "financial_db"
    "database.hostname" = "postgres"
    "database.password" = "postgres"
    "name" = $connectorName
    "plugin.name" = "pgoutput"
    "decimal.handling.mode" = "string"
}

$body = @{
    name = $connectorName
    config = $config
} | ConvertTo-Json -Depth 5

# Check if the connector already exists
try {
    $existingConnector = Invoke-RestMethod -Uri "$baseUrl/$connectorName" -Method Get -Headers $headers
    Write-Host "Connector $connectorName already exists. Updating configuration..."
    $updateUrl = "$baseUrl/$connectorName/config"
    $response = Invoke-RestMethod -Uri $updateUrl -Method Put -Headers $headers -Body ($config | ConvertTo-Json -Depth 5)
    Write-Host "Connector updated successfully."
}
catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "Connector $connectorName does not exist. Creating new connector..."
        $response = Invoke-RestMethod -Uri $baseUrl -Method Post -Headers $headers -Body $body
        Write-Host "Connector created successfully."
    }
    else {
        Write-Host "An error occurred: $_"
        exit 1
    }
}

Write-Host "Connector configuration:"
$response | ConvertTo-Json -Depth 5
