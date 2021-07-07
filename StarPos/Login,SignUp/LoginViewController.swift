//
//  ViewController.swift
//  StarPos
//
//  Created by 한법문 on 2021/07/05.
//

import UIKit
import Firebase
import FirebaseAuth



class LoginViewController: UIViewController {

    
    // MARK: - var, let
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    


    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        idTextField.delegate = self
        pwTextField.delegate = self
        
        let tapMainView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapMainView)
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    

    @IBAction func loginBtnClicked(_ sender: UIButton) {
        
        guard let id = idTextField.text, id != "" else {
            showAlert("아이디 / 비밀번호 오류", "아이디를 입력해주세요")
            return
        }
        guard let pw = pwTextField.text, pw != "" else {
            showAlert("아이디 / 비밀번호 오류", "비밀번호를 입력해주세요")
            return
        }
        
        loginBtnClicked(id: id, pw: pw)
        
    }
    
    
    
    func loginBtnClicked(id: String, pw: String) {
        
        print(id, pw)
        print("LoginViewModel - loginBtnClicked()")
        
        Auth.auth().signIn(withEmail: id, password: pw) { [weak self] authResult, error in
            guard let strongSelf = self, error == nil else {
                if let errorCode = AuthErrorCode(rawValue: (error?._code) as! Int) {
                    switch errorCode {
                    case AuthErrorCode.invalidEmail:
                        self?.showAlert("로그인 오류", "잘못된 이메일 형식입니다.")
                    case AuthErrorCode.userDisabled:
                        self?.showAlert("로그인 오류", "사용 중지된 계정입니다.")
                    case AuthErrorCode.wrongPassword:
                        self?.showAlert("로그인 오류", "잘못된 비밀 번호입니다.")
                    default:
                        self?.showAlert("로그인 오류", "로그인 과정 중 오류가 발생했습니다. \n 아이디, 비밀번호를 다시 확인해주세요.")
                    }
                }
                return
            }
            
            
        }
        
    }
    
    
    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    

    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
