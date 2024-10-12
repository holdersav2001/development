$headers = @{
    "Content-Type" = "application/json"
}

$body = @{
    name = "elasticsearch-sink"
    config = @{
        "connector.class" = "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector"
        "tasks.max" = "1"
        "topics" = "cdc.public.trade_event"
        "key.ignore" = "true"
        "schema.ignore" = "true"
        "connection.url" = "http://elasticsearch:9200"
        "type.name" = "_doc"
        "name" = "elasticsearch-sink"
    }
} | ConvertTo-Json -Depth 5

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8083/connectors" -Method Post -Headers $headers -Body $body -ErrorAction Stop

    if ($response.name -eq "elasticsearch-sink") {
        Write-Host "Elasticsearch Sink connector created successfully." -ForegroundColor Green
        Write-Host "Connector Name: $($response.name)" -ForegroundColor Cyan
        Write-Host "Connector Config:" -ForegroundColor Cyan
        $response.config | Format-Table -AutoSize | Out-String | Write-Host
    } else {
        Write-Host "Unexpected response. Please check the connector configuration manually." -ForegroundColor Yellow
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $statusDescription = $_.Exception.Response.StatusDescription

    if ($statusCode -eq 409) {
        Write-Host "Connector 'elasticsearch-sink' already exists. Attempting to update configuration..." -ForegroundColor Yellow
        
        try {
            $updateResponse = Invoke-RestMethod -Uri "http://localhost:8083/connectors/elasticsearch-sink/config" -Method Put -Headers $headers -Body ($body.config | ConvertTo-Json -Depth 5) -ErrorAction Stop
            Write-Host "Elasticsearch Sink connector updated successfully." -ForegroundColor Green
            Write-Host "Updated Config:" -ForegroundColor Cyan
            $updateResponse | Format-Table -AutoSize | Out-String | Write-Host
        } catch {
            Write-Host "Failed to update Elasticsearch Sink connector. Error: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Failed to create Elasticsearch Sink connector. Status code: $statusCode, Description: $statusDescription" -ForegroundColor Red
        Write-Host "Error details: $_" -ForegroundColor Red
    }
}

Write-Host "Checking connector status..." -ForegroundColor Cyan
try {
    $statusResponse = Invoke-RestMethod -Uri "http://localhost:8083/connectors/elasticsearch-sink/status" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "Connector Status:" -ForegroundColor Cyan
    $statusResponse | ConvertTo-Json -Depth 5 | Write-Host
} catch {
    Write-Host "Failed to retrieve connector status. Error: $_" -ForegroundColor Red
}

Write-Host "`nTroubleshooting steps if data is not flowing to Elasticsearch:" -ForegroundColor Yellow
Write-Host "1. Verify that the Kafka topic 'cdc.public.trade_event' exists and contains data:" -ForegroundColor White
Write-Host "   docker-compose exec broker kafka-console-consumer --bootstrap-server broker:29092 --topic cdc.public.trade_event --from-beginning" -ForegroundColor Gray
Write-Host "2. Check Kafka Connect logs for any errors:" -ForegroundColor White
Write-Host "   docker-compose logs kafka-connect" -ForegroundColor Gray
Write-Host "3. Verify Elasticsearch is running and accessible:" -ForegroundColor White
Write-Host "   curl http://localhost:9200" -ForegroundColor Gray
Write-Host "4. Check Elasticsearch indices to see if data is being indexed:" -ForegroundColor White
Write-Host "   curl http://localhost:9200/_cat/indices" -ForegroundColor Gray
Write-Host "5. If the connector is in a FAILED state, check the connector's tasks for specific error messages:" -ForegroundColor White
Write-Host "   curl http://localhost:8083/connectors/elasticsearch-sink/tasks" -ForegroundColor Gray
Write-Host "6. Ensure the data format in Kafka matches what Elasticsearch expects. You may need to adjust the connector's configuration if the data structure doesn't match." -ForegroundColor White
