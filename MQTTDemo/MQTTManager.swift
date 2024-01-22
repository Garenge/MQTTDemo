//
//  MQTTManager.swift
//  MQTTDemo
//
//  Created by Garenge on 2023/4/21.
//

import UIKit
import CocoaMQTT

public let MQTT_HOST                = "127.0.0.1"
public let MQTT_PORT                = 1883 as UInt16
public let MQTT_KEEPALIVE           = 45 as UInt16
public let MQTT_TIMEOUT             = 30 as TimeInterval
public let kUUID: String                             = UIDevice.current.identifierForVendor?.uuidString ?? ""

class MQTTManager: NSObject {

    static let shared = MQTTManager()

    var mqtt: CocoaMQTT?

    func setupMQTT(host: String = MQTT_HOST, port: UInt16 = MQTT_PORT) {
        let clientID = kUUID
        mqtt = CocoaMQTT(clientID: clientID, host: host, port: port)
        mqtt!.username = ""
        mqtt!.password = ""
        mqtt!.delegate = self
        mqtt!.keepAlive = MQTT_KEEPALIVE
        mqtt!.autoReconnect = true
    }

    func connectMQTT() {

        _ = mqtt!.connect(timeout: MQTT_TIMEOUT)
    }

    func disconnectMQTT() {

        mqtt?.disconnect()

    }

    func subscribeTopic(topic: String) {

        if mqtt?.connState == .connected {
            mqtt?.subscribe(topic, qos: .qos2)
        }
    }

    func unsubscribeTopic(topic: String) {

        if mqtt?.connState == .connected {
            mqtt?.unsubscribe(topic)
        }
    }

    func publishMessage(topic: String, message: String) -> Bool {

        if mqtt?.connState == .connected {
            mqtt?.publish(topic, withString: message, qos: .qos2)
            return true
        } else {
            return false
        }
    }

    func TRACE(_ message: String = "", fun: String = #function) {
        let names = fun.components(separatedBy: ":")
        var prettyName: String
        if names.count == 2 {
            prettyName = names[0]
        } else {
            prettyName = names[1]
        }

        if fun == "mqttDidDisconnect(_:withError:)" {
            prettyName = "didDisconect"
        }

        print("[MQTT] [\(prettyName)]: \(message)")
    }
}

extension MQTTManager: CocoaMQTTDelegate {

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        TRACE()
        NotificationCenter.default.post(name: .MQTT.didConnect, object: nil)
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        TRACE("message: \(message.description), id: \(id)")
#if DEBUG
        if #available(iOS 11.0, *) {
            var sortedString: String? = message.string
            if let dataFromString = (sortedString ?? "").data(using: .utf8, allowLossyConversion: false), let jsonFromData = try? JSONSerialization.jsonObject(with: dataFromString, options: .mutableContainers), let dataFromStringSorted = try? JSONSerialization.data(withJSONObject: jsonFromData, options: [.sortedKeys, .prettyPrinted]) {
                sortedString = String(data: dataFromStringSorted, encoding: .utf8)
                print("[MQTT] prettyJson:\n\n\n\(sortedString ?? "")\n\n\nid: \(id), topic: \(message.topic)")
                return
            }
        }
#endif
        TRACE("message string: \(message.string ?? ""), id: \(id), topic: \(message.topic)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        TRACE("id: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        TRACE("message: \(message.description), id: \(id)")
        NotificationCenter.default.post(name: .MQTT.receiceMessage, object: nil, userInfo: ["msg": message.string ?? ""])
#if DEBUG
        if !(message.string?.contains("networkStats") ?? false) {

            var sortedString: String? = message.string
            if #available(iOS 11.0, *) {
                if let dataFromString = (sortedString ?? "").data(using: .utf8, allowLossyConversion: false), let jsonFromData = try? JSONSerialization.jsonObject(with: dataFromString, options: .mutableContainers), let dataFromStringSorted = try? JSONSerialization.data(withJSONObject: jsonFromData, options: [.sortedKeys, .prettyPrinted]) {
                    sortedString = String(data: dataFromStringSorted, encoding: .utf8)
                    print("[MQTT] prettyJson:\n\n\n\(sortedString ?? "")\n\n\nid: \(id), topic: \(message.topic)")
//                    TLCMQTTResponse.getMQTTResponse(topic: message.topic, message: message.string ?? "")
                    return
                }
            }
        }
#else
        TRACE("message string: \(message.string ?? ""), id: \(id), topic: \(message.topic)")
//        TLCMQTTResponse.getMQTTResponse(topic: message.topic, message: message.string ?? "")
#endif
    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        TRACE("topics: \(success)")
        NotificationCenter.default.post(name: .MQTT.didSubscribeTopic, object: nil, userInfo: ["topics": success])
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        TRACE("topic: \(topics)")
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {
        TRACE()
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        TRACE()
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        TRACE("\(err?.localizedDescription ?? "")")
        NotificationCenter.default.post(name: .MQTT.disConnect, object: err)
    }

    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        TRACE("new state: \(state)")
    }

}
