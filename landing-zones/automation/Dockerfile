FROM mcr.microsoft.com/azure-powershell:latest

COPY ./landing-zones/automation/scripts /scripts

WORKDIR /scripts

ENTRYPOINT ["pwsh"]

CMD ["init.ps1"]