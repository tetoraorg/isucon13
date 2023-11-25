set -x

sudo mysql < ./00_create_database.sql
sudo mysql < ./10_schema.sql