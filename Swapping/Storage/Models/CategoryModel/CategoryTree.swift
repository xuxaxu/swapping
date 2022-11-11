class CategoryTree {
    var category: Category
    var children: [CategoryTree]
    init(category: Category, children: [CategoryTree]) {
        self.category = category
        self.children = children
    }
}
