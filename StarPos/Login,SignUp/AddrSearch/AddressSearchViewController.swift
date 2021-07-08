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
    let addressViewModel = AddressViewModel()
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
    @IBOutlet weak var moreBtn: UIButton!
    
    
    
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
            .map { [weak self] _ in
                guard let keywordText = self?.keywordSearchBar.text else { return }
                self?.addressViewModel.sendKeyword(keywordText)
            }
            .bind(to: viewModel.fetchAddrs)
            .disposed(by: disposeBag)
        
        moreBtn.rx.tap
            .map { [weak self] _ in
                self?.addressViewModel.moreResults()
            }
            .bind(to: viewModel.fetchAddrs)
            .disposed(by: disposeBag)
        
        
        // 셀 선택시
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                let cell = self?.tableView.dequeueReusableCell(withIdentifier: (self?.cellId)!, for: indexPath) as? AddressTableViewCell
                self?.viewModel.allAddrs
                    .subscribe(onNext: { print($0[indexPath.row])}) // 선택시 나오는 것
                self?.dismiss(animated: true, completion: nil)
            })
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
                if let totalcount = Int(info.totalCount), totalcount < AddressAPI.countPerPage {
                    self?.moreBtn.isHidden = true
                } else {
                    self?.moreBtn.isHidden = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    
    
}



