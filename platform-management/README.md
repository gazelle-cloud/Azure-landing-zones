# Platform management

Platform does not have so called 'management' subscription, and it operates at the management group level only.

```
● Tenant Root
  └── Gazelle
      ├── RBAC
      │   ├── Break Glass
      │   └── Platform Engineer
      │
      ├── subscription-bank — reusable pool, drawn at landing zone creation, returned at sunset
      │   └── RBAC: Reader → [App Engineers, Platform Engineers]
      │
      └── oases — isolated, autonomous landing zones, self-service via PR
          └── Azure Policy
              ├── allowed-allowedResources
              ├── allowed-allowedLocations
              ├── deny-denyLocalAuthentication
              ├── deny-denyPublicNetworkAccess
              ├── deny-denyCrossTenantReplication
              └── deny-denyWeakTLS
```

## Deployment stacks

```
● Deployment stacks
  ├── platform
  │   ├── scope: Gazelle
  │   └── action-on-unmanage: deleteAll
  └── landing zone
      ├── scope: oases
      ├── action-on-unmanage: deleteAll
      ├── deny-settings-mode: denyWriteAndDelete
      ├── excluded-principals: Platform Engineers
      └── excluded-actions: [...]
```