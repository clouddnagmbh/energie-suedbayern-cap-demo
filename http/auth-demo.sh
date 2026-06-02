#!/usr/bin/env bash
# Voraussetzung: Anwendung läuft mittels `cds watch` (Port 4004)
set -euo pipefail

BASE="http://localhost:4004/odata/v4/product-catalog/Products"

line() { printf '\n\033[1m%s\033[0m\n' "$1"; }

line "1) OHNE Anmeldung  -> erwartet 401"
curl -s -o /dev/null -w "   HTTP %{http_code}\n" "$BASE"

line "2) MIT viewer      -> erwartet 200"
curl -s -o /dev/null -w "   HTTP %{http_code}\n" -u viewer:viewer "$BASE"

line "3) MIT admin       -> erwartet 200"
curl -s -o /dev/null -w "   HTTP %{http_code}\n" -u admin:admin "$BASE"

line "4) viewer SCHREIBT (POST) -> erwartet 403 (nur Lesen erlaubt)"
curl -s -o /dev/null -w "   HTTP %{http_code}\n" -u viewer:viewer \
  -H "Content-Type: application/json" \
  -d '{"name":"Heizstab 2 kW","price":59.00}' "$BASE"

line "5) admin  SCHREIBT (POST) -> erwartet 201 (Anlage erlaubt)"
curl -s -o /dev/null -w "   HTTP %{http_code}\n" -u admin:admin \
  -H "Content-Type: application/json" \
  -d '{"name":"Heizstab 2 kW","price":59.00}' "$BASE"

echo