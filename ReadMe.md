# Cloud Screen Resolution

Sets screen resolution on Windows server.

Selenium testing in the cloud at a specific resolution is a use case
where this comes in handy.

This package does the following:

- Creates local user account to Remote Desktop Protocol (RDP) - at
  specified screen resolution (default is 1920x1080) - into another
  user account (default is user executing choco install) on same
  Windows server hosted in the cloud
- Enables [Remote Desktop connections](https://technet.microsoft.com/en-us/library/cc722151%28v=ws.10%29.aspx)
- Bypasses [Identity Of The Remote Computer Verification](http://www.mytecbits.com/microsoft/windows/rdp-identity-of-the-remote-computer)

## Quick Start

Set screen resolution to 1920x1080 (default):

```
choco install -y cloud-screen-resolution --params "'/password:redacted /rdpPassword:redacted'"
```

Set screen resolution to 1366×768:

```
choco install -y cloud-screen-resolution --params "'/width:1366 /height:768 /password:redacted /rdpPassword:redacted'"
```

### AutoLogon

To automatically set Cloud Screen Resolution on server start, you need
to install the autologon package and run
`autologon <username> <domain> <password>` once to set it up.

```
choco install -y autologon
autologon rdp_local localhost redacted
```

## Usage

### Package Parameters

The following package parameters can be set:

- `password:` - Password of account to RDP into (required).
    Prompts user for password when it is not provided.
- `rdpPassword:` - RDP password. Defaults to `password` when it is
    not provided.
- `username:` - Username of account to RDP into.
    Default: `$env:UserName`.
- `rdpUsername:` - RDP username. Default: `rdp_local`.
- `width:` - Display width in pixels. Default: `1920`.
- `height:` - Display height in pixels. Default: `1080`.
- `rdpGroups:` - RDP group members.
    Default: `@('Administrators', 'Remote Desktop Users')`.

These parameters can be passed to the installer with the use of
`--params`. For example: `--params "'/password:redacted'"`.
