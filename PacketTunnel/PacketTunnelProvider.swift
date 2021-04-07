import NetworkExtension

let appGroup = "group.com.ileaf.ios.iLeaf"

// See https://github.com/eycorsican/leaf/blob/master/README.zh.md#conf for more conf examples.
let conf = """
[General]
loglevel = trace
dns-server = 223.5.5.5, 114.114.114.114
tun-fd = REPLACE-ME-WITH-THE-FD
routing-domain-resolve = true

[Proxy]
Direct = direct
Proxy = trojan, server.com, 443, password=123456
[Rule]
EXTERNAL, site:cn, Direct
EXTERNAL, mmdb:cn, Direct
FINAL, Proxy
"""

class PacketTunnelProvider: NEPacketTunnelProvider {
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let tunnelNetworkSettings = createTunnelSettings()
        setTunnelNetworkSettings(tunnelNetworkSettings) { [weak self] error in
            let tunFd = self?.packetFlow.value(forKeyPath: "socket.fileDescriptor") as! Int32
            let confWithFd = conf.replacingOccurrences(of: "REPLACE-ME-WITH-THE-FD", with: String(tunFd))
            let url = FileManager().containerURL(forSecurityApplicationGroupIdentifier: appGroup)!.appendingPathComponent("running_config.conf")
            do {
                try confWithFd.write(to: url, atomically: false, encoding: .utf8)
            } catch {
                NSLog("fialed to write config file \(error)")
            }
            // The CA is used by OpenSSl.
            // You may download a CA from https://curl.se/docs/caextract.html
            var certPath = Bundle.main.executableURL?.deletingLastPathComponent()
            setenv("SSL_CERT_DIR", certPath?.path, 1)
            certPath?.appendPathComponent("cacert.pem")
            setenv("SSL_CERT_FILE", certPath?.path, 1)
            DispatchQueue.global(qos: .userInteractive).async {
                signal(SIGPIPE, SIG_IGN)
                run_leaf(url.path)
            }
            completionHandler(nil)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
    }
    
    func createTunnelSettings() -> NEPacketTunnelNetworkSettings  {
        let newSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "240.0.0.10")
        newSettings.ipv4Settings = NEIPv4Settings(addresses: ["240.0.0.1"], subnetMasks: ["255.255.255.0"])
        newSettings.ipv4Settings?.includedRoutes = [NEIPv4Route.`default`()]
        newSettings.proxySettings = nil
        newSettings.dnsSettings = NEDNSSettings(servers: ["223.5.5.5", "8.8.8.8"])
        newSettings.mtu = 1500
        return newSettings
    }
}
