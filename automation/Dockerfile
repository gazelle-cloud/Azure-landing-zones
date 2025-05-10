FROM mcr.microsoft.com/azure-powershell:mariner-2

COPY ./automation/scripts /scripts

WORKDIR /scripts

ENTRYPOINT ["pwsh"]

CMD ["init.ps1"]