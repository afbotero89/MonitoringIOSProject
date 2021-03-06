//
//  GBCSettingsHour.swift
//  MonitoringIOSProject
//
//  Created by Felipe Botero on 24/05/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class GBCSettingsHour: NSObject {
    
    /**
    Hora de conexion: hora en la que se establecio la comunicacion bluetooth
    tiempoDispositivoEncendido: tiempo que transcurrio desde que se encendio el monitor hasta que se establece la comunicacion bluetooth.
    */
    func horaInicioDispositivo(_ horaConexion:String, tiempoDispositivoEncendido:String)->String{
        // Hora de inicio del dispositivo
        var horaInicioDispositivo:Int!
        var minutoInicioDispositivo:Int!
        var segundoInicioDispositivo:Int!
        
        //let horaConexion = "12:51:12"
        //let tiempoDispositivoEncendido = "01:26:42"
        
        
        // Hora de conexion de la app
        let horaConexionApp = horaConexion.components(separatedBy: ":")[0]
        let minutoConexionApp = horaConexion.components(separatedBy: ":")[1]
        let segundoConexionApp = horaConexion.components(separatedBy: ":")[2]
        
        // tiempo que el dispositivo lleva encendido
        let horaDispositivo = tiempoDispositivoEncendido.components(separatedBy: ":")[0]
        let minutoDispositivo = tiempoDispositivoEncendido.components(separatedBy: ":")[1]
        let segundoDispositivo = tiempoDispositivoEncendido.components(separatedBy: ":")[2]
        
        if Int(segundoDispositivo) > Int(segundoConexionApp){
            segundoInicioDispositivo = 60 - (Int(segundoDispositivo)! - Int(segundoConexionApp)!)
            
            if Int(minutoDispositivo) > Int(minutoConexionApp){
                minutoInicioDispositivo = 60 - (Int(minutoDispositivo)! - Int(minutoConexionApp)!) - 1
            }else{
                minutoInicioDispositivo = (Int(minutoConexionApp)! - Int(minutoDispositivo)!) - 1
            }
            
        }else{
            segundoInicioDispositivo = Int(segundoConexionApp)! - Int(segundoDispositivo)!
            
            if Int(minutoDispositivo) > Int(minutoConexionApp){
                minutoInicioDispositivo = 60 - (Int(minutoDispositivo)! - Int(minutoConexionApp)!)
            }else{
                minutoInicioDispositivo = (Int(minutoConexionApp)! - Int(minutoDispositivo)!)
            }
        }
        
        if Int(minutoDispositivo) > Int(minutoConexionApp){
            
            if Int(horaDispositivo) > Int(horaConexionApp){
                horaInicioDispositivo = 24 - (Int(horaDispositivo)! - Int(horaConexionApp)!) - 1
            }else{
                horaInicioDispositivo = (Int(horaConexionApp)! - Int(horaDispositivo)!) - 1
            }
            
        }else{
            if Int(horaDispositivo) > Int(horaConexionApp){
                horaInicioDispositivo = 24 - (Int(horaDispositivo)! - Int(horaConexionApp)!)
            }else{
                horaInicioDispositivo = (Int(horaConexionApp)! - Int(horaDispositivo)!)
            }
        }
        
        return "\(horaInicioDispositivo):\(minutoInicioDispositivo):\(segundoInicioDispositivo)"
        
    }
    
    func horaNoConfigurada(_ horaActual:String, horaEncendidoDispositivo:String)->String{
        
        //let horaActual = "01:50:50"
        //let horaEncendidoDispositivo = "15:24:30"
        
        var horaMedida:Int!
        var minutoMedida:Int!
        var segundoMedida:Int!
        
        let horaMedicion = horaActual.components(separatedBy: ":")[0]
        let minutoMedicion = horaActual.components(separatedBy: ":")[1]
        let segundoMedicion = horaActual.components(separatedBy: ":")[2]
        
        let horaDispositivo = horaEncendidoDispositivo.components(separatedBy: ":")[0]
        let minutoDispositivo = horaEncendidoDispositivo.components(separatedBy: ":")[1]
        let segundoDispositivo = horaEncendidoDispositivo.components(separatedBy: ":")[2]
        
        segundoMedida = Int(segundoMedicion)! + Int(segundoDispositivo)!
        
        minutoMedida = Int(minutoMedicion)! + Int(minutoDispositivo)!
        
        horaMedida = Int(horaMedicion)! + Int(horaDispositivo)!
        
        if minutoMedida > 60{
            
            if horaMedida > 24{
                horaMedida = horaMedida! - 24 + 1
            }else{
                horaMedida = horaMedida! + 1
            }
        }
        
        if segundoMedida > 60{
            segundoMedida = segundoMedida! - 60
            
            if minutoMedida > 60{
                minutoMedida = minutoMedida! - 60 + 1
            }else{
                minutoMedida = minutoMedida! + 1
            }
            
        }else{
            if minutoMedida > 60{
                minutoMedida = minutoMedida! - 60
            }else{
                
            }
        }
        
        return "\(horaMedida):\(minutoMedida):\(segundoMedida)"
        
    }
    
}
