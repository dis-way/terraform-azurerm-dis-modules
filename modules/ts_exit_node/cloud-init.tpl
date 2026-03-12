#cloud-config
package_update: true
package_upgrade: true
package_reboot_if_required: true

packages:
  - dnf-automatic
  - nftables

write_files:
  - path: /etc/dnf/automatic.conf
    content: |
      [commands]
      upgrade_type = security
      apply_updates = yes
      reboot = when-needed
      reboot_command = "shutdown -r +5 'Rebooting for security updates'"
  - path: /etc/systemd/system/dnf-automatic.timer.d/override.conf
    content: |
      [Timer]
      OnCalendar=
      OnCalendar=*-*-* 04:00:00 Europe/Oslo
  - path: /usr/local/bin/update-nftables
    permissions: '0750'
    content: |
      #!/bin/bash
      set -euo pipefail

      ALLOWED_PORTS="{ 22, 80, 443, 5432, 6432, 6443 }"
      CONF=/etc/nftables-exit.conf

      printf 'table inet exit_filter {}\n' > "$CONF"
      printf 'flush table inet exit_filter\n' >> "$CONF"
      printf 'table inet exit_filter {\n' >> "$CONF"
      printf '  chain forward {\n' >> "$CONF"
      printf '    type filter hook forward priority 0; policy drop;\n' >> "$CONF"
      printf '    ct state established,related accept\n' >> "$CONF"
      printf '    iifname "tailscale0" meta l4proto { tcp, udp } th dport 53 accept\n' >> "$CONF"
      printf '    iifname "tailscale0" ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } accept\n' >> "$CONF"
      printf '    iifname "tailscale0" ip6 daddr fd00::/8 accept\n' >> "$CONF"
      printf '    iifname "tailscale0" meta l4proto tcp th dport %s accept\n' "$ALLOWED_PORTS" >> "$CONF"
      printf '    iifname "tailscale0" meta l4proto udp th dport 443 accept\n' >> "$CONF"
      printf '    iifname "tailscale0" drop\n' >> "$CONF"
      printf '  }\n' >> "$CONF"
      printf '}\n' >> "$CONF"

      nft -f "$CONF"
      echo "nftables rules updated"
  - path: /etc/gai.conf
    content: |
      # /etc/gai.conf — prefer IPv6 ULA over IPv4 (RFC 6724 policy table)
      #
      # Precedence: higher = more preferred
      # Label: source/destination pairs with the same label are preferred

      label  ::1/128        0    # loopback
      label  ::/0           1    # native IPv6 (GUA)
      label  ::ffff:0:0/96  4    # IPv4-mapped
      label  2002::/16      2    # 6to4
      label  2001::/32      5    # Teredo
      label  fc00::/7       1    # ULA — same label as ::/0 so ULA src matches IPv6 dst
      label  ::/96          3    # deprecated IPv4-compat
      label  fec0::/10     11    # deprecated site-local
      label  3ffe::/16     12    # deprecated 6bone

      # Precedence table — fc00::/7 raised to 45, above IPv4 (35)
      precedence ::1/128       50
      precedence ::/0          40
      precedence fc00::/7      45   # ULA: above IPv4, below loopback
      precedence ::ffff:0:0/96 35   # IPv4-mapped (native IPv4)
      precedence 2002::/16     30   # 6to4
      precedence 2001::/32      5   # Teredo
      precedence ::/96          1
      precedence fec0::/10      1
      precedence 3ffe::/16      1
  - path: /etc/systemd/system/nftables-update.service
    content: |
      [Unit]
      Description=Apply nftables exit node rules
      After=network-online.target
      Wants=network-online.target

      [Service]
      Type=oneshot
      ExecStart=/usr/local/bin/update-nftables
      RemainAfterExit=yes
  - path: /etc/systemd/system/nftables-update.timer
    content: |
      [Unit]
      Description=Reapply nftables exit node rules on boot

      [Timer]
      OnBootSec=60
      Persistent=true

      [Install]
      WantedBy=timers.target

runcmd:
  - mkdir -p /etc/systemd/system/dnf-automatic.timer.d
  - systemctl daemon-reload
  - systemctl enable --now dnf-automatic.timer
  - echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.d/99-tailscale.conf
  - echo 'net.ipv6.conf.all.forwarding = 1' >> /etc/sysctl.d/99-tailscale.conf
  - sysctl -p /etc/sysctl.d/99-tailscale.conf
  - curl -fsSL https://pkgs.tailscale.com/stable/rhel/9/tailscale.repo -o /etc/yum.repos.d/tailscale.repo
  - dnf install -y tailscale
  - systemctl enable --now tailscaled
  - timeout 30 bash -c 'until systemctl is-active tailscaled; do sleep 1; done'
  - semanage port -a -t ssh_port_t -p tcp 41641 || true
  - tailscale up --login-server=https://headscale.altinn.cloud --ssh --auth-key=${tailscale_auth_key} --advertise-exit-node --accept-dns=false
  - systemctl enable --now nftables-update.timer
  - systemctl start nftables-update.service
