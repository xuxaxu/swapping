//
//  Dynamic.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 11.05.22.
//

import Foundation

class Dynamic<T> {
    
    typealias Listener = (T)->Void
    
    private var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    init(_ val: T) {
        self.value = val
    }
}
