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
