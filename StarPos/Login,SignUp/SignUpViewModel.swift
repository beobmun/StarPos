//
//  SignUpViewModel.swift
//  StarPos
//
//  Created by 한법문 on 2021/07/09.
//

import Foundation
import RxSwift
import FirebaseAuth
import Firebase
import FirebaseFirestore


protocol SignUpViewModelType {
    var selectedAddr: Observable<ViewJuso> { get }
}


class SignUpViewModel: SignUpViewModelType {
    
    let selectedAddr: Observable<ViewJuso>
    
    let disposeBag = DisposeBag()
    
    let db = Firestore.firestore()
    
    
    let toolBar = UIToolbar()
    let doneBtn = UIBarButtonItem.init(barButtonSystemItem: .done, target: nil, action: nil)
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    
    static var address: ViewJuso = ViewJuso(roadAddr: "", jibunAddr: "", zipNo: "")
    
    
    init(_ selectedAddress: ViewJuso = address) {
        let addr = Observable.just(selectedAddress)


        selectedAddr = addr

    }
    
    
    func pickerViewSet(textField: UITextField, pickerView: UIPickerView, title: [Any]) {
        doneBtn.rx.tap
            .subscribe(onNext: { _ in
                let i = pickerView.selectedRow(inComponent: 0)
                textField.text = "\(title[i])"
                textField.endEditing(true)
            })
            .disposed(by: disposeBag)
        toolBar.sizeToFit()
        toolBar.setItems([flexibleSpace, doneBtn], animated: true)
        
        textField.inputView = pickerView
        textField.inputAccessoryView = toolBar
        textField.tintColor = .clear
        
        Observable.just(title)
            .bind(to: pickerView.rx.itemTitles) { _, item in
                return "\(item)"
            }
            .disposed(by: disposeBag)
    }
    
    
    func signUpCheck(id: UITextField, pw1: UITextField, pw2: UITextField, storeName: UITextField, zipNo: UITextField, address: UITextField, detailAddr: UITextField, businessNum: UITextField, phoneNum: UITextField, industry: UITextField, payment: UITextField) -> Observable<String> {
        if id.text == "" {
            return Observable.just("아이디를 입력해주세요")
        } else if pw1.text == "" || pw2.text == "" {
            return Observable.just("비밀번호를 입력해주세요")
        } else if pw1.text != pw2.text {
            return Observable.just("비밀번호가 일치하지 않습니다")
        } else if storeName.text == "" {
            return Observable.just("가게 이름을 입력해주세요")
        } else if zipNo.text == "" || address.text == "" {
            return Observable.just("주소를 입력해주세요")
        } else if detailAddr.text == "" {
            return Observable.just("상세 주소를 입력해주세요")
        } else if businessNum.text == "" {
            return Observable.just("사업자 등록 번호를 입력해주세요")
        } else if phoneNum.text == "" {
            return Observable.just("전화 번호를 입력해주세요")
        } else if industry.text == "" {
            return Observable.just("업종을 선택해주세요")
        } else if payment.text == "" {
            return Observable.just("결제 유형을 선택해주세요")
        } else {
            return Observable.just("정상")
        }
    }
    

    


    func login(email: UITextField, pw: UITextField, storeName: UITextField, zipNo: UITextField, address: UITextField, detailAddr: UITextField, businessNum: UITextField, phoneNum: UITextField, industry: UITextField, payment: UITextField) {
        print("login 실행")
        Auth.auth().signIn(withEmail: email.text!, password: pw.text!) { [weak self] result, error in
            if error == nil {
                self?.saveStoreData(storeName: storeName, zipNo: zipNo, address: address, detailAddr: detailAddr, businessNum: businessNum, phoneNum: phoneNum, industry: industry, payment: payment)

            } else {
                print("로그인 에러 \(error)")
            }
        }
    }
    
    func saveStoreData(storeName: UITextField, zipNo: UITextField, address: UITextField, detailAddr: UITextField, businessNum: UITextField, phoneNum: UITextField, industry: UITextField, payment: UITextField) {
        guard let user = Auth.auth().currentUser else { return }
        self.db.collection("Stores").document(user.uid).setData([
            "가게 이름": storeName.text,
            "주소": "\(zipNo.text!) \(address.text!) \(detailAddr.text!)",
            "사업자 등록 번호": businessNum.text,
            "전화번호": phoneNum.text,
            "업종": industry.text,
            "결제 유형": payment.text
        ])
    }
}
