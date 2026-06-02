# JWT — der digitale Ausweis

Ziel der Demo: Zeigen, dass ein Token kein Passwort ist, sondern ein
**signierter, fälschungssicherer Ausweis**, in dem alle wichtigen Infos stehen.

## Variante A – mit dem mitgelieferten Beispiel-Token

1. Öffne <https://jwt.io>
2. Kopiere den Inhalt von [`sample-jwt.txt`](sample-jwt.txt) in das linke Feld
3. Rechts erscheint der entschlüsselte Inhalt

## Variante B – mit einem ECHTEN Token aus eurer BTP

Wenn die App in der BTP läuft, holt der App Router das Token automatisch. Einen
echten Token bekommt man beispielsweise so:

```bash
# Service-Key des XSUAA-Instanz nutzen (clientid, clientsecret, url aus dem Key):
curl -s -u "<clientid>:<clientsecret>" \
  -X POST "<url>/oauth/token" \
  -d "grant_type=password&username=<user>&password=<pass>" | jq -r .access_token
```

Das Ergebnis ebenfalls in <https://jwt.io> einfügen.
