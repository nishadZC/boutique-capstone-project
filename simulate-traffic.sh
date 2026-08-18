#!/bin/bash
URL="http://k8s-boutique-frontend-d0e8c9a776-1892332005.us-east-1.elb.amazonaws.com/api/products"
echo "Sending traffic to $URL to trigger HighTraffic alert..."
echo "Press Ctrl+C to stop."

# Launch 50 concurrent workers that never stop
for i in {1..50}; do
  while true; do
    curl -s -o /dev/null "$URL"
  done &
done

# Wait indefinitely
wait
