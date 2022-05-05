//
//  ViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 18.04.22.
//

import UIKit

class CatalogVC: UIViewController, UITableViewDataSource, UITableViewDelegate, DataServiceDelegate, FireDataBaseAlertDelegate {
    
    func showAlert(message: String) {
        Coordinator.showAlert(message: message, in: self)
    }
    
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    var categories : [Category] = []
    
    var parentCategory : Category?
    
    let refreshControl = UIRefreshControl()
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        
            if categories.count > 0 {
                DataService.shared.parentCategory = self.categories[0].parent
            }
        Coordinator.showEditingCategory(category: nil, presentingVC: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.register(UINib(nibName: "CategoryTableViewCell", bundle: .main), forCellReuseIdentifier: "categoryCell")
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.startRefreshingData), for: .valueChanged)
        categoryTableView.refreshControl = refreshControl
     }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startRefreshingData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryTableViewCell {
            let category = categories[indexPath.row]
            cell.configure(name: (category.name ?? "unknown"), img: category.image)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func startRefreshingData() {
        DataService.shared.delegate = self
        DataService.shared.getCategories(in: parentCategory)
    }
    
    func refreshData() {
        categories = DataService.shared.categories
        categoryTableView.reloadData()
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let viewParent = Bundle.main.loadNibNamed("CategorySectionTableViewCell", owner: self)?[0] as? CategorySectionTableViewCell
        if let sectionCategory = parentCategory {
            viewParent?.configure(text: (sectionCategory.name ?? "unknown"), image: sectionCategory.image)
        } else {
            viewParent?.configure(text: "", image: nil)
        }
        
        return viewParent
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "edit") {[weak self] _,_,_ in
            if let weakSelf = self, indexPath.row < weakSelf.categories.count {
                DataService.shared.parentCategory = weakSelf.categories[0].parent
                Coordinator.showEditingCategory(category: weakSelf.categories[indexPath.row], presentingVC: weakSelf)
            }
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "delete") {[weak self] _,_,_ in
            if let weakSelf = self, indexPath.row < weakSelf.categories.count {
                FireDataBase.shared.alertDelegate = weakSelf
                FireDataBase.shared.deleteCategory(category: weakSelf.categories[indexPath.row], vcForAlert: weakSelf)
                weakSelf.categories.remove(at: indexPath.row)
                tableView.reloadData()
            }
        }
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
    
}

