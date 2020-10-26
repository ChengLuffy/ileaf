import UIKit
import NetworkExtension

class ViewController: UIViewController {
    
    var manager = VPNManager.shared()
    
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    @IBAction func toggle(_ sender: UISwitch) {
        manager.enableVPNManager() { error in
            guard error == nil else {
                fatalError("enable VPN failed: \(error.debugDescription)")
            }
            self.manager.toggleVPNConnection() { error in
                guard error == nil else {
                    fatalError("toggle VPN connection failed: \(error.debugDescription)")
                }
            }
        }
    }
    
    @objc func updateStatus() {
        toggleSwitch.isOn = (manager.manager.connection.status != .disconnected &&
                            manager.manager.connection.status != .disconnecting &&
                            manager.manager.connection.status != .invalid)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.loadVPNPreference() { error in
            guard error == nil else {
                fatalError("load VPN preference failed: \(error.debugDescription)")
            }
            self.updateStatus()
            NotificationCenter.default.addObserver(self, selector: #selector(self.updateStatus), name: NSNotification.Name.NEVPNStatusDidChange, object: self.manager.manager.connection)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: self.manager.manager.connection)
    }
}
