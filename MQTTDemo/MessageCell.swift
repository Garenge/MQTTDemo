//
//  MessageCell.swift
//  MQTTDemo
//
//  Created by pengpeng on 2024/2/1.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    var messageModel: MessageModel? {
        didSet {
            self.senderNameLabel.text = messageModel?.senderName
            self.contentLabel.text = messageModel?.content
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
