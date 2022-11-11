import Foundation
struct StateProduct {
    var products = [Product]()
    var product: Product?
    var filteredProducts = [Product]() 
    var filterCategoryName: String?
    var filterCategoryWithChildrenNames: [String]?
    var filterStr: String?
    
    mutating func setFilteredProducts(_ products: [Product]) {
        self.filteredProducts = products
    }
    mutating func setProducts(_ products: [Product]) {
        self.products = products
    }
    mutating func setFilterCategoryName(_ name: String) {
        filterCategoryName = name
    }
    mutating func setProduct(_ product: Product?) {
        self.product = product
    }
    mutating func setFilterCategoriesNames(_ names: [String]?) {
        filterCategoryWithChildrenNames = names
    }
    mutating func setFilterStr(_ filter: String) {
        self.filterStr = filter
    }
    mutating func setImage(_ product: Product) {
        if let index = products.firstIndex(of: product) {
            products[index].image = product.image
        }
        if let indexFiltered = filteredProducts.firstIndex(of: product) {
            filteredProducts[indexFiltered].image = product.image
        }
    }
}

extension Notification.Name {
    static let FilteredProductsChanged = Notification.Name(
        rawValue: "com.Sqapping.StateProduct.FilteredProductsHasChanged")
    static let ProductsChanged = Notification.Name(
        rawValue: "com.Swapping.StateProduct.ProductsHasChanged")
}
