import Foundation

class ProductServiceImp: ProductService {
    private var dataService: DataService<Product>
    
    init(dataService: DataService<Product>) {
        self.dataService = dataService
        subscribe()
    }
    
    private func subscribe() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(recieveProducts(_:)),
            name: .RequestForRecievingProducts,
            object: nil)
    }
    
    @objc private func recieveProducts(_ notification: Notification) {
        dataService.getProducts()
    }
}
