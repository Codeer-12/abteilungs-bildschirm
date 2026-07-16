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

## Backend einrichten (Supabase) — echter Geräte-Sync

Ohne Backend läuft die App rein lokal (localStorage, kein Sync zwischen Geräten).
Mit Supabase (gratis Tier reicht): zentrale Datenbank, echter Dateispeicher,
Live-Sync auf alle Bildschirme (Realtime), echte PDF-/Bild-Vorschau.

### Schritt für Schritt

1. **Konto:** https://supabase.com → registrieren (gratis)
2. **Projekt** anlegen (Region z.B. Frankfurt) → warten bis bereit
3. **SQL ausführen:** Dashboard → **SQL Editor** → Inhalt von
   [`supabase_setup.sql`](supabase_setup.sql) einfügen → **Run**
   (legt Tabelle `app_state`, Realtime und Storage-Bucket `dokumente` an)
4. **Schlüssel holen:** Settings → API →
   - **Project URL** (z.B. `https://abcdefgh.supabase.co`)
   - **anon public key**
5. **Eintragen** in `index.html`, Block `const BACKEND = {...}` (ganz oben im Script):

```js
const BACKEND = {
  url:     'https://<projekt-ref>.supabase.co',
  anonKey: '<anon public key>',
  table:   'app_state',
  rowId:   'state',
  bucketId:'dokumente'
};
```

6. Committen & pushen → GitHub Pages baut neu → fertig.
   Grüner Punkt in der Topbar = Sync verbunden.

### ⚠️ Sicherheitshinweis (Prototyp-Stufe)

Die Policies im Setup-SQL sind **bewusst offen** (anon darf schreiben) —
jeder mit der URL könnte Daten ändern. Der anon key im Frontend ist bei Supabase
normal und vorgesehen; die Absicherung passiert über Row Level Security.
Für den Produktivbetrieb härten (Vorlage steht auskommentiert im SQL):

- Supabase Auth (E-Mail/Passwort oder SSO) aktivieren
- Schreib-Policies auf `authenticated` umstellen
- Rollenprüfung serverseitig statt nur im Client

## Rollen (Demo-Login)

| Rolle | Rechte |
|---|---|
| Mitarbeiter/in | Nur lesen, nur freigegebene Inhalte |
| Abteilungs-Admin | Inhalte + Dokumente der eigenen Abteilung |
| System-Admin | Alles inkl. Benutzer- & Abteilungsverwaltung |

## Stack

- Ein HTML-File, kein Framework, kein Build
- Persistenz: localStorage, optional Supabase (Postgres + Storage + Realtime)
- Hosting: GitHub Pages
