import UIKit

class ProductListViewController: UIViewController,
                             UICollectionViewDelegate,
                             UICollectionViewDataSource,
                             CoordinatedVC,
                             UITextFieldDelegate,
                             UICollectionViewDelegateFlowLayout,
                             Storyboarded {
    
    var coordinator: CoordinatorProtocol?
    
    var output: ProductListViewOutput!
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var searchTextView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextView.delegate = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self,
                                 action: #selector(self.askForRefresh),
                                 for: .valueChanged)
        productCollectionView.refreshControl = refreshControl
    }
    
    @objc private func askForRefresh() {
        output.askForRefreshingList()
    }
    
    func refreshData() {
        productCollectionView.reloadData()
        
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func refreshPieceOfData(inx: Int) {
        productCollectionView.reloadItems(at: [IndexPath(item: inx, section: 0)])
    }
    
    @IBOutlet var productCollectionView: UICollectionView! {
        didSet {
            productCollectionView.delegate = self
            productCollectionView.dataSource = self
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return output.productsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = productCollectionView.dequeueReusableCell(
            withReuseIdentifier: "ProductCellId",
            for: indexPath)
        if let productCell = cell as? ProductCollectionViewCell {
            if let product = output.productForIndex(indexPath.item) {
                productCell.confugure(text: (product.name ?? "unknown"),
                                      image: product.image)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 128, height: 128)
    }
    
    //MARK: - search
     @IBAction func searchEditChange(_ sender: UITextField) {
         output.filterStringChanged(sender.text ?? "")
    }
    
    //MARK: - navigation
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        output.itemSelected(indexPath.item)
    }
    
    @IBAction func addProductAction(_ sender: UIBarButtonItem) {
        if let coordinator = coordinator as? ProductListCoordinatorProtocol {
            coordinator.showEditingProduct(product: nil, presentingVC: self)
        }
    }
    
    @IBAction func logOutAction(_ sender: UIBarButtonItem) {
        guard let coordinator = coordinator as? MainCoordinatorProtocol else {
            return
        }
        coordinator.showLogOut(in: self)
    }
    
    @IBOutlet weak var navigation: UINavigationItem!
    
    func fillFilterMenu(_ items: [String]) {
        guard let navigationItem = self.navigationController?.navigationBar.topItem else {
            return
        }
        
        var menuItems = [UIAction]()
        
        for topCategory in items {
            menuItems.append(UIAction(title: topCategory,
                                      handler: {[weak self] action in
                self?.menuAction(action: action)
            }))
        }
        
        let filterCategoryMenu = UIMenu(title: output.menuTitle,
                                        image: nil,
                                        identifier: nil,
                                        options: [],
                                        children: menuItems)
       
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: output.menuBtnTitle,
                                                           image: nil,
                                                           primaryAction: nil,
                                                           menu: filterCategoryMenu)
    }
    
    @objc func menuAction(action: UIAction) {
        output.categoryMenuSelected(action.title)
        navigationItem.leftBarButtonItem?.title = action.title
    }
}

extension ProductListViewController: ProductListViewInput {
    
    func showAlert(_ message: String) {
        coordinator?.showAlert(message: message, in: self)
    }
    func openProductDialog(_ product: Product) {
        if let coordinator = coordinator as? ProductListCoordinatorProtocol {
            coordinator.showProductDialogue(product: product, in: self)
        }  
    }
}
