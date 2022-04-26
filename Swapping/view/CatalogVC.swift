//
//  ViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 18.04.22.
//

import UIKit

class CatalogVC: UIViewController, UITableViewDataSource, UITableViewDelegate, DataServiceDelegate {
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    var categories : [Category] = []
    
    var parentCategory : Category?
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        
            if categories.count > 0 {
                DataService.shared.parentCategory = DataService.shared.categories[0].parent
            }
        Coordinator.showEditingCategory(category: nil, presentingVC: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.register(UINib(nibName: "CategoryTableViewCell", bundle: .main), forCellReuseIdentifier: "categoryCell")
     }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //if view.navi
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DataService.shared.delegateCategories = self
        DataService.shared.getCategories(in: parentCategory)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryTableViewCell {
            let category = categories[indexPath.row]
            cell.configure(name: category.name, img: category.image)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func refreshData() {
        categories = DataService.shared.categories
        categoryTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < categories.count {
            let category = categories[indexPath.row]
            Coordinator.showCategories(in: category, presentingVC: self)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func refreshRow(indexPath: IndexPath) {
        categoryTableView.reloadRows(at: [indexPath], with: .fade)
    }
    
}

