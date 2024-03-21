# my nixos config flake

## Applying config to remote

```sh
nixos-rebuild \
  --flake .#remote_host \
  --use-remote-sudo \
  --target-host remote_host \
  --build-host remote_host \
  switch
```

It currently asks for the remote user's sudo password three times, idk why.
