struct StateUser {
    var userID: String?
    mutating func setUserId(_ id: String?) {
        self.userID = id
    }
}
