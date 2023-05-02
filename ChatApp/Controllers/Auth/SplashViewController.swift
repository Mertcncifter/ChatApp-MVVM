//
//  SplashViewController.swift
//  ChatApp
//
//  Created by mert can çifter on 15.04.2023.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class SplashViewController: UIViewController {

    // MARK: - Properties
    
    private let spinner = JGProgressHUD(style: .dark)

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        spinner.show(in: view)
        validateAuth()
    }
    
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            dismissSpinner()
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        } else {
            dismissSpinner()
            let vc = MainTabViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    private func dismissSpinner(){
        DispatchQueue.main.async {
            self.spinner.dismiss()
        }
    }
}
