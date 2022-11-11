protocol ProductListViewInput: AnyObject {
    var output: ProductListViewOutput! { get set }
    func refreshData()
    func refreshPieceOfData(inx: Int)
    func showAlert(_ message: String)
    func openProductDialog(_ product: Product)
    func fillFilterMenu(_ items: [String])
}
