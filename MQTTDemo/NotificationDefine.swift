//
//  NotificationDefine.swift
//  MQTTDemo
//
//  Created by pengpeng on 2024/1/22.
//

import Foundation

extension Notification.Name {

    // MARK: - MQTT
    struct MQTT {

        static let didConnect              = Notification.Name("NotificationNameMQTTDidConnect")
        static let disConnect              = Notification.Name("NotificationNameMQTTDisconnect")
        static let receiceMessage = Notification.Name("NotificationNameMQTTReceiceMessage")
        static let didSubscribeTopic       = Notification.Name("NotificationNameMQTTDidSubscribeTopic")
        static let didUnsubscribeTopic     = Notification.Name("NotificationNameMQTTDidUnsubscribeTopic")

        static let didReceiveMessage       = Notification.Name("NotificationNameMQTTDidReceiveMessage")
    }

}
