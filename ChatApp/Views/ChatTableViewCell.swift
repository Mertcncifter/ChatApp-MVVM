//
//  ChatTableViewCell.swift
//  ChatApp
//
//  Created by mert can çifter on 25.04.2023.
//

import UIKit
import SnapKit

class ChatTableViewCell: UITableViewCell {

    static let identifier = "ChatTableViewCell"

    // MARK: - Properties

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "person")
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
        super.layoutSubviews()
        
        userImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(5)
            make.left.equalTo(contentView.snp.left).offset(5)
            make.height.width.equalTo(60)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(5)
            make.left.equalTo(userImageView.snp.right).offset(10)
            make.right.equalTo(contentView.snp.right).offset(10)
        }
        
        userMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(5)
            make.left.equalTo(userImageView.snp.right).offset(10)
            make.right.equalTo(contentView.snp.right).offset(10)
        }
        
    }
    
    public func configure(with model: Conversation) {
        self.userMessageLabel.text = model.latestMessage.text
        self.userNameLabel.text = model.name
        
    }
    

}
