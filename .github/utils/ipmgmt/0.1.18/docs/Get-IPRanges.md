---
external help file: ipmgmt-help.xml
Module Name: ipmgmt
online version:
schema: 2.0.0
---

# Get-IPRanges

## SYNOPSIS
This command is to find a free range of a given size among the list of occupied ranges of a "base" network

## SYNTAX

```
Get-IPRanges -Networks <Object> -BaseNet <IPNetwork> -CIDR <Int32> [<CommonParameters>]
```

## DESCRIPTION
This command is to find a free range of a given size among the list of occupied ranges of a "base" network. It takes a list of networks of some "base" range and a CIDR/Length of a subnet you need and then searches through the list to find a free slot of the requested size. The command uses ipnetwork2 library, compiled for netstandard.

## EXAMPLES

### Example 1
```powershell
PS C:\>  Get-IPRanges -Networks "10.10.5.0/24", "10.10.7.0/24" -CIDR 22 -BaseNet "10.10.0.0/16"
```

Base network is "10.10.0.0/16", the list of ranges already in use is ("10.10.5.0/24", "10.10.7.0/24"), we are looking for a free range of a size /22

## PARAMETERS

### -BaseNet
General "base" network, that "supernets" or contains all ranges provided for the "Networks" parameter

```yaml
Type: IPNetwork
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CIDR
The length of the range we search for

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Networks
The list of ranges of the "base" network which are in use

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[ipnetwork2 library](https://github.com/lduchosal/ipnetwork)
[cloudmgmt module](https://github.com/eosfor/cloudmgmt)
[ipmgmt module](https://github.com/eosfor/ipmgmt)