//
//  ProductViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 01.05.22.
//

import UIKit

class ProductViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DataServiceDelegate {
        
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startRefreshingData()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.startRefreshingData), for: .valueChanged)
        productCollectionView.refreshControl = refreshControl
    }

    @objc func startRefreshingData() {
        DataService.shared.delegate = self
        DataService.shared.getProducts()
    }
    
    func refreshData() {
        productCollectionView.reloadData()
        
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func refreshRow(indexPath: IndexPath) {
        productCollectionView.reloadItems(at: [indexPath])
    }
    
    @IBOutlet var productCollectionView: UICollectionView! {
        didSet {
            productCollectionView.delegate = self
            productCollectionView.dataSource = self
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataService.shared.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = productCollectionView.dequeueReusableCell(withReuseIdentifier: "ProductCellId", for: indexPath)
        if let productCell = cell as? ProductCollectionViewCell {
            if indexPath.item < DataService.shared.products.count {
                let product = DataService.shared.products[indexPath.item]
                productCell.confugure(text: (product.name ?? "unknown"), image: product.image)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < DataService.shared.products.count {
            Coordinator.showProductDialogue(product: DataService.shared.products[indexPath.row], in: self)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func addProductAction(_ sender: UIBarButtonItem) {
        Coordinator.showEditingProduct(product: nil, presentingVC: self)
    }
    
}
