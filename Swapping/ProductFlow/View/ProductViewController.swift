//
//  ProductViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 01.05.22.
//

import UIKit

class ProductViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CoordinatedVC, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var coordinator: CoordinatorProtocol?
    
    var model: ProductListVM!
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var searchTextView: UITextField!
    
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextView.delegate = self
        
        bindViewModel()
        
        startRefreshingData()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.startRefreshingData), for: .valueChanged)
        productCollectionView.refreshControl = refreshControl
    }
    
    func bindViewModel() {
        model.productsChanged.bind { [weak self] dataChanged in
            DispatchQueue.main.async {
                self?.refreshData()
            }
        }
        
        model.productChanged.bind { [weak self] inx in
            self?.refreshPieceOfData(inx: inx)
        }
        
        model.errorMessage.bind { [weak self] message in
            self?.coordinator?.showAlert(message: message, in: self!)
        }
        
        model.menuCategories.bind { [weak self] dictForMenu in
            self?.fillFilterCategoryMenu()
        }
    }

    @objc func startRefreshingData() {
        
        model.getCategoriesForFilter()
        
        model.loadData()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.dataCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = productCollectionView.dequeueReusableCell(withReuseIdentifier: "ProductCellId", for: indexPath)
        if let productCell = cell as? ProductCollectionViewCell {
            if let product = model.dataForIndex(inx: indexPath.item) {
                productCell.confugure(text: (product.name ?? "unknown"), image: product.image)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 128, height: 128)
    }
    
    //MARK: - search
     @IBAction func searchEditChange(_ sender: UITextField) {
        model.filterString = sender.text ?? ""
    }
    
    //MARK: - navigation
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < model.dataCount(),
            let product = model.dataForIndex(inx: indexPath.row),
            let coordinator = coordinator as? ProductListCoordinatorProtocol {
            coordinator.showProductDialogue(product: product, in: self)
        }
    }
    
    @IBAction func addProductAction(_ sender: UIBarButtonItem) {
        if let coordinator = coordinator as? ProductListCoordinatorProtocol {
            coordinator.showEditingProduct(product: nil, presentingVC: self)
        }
    }
    
    @IBAction func logOutAction(_ sender: UIBarButtonItem) {
        coordinator?.showLogOut(in: self)
    }
    
    @IBOutlet weak var navigation: UINavigationItem!
    
    private func fillFilterCategoryMenu() {
        
        var menuItems : [UIAction] = [UIAction(title: "All", image: nil, identifier: nil, handler: menuAction(action:))]
        
        for topCategory in model.menuCategories.value {
            menuItems.append(UIAction(title: topCategory.key.name ?? "unknown", handler: {[weak self] action in
                self?.menuAction(action: action)
            }))
        }
        
        let filterCategoryMenu = UIMenu(title: "categories", image: nil, identifier: nil, options: [], children: menuItems)
        if let navigationItem = self.navigationController?.navigationBar.topItem {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "All ⌄", image: nil, primaryAction: nil, menu: filterCategoryMenu)
        }
    }
    
    @objc func menuAction(action: UIAction) {
        model.choosenCategory = action.title
        navigationItem.leftBarButtonItem?.title = action.title
        model.filterString = model.filterString
    }
    
    
}
