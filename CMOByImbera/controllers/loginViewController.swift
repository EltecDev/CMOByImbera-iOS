//
//  loginViewController.swift
//  CMOByImbera
//
//  Created by Victor Manuel Garcia on 28/10/22.
//

import Foundation
import UIKit
import OHMySQL
import CoreBluetooth
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork

class loginViewController: UIViewController{

    
    
    @IBOutlet weak var userTxt: UITextField!{
        didSet{
            userTxt.layer.cornerRadius =  25
            let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 20.0, height: 2.0))
            userTxt.leftView = leftView
            userTxt.leftViewMode = .always
        }
    }
    
    @IBOutlet weak var passTxt: UITextField!{
        didSet{
            passTxt.layer.cornerRadius =  25
            let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 20.0, height: 2.0))
            passTxt.leftView = leftView
            passTxt.leftViewMode = .always
        }
    }
    @IBOutlet weak var userLAbel: UILabel!
    
    @IBOutlet weak var labelVersion: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var loginButton: UIButton!
    var ud = UserDefaults()
    var alertC = UIAlertController()
    //MARK: ciclo de vida de la aplicación
    
    var tabBarControllerItems:[UITabBarItem] = []

    override func viewDidLoad() {
            
        //create the connection object

         let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
         self.labelVersion.text = "Versión: " + versionNumber
        
//        tab bar predefinidos
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        verificación de login
        
    }
    
    @IBAction func loginFunc(_ sender: Any) {
        
        if isConnectedToNetwork(){
            
            if !(self.userTxt.text!.isEmpty && self.passTxt.text!.isEmpty){
                
                let x = self.view.center.x
                let y = self.view.center.y
                
                let frame = CGRect(x: (x-50), y: (y-50), width: 100, height: 100)
                let activityIndicatorView = UIActivityIndicatorView(frame: frame)
                
                activityIndicatorView.color = UIColor.white
                activityIndicatorView.backgroundColor = UIColor.black
                activityIndicatorView.alpha = 0.5
                activityIndicatorView.layer.cornerRadius = 5
                activityIndicatorView.layer.masksToBounds = true
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
                let userTxt = self.userTxt.text!
                DispatchQueue.global(qos: .background).async{
                    
                    
                    let user = OHMySQLUser(user: "moises", password: "9873216543", serverName: "electronicaeltec.com", dbName: "cmo_users", port: 3306, socket: "/Applications/MAMP/tmp/mysql/mysql.sock")
                    let coordinator = MySQLStoreCoordinator(configuration: user)
                    coordinator.encoding = .UTF8MB4
                    coordinator.connect()
                    let context = MySQLQueryContext()
                    context.storeCoordinator = coordinator
                    MySQLContainer.shared.mainQueryContext = context
                    let query = MySQLQueryRequestFactory.select("usuarios", condition: "usuario = '" + userTxt + "' " )  //and '" + self.passTxt.text! + "''
                    let response = ((try? MySQLContainer.shared.mainQueryContext?.executeQueryRequestAndFetchResult(query))!)
                    
                    print("loginsql")
                    
                    DispatchQueue.main.async(execute: {
                        
                        activityIndicatorView.removeFromSuperview()
                        if !response.isEmpty{
                            let response1 = Array(response[0].values)
                            print(response1[0])
                            print(response1[1])
                            let passReceived = String(stringLiteral: response1[0] as! String)
                            let passReceived1 = String(stringLiteral: response1[1] as! String)
                            if self.passTxt.text!.contains(passReceived) {
                                
                                self.alertC = UIAlertController(title: "Inicio de sesión correcto ",
                                                                message: "Ya puedes controlar tu CMO",
                                                                preferredStyle: .alert)
                                let aceptAction = UIAlertAction(title: "Aceptar", style: .default){ [self] (action:UIAlertAction) in
                                    
                                    // cambio de interfaz para login
                                    ud.set(true, forKey: "login")
                                    self.performSegue(withIdentifier: "toTabController", sender:nil)
                                }
                                self.alertC.addAction(aceptAction)
                                self.present(self.alertC, animated: true, completion: nil)
                            }else{
                                
                                if self.passTxt.text!.contains(passReceived1) {
                                    self.alertC = UIAlertController(title: "Inicio de sesión correcto ",
                                                                    message: "Ya puedes controlar tu CMO",
                                                                    preferredStyle: .alert)
                                    let aceptAction = UIAlertAction(title: "Aceptar", style: .default){ [self] (action:UIAlertAction) in
                                        
                                        // cambio de interfaz para login
                                        ud.set(true, forKey: "login")
                                        self.performSegue(withIdentifier: "toTabController", sender:nil)
                                    }
                                    self.alertC.addAction(aceptAction)
                                    self.present(self.alertC, animated: true, completion: nil)
                                    
                                }else{
                                    
                                    self.alertC = UIAlertController(title: "Error",
                                                                    message: "Ingresa el usuario y la contraseña",
                                                                    preferredStyle: .alert)
                                    let connectAction = UIAlertAction(title: "Aceptar", style: .default){ (action:UIAlertAction) in
                                        // syncronizar
                                    }
                                    self.alertC.addAction(connectAction)
                                    self.present(self.alertC, animated: true, completion: nil)
                                }
                                
                            }
                            
                        }else{
                            
                            print("respuesta nula usuario no existe")
            //                desplegar alerta de contraseña o usuario incorrecto
                            
                            self.alertC = UIAlertController(title: "No es posible iniciar sesión",
                                                            message: "Usuario y/o Contraseña incorrectas",
                                                            preferredStyle: .alert)
                            let connectAction = UIAlertAction(title: "Aceptar", style: .default){ (action:UIAlertAction) in
                                // syncronizar
                            }
                            self.alertC.addAction(connectAction)
                            self.present(self.alertC, animated: true, completion: nil)
                        }
                    })
                }
                
            }else{
                self.alertC = UIAlertController(title: "Error",
                                                message: "Ingresa el usuario y la contraseña",
                                                preferredStyle: .alert)
                let connectAction = UIAlertAction(title: "Aceptar", style: .default){ (action:UIAlertAction) in
                    // syncronizar
                }
                self.alertC.addAction(connectAction)
                self.present(self.alertC, animated: true, completion: nil)
            }
        }else{
            
            self.alertC = UIAlertController(title: "Error ",
                                            message: "Revisa tu conexión a internet para iniciar sesión ",
                                            preferredStyle: .alert)
            let aceptAction = UIAlertAction(title: "Aceptar", style: .default)
            self.alertC.addAction(aceptAction)
            self.present(self.alertC, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func logOutFunc(_ sender: Any) {
        
        self.tabBarControllerItems[2].isEnabled = false
        self.tabBarControllerItems[1].isEnabled = false
        self.loginButton.isHidden = false
        self.stackView.isHidden = false
        self.ud.set(false, forKey: "login")
        
    }
    
    //verificación de internet
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
            
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        return ret
    }
    
}
