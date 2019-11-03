//
//  ViewController.swift
//  UnHindr
//
//  Created by Allan on 2019-10-28.
//  Copyright © 2019 Sigma. All rights reserved.
//
import Foundation
import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    // MARK: - Outlets
    //Input fields for username and password
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    // MARK: - View controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureEmailText()
        configurePasswordText()
        
        configureTapGesture()
    }
    
    // MARK: - Database methods for login authentication
    // Backend Function
    // Input:
    //      1. Email
    //      2. Password
    // Output:
    //      1. Signin successful -> Navigate to home menu
    //      2. Signin unsuccessful -> Display an error message
    private func authenticateLogin(){
        guard let email = self.emailTextField.text, let password = self.passwordTextField.text else {
            print("Email and password fields are empty")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if error != nil {
                print("Error with authentication")
                return
            }
            strongSelf.transitionToHomeScreen()
            
        }
    }
    
    private func configureEmailText(){
        emailTextField.delegate = self
    }
    private func configurePasswordText(){
        passwordTextField.delegate = self
    }
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleTapOutsideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapOutsideKeyboard() {
        view.endEditing(true)
    }

    
    // MARK - Changes storyboard and view controller to the home screen
    // Input: None
    // Output:
    //      1. Storyboard changes to HomeScreen and displays first view on the storyboard
    private func transitionToHomeScreen(){
        //Switch storyboard to the home menu
        let storyboard = UIStoryboard(name: "HomeScreen", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as UIViewController
        present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Segue functions for navigation to adjacent views
    // UI Component
    // Activation: When pressed
    // Action: If successful -> Navigate to home menu
    //         else not successful -> display error message
    @IBAction func loginTapped(_ sender: Any) {
        authenticateLogin()
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
