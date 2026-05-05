#!/bin/bash
set -e

echo "Running migrations..."
bin/rails db:migrate

echo "Starting server..."
exec bin/rails server -b 0.0.0.0 -p ${PORT:-3000}