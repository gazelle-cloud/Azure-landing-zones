# Platform management

Platform does not have so called 'management' subscription, and it operates at the management group level only.

```
● Tenant Root
  └── Gazelle
      ├── RBAC
      │   ├── Break Glass
      │   └── Platform Engineer
      │   
      ├── subscription-bank
      │   └── RBAC: Reader → [App Engineers, Platform Engineers]
      │
      └── oases
          ├── allowed-allowedResources
          ├── allowed-allowedLocations
          ├── deny-denyLocalAuthentication
          ├── deny-denyPublicNetworkAccess
          ├── deny-denyCrossTenantReplication
          └── deny-denyWeakTLS
```

What's defined at `oases` applies to every landing zone 