//
//  RxPickerViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Segii Shulga on 5/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

    import RxSwift
    import UIKit

    extension UIPickerView: HasDelegate {
        public typealias Delegate = UIPickerViewDelegate
    }

    open class RxPickerViewDelegateProxy
        : DelegateProxy<UIPickerView, UIPickerViewDelegate>
        , DelegateProxyType 
        , UIPickerViewDelegate {

        /// Typed parent object.
        public weak private(set) var industryPickerView: UIPickerView?

        /// - parameter pickerView: Parent object for delegate proxy.
        public init(industryPickerView: ParentObject) {
            self.industryPickerView = industryPickerView
            super.init(parentObject: industryPickerView, delegateProxy: RxPickerViewDelegateProxy.self)
        }

        // Register known implementationss
        public static func registerKnownImplementations() {
            self.register { RxPickerViewDelegateProxy(industryPickerView: $0) }
        }
    }
#endif
