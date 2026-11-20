# URL Shortener – Hausübung 1 (Docker und CI/CD)

ASP.NET Core 10 API mit PostgreSQL. Die ursprünglichen C#-Dateien sind unverändert.

## Anforderungen

- `Dockerfile.naive`: absichtlich ineffizienter Single-Stage-Build inklusive .NET SDK.
- `Dockerfile`: optimierter Multi-Stage-Build mit NuGet-Cache und kleinerem Runtime-Image.
- `compose.yaml`: startet API und PostgreSQL mit dauerhaftem Daten-Volume.
- `.github/workflows/ci.yml`: baut das optimierte Image und veröffentlicht es unter GitHub Packages (GHCR).
- `.dockerignore`: verhindert unnötige Dateien und lokale Zugangsdaten im Build-Kontext.

## 1. Dockerfiles testen

Im Ordner mit der `UrlShortener.csproj`:

```powershell
docker build -f Dockerfile.naive -t url-shortener:naive .
docker build -f Dockerfile -t url-shortener:optimized .
docker image ls url-shortener
```

Das optimierte Image sollte kleiner als das naive sein, da es nur die ASP.NET-Laufzeit beinhaltet.

## 2. Datenbank und Anwendung starten

```powershell
Copy-Item .env.example .env
docker compose up --build -d
docker compose ps
docker compose logs -f api
```

Adressen zum Testen:

- Swagger: http://localhost:8080/swagger
- Healthcheck: http://localhost:8080/healthz
- Beispiel-Weiterleitungen: http://localhost:8080/dotnet und http://localhost:8080/docker

In Swagger bei `POST /api/links` z. B. `{"url":"https://www.orf.at"}` eingeben. Anschließend den erzeugten Kurzlink testen.

```powershell
docker compose down        # stoppt Container, Volume bleibt erhalten
docker compose down -v     # ACHTUNG: löscht auch die Datenbankdaten
```

Das Beispiel-Passwort in `.env.example` ist nur für lokale Tests gedacht. Die Datei `.env` wird über `.gitignore` nicht hochgeladen. Die PostgreSQL-Datenbank ist nicht auf den Host-Port 5432 veröffentlicht.

## 3. Öffentliches GitHub-Repository erstellen

1. Auf GitHub ein **öffentliches** Repository `url-shortener` ohne zusätzliche Initialisierungsdateien erstellen.
2. Im VS-Code-Terminal im Projektordner ausführen (Nutzername ersetzen):

```powershell
git init
git branch -M main
git remote add origin https://github.com/<USERNAME>/url-shortener.git
git add .
git commit -m "Implement Hausuebung 1: Docker and GitHub Actions"
git push -u origin main
```

Falls ein Git-Repository oder eine `origin`-Remote bereits existiert, diese Initialisierungsschritte überspringen.

3. Unter GitHub **Actions** überprüfen, ob der Workflow `Docker CI - Build and Publish` erfolgreich ist.
4. Unter **Packages** kontrollieren, ob `url-shortener:latest` angezeigt wird. Bei Bedarf die **Package Visibility auf Public** setzen.
5. Als Abgabe den Link zum **öffentlichen GitHub-Repository** einreichen.

## 4. Hausübung 2 (später)

Erst nach Abgabe von Hausübung 1 wird dieselbe `.github/workflows/ci.yml` um **Trivy (Backend und Image)**, **SBOM-Erzeugung** und **SBOM-Attestation** erweitert. Diese Funktionen sind in der vorliegenden Version bewusst noch nicht enthalten.

## Anwendung

| Methode | Route | Funktion |
| --- | --- | --- |
| `POST` | `/api/links` | Kurzlink erzeugen |
| `GET` | `/api/links` | Kurzlinks anzeigen |
| `GET` | `/api/links/{code}` | Kurzlink anzeigen |
| `DELETE` | `/api/links/{code}` | Kurzlink löschen |
| `GET` | `/{code}` | Weiterleitung |
| `GET` | `/healthz` | Datenbank-Healthcheck |

Die Datenbankmigrationen und Beispiel-Links werden beim Start automatisch eingerichtet.
