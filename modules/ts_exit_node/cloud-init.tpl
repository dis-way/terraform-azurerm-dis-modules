#cloud-config
package_update: true
package_upgrade: true
package_reboot_if_required: true

packages:
  - dnf-automatic
  - ansible-core
  - python3-cryptography

write_files:
  - path: /etc/github-app/app-id
    permissions: '0644'
    content: |
      3104534

  - path: /etc/github-app/installation-id
    permissions: '0644'
    content: |
      116758437

  - path: /etc/github-app/private-key.pem
    permissions: '0600'
    content: |
      ${github_app_private_key}

  - path: /usr/local/bin/github-app-token
    permissions: '0750'
    content: |
      #!/usr/bin/env python3
      import time, json, base64, urllib.request
      from cryptography.hazmat.primitives import hashes, serialization
      from cryptography.hazmat.primitives.asymmetric import padding

      app_id = open('/etc/github-app/app-id').read().strip()
      installation_id = open('/etc/github-app/installation-id').read().strip()
      private_key = serialization.load_pem_private_key(
          open('/etc/github-app/private-key.pem', 'rb').read(), password=None)

      def b64url(data):
          return base64.urlsafe_b64encode(data).rstrip(b'=').decode()

      now = int(time.time())
      header = b64url(json.dumps({'alg': 'RS256', 'typ': 'JWT'}).encode())
      body = b64url(json.dumps({'iat': now - 60, 'exp': now + 540, 'iss': app_id}).encode())
      message = f'{header}.{body}'.encode()
      signature = b64url(private_key.sign(message, padding.PKCS1v15(), hashes.SHA256()))
      jwt = f'{header}.{body}.{signature}'

      req = urllib.request.Request(
          f'https://api.github.com/app/installations/{installation_id}/access_tokens',
          method='POST',
          headers={
              'Authorization': f'Bearer {jwt}',
              'Accept': 'application/vnd.github+json',
              'X-GitHub-Api-Version': '2022-11-28'
          }
      )
      with urllib.request.urlopen(req) as resp:
          print(json.loads(resp.read())['token'])

  - path: /usr/local/bin/ansible-pull-wrapper
    permissions: '0750'
    content: |
      #!/bin/bash
      set -euo pipefail
      TOKEN=$(/usr/local/bin/github-app-token)
      exec ansible-pull \
        --url "https://x-access-token:$${TOKEN}@github.com/dis-way/adminservices.git" \
        --checkout main \
        ansible/ts-exit-node-playbooks.yml

  - path: /etc/tailscale/auth-key
    permissions: '0600'
    content: |
      ${tailscale_auth_key}

  - path: /etc/dnf/automatic.conf
    content: |
      [commands]
      upgrade_type = default
      apply_updates = yes
      reboot = when-needed
      reboot_command = "shutdown -r +5 'Rebooting for security updates'"

  - path: /etc/systemd/system/dnf-automatic.timer.d/override.conf
    content: |
      [Timer]
      OnCalendar=
      OnCalendar=Mon..Fri *-*-* 04:00:00 Europe/Oslo

  - path: /etc/systemd/system/ansible-pull.service
    content: |
      [Unit]
      Description=Run ansible-pull to apply configuration
      After=network-online.target
      Wants=network-online.target

      [Service]
      Type=oneshot
      ExecStart=/usr/local/bin/ansible-pull-wrapper
      User=root

runcmd:
  - mkdir -p /etc/systemd/system/dnf-automatic.timer.d
  - systemctl daemon-reload
  - systemctl enable --now dnf-automatic.timer
  - ansible-galaxy collection install ansible.posix community.general
  - systemctl start ansible-pull.service
