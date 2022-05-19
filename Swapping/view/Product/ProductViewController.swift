//
//  ProductViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 01.05.22.
//

import UIKit

class ProductViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CoordinatedVC {
    
    var coordinator: Coordinator?
    
    var model: ProductListVM!
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }

    @objc func startRefreshingData() {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < model.products.count, let coordinator = coordinator {
            coordinator.showProductDialogue(product: model.products[indexPath.row], in: self)
        }
    }

    
    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
    }
     */
    
    @IBAction func addProductAction(_ sender: UIBarButtonItem) {
        if let coordinator = coordinator {
            coordinator.showEditingProduct(product: nil, presentingVC: self)
        }
    }
    
}
