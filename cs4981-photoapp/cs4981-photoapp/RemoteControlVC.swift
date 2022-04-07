//
//  RemoteControlVC.swift
//  cs4981-photoapp
//
//  Created by Bo-Chen Kuo on 12/9/21.
//

import SwiftUI
import Shout
import SwiftSocket

class RemoteControlVC: UIViewController {
    
    var ssh: SSH?{
        do{
            
            let ssh = try SSH(host: ServerData.host)
            try ssh.authenticate(username: ServerData.ur, password: ServerData.pw)
            
            print("SSH connected!")
            return ssh
        } catch let error as SSHError{
            print("SSH failed!")
            print("Error: \(error.message)")
            return nil
        } catch let error{
            print("SSH failed!")
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    let buttunWidth = CGFloat(80)
    let buttunHeight = CGFloat(30)
    let tf: UITextField =  UITextField(frame: CGRect(x: UIScreen.screenWidth*0.5-80, y: UIScreen.screenHeight*0.18, width: CGFloat(80)*2, height: CGFloat(30)))
    
    
    // From UIViewController
    // Def: Called after the controller's view is loaded into memory.
    //link:https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lgBWidth = buttunWidth * 2
        let lgBHeight = buttunHeight
        let lgBXOffset = UIScreen.screenWidth - lgBWidth
        
        tf.text = "Enter only nunber"
        // tf.backgroundColor = .tintColor
        tf.layer.borderWidth = 1.0
        tf.layer.cornerRadius = 10 // https://www.swiftbysundell.com/articles/rounded-corners-uikit-swiftui/
        self.view.addSubview(tf)
        
        self.view.addSubview(buttonCreate(lgBXOffset*0.5, UIScreen.screenHeight*0.24, lgBWidth, lgBHeight, "host addr set", bg_color: .gray, txt_color: .white, action: #selector(hostAddrButtonAction)))
        self.view.addSubview(buttonCreate(lgBXOffset*0.5, UIScreen.screenHeight*0.3, lgBWidth, lgBHeight, "motion delay set", bg_color: .systemOrange, txt_color: .white, action: #selector(motionDSButtonAction)))
        self.view.addSubview(buttonCreate(lgBXOffset*0.5, UIScreen.screenHeight*0.36, lgBWidth, lgBHeight, "light delay set", bg_color: .systemPurple, txt_color: .white, action: #selector(lightDSButtonAction)))
        self.view.addSubview(buttonCreate(lgBXOffset*0.5, UIScreen.screenHeight*0.42, lgBWidth, lgBHeight, "light threshold set ", bg_color: .systemPurple, txt_color: .white, action: #selector(lightTSButtonAction)))
        
        let xOffset = UIScreen.screenWidth - buttunWidth
        let yOffset = UIScreen.screenHeight - buttunHeight
        self.view.addSubview(buttonCreate(xOffset*0.3, yOffset*0.55, buttunWidth, buttunHeight, "easel out", bg_color: .systemRed, txt_color: .white, action: #selector(easelOtButtonAction)))
        self.view.addSubview(buttonCreate(xOffset*0.3, yOffset*0.61, buttunWidth, buttunHeight, "easel in", bg_color: .systemRed, txt_color: .white, action: #selector(easelInButtonAction)))
        
        self.view.addSubview(buttonCreate(xOffset*0.7, yOffset*0.55, buttunWidth, buttunHeight, "cover out", bg_color: .systemYellow, txt_color: .white, action: #selector(coverOtButtonAction)))
        self.view.addSubview(buttonCreate(xOffset*0.7, yOffset*0.61, buttunWidth, buttunHeight, "cover in", bg_color: .systemYellow, txt_color: .white, action: #selector(coverInButtonAction)))
        
        let awBXOffset = UIScreen.screenWidth - buttunWidth / 1.33
        let awBYOffset = UIScreen.screenHeight - buttunHeight*1.5
        let awSetYOffset = UIScreen.screenHeight*(-0.3)
        self.view.addSubview(arrowButtonCreate(awBXOffset*0.5, awBYOffset*0.425 - awSetYOffset, "↑", action: #selector(upButtonAction)))
        self.view.addSubview(arrowButtonCreate(awBXOffset*0.325, awBYOffset*0.5 - awSetYOffset, "←", action: #selector(leftButtonAction)))
        self.view.addSubview(arrowButtonCreate(awBXOffset*0.675, awBYOffset*0.5 - awSetYOffset, "→", action: #selector(rightButtonAction)))
        self.view.addSubview(arrowButtonCreate(awBXOffset*0.5, awBYOffset*0.575 - awSetYOffset, "↓", action: #selector(downButtonAction)))
        
        let cBWidth = buttunWidth*0.5
        let cBHeight = buttunHeight
        self.view.addSubview(buttonCreate((UIScreen.screenWidth - cBWidth)*0.5, (UIScreen.screenHeight - cBHeight)*0.5 - awSetYOffset, cBWidth, cBHeight, "●", bg_color: .systemCyan, txt_color: .white, action: #selector(enterButtonAction)))
        self.view.addSubview(buttonCreate((UIScreen.screenWidth - cBWidth)*0.075, (UIScreen.screenHeight - cBHeight)*0.59 - awSetYOffset, cBWidth, cBHeight, "X", bg_color: .red, txt_color: .white, action: #selector(deleteButtonAction)))
        
        
        self.view.addSubview(buttonCreate(lgBXOffset*0.1, UIScreen.screenHeight*0.925, lgBWidth, lgBHeight, "start tcp server", bg_color: .systemGray6, txt_color: .white, action: #selector(TCPButtonAction)))
        self.view.addSubview(buttonCreate(lgBXOffset*0.9, UIScreen.screenHeight*0.925, lgBWidth, lgBHeight, "start album GUI (X)", bg_color: .systemGray6, txt_color: .white, action: #selector(albumButtonAction)))
        
        
    }
    
    @objc func hostAddrButtonAction(sender: UIButton!) {
        print("hostAddrButtonAction tapped")
        print("tf.text: \(String(describing: tf.text))")
        //Note:// should use regex or anything to check before setting
        ServerData.host = tf.text ?? "localhost"
        print("ServerData.host is set to \(ServerData.host)")
    }
    @objc func motionDSButtonAction(sender: UIButton!) {
        print("motionDSButtonAction tapped")
        print("tf.text: \(String(describing: tf.text))")
        // guard let (status, out) = self.sendCmd("/home/pi/Album/xml_parse.py -m \(String(describing: tf.text))") else { print("faild?") ;return }
        guard let (status, out) = self.sendCmd(ServerData.location + "xml_parse.py -m \(tf.text!)") else { print("faild?") ;return }
        print("run cmd: /home/pi/Album/xml_parse.py -m \(tf.text!)")
        result(status, out)
    }
    @objc func lightDSButtonAction(sender: UIButton!) {
        print("lightDSButtonAction tapped")
        guard let (status, out) = self.sendCmd(ServerData.location + "xml_parse.py -b \(tf.text!)") else { print("faild?") ;return }
        print("run cmd: /home/pi/Album/xml_parse.py -b \(tf.text!)")
        result(status, out)
    }
    @objc func lightTSButtonAction(sender: UIButton!) {
        print("lightTSButtonAction tapped")
        guard let (status, out) = self.sendCmd(ServerData.location + "xml_parse.py -t \(tf.text!)") else { print("faild?") ;return }
        print("run cmd: /home/pi/Album/xml_parse.py -t \(String(describing: tf.text))")
        result(status, out)
    }
    
    @objc func easelOtButtonAction(sender: UIButton!) {
        print("easelOtButtonAction tapped")
        guard let (status, out) = self.sendCmd(ServerData.location + "motor_easel.py 1") else { print("faild?") ;return }
        result(status, out)
    }
    @objc func easelInButtonAction(sender: UIButton!) {
        print("easelInButtonAction tapped")
        guard let (status, out) = self.sendCmd(ServerData.location + "motor_easel.py 0") else { print("faild?") ;return }
        result(status, out)
    }
    @objc func coverOtButtonAction(sender: UIButton!) {
        print("coverOtButtonAction tapped")
        guard let (status, out) = self.sendCmd(ServerData.location + "motor_cover.py 0") else { print("faild?") ;return }
        result(status, out)
    }
    @objc func coverInButtonAction(sender: UIButton!) {
        print("coverInButtonAction tapped")
        guard let (status, out) = self.sendCmd(ServerData.location + "motor_cover.py 1") else { print("faild?") ;return }
        result(status, out)
    }
    
    func result(_ s: Int32, _ o: String) -> Void{
        print("status is: \(s)")
        print("output is: \(o)")
    }
    
    
    @objc func upButtonAction(sender: UIButton!) {
        print("upButtonAction tapped")
        self.sendMsg("up")
    }
    @objc func leftButtonAction(sender: UIButton!) {
        print("leftButtonAction tapped")
        self.sendMsg("left")
    }
    @objc func rightButtonAction(sender: UIButton!) {
        print("rightButtonAction tapped")
        self.sendMsg("right")
    }
    @objc func downButtonAction(sender: UIButton!) {
        print("downButtonAction tapped")
        self.sendMsg("down")
    }
    @objc func enterButtonAction(sender: UIButton!) {
        print("enterButtonAction tapped")
        self.sendMsg("enter")
    }
    @objc func deleteButtonAction(sender: UIButton!) {
        print("deleteButtonAction tapped")
        self.sendMsg("delete")
    }
    
    @objc func TCPButtonAction(sender: UIButton!) {
        print("TCPButtonAction tapped")
        // this should re-open the tcp server on pi, but current implemetaion tcp server is bind with gui, so it can't
        // self.sendCmd(ServerData.location + "integrated_server.py")
    }
    
    @objc func albumButtonAction(sender: UIButton!) {
        // this should open the gui on pi, but current implemetaion can't
        print("TCPButtonAction tapped")
        // self.sendCmd(ServerData.location + "Album_GUI.py")
    }
    
    
    
    func buttonCreate(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, _ title: String, bg_color: UIColor, txt_color: UIColor,action: Selector) -> UIButton {
        let button = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
        button.backgroundColor = bg_color
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.setTitleColor( txt_color, for: .normal)
        button.layer.cornerRadius = 10 // https://www.swiftbysundell.com/articles/rounded-corners-uikit-swiftui/
        
        return button
    }
    
    func arrowButtonCreate(_ x: CGFloat, _ y: CGFloat, _ title: String, action: Selector) -> UIButton {
        return buttonCreate(x, y, buttunWidth / 1.33, buttunHeight*1.5, title, bg_color: .systemCyan, txt_color: .white, action: action)
    }
    
    func sendMsg(_ msg: String) -> Void{
        print("press")
        let client = TCPClient(address: ServerData.host, port: Int32(ServerData.tcp_port))
        switch client.connect(timeout: 10) {
        case .success:
            print("connect success")
            let message = msg
            switch client.send(string: message) {
            case .success:
                print("sent success")
                    print("ready recieve")
                    guard let data = client.read(1024*10, timeout: 10) else {
                        print("not pass guard"); return }
                    print("pass guard")
                    if let response = String(bytes: data, encoding: .utf8) {
                        print("response: " + response)
                    }
                client.close()
            case .failure(let error):
                print("sent failure")
                print(error)
            }
            // client.close()
            break
        case .failure(let error):
            print("connect failure")
            print(error)
            break
        }
    }
    
    func sendCmd(_ cmd: String) -> (Int32 ,String)? {
        do{
            let ssh = try SSH(host: ServerData.host)
            try ssh.authenticate(username: ServerData.ur, password: ServerData.pw)
            
            print("SSH connected!")
            let (status, out) = try ssh.capture(cmd)
            
            return (status, out)
        }catch let error as SSHError{
            print("Error: \(error.message)")
        } catch let error{
            print("Error: \(error.localizedDescription)")
        }
        return nil
    }
}
