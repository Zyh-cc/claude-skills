---
name: linux-routing-debug
description: Debug Linux multi-NIC routing issues where traffic exits the wrong network interface. Use this when a device with multiple network cards (e.g., one for internet, one for LAN) fails external connections with "No route to host" or traffic goes out the wrong interface.
---

## Diagnosis

### Step 1: Find which interface traffic is using

```bash
ping -c 3 <target>
```

If output shows `From 172.16.0.100 ... Destination Host Unreachable` — traffic is exiting the LAN interface, not the internet interface.

### Step 2: Check routing table

```bash
ip route show
```

Look at `default` entries — lower metric = higher priority:
```
default via 172.16.0.1 dev eth1  metric 20101  ← wrong (LAN)
default via 192.168.1.1 dev eth0  metric 20102  ← correct (internet)
```

### Step 3: Confirm which NIC is which

```bash
ip addr show
```

## Fix

### Temporary (lost on reboot)

```bash
sudo ip route del default via <wrong-gateway> dev <wrong-interface>
# Example:
sudo ip route del default via 172.16.0.1 dev eth1
```

### Permanent (NetworkManager)

```bash
nmcli connection show
sudo nmcli connection modify "<connection-name>" ipv4.never-default yes
sudo nmcli connection up "<connection-name>"
```

To revert: set `ipv4.never-default no`

### Verify

```bash
ip route show     # Confirm wrong default route is gone
ping -c 3 <target>
```

## Notes

- Removing wrong default route does NOT break LAN — subnet routes (e.g., `172.16.0.0/16 dev eth1`) remain intact
- `nmcli` connection name ≠ interface name; use `nmcli connection show` to find it
- Temporary fix (`ip route del`) resets on reboot; use nmcli for persistence
