//
//  AddressStore.swift
//  StarPos
//
//  Created by 한법문 on 2021/07/07.
//

import Foundation
import RxSwift

protocol JusoFetchable {
    func fetchJusos() -> Observable<[JusoItem]>
}

class JusoStore: JusoFetchable {
    func fetchJusos() -> Observable<[JusoItem]> {
        struct Response: Decodable {
            let jusos: [JusoItem]
        }
        
        return APIService.fetchAddressRx()
            .map { data in
                guard let response = try? JSONDecoder().decode(Response.self, from: data) else {
                    throw NSError(domain: "Decoding error", code: -1, userInfo: nil)
                }
                return response.jusos
            }
    }
}
