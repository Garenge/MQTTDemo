//
//  ViewController.swift
//  MQTTDemo
//
//  Created by Garenge on 2023/4/21.
//

import UIKit

struct MessageModel: Codable {
    var content: String?
    var timeStamp: TimeInterval = Date().timeIntervalSince1970
    var senderName: String?
}

class ViewController: UIViewController {

    @IBOutlet weak var localIDTF: UITextField!
    @IBOutlet weak var toIDTF: UITextField!
    @IBOutlet weak var sendMessageTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [MessageModel] = []
    let cellIdentifier = "MessageCell"

    let array = ["id_0001", "id_0002"]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "MessageCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        self.localIDTF.text = array[0]
        self.toIDTF.text = array[1]

        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMQTTMessage(_:)), name: .MQTT.receiceMessage, object: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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

    /// 订阅主题, 需要订阅之后才能收到消息
    @IBAction func subscribeTopicBtnClickAction(_ sender: Any) {
        // 对方发送跟你约定好的消息, 比如主题设置为你的id
        MQTTManager.shared.subscribeTopic(topic: self.localIDTF.text ?? "")
    }

    /// 发送信息,
    @IBAction func sendBtnClickedAction(_ sender: Any) {
        // 发送信息使用对方的id作为topic内容
        self.sendMessage()
    }

    @objc func didReceiveMQTTMessage(_ noti: Notification) {
        guard let userInfo = noti.userInfo else {
            return
        }
        guard let data = try? JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted) else {
            return
        }
        guard let messageModel = try? JSONDecoder().decode(MessageModel.self, from: data) else {
            return
        }
        self.receivedMessage(messageModel: messageModel)
    }

}

extension ViewController {
    func sendMessage() {
        self.sendMessage(message: self.sendMessageTF.text, topic: self.toIDTF.text, senderName: self.localIDTF.text)
        self.sendMessageTF.text = nil;
    }
    func sendMessage(message: String?, topic: String?, senderName: String?) {
        guard let message = message, message.count > 0,
              let topic = topic, topic.count > 0,
              let senderName = senderName, senderName.count > 0 else {
            return
        }
        MQTTManager.shared.publishMessage(topic: topic, content: message, currentUser: senderName)

        let count = self.messages.count
        let messageModel = MessageModel(content: message, timeStamp: Date().timeIntervalSince1970, senderName: senderName)
        self.messages.append(messageModel)
        self.tableView.insertRows(at: [IndexPath(row: count, section: 0)], with: .none)
//        self.tableView.reloadData()
    }

    func receivedMessage(messageModel: MessageModel) {
        let count = self.messages.count
        self.messages.append(messageModel)
        self.tableView.insertRows(at: [IndexPath(row: count, section: 0)], with: .none)
//        self.tableView.reloadData()
    }
}

extension ViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text?.count ?? 0 > 0) {
            self.sendMessage()
        }
        return true
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MessageCell

        cell?.messageModel = self.messages[indexPath.row]

        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

