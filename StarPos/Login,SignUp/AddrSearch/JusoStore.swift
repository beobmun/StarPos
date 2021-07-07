//
//  AddressStore.swift
//  StarPos
//
//  Created by 한법문 on 2021/07/07.
//

import Foundation
import RxSwift

protocol JusoFetchable {
    func fetchJusos() -> Observable<AddrItem>
}

class JusoStore: JusoFetchable {
    func fetchJusos() -> Observable<AddrItem> {
        struct Response: Codable {
            let addr: AddrItem
        }
        
        return APIService.fetchAddressRx()
            .map { data in
                
                guard let response = try? JSONDecoder().decode(AddrItem.self, from: data) else {
                    throw NSError(domain: "Decoding error", code: -1, userInfo: nil)
                }
                print(response)
                return response
            }
    }
}
