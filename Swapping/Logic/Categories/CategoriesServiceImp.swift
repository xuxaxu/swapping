import Foundation

class CategoriesServiceImp: NSObject, IPerRequest {
    private var dataService: DataService<Category>
    
    var allCategories = [CategoryTree]()
    
    var namesDict = [String: String]()
    
    private var container: IContainer
    
    required init(container: IContainer, args: ()) {
        self.container = container
        self.dataService = container.resolve(args: Category.self)
        super.init()
        bindDataService()
    }
    
    private func bindDataService() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(categoriesLoaded(_:)),
            name: .ArrayOfObjectsChanged,
            object: nil)
    }
    
    @objc private func categoriesLoaded(_ notification: Notification) {
        guard let object = notification.object as? DataService<Category> else {
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let categories = object.arrayOfObjects.value
            self?.addCategoriesToTree(categories)
            
            self?.notifyAboutUpdate()
        }
    }
    
    private func addCategoriesToTree(_ categories: [Category]) {
        guard categories.count > 0 else {
            return
        }
        allCategories = []
        let main = categories.filter{ ($0.parentId == nil) || ($0.parentId == "") }
        for category in main {
            if let name = category.name {
                let node = CategoryTree(category: category, children: [])
                allCategories.append(node)
                namesDict[name] = category.id
                addBranch(parent: node, categories: categories)
            }
        }
    }
    
    private func addBranch(parent: CategoryTree, categories: [Category]) {
        let children = categories.filter{ $0.parentId == parent.category.id }
        for child in children {
            if let name = child.name {
                let node = CategoryTree(category: child, children: [])
                parent.children.append(node)
                namesDict[name] = child.id
                addBranch(parent: node, categories: categories)
            }
        }
    }
    
    private func notifyAboutUpdate() {
        DispatchQueue.main.async { [weak self] in
            NotificationCenter.default.post(name: .CategoryTreeUpdated,
                                            object: self)
        }
    }
    
    private func findNode(categoryId: String, nodes: [CategoryTree]) -> CategoryTree? {
        for node in nodes {
            if node.category.id == categoryId {
                return node
            }
            if let found = findNode(categoryId: categoryId, nodes: node.children) {
                return found
            }
        }
        return nil
    }
    
    private func findPath(categoryId: String,
                          nodes: [CategoryTree],
                          path: String) -> String? {
        for node in nodes {
            var newPath = path
            if let name = node.category.name {
                newPath += (path == "") ? "" : "\\" + name
            }
            if node.category.id == categoryId {
                return newPath
            }
            if let childPath = findPath(categoryId: categoryId, nodes: node.children, path: newPath) {
                return childPath
            }
        }
        return nil
    }
    
    private func getChildrenNames(node: CategoryTree, answer: inout [String]) {
        if let parentName = node.category.name {
            answer.append(parentName)
        }
        for child in node.children {
            getChildrenNames(node: child, answer: &answer)
        }
    }
}

extension Notification.Name {
    static let CategoryTreeUpdated = Notification.Name(
        rawValue: "com.Swapping.CategoriesService.categoriesTreeChanged")
}

extension CategoriesServiceImp: CategoriesService {
    func getPathToCategory(name: String, completion: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let state = strongSelf.container.appState
            let names = state.getStateCategoriesNamesDict()
            guard let id = names[name] else {
                return
            }
            let root = state.getStateCategoriesRoot()
            guard let path = strongSelf.findPath(categoryId: id, nodes: root, path: "") else {
                return
            }
            DispatchQueue.main.async {  
                completion(path)
            }
        }
    }
    
    func getCategoryId(name: String) -> String? {
        let names = container.appState.getStateCategoriesNamesDict()
        let id = names[name]
        return id
    }
    
    func getAllCategoriesNamesInBranch(parentId: String) -> [String] {
        let root = container.appState.getStateCategoriesRoot()
        guard let parentNode = findNode(categoryId: parentId, nodes: root) else {
            return []
        }
        var answer = [String]()
        
        getChildrenNames(node: parentNode, answer: &answer)
        
        return answer
    }
    
    func recieveCategories() {
        dataService.getAllCategories()
    }
}
