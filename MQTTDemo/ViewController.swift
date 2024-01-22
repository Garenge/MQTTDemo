//
//  ViewController.swift
//  MQTTDemo
//
//  Created by Garenge on 2023/4/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var localIDTF: UITextField!
    @IBOutlet weak var toIDTF: UITextField!
    @IBOutlet weak var sendMessageTF: UITextField!
    @IBOutlet weak var receiveMessageLabel: UILabel!

    let array = ["id_0001", "id_0002"]

    override func viewDidLoad() {
        super.viewDidLoad()


        self.localIDTF.text = array[0]
        self.toIDTF.text = array[1]

        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMQTTMessage(_:)), name: .MQTT.receiceMessage, object: nil)
    }
    @IBAction func exchangeBtnClicked(_ sender: Any) {
        if self.localIDTF.text == array[0] {
            self.localIDTF.text = array[1]
            self.toIDTF.text = array[0]
        } else {
            self.localIDTF.text = array[0]
            self.toIDTF.text = array[1]
        }
    }

    @IBAction func subscribeTopicBtnClickAction(_ sender: Any) {
        MQTTManager.shared.subscribeTopic(topic: self.localIDTF.text ?? "")
    }
    @IBAction func sendBtnClickedAction(_ sender: Any) {
        MQTTManager.shared.publishMessage(topic: self.toIDTF.text ?? "", message: self.sendMessageTF.text ?? "")
    }

    @objc func didReceiveMQTTMessage(_ noti: Notification) {
        guard let userInfo = noti.userInfo else {
            return
        }
        let msg = userInfo["msg"]

        self.receiveMessageLabel.text = msg as? String
    }

}

