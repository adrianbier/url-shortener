# syntax=docker/dockerfile:1
# HA 1: Optimiertes Multi-Stage-Image fuer ASP.NET Core 10.
# Build: docker build -t url-shortener:optimized .

# Stage 1: Kompilieren mit dem grossen SDK-Image.
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Projektdatei zuerst: NuGet-Restore wird bei reinen Codeaenderungen gecacht.
COPY UrlShortener.csproj ./
RUN dotnet restore UrlShortener.csproj

COPY . .
RUN dotnet publish UrlShortener.csproj -c Release -o /app/publish --no-restore /p:UseAppHost=false

# Stage 2: Nur ASP.NET-Runtime, kein SDK und kein Quellcode.
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

ENV ASPNETCORE_HTTP_PORTS=8080 \
    ASPNETCORE_ENVIRONMENT=Production

COPY --from=build /app/publish ./

# Der in offiziellen .NET-Images vorhandene, unprivilegierte App-User.
USER $APP_UID

EXPOSE 8080
ENTRYPOINT ["dotnet", "UrlShortener.dll"]
