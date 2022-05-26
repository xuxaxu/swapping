//
//  ViewController.swift
//  Swapping
//
//  Created by Ксения Каштанкина on 18.04.22.
//

import UIKit

class CatalogVC: UIViewController, UITableViewDataSource, UITableViewDelegate, CoordinatedVC {
    
    var coordinator: Coordinator?
    
    var model: CategoryListVM!
        
    @IBOutlet weak var categoryTableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.register(UINib(nibName: "CategoryTableViewCell", bundle: .main), forCellReuseIdentifier: "categoryCell")
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.startRefreshingData), for: .valueChanged)
        categoryTableView.refreshControl = refreshControl
        
        bindViewModel()
     }
    
    func bindViewModel() {
        model?.allDataChanged.bind({ [weak self] changed in
            if changed {
                self?.refreshData()
            }
        })
        
        model?.rowChanged.bind({ [weak self] inx in
            //self?.refreshRow(indexPath: IndexPath(row: inx, section: 1))
            self?.categoryTableView.reloadRows(at: [IndexPath(row: inx, section: 0)], with: .fade)
        })
        
        model?.errorMessage.bind({ [weak self] message in
            self?.coordinator?.showAlert(message: message, in: self!)
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startRefreshingData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if model != nil {
            return model!.categories.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryTableViewCell, let model = self.model {
            let category = model.categories[indexPath.row]
            cell.configure(name: (category.name ?? "unknown"), img: category.image)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func startRefreshingData() {
        if model != nil {
            model!.getCategories()
        }
    }
    
    func refreshData() {
        
        categoryTableView.reloadData()
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let model = model, indexPath.row < model.categories.count {
            let category = model.categories[indexPath.row]
            if let coordinator = coordinator {
                coordinator.showCategories(in: category, presentingVC: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func refreshRow(indexPath: IndexPath) {
        self.categoryTableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let viewParent = Bundle.main.loadNibNamed("CategorySectionTableViewCell", owner: self)?[0] as? CategorySectionTableViewCell
        if let model = model, let sectionCategory = model.parentCategory {
            viewParent?.configure(text: (sectionCategory.name ?? "unknown"), image: sectionCategory.image)
        } else {
            viewParent?.configure(text: "", image: nil)
        }
        
        return viewParent
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "edit") {[weak self] _,_,_ in
            if let weakSelf = self, let model = weakSelf.model, indexPath.row < model.categories.count, let coordinator = weakSelf.coordinator {
                coordinator.showEditingCategory(category: model.categories[indexPath.row], parentCategory: model.parentCategory, presentingVC: weakSelf)
            }
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "delete") {[weak self] _,_,_ in
            if let weakSelf = self, let model = weakSelf.model, indexPath.row < model.categories.count {
                
                model.deleteCategory(inx: indexPath.row) { [weak self] massage in
                    if let weakSelf = self, let coordinator = weakSelf.coordinator {
                        coordinator.showAlert(message: massage, in: weakSelf)
                    }
                }
            }
        }
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        if let coordinator = coordinator {
            let parentCategory = model?.parentCategory
            coordinator.showEditingCategory(category: nil, parentCategory: parentCategory, presentingVC: self)
        }
    }
    
    @IBAction func logOutAction(_ sender: UIBarButtonItem) {
        coordinator?.showLogOut(in: self)
    }
    
    
}

