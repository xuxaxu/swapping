protocol ProductListViewOutput {
    var menuTitle: String { get }
    var menuBtnTitle: String { get }
    func categoryMenuSelected(_ menuTitle: String)
    func askForRefreshingList()
    func productsCount() -> Int
    func productForIndex(_ index: Int) -> Product?
    func filterStringChanged(_ filterStr: String)
    func itemSelected(_ index: Int)
}
