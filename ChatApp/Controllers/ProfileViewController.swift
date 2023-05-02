//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by mert can çifter on 15.04.2023.
//

import UIKit
import FirebaseAuth
import SnapKit

class ProfileViewController: UIViewController {

    // MARK: - Properties
    
    private lazy var logoutButton: UIView = {
        let button = UIButton()
        button.setTitle("Logout", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(logoutButton)
        
        configureUI()
    }
    
    private func configureUI() {
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide.snp.top).offset(50)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - Selectors
    
    @objc private func logoutButtonTapped() {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        } catch {
            
        }
    }
}
