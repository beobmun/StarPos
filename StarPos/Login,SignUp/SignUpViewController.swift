//
//  SignUpViewController.swift
//  StarPos
//
//  Created by 한법문 on 2021/07/05.
//

import UIKit


class SignUpViewController: UIViewController {
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField1: UITextField!
    @IBOutlet weak var pwTextField2: UITextField!
    @IBOutlet weak var storeNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var detailAddTextField: UITextField!
    @IBOutlet weak var businessNumTextField: UITextField!
    @IBOutlet weak var phoneNumTextField: UITextField!
    @IBOutlet weak var industryTextField: UITextField!
    @IBOutlet weak var paymentTypeTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldConfig()
        
        let tapMainView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapMainView)
    }
    
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    
    func textFieldConfig() {
        idTextField.delegate = self
        pwTextField1.delegate = self
        pwTextField2.delegate = self
        storeNameTextField.delegate = self
        detailAddTextField.delegate = self
        businessNumTextField.delegate = self
        phoneNumTextField.delegate = self
        industryTextField.delegate = self
        paymentTypeTextField.delegate = self
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
