
//  ViewController.swift
//  CMOByImbera
//
//  Created by Victor Manuel Garcia on 18/10/22.
//

import UIKit
import CoreBluetooth


//estructura con las propiedades del dispositivo
struct device {
    var localName: String
    var uuidB:UUID
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BLEDelegate {
    
    //outlets de interfaz
    @IBOutlet weak var serchButtom: UIButton!
    @IBOutlet weak var devicesTableView: UITableView!
    @IBOutlet weak var connectStateLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var versionFirmwareLabel: UILabel!
    @IBOutlet weak var labelVersion: UILabel!
    @IBOutlet weak var plantillaLabel: UILabel!
    @IBOutlet weak var logout: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var alertC = UIAlertController()
    //MARK: variables del controlador
    var bluetoothCell1 = bluetoothCell()
    var BLE: BLEControl!
    var BLETimeOutTimer: Timer? = nil
    var arrayDevices:[device] = []
    var connectBluetooth: Bool = false
    var currentDeviceName:String = ""
    var stringArrayList : Array<String> = []
    //MARK: ciclo de vida del controlador
    var devicesScaned : NSMutableDictionary!
    var uds = UserDefaults()
    var window: UIWindow?
    var activityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
//        navigation bar height
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        self.labelVersion.text = "Versión: " + versionNumber


        // inicializa la configuración del bluetooth para realizar una conexión
        BLE = BLEControl(delegate: self)
        
        //configuración y asignación del delgado del table view
        self.devicesTableView.delegate = self
        self.devicesTableView.dataSource = self
        self.devicesTableView.reloadData()
        self.devicesTableView.backgroundColor = UIColor.white
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //actualizar etiquetas de los datos del CMO
        self.devicesTableView.reloadData()
        if self.appDelegate.connected{
            self.connectStateLabel.textColor = UIColor.green
            self.connectStateLabel.text = "Conectado a " + self.appDelegate.macAdress
            self.modelLabel.text = "Modelo: " + self.appDelegate.modelV
            self.versionFirmwareLabel.text = "Versión de Firmware: " + self.appDelegate.firmwareV
            self.plantillaLabel.text = "Plantilla: " + self.appDelegate.plantilla
        }else{
            self.connectStateLabel.textColor = UIColor.red
            self.connectStateLabel.text = "No Conectado"
            self.modelLabel.text = "Modelo: "
            self.versionFirmwareLabel.text = "Versión de Firmware: "
            self.plantillaLabel.text = "Plantilla: "
        }
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        self.labelVersion.text = "Versión: " + versionNumber
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //timer para detener el escaneo de dispostivos
        
       DispatchQueue.main.async{ [self] in
             print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>:  inicializar el timer")
             self.BLETimeOutTimer = Timer.scheduledTimer(timeInterval: 1,
                                                          target: self,
                                                         selector: #selector(self.stopScan),
                                                          userInfo: nil,
                                                          repeats: false)
            RunLoop.main.add(self.BLETimeOutTimer! , forMode: RunLoop.Mode.common)
         }
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.BLE.disconnectCurrentlyConnectedDevice()
    }
    
    //  MARK: funciones adicionales
    func firstCommunication(){
        //        ejemplo de como usar la extensión de string a hexadecimal
        //        print(str.toHexEncodedString())
        //        print(str.toHexEncodedString(uppercase: false, prefix: "0x", separator: " "))
        
        self.BLE.sendData("@!")
        
    }
    
    //MARK: funciones de la interfaz
    @objc func stopScan(){
        self.serchButtom.isUserInteractionEnabled = true
        print(">>>>>>>>>>>>: time out")
        BLE.centralManager.stopScan()
        self.devicesTableView.reloadData()
        activityIndicatorView.removeFromSuperview()
    }
    
    @IBAction func scanInit(_ sender: Any) {
        self.serchButtom.isUserInteractionEnabled = false
        self.BLE.disconnectCurrentlyConnectedDevice()
        print("escaneo de dispositivos ")
        let x = self.view.center.x
        let y = self.view.center.y
        let frame = CGRect(x: (x-50), y: (y-50), width: 100, height: 100)
        activityIndicatorView = UIActivityIndicatorView(frame: frame)
         activityIndicatorView.color = UIColor.white
         activityIndicatorView.backgroundColor = UIColor.black
         activityIndicatorView.alpha = 0.5
         activityIndicatorView.layer.cornerRadius = 5
         activityIndicatorView.layer.masksToBounds = true
         self.view.addSubview(activityIndicatorView)
         activityIndicatorView.startAnimating()
        DispatchQueue.main.async{ [self] in
              print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>:  inicializar el timer")
              self.BLETimeOutTimer = Timer.scheduledTimer(timeInterval: 2,
                                                           target: self,
                                                          selector: #selector(self.stopScan),
                                                           userInfo: nil,
                                                           repeats: false)
             RunLoop.main.add(self.BLETimeOutTimer! , forMode: RunLoop.Mode.common)
          }
        
    }
    
    @IBAction func stopScanDevices(_ sender: Any) {
        
        print("detener busqueda de dispositivos")
        BLE.centralManager.stopScan()
        self.devicesTableView.reloadData()
        
    }
    
    
    @IBAction func logoutFunc(_ sender: Any) {
        
        self.uds.removeObject(forKey: "login")
        print(" logout")
        self.appDelegate.connected = false
        self.window?.rootViewController?.dismiss(animated: true, completion: nil)
        let story = UIStoryboard(name: "Main", bundle:nil)
        let vc = story.instantiateViewController(withIdentifier: "loginvc") as! loginViewController
        UIApplication.shared.windows.first?.rootViewController = vc
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        
    }
    
    
    
//  función que se ejecuta para terminar el escaneo de dispositivos
    //MARK: delegados del table view
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       //función que obtiene el número de celdas de la tabla acorde al data source
       return arrayDevices.count
   }
   
    //    MARK: NO RECARGAR NUNCA EL TABLE VIEW EN LA SIGUIENTE FUNCIÓN
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let currentCell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as! bluetoothCell
       
       let arrayD = arrayDevices[indexPath.row]
       currentCell.deviceName.text = arrayD.localName
       currentCell.uuidLabel.text = arrayD.uuidB.uuidString
       
       return currentCell
       
   }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !self.appDelegate.connected{
            self.alertC = UIAlertController(title: "¿Conectar con este dispositivo?",
                                            message: "Pulsa \"Conectar\" para establecer conexión con tu CMO",
                                            preferredStyle: .alert)
            let connectAction = UIAlertAction(title: "Conectar", style: .default){ (action:UIAlertAction) in
                // conectar Lanzar la conexión bluetooth
                let arrayD = self.arrayDevices[indexPath.row]
                self.BLE.disconnectCurrentlyConnectedDevice()
                self.appDelegate.nameDevice = arrayD.uuidB.uuidString
                if self.BLE.connectToDevice(arrayD.uuidB){
                    
                }
            }
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
            self.alertC.addAction(connectAction)
            self.alertC.addAction(cancelAction)
            self.present(self.alertC, animated: true, completion: nil)
        }else{
            
            self.alertC = UIAlertController(title: "Estas Conectado a otro CMO",
                                            message: "Desconectate de tu CMO atual para interactuar con uno diferente",
                                        preferredStyle: .actionSheet)
            let connectAction = UIAlertAction(title: "Aceptar", style: .default)
            //let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
            self.alertC.addAction(connectAction)
            //self.alertC.addAction(cancelAction)
            self.present(self.alertC, animated: true, completion: nil)
        }
        
    }
    

    //MARK: delegados del bluetooth
    func newDeviceScanned(_ deviceName: String, localName: String, uuid: UUID, rssi: Int, advertisementData: [AnyHashable : Any]!) {
        
       // print("device: " + localName )
        if localName.hasPrefix("OXXO-CMO"){
            arrayDevices.append(device(localName: localName, uuidB: uuid))
            
        }else{
            print(localName + "no es un dispositivo de imbera")
        }
    }
    
    func connectionState(_ deviceName: String, state: Bool) {
        if self.BLE.dispositivoCorrente?.state == .connecting{
            print("conecting")
            
        }
        if self.BLE.dispositivoCorrente?.state == .connected{
            print("device connected")            //
            self.appDelegate.connected = true
            dictionary1.sharedInstance.foundDevicesShared = self.BLE.foundDevices
           
            //actualizar el label de el estadod e conexión
             DispatchQueue.main.async(execute: {
                 
                self.connectStateLabel.text = "Conectado"
                self.connectStateLabel.textColor = UIColor.green
                self.alertC = UIAlertController(title: "Sincronizar",
                                                message: "Sincronizar  tu CMO",
                                                preferredStyle: .alert)
                let connectAction = UIAlertAction(title: "Sincronizar", style: .default){ (action:UIAlertAction) in
                    // syncronizar
                 self.BLE.sendData("@!")
                    self.appDelegate.connected = true
                }
                let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
                self.alertC.addAction(connectAction)
                self.alertC.addAction(cancelAction)
                self.present(self.alertC, animated: true, completion: nil)
                
                })
        }
    }
    
    func receivedStringValue(_ deviceName: String, dataStr: Data) {
        print("received value")
        var macAd = ""
        var arrayMac = Array(macAd)
        var byteArray: [UInt8] = []
        
        var verFirm:String = ""
        if dataStr.count >= 5{
            macAd =  String(data: dataStr, encoding: String.Encoding.ascii)!.substring(with: 2..<14)
             byteArray =  dataStr.map { $0 }
            print(String(data: dataStr, encoding: String.Encoding.ascii)!)
            //  f1 0x3f 0x33 0x43 0x41 0x35 0x35 0x31 0x39 0x34 0x42 0x41 0x38 0x46 0x00 0x00 0x00 0x00 0x0a 0xff 0xff
            arrayMac = Array(macAd)
            // f1 3f 30 30 45 34 34 43 30 30 39 32 45 34 23 01 04 00 0a ff ff
             //f1 3f 33 43 41 35 35 31 39 34 42 33 43 31 40 01 07 00 0f ff ff
            var j = 2
            for i in 0 ... (arrayMac.count+3){
                    if i == j{
                        arrayMac.insert(":", at: i)
                        j += 3
                }

            }
            print(String(arrayMac))
            let p15 = String(byteArray[15])
            let p16 = String(byteArray[16])
             verFirm = String(p15 + p16)
            
            
            DispatchQueue.main.async(execute: {
                self.connectStateLabel.text = "Conectado a " + String(arrayMac)
                self.modelLabel.text = "Modelo: " + String(Float(byteArray[14]) / 10)
                self.versionFirmwareLabel.text = "Versión de Firmware: " + String(Float(verFirm)! / 10)
                self.plantillaLabel.text = "Plantilla: " + String(Float(byteArray[18]) / 10)
                
            })
            //pasar parametros al app delegate
            self.appDelegate.macAdress = String(arrayMac)
            self.appDelegate.modelV = String(Float(byteArray[14]) / 10)
            self.appDelegate.firmwareV = String(Float(verFirm)! / 10)
            self.appDelegate.plantilla = String(Float(byteArray[18]) / 10)
            self.appDelegate.nameDevice = (self.BLE.dispositivoCorrente?.identifier.uuidString)!
            
        }else{
        }
    }

}

extension StringProtocol {
    var data: Data { .init(utf8) }
    var bytes: [UInt8] { .init(utf8) }
}


    
