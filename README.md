# iLeaf

This simple app demonstrates the use of [Leaf](https://github.com/eycorsican/leaf) on iOS.

Leaf has released an iOS static library and can be downloaded by running a script (see details below).

Leaf supports a large feature set including SOCKS 5, HTTP, Shadowsocks, VMess and Trojan proxy protocols, and plugable proxy transports such as WebSocket and TLS. There are also flexible load balancing / high availability features to better deliver your network requests.

The app has no UIs and the switch is the only button to start and stop the proxy, you can control all the proxy behaviors by changing a config file, which is defined as a `String` variable and located in `PacketTunnel/PacketTunnelProvider.swift`.

### Build & Run

1. Fix `Bundle Identifier` and `App Groups` identifier and entitlements.

2. Download `leaf` library:

```sh
./misc/download_leaf.sh
```

3. Download dat files:

```sh
./misc/download_data.sh
```

4. Edit the config `conf` in `PacketTunnel/PacketTunnelProvider.swift`, examples can be found [here](https://github.com/eycorsican/leaf/blob/master/README.zh.md#conf)

5. Build and Run

### View Logs

Leaf by default outputs logs to the console, since it's a static library used by the NetworkExtension executable, you can checkout the logs on macOS via the `Console.app`.

While using the `Console.app` is the easiest way, my favorite is using the command

```sh
idevicesyslog -p PacketTunnel
```

You may install it via Homebrew, see https://libimobiledevice.org/ for more details.
