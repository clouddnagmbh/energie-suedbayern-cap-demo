# Energie Südbayern – CAP Auth Demo

Eine kompakte Referenz-Anwendung für **SAP Cloud Application Programming Model
(CAP)**, die zeigt, wie **Authentifizierung** („Wer bist du?") und
**Autorisierung** („Was darfst du?") von der lokalen Entwicklung bis zum
produktiven Betrieb auf SAP BTP funktionieren.

Die App besteht bewusst aus wenigen, klaren Bausteinen – ein Produktkatalog mit
Reviews –, damit die Auth-Konzepte im Vordergrund stehen und nicht von Features
abgelenkt werden.

```
Fiori Elements UI  ⇄  CAP Backend (Node.js · OData V4)
```

## Inhalt

- [Schnellstart](#schnellstart)
- [Projektstruktur](#projektstruktur)
- [Authentifizierung & Autorisierung](#authentifizierung--autorisierung)
- [Demo-Ordner: `jwt/` und `http/`](#demo-ordner-jwt-und-http)
- [Deployment auf SAP BTP](#deployment-auf-sap-btp)
- [Offene Punkte](#offene-punkte)

## Schnellstart

```bash
npm install
cds watch
```

`cds watch` startet das Backend auf Port **4004** und die Fiori-UI über das
`cds-plugin-ui5`. Lokal greift das Profil `[development]` mit der Auth-Strategie
`mocked` – es stehen zwei Test-Nutzer bereit:

| Nutzer   | Passwort | Rolle    | Darf …                          |
| -------- | -------- | -------- | ------------------------------- |
| `viewer` | `viewer` | `Viewer` | nur lesen                       |
| `admin`  | `admin`  | `Admin`  | lesen, anlegen, ändern, löschen |

> ⚠️ `mocked` (und `dummy`) dienen **nur der Entwicklung**. Passwörter stehen im
> Klartext und es findet keine echte Token-Prüfung statt – niemals produktiv
> einsetzen.

## Projektstruktur

| Ordner / Datei     | Zweck                                                             |
| ------------------ | ----------------------------------------------------------------- |
| `db/`              | Domänenmodell (`schema.cds`) und Seed-Daten (`data/*.csv`)        |
| `srv/`             | Service-Modell mit den Berechtigungen (`@requires` / `@restrict`) |
| `app/products/`    | Fiori-Elements-UI (UI5) inkl. `xs-app.json` für den App Router    |
| `jwt/`             | Demo-Material rund um JSON Web Tokens → siehe unten               |
| `http/`            | Ausführbare Auth-Beispiele (REST-Client & curl) → siehe unten     |
| `xs-security.json` | XSUAA-Sicherheitsbeschreibung (Scopes, Rollen) für Produktion     |
| `mta.yaml`         | Multi-Target-Application-Deskriptor für BTP-Deployment            |
| `package.json`     | Abhängigkeiten + CAP-Konfiguration (`cds.requires`, Auth-Profile) |

### Datenmodell

- **Products** – Produkte mit `name`, `description`, `price`
- **Reviews** – Bewertungen (`title`, `comment`, `rating` 1–5), zugeordnet zu
  einem Produkt

Beide Entitäten erben `cuid` (UUID-Schlüssel) und `managed` (`createdBy`,
`createdAt`, …). `createdBy` wird für die instanzbasierte Berechtigung der
Reviews genutzt.

## Authentifizierung & Autorisierung

### Umschalten per Konfiguration – nicht per Code

Auth-Strategie wird ausschließlich über `cds.requires.auth.kind` gesteuert
(siehe [`package.json`](package.json)). Der Anwendungscode bleibt unverändert:

| `kind`             | Wann?              | Beschreibung                                 |
| ------------------ | ------------------ | -------------------------------------------- |
| `dummy`            | nur Entwicklung    | alle Prüfungen aus                           |
| `mocked` / `basic` | Entwicklung & Test | Test-Nutzer mit Passwort & Rollen im Code    |
| `jwt`              | Produktion         | prüft eingehende, signierte Token            |
| `xsuaa`            | Produktion         | Token **und Rollen** von BTP (in dieser App) |
| `ias`              | Produktion         | zentrale Identität (Identity Authentication) |

In diesem Projekt:

```jsonc
"cds": {
  "requires": {
    "[development]": { "auth": { "kind": "mocked", "users": { … } } },
    "[production]":  { "db": "hana", "auth": "xsuaa" }
  }
}
```

### Berechtigungen im Modell (`srv/service.cds`)

- **`@requires: 'authenticated-user'`** auf dem Service → es kommt nur jemand
  hinein, der auch angemeldet ist
- **`@restrict`** je Entität regelt, welche Rolle welche Aktion ausführen darf:
  - `Viewer` → `READ`
  - `Admin` → `*` (READ + CREATE + UPDATE + DELETE)
  - Reviews zusätzlich: jeder angemeldete Nutzer darf **seine eigenen** Reviews
    bearbeiten (`where: 'createdBy = $user'` – instanzbasierte Berechtigung)

Die Rollennamen `Viewer` / `Admin` sind frei wählbar, müssen aber **überall
gleich** heißen:

1. in `@restrict … to:` (`srv/service.cds`)
2. bei den Test-Nutzern (`package.json` → `auth.users.*.roles`) – für `mocked`
3. in `xs-security.json` (`role-templates`) – für `xsuaa`

### Vertrauenskette (Produktion)

`xs-security.json` definiert Scopes/Rollen → im BTP-Cockpit werden sie zu
**Rollensammlungen** gebündelt → eine Sammlung wird einem Nutzer zugewiesen →
damit greift das jeweilige Recht im Token.

## Demo-Ordner: `jwt/` und `http/`

### `jwt/` – der digitale Ausweis

Material, um zu zeigen, dass ein Token **kein Passwort**, sondern ein signierter
und fälschungssicherer Ausweis ist.

- [`jwt/sample-jwt.txt`](jwt/sample-jwt.txt) – ein **Beispiel-Token** (RS256),
  das alle typischen Claims enthält: Aussteller (`iss`), Nutzer (`sub` /
  `email`), Rollen/Scopes (`Viewer`, `Admin`) und Attribute (`Country`,
  `Department`)
- [`jwt/README.md`](jwt/README.md) – Anleitung, den Token auf <https://jwt.io>
  zu entschlüsseln (Variante A: Beispiel-Token, Variante B: echtes Token aus
  eurer BTP via XSUAA-Service-Key)

> Hinweis: Beispiel-Token ist nur zur Anschauung gedacht und bei keiner echten
> Instanz gültig.

### `http/` – Auth live ausprobieren

Ausführbare Beispiele, welche die Auth-Regeln gegen das lokal laufende Backend
(`cds watch`, Port 4004) zeigen:

- [`http/auth-demo.http`](http/auth-demo.http) – für die
  **VS-Code-REST-Client-Erweiterung**: jede Anfrage einzeln per Klick ausführbar
- [`http/auth-demo.sh`](http/auth-demo.sh) – dasselbe als **Shell-Skript** mit
  `curl` (`bash http/auth-demo.sh`)

Beide durchlaufen dieselben fünf Fälle:

| # | Anfrage            | Erwartung          |
| - | ------------------ | ------------------ |
| 1 | GET ohne Anmeldung | `401 Unauthorized` |
| 2 | GET als `viewer`   | `200 OK`           |
| 3 | GET als `admin`    | `200 OK`           |
| 4 | POST als `viewer`  | `403 Forbidden`    |
| 5 | POST als `admin`   | `201 Created`      |

→ Anschaulich der Unterschied zwischen **Authentifizierung** (Fall 1 vs. 2/3)
und **Autorisierung** (Fall 4 vs. 5).

## Deployment auf SAP BTP

Das Deployment erfolgt als **Multi-Target Application**
([`mta.yaml`](mta.yaml)):

- durchgängige **XSUAA**-Authentifizierung (`auth: xsuaa` im
  `[production]`-Profil)
- **Managed App Router** über das HTML5 Application Repository
- Weiterreichen des Nutzer-Tokens ans Backend (`HTML5.ForwardAuthToken`)
- **CSRF-Schutz** bei Schreibzugriffen (`xs-app.json`)
- **HANA** als Datenbank in der Produktion

```bash
# MTA-Archiv bauen und deployen
mbt build                 # erzeugt mta_archives/*.mtar
cf deploy mta_archives/*.mtar
```

## Weiterführend

- CAP-Dokumentation: <https://cap.cloud.sap/docs/>
- CAP Authorization: <https://cap.cloud.sap/docs/guides/security/authorization>
