import Foundation

struct StateCategories {
    var main: [CategoryTree]
    var categoriesNames = [String: String]()
    
    var currentParent: CategoryTree?
}

extension Notification.Name {
    static let SomeChangesInCategories = Notification.Name(
        rawValue: "com.Swapping.StateCategories.categoriesChanged")
    static let ParentCategoryChanged = Notification.Name(
        rawValue: "com.Swapping.StateCategories.currentParentChanged")
}
