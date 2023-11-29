//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Arslan Raza on 22/11/2023.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let firstNameTextField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.placeholder = "First Name"
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let lastNameTextField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.placeholder = "Last Name"
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.placeholder = "Email Address"
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.placeholder = "Password"
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private var button: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Login"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameTextField)
        scrollView.addSubview(lastNameTextField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(button)
        emailField.delegate = self
        passwordField.delegate = self
        button.addTarget(self, action: #selector(registerButtontapped), for: .touchUpInside)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didtapProfileImage))
        imageView.addGestureRecognizer(gesture)
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
    }
    
    @objc private func didtapProfileImage() {
        presentPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = view.width / 3
        imageView.frame = CGRect(x: (view.width - size) / 2, y: 20, width: size, height: size)
        imageView.layer.cornerRadius = imageView.width/2
        firstNameTextField.frame = CGRect(x: 30, y: imageView.bottom + 20, width: scrollView.width - 60, height: 52)
        lastNameTextField.frame = CGRect(x: 30, y: imageView.bottom + 80, width: scrollView.width - 60, height: 52)
        emailField.frame = CGRect(x: 30, y: imageView.bottom + 140, width: scrollView.width - 60, height: 52)
        passwordField.frame = CGRect(x: 30, y: imageView.bottom + 200, width: scrollView.width - 60, height: 52)
        button.frame = CGRect(x: 30, y: imageView.bottom + 272, width: scrollView.width - 60, height: 52)

    }
    
    @objc private func registerButtontapped() {
        
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, !email.isEmpty, !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty, password.count > 6 else {
            alertUserLoginError()
            return
        }
        
        DatabaseManager.shared.userExists(with: email) { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            
            guard !exists else{
                strongSelf.alertUserLoginError(message: "Account for this email is alredy exists.")
                return
            }
        }
        
        FirebaseAuth.Auth.auth().createUser(withEmail: emailField.text ?? "", password: passwordField.text ?? "") { [weak self] user, error in
            guard let strongSelf = self else {
                return
            }
            if error != nil {
                print("Error while creating the user")
                return
            }
            
            DatabaseManager.shared.insertUser(user: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
            
            strongSelf.navigationController?.dismiss(animated: true)
        }
    }
    
    func alertUserLoginError(message: String = "Please enter all information to create a new account.") {
        let alert = UIAlertController(title: "Wooops", message: "Please enter all information to create a new account.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func didTapRegister() {
        let viewController = RegisterViewController()
        viewController.title = "Create Account"
        navigationController?.pushViewController(viewController, animated: true)
        
    }
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            registerButtontapped()
        }
        return true
    }
}


extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        
        let photoAlert = UIAlertController(title: "Profile Photo", message: "How would like to slect the picture", preferredStyle: .alert)
        photoAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        photoAlert.addAction(UIAlertAction(title: "Take photo", style: .default, handler: { _ in
            self.presentCamera()
        }))
        photoAlert.addAction(UIAlertAction(title: "Chose photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        self.present(photoAlert, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        imageView.image = selectedImage
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
