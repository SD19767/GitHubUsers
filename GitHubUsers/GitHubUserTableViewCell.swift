//
//  GitHubUserTableViewCell.swift
//  GitHubUsers
//
//  Created by Alvin on 2024/4/29.
//

import UIKit
import SnapKit
import AlamofireImage

class GitHubUserTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    private lazy var numberOfItemsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 23, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .right
        return label
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let siteAdminBadgeHeight: CGFloat = 20
    private let siteAdminBadgePadding: CGFloat = 8
    
    private lazy var siteAdminBadge: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.purple.withAlphaComponent(0.8)
        button.layer.cornerRadius = siteAdminBadgeHeight / 2
        button.clipsToBounds = true
        button.setTitle("STAFF", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [usernameLabel, siteAdminBadge])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        return stackView
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(stackView)
        contentView.addSubview(numberOfItemsLabel)
        
        avatarImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(50)
            make.top.bottom.equalToSuperview().inset(12)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(avatarImageView.snp.trailing).offset(16)
        }
        
        numberOfItemsLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(12)
        }
    }
    
    // MARK: - Configure
    
    func configure(with user: GitHubUser, atIndex index: Int) {
        usernameLabel.text = user.login
        siteAdminBadge.isHidden = !user.siteAdmin
        if let url = URL(string: user.avatarURL) {
            avatarImageView.af.setImage(withURL: url, placeholderImage: UIImage(systemName: "person.fill"))
        }
        numberOfItemsLabel.text = "#\(index + 1)"
    }
}
