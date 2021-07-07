//
//  AddressSearchViewController.swift
//  StarPos
//
//  Created by 한법문 on 2021/07/06.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewController
import Alamofire


class AddressSearchViewController: UIViewController {
    let viewModel: AddressViewModelType
    var disposeBag = DisposeBag()
    
    init(viewModel: AddressViewModelType = AddressViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        viewModel = AddressViewModel()
        super.init(coder: aDecoder)
    }
    
    let cellId = "AddressTableViewCell"
    
//    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var keywordSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchResultCountLabel: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshControl = UIRefreshControl()
        setupBindings()

    }
    
    func setupBindings() {
        
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        let reload = tableView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .map { _ in () } ?? Observable.just(())
        
        Observable.merge([firstLoad, reload])
            .bind(to: viewModel.fetchAddrs)
            .disposed(by: disposeBag)
        
        viewModel.activated
            .map { !$0 }
            .do(onNext: { [weak self] finished in
                if finished {
                    self?.tableView.refreshControl?.endRefreshing()
                }
            })

        
        searchBtn.rx.tap
            .map { _ in () }
            .bind(to: viewModel.fetchAddrs)
            .disposed(by: disposeBag)

        viewModel.allAddrs
            .bind(to: tableView.rx.items(cellIdentifier: AddressTableViewCell.identifier, cellType: AddressTableViewCell.self)) {
                _, item, cell in
                cell.onData.onNext(item)
            }
            .disposed(by: disposeBag)
        
        viewModel.searchInfo
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] info in
                self?.searchResultCountLabel.text = "주소 검색 결과 : \(info.totalCount) 건"
            })
            .disposed(by: disposeBag)
    }
    
    func sendKeyword(_ keyword: String) -> Observable<String> {
        
        return Observable.just(keyword)
    }
    
    @IBAction func searchBtnClicked(_ sender: UIButton) {
        
        guard let kw = keywordSearchBar.text else { return }
        let observable = sendKeyword(kw)
            .subscribe(onNext: { AddressAPI.keyword = $0 })
            .disposed(by: disposeBag)



//        var param: [String: Any] = [
//            "confmKey": AddressAPI.confmKey,
//            "countPerPage": 10,
//            "keyword": "그린시티",
//            "resultType": "json"
//        ]
//
//        AF.request(AddressAPI.baseUrl, method: .get, parameters: param).validate().responseJSON { (response) in
//            guard let data = response.data else { return }
//            switch response.result {
//                case .failure(let err):
//                    //onComplete(.failure(err))
//                    print("fail")
//                    return
//                case .success(let obj):
//                    do {
//                        let dataJson = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
//                        let getInstanceData = try JSONDecoder().decode(AddrResult.self, from: dataJson)
//                        self.searchResultCountLabel.text = "주소 검색 결과 : \(getInstanceData.results.common.totalCount)건"
//                        getInstanceData.results.juso.forEach { item in
//                            print("지번: \(item.jibunAddr)")
//                        }
////                        print("juso : \(getInstanceData.results.juso.enumerated().forEach({ (index, item) in }))")
//
//                    } catch {
//                        print("Err: \(error)")
//                    }
//
//            }
//        }
    }
    

}

struct AddrResult: Codable {
    var results: Results

    struct Results: Codable {
        var common: Common
        var  juso: [JusoInfo]
        
        struct Common: Codable {
            var totalCount: String
            var currentPage: String
            var countPerPage: String
            var errorCode: String
            var errorMessage: String
        }
        
        struct JusoInfo: Codable {
            
            var zipNo: String
            var roadAddr: String
            var jibunAddr: String
        }
    }
}


