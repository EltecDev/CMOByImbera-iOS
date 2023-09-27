//
//  homeViewController.swift
//  CMOByImbera
//
//  Created by Victor Manuel Garcia on 27/10/22.
//

import Foundation
import UIKit

class homeViewController:UIViewController, BLEDelegate  {

    //oultlets del encabezado
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var firmwareVersionLabel: UILabel!
    @IBOutlet weak var plantillaLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    //outlets de la plantilla de valores
    @IBOutlet weak var stateDeviceLabel: UILabel!
    @IBOutlet weak var tempDeviceLabel: UILabel!
    
    @IBOutlet weak var tcText: UITextField!
    @IBOutlet weak var a6Text: UITextField!
    @IBOutlet weak var a7text: UITextField!
    @IBOutlet weak var a8Text: UITextField!
    @IBOutlet weak var lcText: UITextField!
    @IBOutlet weak var fcText: UITextField!
    
    @IBOutlet weak var sendConfigButton: UIButton!
    
    @IBOutlet weak var disconnectButton: UIButton!{
        didSet{
            self.disconnectButton.layer.masksToBounds = false
            self.disconnectButton.layer.shadowOffset = CGSize(width: 0, height:2)
            self.disconnectButton.layer.shadowOpacity = 0.15
            self.disconnectButton.layer.shadowRadius = CGFloat(2.0)
        }
    }
    
    var wrongValue:Bool = false
    //variables de aplicación
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var BLE: BLEControl!
    //var vC =  ViewController()
    var arrayDevices:[device] = []
    var receivedString :String = ""  //string plantilla predefinida como ejemplo de iniciaización y formato a enviar, se camvia el valor al recibir directo del equipo
    var templateArr:[String] = [""]
    var alertC = UIAlertController()
    var statusTimer: Timer? = nil
    var statusTimerR: Timer? = nil
    var communicationFlag: Int = 0      //bandera de control de comunicación: 1 lectura de parametros, 2 modificación de parametros, se usa en la función del delegado receivedStringValue
    var synconized: Bool = false
    
    override func viewDidLoad() {
       
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        self.appVersionLabel.text = "Versión: " + versionNumber
        BLE = BLEControl(delegate: self)
        self.tcText.addDoneButtonOnKeyboard()
        self.a6Text.addDoneButtonOnKeyboard()
        self.a7text.addDoneButtonOnKeyboard()

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        //instanciar delegado bluetooth

        if appDelegate.connected{
            
            self.connectionLabel.textColor = UIColor.green
            self.connectionLabel.text = "Conectado a " + self.appDelegate.macAdress
            self.modelLabel.text = "Modelo: " + self.appDelegate.modelV
            self.firmwareVersionLabel.text = "Versión de Firmware: " + self.appDelegate.firmwareV
            self.plantillaLabel.text = "Plantilla: " + self.appDelegate.plantilla
            print(self.appDelegate.nameDevice)
            
                if self.appDelegate.connected{

                     if self.BLE.connectToDevice(UUID(uuidString: self.appDelegate.nameDevice)){
                         print("connected to device in home")
                         //self.BLE.writeString("@Q")
                         DispatchQueue.main.async(execute: {
                             
                             self.BLE.writeString("@Q")
                         })
                     }else{
                         print("not connnected :C")
                         
                     }
                }
            }else{
                
                self.connectionLabel.textColor = UIColor.red
            }
        
    }
    
    //funciones de interacción del usuario
    @IBAction func sendConfig(_ sender: Any) {
        self.wrongValue = false
        if self.appDelegate.connected {
            // mandar la configuración de bluetooth
            if (!self.tcText.text!.isEmpty && !self.a6Text.text!.isEmpty && !self.a7text.text!.isEmpty && !self.a8Text.text!.isEmpty  && !self.lcText.text!.isEmpty && !self.fcText.text!.isEmpty) {
                self.communicationFlag = 2
                print(self.receivedString)
                print("OK ready to write ")
               
                //TC
            if Float(self.tcText.text!)!  >= -9.9 &&  Float(self.tcText.text!)!  <= 9.9{
                    
                    print("numero en rango")
                    let tcInt = Int(Float(self.tcText.text!)!*10)
                    print()
                    let hexTc = String(UInt16(bitPattern: Int16(tcInt)), radix: 16)
                    print("hex tc")
                    print(hexTc)
                    var tempTc = Array(hexTc)
                    var tempTc2 = Array(hexTc)
                    print(tempTc)
                    if tempTc.count < 4{
                        
                        for _ in 0 ... 4{
                            if tempTc.count < 4{
                                tempTc.append("0")
                            }
                        }
                        print("desordenado a6")
                        print(tempTc)
                        tempTc2 = tempTc
                        tempTc[0] = tempTc2[2]
                        tempTc[1] = tempTc2[3]
                        tempTc[2] = tempTc2[0]
                        tempTc[3] = tempTc2[1]
                        print("ordenado")
                        print(tempTc)
                    }
                    
                    self.templateArr[25] = String(tempTc[0]) + String(tempTc[1])
                    print(self.templateArr[25])
                    self.templateArr[26] = String(tempTc[2]) + String(tempTc[3])
                    print(self.templateArr[46])
                    
                }else{
                    print("numero fuera de rango")
                    self.wrongValue = true
                    self.tcText.text = ""
                    self.alertC = UIAlertController(title: "Parametro TC incorrecto",
                                                    message: "El número introducido en TC esta fuera del rango admitido",
                                                    preferredStyle: .alert)
                    let connectAction = UIAlertAction(title: "Aceptar", style: .default)
                    self.alertC.addAction(connectAction)
                    self.present(self.alertC, animated: true, completion: nil)
                }
                
                //A6
                if Float(self.a6Text.text!)! >= -30 && Float(self.a6Text.text!)! <= 30{
                    
                    let a6Int = Int(Float(self.a6Text.text!)! * 10)
                    let hexA6 = String(UInt16(bitPattern: Int16(a6Int)), radix: 16)
                    print("hex a6")
                    print(hexA6)
                    print("a6")
                    
                    var tempA6 = Array(hexA6)
                    var tempA62 = Array(hexA6)
                    print(tempA6)
                    if tempA6.count < 4{
                        
                        print("Longitud de tempA6 antes del relleno: \(tempA6.count)")
                            
                            let digitsToAdd = 4 - tempA6.count
                            let zerosToAdd = max(0, min(digitsToAdd, 3))
                            
                            let zerosString = String(repeating: "0", count: zerosToAdd)
                            tempA6 = zerosString + tempA6
                            print(tempA6)
                        print("desordenado a6")
                        print(tempA6)
                        tempA62 = tempA6
                        tempA6[0] = tempA62[0]
                        tempA6[1] = tempA62[1]
                        tempA6[2] = tempA62[2]
                        tempA6[3] = tempA62[3]
                        print("ordenado")
                        print(tempA6)
                    }
                    
                    self.templateArr[45] = String(tempA6[0]) + String(tempA6[1])
                    print(self.templateArr[45])
                    self.templateArr[46] = String(tempA6[2]) + String(tempA6[3])
                    print(self.templateArr[46])
                    
                }else{
                    print("numero fuera de rango")
                    self.wrongValue = true
                    self.alertC = UIAlertController(title: "Parametro A6 incorrecto",
                                                    message: "El número introducido en A6 esta fuera del rango admitido",
                                                    preferredStyle: .alert)
                    let connectAction = UIAlertAction(title: "Aceptar", style: .default)
                    self.alertC.addAction(connectAction)
                    self.present(self.alertC, animated: true, completion: nil)
                }
                
                //edición de plantilla A7
                if Float(self.a7text.text!)! >= -30 && Float(self.a7text.text!)! <= 30{
                    let a7Int = Int(Float(self.a7text.text!)! * 10)
                    let hexA7 = String(UInt16(bitPattern: Int16(a7Int)), radix: 16)
                    var tempA7 = Array(hexA7)
                    var tempA72 = Array(hexA7)
                    
                    print("int a7")
                    print(a7Int)
                    print("a7 hex")
                    print(hexA7.utf8)
                    print(tempA7)
                    if tempA7.count < 4{
                        print("Longitud de tempA7 antes del relleno: \(tempA7.count)")
                            
                            let digitsToAdd = 4 - tempA7.count
                            let zerosToAdd = max(0, min(digitsToAdd, 3)) // Limit zeros to a maximum of 3
                            
                            let zerosString = String(repeating: "0", count: zerosToAdd)
                            tempA7 = zerosString + tempA7
                            print(tempA7)

                     
                        
                        print("parametro a7 menor a 8 bytes, rellenar")
                        tempA72 = tempA7
                        tempA7[0] = tempA72[0]
                        tempA7[1] = tempA72[1]
                        tempA7[2] = tempA72[2]
                        tempA7[3] = tempA72[3]
                        print("o0rdenado a7:")
                        print(tempA7)
                    }
                    self.templateArr[47] = String(tempA7[0]) + String(tempA7[1])
                    print(self.templateArr[47])
                    self.templateArr[48] = String(tempA7[2]) + String(tempA7[3])
                    print(self.templateArr[48])
                    
                }else{
                    print("numero fuera de rango")
                    self.wrongValue = true
                    self.alertC = UIAlertController(title: "Parametro A7 incorrecto",
                                                    message: "El número introducido en A7 esta fuera del rango admitido",
                                                    preferredStyle: .alert)
                    let connectAction = UIAlertAction(title: "Aceptar", style: .default)
                    self.alertC.addAction(connectAction)
                    self.present(self.alertC, animated: true, completion: nil)
                }
                
                
                //edición de plantilla A8
                if Float(self.a8Text.text!)! <= 10 && Float(self.a8Text.text!)! >= 0.5{
                    
                    let a8Int = Int(Float(self.a8Text.text!)!*10)
                    let hexA8 = String(UInt16(bitPattern: Int16(a8Int)), radix: 16)
                    print("int a8")
                    
                    print(hexA8)
                    var tempA8 = Array(hexA8)
                    var tempA82 = Array(hexA8)
                    print("A8")
                    print(tempA8)
                    if tempA8.count < 4{
        //                a8 menor a 2 bytes rellenando...
                        for _ in 0 ... 4{
                            if tempA8.count < 4{
                                tempA8.append("0")
                            }
                        }

                        tempA82 = tempA8
                        tempA8[0] = tempA82[2]
                        tempA8[1] = tempA82[3]
                        tempA8[2] = tempA82[0]
                        tempA8[3] = tempA82[1]
                        print("0rdenado:")
                        print(tempA8)
                    }

                    //edición de plantilla
                    self.templateArr[49] = String(tempA8[0]) + String(tempA8[1])
                    print(self.templateArr[49])
                    self.templateArr[50] = String(tempA8[2]) + String(tempA8[3])
                    print(self.templateArr[50])
                    
                }else{
                    
                    print("numero fuera de rango")
                    self.wrongValue = true
                    self.alertC = UIAlertController(title: "Parametro A8 incorrecto",
                                                    message: "El número introducido en A8 esta fuera del rango admitido",
                                                    preferredStyle: .alert)
                    let connectAction = UIAlertAction(title: "Aceptar", style: .default)
                    self.alertC.addAction(connectAction)
                    self.present(self.alertC, animated: true, completion: nil)
                    
                }
                //LC
                
                if Float(self.lcText.text!)! > 0 && Float(self.lcText.text!)! <= 250 {
                    

                    let lcInt = Int(Float(self.lcText.text!)!)
                    let hexLc = String(UInt16(bitPattern: Int16(lcInt)), radix: 16)
                    print("int lc")
                    print(hexLc)
                
                    var tempLc = Array(hexLc)
                    var tempLc2 = Array(hexLc)
                    if tempLc.count < 2{
                        
                        for _ in 0 ... 4{
                            if tempLc.count < 2{
                                tempLc.append("0")
                            }
                        }
                        tempLc2 = tempLc
                        tempLc[0] = tempLc2[1]
                        tempLc[1] = tempLc2[0]
                        print("0rdenado:")
                        print(tempLc)
                        
                    }
                    
                    self.templateArr[78] = String(tempLc[0]) + String(tempLc[1])
                    print(self.templateArr[78])
                
                }else{
                    
                    print("numero fuera de rango")
                    self.wrongValue = true
                    self.alertC = UIAlertController(title: "Parametro LC incorrecto",
                                                    message: "El número introducido en LC esta fuera del rango admitido",
                                                    preferredStyle: .alert)
                    let connectAction = UIAlertAction(title: "Aceptar", style: .default)
                    self.alertC.addAction(connectAction)
                    self.present(self.alertC, animated: true, completion: nil)
                    
                }
                
                // FC
                if Float(self.fcText.text!)! > 0 && Float(self.fcText.text!)! <= 250{
                    
                    let fcInt = Int(Float(self.fcText.text!)!)
                    let hexFc = String(UInt16(bitPattern: Int16(fcInt)), radix: 16)
                    print(fcInt)
                    print(hexFc)
                    var tempFc = Array(hexFc)
                    var tempFc2 = Array(hexFc)
                    
                    if tempFc.count < 2{
                        
                        for _ in 0 ... 4{
                            if tempFc.count < 2{
                                tempFc.append("0")
                            }
                        }
                        tempFc2 = tempFc
                        tempFc[0] = tempFc2[1]
                        tempFc[1] = tempFc2[0]
                        print("0rdenado:")
                        print(tempFc)
                        
                    }
                    
                    self.templateArr[79] = String(tempFc[0]) + String(tempFc[1])
                    print(self.templateArr[79])
                    
                }else{
                    print("numero fuera de rango")
                    self.wrongValue = true
                    self.alertC = UIAlertController(title: "Parametro FC incorrecto",
                                                    message: "El número introducido en FC esta fuera del rango admitido",
                                                    preferredStyle: .alert)
                    let connectAction = UIAlertAction(title: "Aceptar", style: .default)
                    self.alertC.addAction(connectAction)
                    self.present(self.alertC, animated: true, completion: nil)
                    
                }
                
    //            creación de trama a enviar
                let sendData = "4050" + self.templateArr.joined()
                let sendDataStr = sendData.substring(to: sendData.count-8)

                let hexa = sendDataStr.chunked(into: 2)
                var checksum = 0
                for hexa2 in hexa{
                    checksum = checksum + hexa2.hexaToDecimal
                }
                print(checksum)
                print(String(format:"%02X", checksum))
                var strChecksum = String(format:"%02X", checksum)
                
               
                if (strChecksum.count <= 1 ){
                    strChecksum = "0000000" + strChecksum
                    }
                if (strChecksum.count <= 2 ){
                    strChecksum = "000000" + strChecksum
                }
                if  (strChecksum.count <= 3 ){
                    strChecksum = "00000" + strChecksum
                }
                if  (strChecksum.count <= 4 ){
                    strChecksum = "0000" + strChecksum
                }
                if  (strChecksum.count <= 5 ){
                    strChecksum = "000" + strChecksum
                }
                if  (strChecksum.count <= 6 ){
                    strChecksum = "00" + strChecksum
                }
                if  (strChecksum.count <= 7 ){
                    strChecksum = "0" + strChecksum
                }
                
                print("cadena ordenada hexa del checksum")
                print(strChecksum)
                let send = sendDataStr +  strChecksum
                
    //            let hexa4 = "4050AA000A00780014001B009600960014001400960032FFCE00000000000A000A00AAFFBA000000000000000000000078ff88000A0000000000000000000000000000665528280A0F323C5A0F1E0C103c000003020000040200010200000000000100662A0A1E0F1E1E6432011E056464140A3C0050053C00000000000000000ACC0000111a".hexaData
                
                if !self.wrongValue{
                    print("cadena creada")
                    print(send)
                    DispatchQueue.main.async(execute: {
                        print("Evaluación de campos correcta")
                        self.BLE.writeData(send.hexaData)
                        
                    })
                    
                }else{
                    print("parametros incorrectos")
                }

            }else{
                
                self.alertC = UIAlertController(title: "Parametros incorrectos",
                                                message: "Verifica que hayas llenado todos los campos o introducido los valores correctos",
                                                preferredStyle: .alert)
                let connectAction = UIAlertAction(title: "Aceptar", style: .default){ (action:UIAlertAction) in
                    // syncronizar
                    print(" LECTURA DE PARAMETROS")

                }
                self.alertC.addAction(connectAction)
                self.present(self.alertC, animated: true, completion: nil)
            }
        }else{
            //alerta de conectarse a un dispositivo
            self.alertC = UIAlertController(title: "Error",
                                            message: "Para editar las configuraciones nececitas conectarte a un dispositivo en la sección CMO",
                                            preferredStyle: .alert)
            let aceptlAction = UIAlertAction(title: "Aceptar", style: .default)
            self.alertC.addAction(aceptlAction)
            self.present(self.alertC, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func disconnectFunc(_ sender: Any) {
        
        print("Desconectar dispositivo")
        if self.appDelegate.connected {
            
            self.BLE.disconnectCurrentlyConnectedDevice()
            self.alertC = UIAlertController(title: "Desconectado",
                                            message: "Ya no estas conectado a tu dispositivo ",
                                            preferredStyle: .alert)
            let aceptlAction = UIAlertAction(title: "Aceptar", style: .default)
            self.alertC.addAction(aceptlAction)
            self.present(self.alertC, animated: true, completion: nil)
            
        }else{
            self.alertC = UIAlertController(title: "Desconectado",
                                            message: "Ya no estas conectado a tu dispositivo ",
                                            preferredStyle: .alert)
            let aceptlAction = UIAlertAction(title: "Aceptar", style: .default)
            self.alertC.addAction(aceptlAction)
            self.present(self.alertC, animated: true, completion: nil)
            
        }
        
    }

    //bluetooth delegate
    func newDeviceScanned(_ deviceName: String, localName: String, uuid: UUID, rssi: Int, advertisementData: [AnyHashable : Any]!) {
        //
        
    }
    
    func connectionState(_ deviceName: String, state: Bool) {
        
        if self.BLE.dispositivoCorrente?.state == .connected{
                
                self.BLE.peripheral(self.BLE.dispositivoCorrente!, didDiscoverServices: nil)
                //TODO: alarma de teperatura alta no puede ser menor a la de temperatura baja
               
                DispatchQueue.main.async(execute: {
                
                      self.alertC = UIAlertController(title: "Sincronización completa",
                                                      message: "Los datos de tu CMO fueron obtenidos correctamente",
                                                      preferredStyle: .alert)
                      let connectAction = UIAlertAction(title: "Aceptar", style: .default){ (action:UIAlertAction) in
                          // syncronizar
                          print(" LECTURA DE PARAMETROS")
                          self.communicationFlag = 1
                          
                          self.BLE.writeString("@Q")
                          DispatchQueue.main.async{ [self] in
                                print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>:  inicializar el timer")
                                self.statusTimer = Timer.scheduledTimer(timeInterval: 1,
                                                                             target: self,
                                                                            selector: #selector(self.status),
                                                                             userInfo: nil,
                                                                             repeats: false)
                               RunLoop.main.add(self.statusTimer! , forMode: RunLoop.Mode.common)
                            }
                      }
                      let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
                      self.alertC.addAction(connectAction)
                      self.alertC.addAction(cancelAction)
                      self.present(self.alertC, animated: true, completion: nil)
                      
                      })
              
                self.appDelegate.connected = true
        }
        
        if self.BLE.dispositivoCorrente?.state == .disconnected{
            DispatchQueue.main.async(execute: {
                //borrar datos del dispositivo de las etiquetas
                self.connectionLabel.textColor = UIColor.red
                self.connectionLabel.text = "Conectado a "
                self.modelLabel.text = "Modelo: "
                self.firmwareVersionLabel.text = "Versión de Firmware: "
                self.plantillaLabel.text = "Plantilla: "
                self.appDelegate.connected = false
                
                //borrar datos de text field
                self.tcText.text = ""
                self.a6Text.text = ""
                self.a7text.text = ""
                self.a8Text.text = ""
                self.lcText.text = ""
                self.fcText.text = ""
            })
            
            self.appDelegate.connected = false
        }
        
    }
    
    @objc func status(){
        print("funcion de status del timer")
        DispatchQueue.main.async(execute: {
            self.communicationFlag = 3
            self.BLE.writeString("@S")
        })

    }

    func receivedStringValue(_ deviceName: String, dataStr: Data) {
        
//        var byteArray: [UInt8] = []
        print("received value home controller")
        print(" hexadecimal")
        self.receivedString = dataStr.hexEncodedString()
        print(receivedString)
        if self.communicationFlag == 1 {
            if self.receivedString.count > 20{
                
                let temp = self.receivedString.substring(from: 24)
                
                let array = temp.components(separatedBy: " ")
                self.templateArr = array
               print(array)
                
                //actualiazción de los datos del control en los Textfield:
                DispatchQueue.main.async(execute: {
                    
                    print("valores:")
                    //sensor
                    print("offset del sensor:")
                    let h = UInt16(array[25] + array[26], radix: 16)!
                    let g = Int16(bitPattern: h)
                    print(Float(g / 10))
                    self.tcText.text = String(Float(g / 10))
                    
                    //alarma de temp alta
                    print("A6 alarma de temperatura alta")
                    let u = UInt16(array[45] + array[46], radix: 16)!
                    let s = Int16(bitPattern: u)
                    print(Float(s / 10))
                    self.a6Text.text = String(Float(s / 10))
                    
                    //alarma de temp baja
                    print("A7 alarma de temperatura baja")
                    let u3 = UInt16(array[47] + array[48], radix: 16)!
                    let s3 = Int16(bitPattern: u3)
                    print(Float(s3 / 10))
                    self.a7text.text = String(Float(s3 / 10))
                    
                    // diferenciad e temp
                    print("A8 diferencia de temperatura")
                    if let value = UInt8(array[49] + array[50], radix: 16) {
                        print(Float(value / 10 ))
                        self.a8Text.text = String(Float(value / 10 ))
                    }
                    // tiempo de silencio de alarma
                    print("Lc tiempo de silencio de alarma")
                    if let value = UInt8(array[78], radix: 16) {
                        print(Float(value) )
                        self.lcText.text = String(Int(value))
                    }
                    
                    // tiempo de retardo inicial
                    print("FC tiempo de retardo inicial")
                    if let value = UInt8(array[79], radix: 16) {
                        print(Float(value ) )
                        self.fcText.text = String(Int(value ))
                    }
                    
                })
            }else{
                print(self.receivedString )
                //MARK: alerta de confirmación de envio de parametros
            }

        }
        
        if self.communicationFlag == 2 {
            print("flag 2")
            if self.receivedString.contains("f1 3d"){
                DispatchQueue.main.async(execute: {
                    self.alertC = UIAlertController(title: "Parametros guardados",
                                                    message: "Se guardo correctamente la configuración de tu CMO",
                                                    preferredStyle: .alert)
                    let aceptAction = UIAlertAction(title: "Aceptar", style: .default)
                    let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
                    self.alertC.addAction(aceptAction)
                    self.alertC.addAction(cancelAction)
                    self.present(self.alertC, animated: true, completion: nil)
                })
            }
        }
        
        if self.communicationFlag == 3 {
            if receivedString.count > 15{
                DispatchQueue.main.async(execute: {
                    
                    print("petición de estatus en tiempo real")
                    let temp1 = self.receivedString.substring(with: 24..<29)
                    let temp = temp1.components(separatedBy: " ")
                    print(temp)
                    print(temp[0])
                    print("hjghj")
                    let valueTemp = temp.joined()
                    print(valueTemp)
                    let value = UInt16(valueTemp, radix: 16)!
                    print(value)
                    self.tempDeviceLabel.text = "Temperatura 1: " + String(value/10) + "°C"
                    
                })
            }

        }
        // flag == 2
        //TODO: escritura de parametros, envio y recepción de comandos
    }

}

extension Data {
    var checksum: Int {
        return self.map { Int($0) }.reduce(0, +) & 0xff
    }
}

extension Decimal {
    var int: Int {
        return NSDecimalNumber(decimal: self).intValue
    }
}

extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}

extension UITextField{
    
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let negative: UIBarButtonItem = UIBarButtonItem(title: "—", style: .done, target: self, action: #selector(self.negativeButtonAction))
        let done: UIBarButtonItem = UIBarButtonItem(title: "Ok", style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [negative, flexSpace, done ]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func negativeButtonAction(){
        self.text = "-"
    }
    
    @objc func doneButtonAction(){
        self.resignFirstResponder()

    }
    
}

