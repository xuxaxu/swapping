//
//  ViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 18.04.22.
//

import UIKit

class CatalogVC: UIViewController, UITableViewDataSource, UITableViewDelegate, FireDataBaseDelegate {
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let categoryVC = storyboard.instantiateViewController(withIdentifier: "categoryViewController") as? CategoryViewController {
        
            if FireDataBase.shared.categories.count > 0 {
                FireDataBase.shared.parentCategory = FireDataBase.shared.categories[0].parent
            }
            categoryVC.modalPresentationStyle = .fullScreen
            if let navigationController = self.navigationController {
                navigationController.pushViewController(categoryVC, animated: true)
            } else {
                self.present(categoryVC, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.register(UINib(nibName: "CategoryTableViewCell", bundle: .main), forCellReuseIdentifier: "categoryCell")
        FireDataBase.shared.delegateCategories = self
     }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SwappingAuth().signInSwap(in: self)
        FireDataBase.shared.getCategories(in: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FireDataBase.shared.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryTableViewCell {
            let category = FireDataBase.shared.categories[indexPath.row]
            cell.configure(name: category.name, img: category.img)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func refreshData() {
        categoryTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.row < FireDataBase.shared.categories.count {
            let category = FireDataBase.shared.categories[indexPath.row]
            FireDataBase.shared.getCategories(in: category)
        }
    }
    
}

