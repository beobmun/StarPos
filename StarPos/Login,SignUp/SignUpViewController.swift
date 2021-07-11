//
//  SignUpViewController.swift
//  StarPos
//
//  Created by 한법문 on 2021/07/05.
//

import UIKit
import RxCocoa
import RxSwift
import RxViewController
import FirebaseAuth


class SignUpViewController: UIViewController {
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField1: UITextField!
    @IBOutlet weak var pwTextField2: UITextField!
    @IBOutlet weak var storeNameTextField: UITextField!
    @IBOutlet weak var zipNoTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var detailAddTextField: UITextField!
    @IBOutlet weak var businessNumTextField: UITextField!
    @IBOutlet weak var phoneNumTextField: UITextField!
    @IBOutlet weak var industryTextField: UITextField!
    @IBOutlet weak var paymentTypeTextField: UITextField!
    
    @IBOutlet weak var pwNotifyLabel: UILabel!
    @IBOutlet weak var signUpBtn: UIButton!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var viewModel: SignUpViewModelType
    var disposeBag = DisposeBag()
    let signUpViewModel = SignUpViewModel()
    
    
    let industryPickerView = UIPickerView()
    let paymentPickerView = UIPickerView()
    
    
    let industries = ["카페", "음식점", "기타"]
    let payments = ["선불", "후불"]
    
    init(viewModel: SignUpViewModelType = SignUpViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        viewModel = SignUpViewModel()
        super.init(coder: aDecoder)
    }


        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.removeObserver(self)
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        textFieldConfig()
        setupBindings()
        
        let tapMainView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapMainView)
    }
    
    
    // keyboar 관련
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            scrollView.contentInset.bottom = keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
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
        
        pwNotifyLabel.isHidden = true
    }
    
    func setupBindings() {
        
        // 주소 선택 한 후 주소 넣기
        rx.viewWillAppear.subscribe(onNext: { [weak self]_ in
            self?.viewModel.selectedAddr
            .subscribe(onNext: { [weak self] _ in
                self?.addressTextField.text = SignUpViewModel.address.roadAddr
                self?.zipNoTextField.text = SignUpViewModel.address.zipNo
            })
                .disposed(by: self!.disposeBag)
        })
        .disposed(by: disposeBag)
        
        
        
        // 비밀 번호 같은지 비교
        pwTextField1.rx.controlEvent(.editingChanged)
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                if self?.pwTextField1.text == self?.pwTextField2.text {
                    self?.pwNotifyLabel.isHidden = true
                } else {
                    self?.pwNotifyLabel.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        pwTextField2.rx.controlEvent(.editingChanged)
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                if self?.pwTextField1.text == self?.pwTextField2.text {
                    self?.pwNotifyLabel.isHidden = true
                } else {
                    self?.pwNotifyLabel.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        

        
        signUpViewModel.pickerViewSet(textField: paymentTypeTextField, pickerView: paymentPickerView, title: payments)
        
        signUpViewModel.pickerViewSet(textField: industryTextField, pickerView: industryPickerView, title: industries)
        
        signUpBtn.rx.tap
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.signUpViewModel.signUpCheck(id: self!.idTextField, pw1: self!.pwTextField1, pw2: self!.pwTextField2, storeName: self!.storeNameTextField, zipNo: self!.zipNoTextField, address: self!.addressTextField, detailAddr: self!.detailAddTextField, businessNum: self!.businessNumTextField, phoneNum: self!.phoneNumTextField, industry: self!.industryTextField, payment: self!.paymentTypeTextField)
                    .subscribe(onNext: {
                        switch $0 {
                        case "정상":
                            self?.signUp(email: self!.idTextField, pw: self!.pwTextField1)
                            
                        default:
                            self?.showAlert("회원가입 오류", $0)
                        }
                    })
                    .disposed(by: self!.disposeBag)

            })
            .disposed(by: disposeBag)
        

    }
    
    
    func signUp(email: UITextField, pw: UITextField) {
        
        Auth.auth().createUser(withEmail: email.text!, password: pw.text!) { [weak self] authResult, error in
            
            if error == nil {
                let alert = UIAlertController(title: "회원가입 성공", message: "회원가입을 완료하였습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                    self?.signUpViewModel.login(email: self!.idTextField, pw: self!.pwTextField1, storeName: self!.storeNameTextField, zipNo: self!.zipNoTextField, address: self!.addressTextField, detailAddr: self!.detailAddTextField, businessNum: self!.businessNumTextField, phoneNum: self!.phoneNumTextField, industry: self!.industryTextField, payment: self!.paymentTypeTextField)
                    let pushVC = self?.storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
                    self?.navigationController?.pushViewController(pushVC!, animated: true)
                }))
                self?.present(alert, animated: true, completion: nil)
            } else {
                if let errorCode = AuthErrorCode(rawValue: (error!._code)) {
                    switch errorCode {
                    case AuthErrorCode.invalidEmail:
                        self?.showAlert("회원가입 오류", "잘못된 이메일 형식입니다.")
                    case AuthErrorCode.emailAlreadyInUse:
                        self?.showAlert("회원가입 오류", "이미 존재하는 이메일 입니다.")
                    case AuthErrorCode.weakPassword:
                        self?.showAlert("회원가입 오류", "비밀번호의 안정성이 너무 낮습니다.")
                    default:
                        self?.showAlert("회원가입 오류", "회원가입 과정에서 오류가 발생했습니다. \n 아이디/비밀번호를 다시 설정해주세요.")
                    }
                }
            }
        }
        
    }
    
    
    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
}
