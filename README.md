# my nixos config flake

Deploy on remote using [`deploy-rs`](https://github.com/serokell/deploy-rs) or

```sh
nixos-rebuild \
  --flake .#remote_host \
  --use-remote-sudo \
  --target-host remote_host \
  --build-host remote_host \
  switch
```

## Structure

```
machines                — machine-specific config;
└─ {hostname}             all are auto-imported
   ├─ configuration.nix
   ├─ hardware-configuration.nix
   └─ home.nix
modules                 — modules; all auto-imported,
├─ home/…                 switch on in flake.nix
└─ ….nix
secrets                 — secrets; add here and to
├─ encrypted/…            machine-specific configs
└─ secrets.nix
flake.lock
flake.nix
README.md
```

Sections from machine-specific configs are broken out into modules when the section is or can be reused, or if it becomes too big and deserves its own file.
