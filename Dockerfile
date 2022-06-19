FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine3.16 AS base
WORKDIR /app
EXPOSE 7166
EXPOSE 44401

ENV ASPNETCORE_URLS=http://+:7166

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine3.16 AS build
WORKDIR /src
COPY ["dotnet_spa_react.csproj", "./"]
RUN dotnet restore "dotnet_spa_react.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "dotnet_spa_react.csproj" -c Release -o /app/build

# install node for building react
# https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
RUN apk add nodejs npm

FROM build AS publish
RUN dotnet publish "dotnet_spa_react.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "dotnet_spa_react.dll"]
