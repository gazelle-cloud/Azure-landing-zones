---
external help file: ipmgmt-help.xml
Module Name: ipmgmt
online version:
schema: 2.0.0
---

# Get-VLSMBreakdown

## SYNOPSIS
This command is to calculate the network range breakdown to subnets, given the list of subnets and their sizes

## SYNTAX

```
Get-VLSMBreakdown [-Network] <IPNetwork> [-SubnetSize] <Array> [<CommonParameters>] [-SubnetSizeCidr] <Array> [<CommonParameters>]
```

## DESCRIPTION
This command is to calculate the network range breakdown to subnets, given the list of subnets and their sizes. Command takes a list of subnets in a form of hashtable with subnet names and their sizes, and the IP range to break in a form of a CIDR notation. Then in calculates the breakdown and returns it. If it is not possible - nothing is returned.

## EXAMPLES

### Example 1
```powershell
PS C:\> $subnets = @{type = "GTWSUBNET"; size = 30},
>> @{type = "DMZSUBNET"; size = 62},
>> @{type = "EDGSUBNET"; size = 30},
>> @{type = "APPSUBNET"; size = 62},
>> @{type = "CRESUBNET"; size = 62}
PS C:\> Get-VLSMBreakdown -Network 10.10.5.0/24 -SubnetSize $subnets
```

The variable $subnets contains subnets, or subnet zones we want to use.
- type: specifies the name of the zone or subnet.
- size: sets the maximum number of IPs which will be available for the subnet.

### Example 2
```powershell
PS C:\> $subnets = @{type = "GTWSUBNET"; cidr = 27},
>> @{type = "DMZSUBNET"; cidr = 26},
>> @{type = "EDGSUBNET"; cidr = 27},
>> @{type = "APPSUBNET"; cidr = 26},
>> @{type = "CRESUBNET"; cidr = 26}
PS C:\> Get-VLSMBreakdown -Network 10.10.5.0/24 -SubnetSizeCidr $subnets
```

The variable $subnets contains subnets, or subnet zones we want to use. 
- type: specifies the name of the zone or subnet. 
- cidr: specifies the address range based on Cidr notation.

## PARAMETERS

### -Network
The network range we want to break

```yaml
Type: IPNetwork
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubnetSize
The array of subnets in a form of a hashtable @{type = "<name>"; size = <int>} we want to put into the specified network range

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubnetSizeCidr
The array of subnets in a form of network cidr notation @{type = "<name>"; cidr = <int>} we want to put into the specified network range

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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