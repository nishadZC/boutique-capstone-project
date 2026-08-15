#!/bin/bash
URL="http://localhost:3000/"
echo "Sending traffic to $URL to trigger HighTraffic alert..."
echo "Press Ctrl+C to stop."

while true; do
  curl -s -o /dev/null -w "Status Code: %{http_code}\n" "$URL"
  # Sleep for 0.05 seconds = ~20 requests per second.
  # This is enough to trigger the >10 req/s alert we configured.
  sleep 0.05
done
