## NixOS Configuration

My configuration files for NixOS.
Uses [deploy-rs](https://github.com/serokell/deploy-rs) for deployments.

### Deployment

Update _my-node_ by invoking `LOCAL_KEY=nix.key deploy .#my-node`.

### Logseq sync server

Self-hosted [Logseq DB sync](https://github.com/yshalsager/logseq-selfhost)
on `desktop` (WSL2), declared in `modules/logseq-sync.nix`:

- `podman-logseq-sync`: the sync server, rootless podman under the
  `logseq-sync` user (home-manager), published on `127.0.0.1:8787` only.
  Data lives in `/home/logseq-sync/data` (`index.sqlite`,
  `graphs/<id>/db.sqlite`, `assets/`).
- `podman-logseq-tailscale`: a Tailscale sidecar sharing the server's network
  namespace. It is its own tagged node (`svc-desktop`, `tag:server`) and hosts
  the Tailscale Service `svc:logseq`, terminating TLS for
  `https://logseq.tail1968e.ts.net`.

`desktop` itself stays a user-owned node. Do not tag it: tagged devices cannot
Tailscale-SSH into user-owned devices.

#### Tailscale console (one-time)

1. **DNS**: enable MagicDNS and HTTPS Certificates.
2. **Access controls**: merge into the policy:

   ```jsonc
   {
     "tagOwners": {
       "tag:server": ["autogroup:admin"],
     },
     "grants": [
       {
         "src": ["alain.peteut@…"], // own login only, not autogroup:member
         "dst": ["svc:logseq"],
         "ip": ["443"],
       },
     ],
     "autoApprovers": {
       "services": {
         "svc:logseq": ["tag:server"],
       },
     },
   }
   ```

3. **Services**: Advertise → Define a Service, name `logseq`, endpoint
   `tcp:443`, no tags. Do this before the sidecar first starts (see below).
4. **Settings → Keys**: generate an auth key: single-use, not ephemeral,
   pre-approved, tag `tag:server`.

#### Commissioning on `desktop`

1. Store the auth key (only used for the first login, `TS_AUTH_ONCE`; the node
   state persists in `/home/logseq-sync/tailscale`):

   ```sh
   echo 'TS_AUTHKEY=tskey-auth-...' | sudo install -m 600 -o logseq-sync -g logseq-sync /dev/stdin /home/logseq-sync/tailscale.env
   ```

   Afterwards the value may be emptied; keep the file, the unit requires it.
2. Deploy `desktop`.
3. Check both units and the sidecar:

   ```sh
   sudo machinectl shell logseq-sync@ /run/current-system/sw/bin/systemctl --user status podman-logseq-sync podman-logseq-tailscale
   sudo machinectl shell logseq-sync@ /run/current-system/sw/bin/podman logs --tail 50 logseq-tailscale
   ```

4. Console → Services → `logseq` must show `svc-desktop` as an approved host
   and the Service as Connected. If the sidecar advertised before the Service
   was defined, it is not listed; re-advertise:

   ```sh
   sudo machinectl shell logseq-sync@ /run/current-system/sw/bin/podman exec logseq-tailscale tailscale serve drain svc:logseq
   sudo machinectl shell logseq-sync@ /run/current-system/sw/bin/podman exec logseq-tailscale tailscale serve advertise svc:logseq
   ```

5. From another tailnet device:

   ```sh
   curl -s https://logseq.tail1968e.ts.net/health   # {"ok":true}
   ```

   The first HTTPS request can take a while (certificate issuance).

#### Clients

Windows hosts (`desktop`, `ws-27`) need their own Tailscale node; WSL guests
must use NAT networking mode (not mirrored).

```powershell
scoop bucket add extras
scoop install tailscale                  # elevated
Get-Service Tailscale                    # if stopped (elevated):
Start-Service Tailscale; Set-Service Tailscale -StartupType Automatic
tailscale up --unattended --hostname=<host>-win   # e.g. desktop-win
curl.exe -s https://logseq.tail1968e.ts.net/health
```

`--unattended` keeps the service running without the tray app; without it the
service shuts down as soon as the CLI disconnects, mid-login (stuck in
"Tailscale is starting", state `NoState`).

The sync server accepts any valid Logseq account, hence the grant is limited
to the own login rather than `autogroup:member`.

In the Logseq 2.x DB client: set Settings → Advanced → Sync Server URL to
`https://logseq.tail1968e.ts.net`, enable "Use Logseq Sync Beta" and log in
with the Logseq account; the sync button only appears when logged in. On first
login the client asks for a password for remote graphs: it encrypts the graphs
end to end and is needed on every new device. Store it in the password
manager; without it the server copy and its backups cannot be decrypted.
Upload the graph (`notes`) from one client only; others join the existing
remote graph.

Verify on `desktop` (expect one user, one graph, and
`data/graphs/<id>/db.sqlite`):

```sh
sudo -u logseq-sync nix run nixpkgs#sqlite -- /home/logseq-sync/data/index.sqlite 'select count(*) from users; select count(*) from graphs;'
sudo find /home/logseq-sync/data -type f -exec ls -l {} +
```

Server logs:

```sh
sudo machinectl shell logseq-sync@ /run/current-system/sw/bin/podman logs -f logseq-sync
```

#### Backup and restore

The sync server is the only server-side copy of the graphs. A daily restic job
(`restic-backups-logseq-sync.service`, as `logseq-sync`) copies the databases
with SQLite's online backup into `/home/logseq-sync/backup-staging` and
snapshots them together with `data/assets` into
`/mnt/c/Users/alain/OneDrive/backup/logseq-sync` (OneDrive, encrypted). Missed
runs catch up at the next boot. Retention: 7 daily, 4 weekly, 6 monthly,
1 yearly.

Commissioning, once:

```sh
sudo chown logseq-sync: /mnt/c/Users/alain/OneDrive/backup/logseq-sync
head -c 32 /dev/urandom | base64 | sudo install -m 600 -o logseq-sync -g logseq-sync /dev/stdin /home/logseq-sync/restic.password
sudo cat /home/logseq-sync/restic.password   # store in the password manager!
```

In Explorer, set the `backup` folder to "Always keep on this device". Then run
the first backup and check it:

```sh
sudo systemctl start restic-backups-logseq-sync
sudo -u logseq-sync restic-logseq-sync snapshots
sudo -u logseq-sync restic-logseq-sync check
```

Restore (test into a scratch directory first):

```sh
sudo -u logseq-sync restic-logseq-sync restore latest --target /home/logseq-sync/restore-test
# stop the server, replace data/ with the restored files:
#   backup-staging/{index.sqlite,graphs/<id>/db.sqlite} -> data/...
#   data/assets -> data/assets
sudo machinectl shell logseq-sync@ /run/current-system/sw/bin/systemctl --user stop podman-logseq-sync
sudo machinectl shell logseq-sync@ /run/current-system/sw/bin/systemctl --user start podman-logseq-sync
```

### TODO

- [ ] remove clutter, move more stuff to `./modules`
- [ ] secret management
