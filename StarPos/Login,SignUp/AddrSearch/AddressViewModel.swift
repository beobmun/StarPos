//
//  AddressViewModel.swift
//  StarPos
//
//  Created by 한법문 on 2021/07/06.
//

import Foundation
import RxSwift
import RxRelay
import Alamofire



struct Juso {
    var id: Int
    var zipNo: String
    var roadAddr: String
    var jibunAddr: String
}
extension Juso {
    static func fromJusoItems(id: Int, item: AddrItem.Results.JusoItem) -> Juso {
        return Juso(id: id, zipNo: item.zipNo, roadAddr: item.roadAddr, jibunAddr: item.jibunAddr)
    }
}




protocol AddressViewModelType {
    var fetchAddrs: AnyObserver<Void> { get }
    var activated: Observable<Bool> { get }
    var errorMessage: Observable<NSError> { get }
    var allAddrs: Observable<[ViewJuso]> { get }
    var searchInfo: Observable<ViewSearchInfo> { get }
//    var totalCountText: Observable<String> { get }
    
    
}

class AddressViewModel: AddressViewModelType {
    let disposeBag = DisposeBag()
    
    
    let fetchAddrs: AnyObserver<Void>
    let fetchInfo: AnyObserver<Void>
    
    let activated: Observable<Bool>
    let errorMessage: Observable<NSError>
    let allAddrs: Observable<[ViewJuso]>
    let searchInfo: Observable<ViewSearchInfo>
//    let totalCountText: Observable<String>
    
    init(domain: JusoFetchable = JusoStore()) {
        let fetching = PublishSubject<Void>()
        let addrs = BehaviorSubject<[ViewJuso]>(value: [])
        let info = BehaviorSubject<ViewSearchInfo>(value: ViewSearchInfo.init(totalCount: "", errorCode: "", errorMg: ""))
        let activating = BehaviorSubject<Bool>(value: false)
        let error = PublishSubject<Error>()
        
        
        fetchAddrs = fetching.asObserver()
        fetchInfo = fetching.asObserver()
        
        fetching
            .do(onNext: { _ in activating.onNext(true) })
            .flatMap(domain.fetchJusos)
            .map { $0.results.juso.map { ViewJuso($0) } }
            .do(onNext: { _ in activating.onNext(false) })
            .do(onError: { err in error.onNext(err) })
            .subscribe(onNext: addrs.onNext)
            .disposed(by: disposeBag)
        
        fetching
            .do(onNext: { _ in activating.onNext(true) })
            .flatMap(domain.fetchJusos)
            .map { ViewSearchInfo(totalCount: $0.results.common.totalCount,
                errorCode: $0.results.common.errorCode,
                errorMg: $0.results.common.errorMessage)
            }
            .do(onNext: { _ in activating.onNext(false) })
            .do(onError: { err in error.onNext(err) })
            .subscribe(onNext: info.onNext)
            .disposed(by: disposeBag)
        
        allAddrs = addrs
        
        searchInfo = info
        
        activated = activating.distinctUntilChanged()
        
        errorMessage = error.map { $0 as NSError }
        
        
    }
    
    func keywordReturn(_ keyword: String) -> Observable<String> {
        
        return Observable.just(keyword)
    }
    
    func sendKeyword(_ keyword: String) {
        if AddressAPI.countPerPage > 10 {
            AddressAPI.countPerPage = 10
        }
        _ = keywordReturn(keyword)
            .subscribe(onNext: { AddressAPI.keyword = $0 })
            .disposed(by: disposeBag)
    }
    
    func moreResults() {
        AddressAPI.countPerPage += 10
    }
    
    
}


