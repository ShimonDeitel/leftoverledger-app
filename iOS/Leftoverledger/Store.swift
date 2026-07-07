import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [LeftoverEntry] = []
    @Published var isProUnlocked: Bool = false

    /// Free tier limit — deliberately set well above seed data count so a
    /// fresh install never hits the paywall immediately.
    static let freeLimit = 15

    private let fileName = "leftoverledger_entries.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    var canAddMore: Bool {
        isProUnlocked || entries.count < Store.freeLimit
    }

    func add(_ entry: LeftoverEntry) {
        guard canAddMore else { return }
        entries.append(entry)
        save()
    }

    func update(_ entry: LeftoverEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: LeftoverEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([LeftoverEntry].self, from: data) else {
            entries = Store.seedData()
            save()
            return
        }
        entries = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [LeftoverEntry] {
        [
        LeftoverEntry(dish: "Roast Chicken", storedDate: Date(), container: "Glass Bowl", useByDate: Date()),
        LeftoverEntry(dish: "Veggie Stir Fry", storedDate: Date(), container: "Tupperware", useByDate: Date()),
        LeftoverEntry(dish: "Chili", storedDate: Date(), container: "Mason Jar", useByDate: Date())
        ]
    }
}
