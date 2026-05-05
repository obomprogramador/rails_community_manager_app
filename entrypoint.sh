#!/bin/bash
set -e

echo "Running migrations..."
bin/rails db:drop db:create db:migrate

echo "Precompiling assets..."
bin/rails assets:precompile

echo "Running seeds..."
bin/rails db:seed

echo "Starting server..."
exec bin/rails server -b 0.0.0.0 -p ${PORT:-3000}