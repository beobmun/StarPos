//
//  AddressTableViewCell.swift
//  StarPos
//
//  Created by 한법문 on 2021/07/06.
//

import UIKit
import RxSwift


class AddressTableViewCell: UITableViewCell {
    
    static let identifier = "AddressTableViewCell"
    
    private let cellDisposeBag = DisposeBag()
    
    var disposeBag = DisposeBag()
    let onData: AnyObserver<ViewJuso>
    
    required init?(coder aDecoder: NSCoder) {
        let data = PublishSubject<ViewJuso>()
        onData = data.asObserver()
        
        super.init(coder: aDecoder)
        
        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] juso in
                self?.roadAddrLabel.text = juso.roadAddr
                self?.jibunAddrLabel.text = juso.jibunAddr
                self?.zipNoLabel.text = juso.zipNo
            })
            .disposed(by: cellDisposeBag)
    }
    
    
    @IBOutlet weak var zipNoLabel: UILabel!
    @IBOutlet weak var roadAddrLabel: UILabel!
    @IBOutlet weak var jibunAddrLabel: UILabel!
}




// 승인키 : U01TX0FVVEgyMDIxMDcwNjIzMDk1NTExMTM2ODc=
