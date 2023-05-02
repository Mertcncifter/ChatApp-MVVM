//
//  LoginViewController.swift
//  ChatApp
//
//  Created by mert can çifter on 15.04.2023.
//

import UIKit
import SnapKit
import FirebaseAuth
import JGProgressHUD


class LoginViewController: UIViewController {

    // MARK: - Properties
    
    private var viewModel : LoginViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    
    private lazy var emailTextField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.textColor = .label
        field.font = UIFont.systemFont(ofSize: 14)
        field.attributedPlaceholder = NSAttributedString(string: "Email",attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        
        field.delegate = self
        
        return field
    }()
    
    private lazy var passwordTextField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.textColor = .label
        field.font = UIFont.systemFont(ofSize: 14)
        field.attributedPlaceholder = NSAttributedString(string: "Password",attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        field.isSecureTextEntry = true
        
        field.delegate = self
        
        return field
    }()
    
    private lazy var loginButton: UIView = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?", attributes:
            [NSMutableAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSMutableAttributedString.Key.foregroundColor: UIColor.label])
        
        attributedTitle.append(NSMutableAttributedString(string: " Sign Up", attributes:
            [NSMutableAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),
            NSMutableAttributedString.Key.foregroundColor: UIColor.label]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = LoginViewModel()
        
        view.backgroundColor = .systemBackground
        
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(dontHaveAccountButton)
        
        view.addSubview(scrollView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        configureUI()
        
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide.snp.top).offset(50)
            make.centerX.equalTo(view)
            make.height.equalTo(52)
            make.width.equalTo(scrollView.width - 60)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(emailTextField.snp.bottom).offset(10)
            make.height.equalTo(52)
            make.width.equalTo(scrollView.width - 60)
        }
        
        loginButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.height.equalTo(52)
            make.width.equalTo(scrollView.width - 60)
        }
        
        
        dontHaveAccountButton.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(40)
            make.right.equalTo(view.snp.right).offset(-40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
         
    }
    
    private func configureSpinner(state: Bool) {
        if state {
            spinner.show(in: view)
        }
        else {
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
        }
    }

    
    // MARK: - Selectors
    
    @objc private func loginButtonTapped() {
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text, let password = passwordTextField.text,
              !email.isEmpty, !password.isEmpty, password.count > 6 else {
            return
        }
        
        viewModel.login(email: email, password: password)
        
    }
    
    @objc func handleShowSignUp(){
        let controller = RegisterViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
}


// MARK: - LoginViewModelDelegate

extension LoginViewController: LoginViewModelDelegate {

    func handleViewModelOutput(_ output: LoginViewModelOutput) {
        switch output {
        case .setLoading(let bool):
            configureSpinner(state: bool)
        case .error(let error):
            self.showToast(message: error)
            
        }
    }
    
    func navigate(to route: LoginViewRoute) {
        switch route {
        case .home:
            self.navigationController?.dismiss(animated: true,completion: nil)
        }
    }
}


// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        
        else if textField == passwordTextField {
            loginButtonTapped()
        }
        
        return true
    }
}
