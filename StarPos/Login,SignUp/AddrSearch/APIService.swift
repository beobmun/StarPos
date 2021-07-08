//
//  APIService.swift
//  StarPos
//
//  Created by 한법문 on 2021/07/07.
//

import Foundation
import RxSwift
import Alamofire


enum AddressAPI {
    static let baseUrl: String = "https://www.juso.go.kr/addrlink/addrLinkApi.do"
    static let confmKey: String = "U01TX0FVVEgyMDIxMDcwNjIzMDk1NTExMTM2ODc="
    static var keyword: String?
    static var countPerPage: Int = 10
//    static var keyword: String = "그린시티"
}

//API로 주소 호춯
class APIService {
    
    
    static func fetchAddress(onComplete: @escaping (Result<Data, Error>) -> Void) {
        guard let keyword = AddressAPI.keyword else { return }
        
        var param: [String: Any] = [
            "confmKey": AddressAPI.confmKey,
            "countPerPage": AddressAPI.countPerPage,
            "keyword": keyword,
            "resultType": "json"
        ]
        
        AF.request(AddressAPI.baseUrl, method: .get, parameters: param).validate().responseJSON { (response) in
            guard let data = response.data else { return }
            switch response.result {
                case .failure(let err):
                    onComplete(.failure(err))
                    return
                case .success(let obj):
                    do {
                        let dataJson = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        onComplete(.success(dataJson))
                    } catch {
                        print(error)
                    }
                    
            }
        }
    }
    
    static func fetchAddressRx() -> Observable<Data> {
        return Observable.create { emitter in
            fetchAddress() { result in
                switch result {
                case let .success(data):
                    print("fetchRx Success")
                    emitter.onNext(data)
                    emitter.onCompleted()
                    
                case let .failure(err):
                    emitter.onError(err)
                }
            }
            return Disposables.create()
        }
    }
}
