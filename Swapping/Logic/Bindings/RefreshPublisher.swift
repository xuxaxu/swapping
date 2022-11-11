//
//  RefreshPublisher.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 06.06.22.
//

import Foundation
import Combine
import UIKit

class RefreshPublisher: ISingleton {
    required init(container: IContainer, args: ()) {
        
    }
    
    struct updatedUrl {
        let id: String
        let url: URL
    }
    
    let updatesPublisher = NotificationCenter.Publisher(center: .default, name: .objectUpdated, object: nil).map { (notification) -> updatedUrl? in
        return (notification.object as? updatedUrl)
    }
    
    func subscribeforUpdates(some: ObjectUpdatesSubscriber) {
        let subscriber = Subscribers.Assign(object: some, keyPath: \.id)
        updatesPublisher.subscribe(subscriber)
    }
    
    func postUpdates(id: updatedUrl) {
        NotificationCenter.default.post(name: .objectUpdated, object: id)
    }
}

extension Notification.Name {
    static let objectUpdated = Notification.Name("object_updated")
}

protocol ObjectUpdatesSubscriber: AnyObject {
    var id: RefreshPublisher.updatedUrl? {
        get set
    }
}
