//
//  ViewJuso.swift
//  StarPos
//
//  Created by 한법문 on 2021/07/07.
//

import Foundation

struct ViewJuso {

    
    var roadAddr: String
    var jibunAddr: String
    var zipNo: String
    
    init(_ item: AddrItem.Results.JusoItem) {
        roadAddr = item.roadAddr
        jibunAddr = item.jibunAddr
        zipNo = item.zipNo
    }
    
    init(roadAddr: String, jibunAddr: String, zipNo: String) {
        self.roadAddr = roadAddr
        self.jibunAddr = jibunAddr
        self.zipNo = zipNo
    }
    

}

struct ViewSearchInfo {
    var totalCount: String
    var errorCode: String
    var errorMg: String
    
    init(_ item: AddrItem) {
        totalCount = item.results.common.totalCount
        errorCode = item.results.common.errorCode
        errorMg = item.results.common.errorMessage
    }
    
    init(totalCount: String, errorCode: String, errorMg: String) {
        self.errorCode = errorCode
        self.errorMg = errorMg
        self.totalCount = totalCount
    }
}
