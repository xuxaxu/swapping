protocol CategoriesService {
    func recieveCategories()
    func getCategoryId(name: String) -> String?
    func getAllCategoriesNamesInBranch(parentId: String) -> [String]
    var allCategories: [CategoryTree] { get }
    var namesDict: [String: String] { get }
    func getPathToCategory(name: String, completion: @escaping (String) -> Void)
}
