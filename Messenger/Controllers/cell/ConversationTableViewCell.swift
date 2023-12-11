//
//  ConversationTableViewCell.swift
//  Messenger
//
//  Created by Arslan Raza on 01/12/2023.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 1
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        userImageView.frame = CGRect(x: 10, y: 10, width: 80, height: 80)
        userNameLabel.frame = CGRect(x: Int(userImageView.right) + 10, y: 10, width: Int(contentView.width - 20 - userImageView.width), height: Int((contentView.height - 20)/2))
        
        userMessageLabel.frame = CGRect(x: Int(userImageView.right) + 10, y: Int(userNameLabel.height), width: Int(contentView.width - 20 - userImageView.width), height: Int((contentView.height - 20) / 2))
    }
    
    public func configure(with model: Conversation) {
        userNameLabel.text = model.name
        userMessageLabel.text = model.latestMessage.text
        
        let path = "images/\(model.otherUserEmail)_Profile_Picture_png"
        StorageManager.shared.downloadProfileImage(for: path) { [weak self] result in
            switch result {
                
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("falied to get url \(error.localizedDescription)")
            }
        }
    }
}
