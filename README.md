# AES67 Daemon Setup
## Scripts to setup the [AES67 Linux Daemon](https://github.com/bondagit/aes67-linux-daemon) as a systemd service.

This has currently only been tested on Raspbian Buster and makes certain assumptions:
- systemd is installed
- dhcpcd is being used as the network manager

## Installation
```bash
./setup.sh
```

The setup script:
- Clones the [AES67 Linux Daemon](https://github.com/bondagit/aes67-linux-daemon) repo to `/opt/aes67`
- Installs the packages required for building and running the daemon
- On Raspberry Pi, disables unnecessary services adn moves `/var/log` to tmpfs
- Builds the daemon and kernel driver
- Sets up a default config for the daemon
- Installs the kernel module and sets it to auto-start
- Adds a hook to dhcpcd to restart the daemon and alsaloop streams
    - This is needed because when there is a network outage the streams become broken and if they are still active when daemon re-establishes them only the first channel is received.
- Adds a systemd service for the daemon and a template for alsaloop streams
- Enables the daemon service

Once the setup script has completed sources and sinks can be created on the web interface at `http://localhost:8080`.
To connect the AES67 stream to a physical input or output the `aes67-stream` template can be used.
This uses `alsaloop` to redirect audio from a source to a sink, see the [stream-config readme](stream-config/README.md) for how to configure the config.
Once the config has been created use:

```bash
sudo systemctl enable --now aes67-stream@<config-name>
```

To enable the stream.
Two example configs are provided for routing audio to the Raspberry Pi headphone jack and looping the AES67 sink to the AES67 source.
