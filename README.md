# Abteilungsbildschirm

Interaktive Touchscreen-Webanwendung als zentrale Informationszentrale pro Abteilung.
Single-File-App (`index.html`) — läuft ohne Build direkt im Browser.

**Live:** https://codeer-12.github.io/abteilungs-bildschirm/

## Modi

| URL | Modus |
|---|---|
| `/` | Normal — Login-Screen, alle Rollen |
| `/?kiosk=prod` | **Kiosk** — kein Login, nur Anzeige, Abteilung fix (`prod`, `qa`, `maint`, `log`) |

Kiosk-URL für ScreenCloud: `https://codeer-12.github.io/abteilungs-bildschirm/?kiosk=prod`

## Notfall-Override

Admins: 🚨-Button in der Topbar → Titel + Meldung → erscheint sofort bildschirmfüllend.
Mit aktivem Backend-Sync auf **allen** Geräten in Echtzeit; ohne Backend nur im selben Browser.
Entwarnung über denselben Button.

## Backend einrichten (Appwrite) — echter Geräte-Sync

Ohne Backend läuft die App rein lokal (localStorage, kein Sync zwischen Geräten).
Mit Appwrite (gratis Tier reicht): zentrale Datenbank, echter Dateispeicher,
Live-Sync auf alle Bildschirme, echte PDF-/Bild-Vorschau.

### Schritt für Schritt

1. **Konto:** https://cloud.appwrite.io → registrieren (gratis)
2. **Projekt** anlegen → Region wählen (z.B. Frankfurt) → **Projekt-ID** notieren
3. **Plattform hinzufügen:** Project Settings → Platforms → *Web App* →
   Hostname: `codeer-12.github.io` (und `localhost` fürs lokale Testen)
4. **Datenbank:** Databases → Create database (Name egal) → **Database-ID** notieren
5. **Tabelle:** Create table → Name `state` → **Table-ID** notieren
   - Spalte anlegen: Key `json`, Typ **Long text** (bzw. String mit großer Länge), nicht required
   - **Settings → Permissions:** Role `Any` → Read ✓, Create ✓, Update ✓
6. **Storage:** Buckets → Create bucket → **Bucket-ID** notieren
   - Permissions: Role `Any` → Read ✓, Create ✓, Update ✓, Delete ✓
   - Erlaubte Dateitypen: pdf, doc, docx, xls, xlsx, ppt, pptx, png, jpg, jpeg, gif, svg
   - Max. Dateigröße: 25 MB
7. **IDs eintragen** in `index.html`, Block `const BACKEND = {...}` (ganz oben im Script):

```js
const BACKEND = {
  endpoint:  'https://fra.cloud.appwrite.io/v1', // deine Region
  projectId: '…',
  databaseId:'…',
  tableId:   '…',
  rowId:     'state',
  bucketId:  '…'
};
```

8. Committen & pushen → GitHub Pages baut neu → fertig.
   Grüner Punkt in der Topbar = Sync verbunden.

### ⚠️ Sicherheitshinweis (Prototyp-Stufe)

Die Permissions oben (`Any` darf schreiben) sind **bewusst offen** für den schnellen Start —
jeder mit der URL könnte Daten ändern. Für den Produktivbetrieb härten:

- Appwrite-Auth (E-Mail/Passwort oder SSO) aktivieren
- Schreibrechte auf Role `users` bzw. Teams beschränken
- Rollenprüfung serverseitig (Appwrite Functions) statt nur im Client

## Rollen (Demo-Login)

| Rolle | Rechte |
|---|---|
| Mitarbeiter/in | Nur lesen, nur freigegebene Inhalte |
| Abteilungs-Admin | Inhalte + Dokumente der eigenen Abteilung |
| System-Admin | Alles inkl. Benutzer- & Abteilungsverwaltung |

## Stack

- Ein HTML-File, kein Framework, kein Build
- Persistenz: localStorage, optional Appwrite (TablesDB + Storage + Realtime)
- Hosting: GitHub Pages
