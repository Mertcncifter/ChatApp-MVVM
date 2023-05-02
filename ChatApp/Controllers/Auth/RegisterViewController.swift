//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by mert can çifter on 15.04.2023.
//

import UIKit
import SnapKit
import FirebaseAuth
import JGProgressHUD


class RegisterViewController: UIViewController {

    // MARK: - Properties
    
    private var viewModel : RegisterViewModelProtocol! {
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
    
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(handleAddProfilPhoto), for: .touchUpInside)
        return button
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
    
    private lazy var firstNameTextField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.textColor = .label
        field.font = UIFont.systemFont(ofSize: 14)
        field.attributedPlaceholder = NSAttributedString(string: "First Name",attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        
        field.delegate = self
        
        return field
    }()
    
    private lazy var lastNameTextField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.textColor = .label
        field.font = UIFont.systemFont(ofSize: 14)
        field.attributedPlaceholder = NSAttributedString(string: "Last Name",attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])
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
    
    private lazy var registerButton: UIView = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?", attributes:
            [NSMutableAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSMutableAttributedString.Key.foregroundColor: UIColor.label])
        
        attributedTitle.append(NSMutableAttributedString(string: " Log In", attributes:
            [NSMutableAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),
            NSMutableAttributedString.Key.foregroundColor: UIColor.label]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = RegisterViewModel()
        
        view.backgroundColor = .systemBackground
        
        scrollView.addSubview(plusPhotoButton)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(firstNameTextField)
        scrollView.addSubview(lastNameTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(registerButton)
        scrollView.addSubview(alreadyHaveAccountButton)
        
        view.addSubview(scrollView)
        
        
    }
    
    
    // MARK: - Lifecycle

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        configureUI()

    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        
        plusPhotoButton.snp.makeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide.snp.top).offset(50)
            make.centerX.equalTo(view)
            make.height.width.equalTo(128)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(plusPhotoButton.snp.bottom).offset(50)
            make.centerX.equalTo(view)
            make.height.equalTo(52)
            make.width.equalTo(scrollView.width - 60)
        }
        
        firstNameTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(10)
            make.centerX.equalTo(view)
            make.height.equalTo(52)
            make.width.equalTo(scrollView.width - 60)
        }
        
        lastNameTextField.snp.makeConstraints { make in
            make.top.equalTo(firstNameTextField.snp.bottom).offset(10)
            make.centerX.equalTo(view)
            make.height.equalTo(52)
            make.width.equalTo(scrollView.width - 60)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(lastNameTextField.snp.bottom).offset(10)
            make.height.equalTo(52)
            make.width.equalTo(scrollView.width - 60)
        }
        
        registerButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.height.equalTo(52)
            make.width.equalTo(scrollView.width - 60)
        }
        
        alreadyHaveAccountButton.snp.makeConstraints { make in
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
    
    @objc private func registerButtonTapped() {
        
        emailTextField.resignFirstResponder()
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text,
              let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let password = passwordTextField.text,
              !email.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !password.isEmpty, password.count > 6 else {
            return
        }
        
        viewModel.register(email: email, password: password, firstName: firstName, lastName: lastName)
        
    }
    
    @objc func handleShowLogin(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleAddProfilPhoto(){
        presentPhotoActionSheet()
    }

}


// MARK: - RegisterViewModelDelegate

extension RegisterViewController: RegisterViewModelDelegate {

    func handleViewModelOutput(_ output: RegisterViewModelOutput) {
        switch output {
        case .setLoading(let bool):
            configureSpinner(state: bool)
        case .error(let error):
            self.showToast(message: error)
        case .success:
            self.navigationController?.dismiss(animated: true,completion: nil)
        }
    }

}

// MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            firstNameTextField.becomeFirstResponder()
        }
        
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        }
        
        if textField == lastNameTextField {
            passwordTextField.becomeFirstResponder()
        }
        
        else if textField == passwordTextField {
            registerButtonTapped()
        }
        
        return true
    }
}


// MARK: - UIImagePickerControllerDelegate

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like a select a picture", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default,handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Chose Photo", style: .default,handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet,animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true,completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        
        self.plusPhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }
}
