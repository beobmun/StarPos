//
//  JusoItem.swift
//  StarPos
//
//  Created by 한법문 on 2021/07/07.
//

import Foundation


struct AddrItem: Codable {
    var results: Results
    
    struct Results: Codable {
        var common: Common
        var  juso: [JusoItem]
        
        struct Common: Codable {
            var totalCount: String
            var currentPage: String
            var countPerPage: String
            var errorCode: String
            var errorMessage: String
        }

        struct JusoItem: Codable {
            var zipNo: String
            var roadAddr: String
            var jibunAddr: String
        }
    }
}



