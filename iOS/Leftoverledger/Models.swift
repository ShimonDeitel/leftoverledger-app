import Foundation

struct LeftoverEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var dish: String
    var storedDate: Date
    var container: String
    var useByDate: Date

    init(id: UUID = UUID(), dish: String = "", storedDate: Date = Date(), container: String = "", useByDate: Date = Date()) {
        self.id = id
        self.dish = dish
        self.storedDate = storedDate
        self.container = container
        self.useByDate = useByDate
    }
}
