import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showingAddSheet = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: LeftoverEntry?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.entries) { entry in
                    Button(action: { editingEntry = entry }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(entry.dish)").font(Theme.headingFont)
                            Text(entry.storedDate, style: .date).font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityIdentifier("entryRow_\(entry.id.uuidString)")
                    .buttonStyle(.plain)
                }
                .onDelete(perform: store.delete)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Leftover Ledger")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if store.canAddMore {
                            showingAddSheet = true
                        } else {
                            showingPaywall = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .overlay {
                if store.entries.isEmpty {
                    ContentUnavailableView("No Leftovers Yet", systemImage: "tray", description: Text("Tap + to add your first leftover."))
                }
            }
        }
        .tint(Theme.accent)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    let existing: LeftoverEntry?
    let onSave: (LeftoverEntry) -> Void

    @State private var dish: String
    @State private var storedDate: Date
    @State private var container: String
    @State private var useByDate: Date

    init(entry: LeftoverEntry?, onSave: @escaping (LeftoverEntry) -> Void) {
        self.existing = entry
        self.onSave = onSave
        _dish = State(initialValue: entry?.dish ?? "")
        _storedDate = State(initialValue: entry?.storedDate ?? Date())
        _container = State(initialValue: entry?.container ?? "")
        _useByDate = State(initialValue: entry?.useByDate ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Dish", text: $dish)
                    .focused($isFocused)
                    .accessibilityIdentifier("form_dishField")
                DatePicker("StoredDate", selection: $storedDate, displayedComponents: .date)
                TextField("Container", text: $container)
                    .focused($isFocused)
                    .accessibilityIdentifier("form_containerField")
                DatePicker("UseByDate", selection: $useByDate, displayedComponents: .date)
            }
            .navigationTitle(existing == nil ? "Add Leftover" : "Edit Leftover")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("formCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("formSaveButton")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = false
            }
        }
    }

    private func save() {
        let id = existing?.id ?? UUID()
        let entry = LeftoverEntry(id: id, dish: dish, storedDate: storedDate, container: container, useByDate: useByDate)
        onSave(entry)
    }
}
