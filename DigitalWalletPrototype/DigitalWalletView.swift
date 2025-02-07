import SwiftUI

// MARK: - Model Definitions

enum CardType: String, CaseIterable, Identifiable {
    case bank = "Bank Card"
    case loyalty = "Loyalty Card"
    case other = "Other"
    
    var id: String { self.rawValue }
}

struct DigitalCard: Identifiable, Equatable {
    let id: UUID
    var type: CardType
    var title: String
    var details: String
}

// MARK: - Digital Card View

struct DigitalCardView: View {
    let card: DigitalCard
    let isSelected: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.white)
            .overlay(
                HStack {
                    Image(systemName: "creditcard")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text(card.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(card.details)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .padding()
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            .frame(height: 100)
    }
}

// MARK: - Main Digital Wallet View

struct DigitalWalletView: View {
    @State private var digitalCards: [DigitalCard] = [
        DigitalCard(id: UUID(), type: .bank, title: "Bank Card", details: "Visa **** 1234"),
        DigitalCard(id: UUID(), type: .loyalty, title: "Loyalty Card", details: "Rewards: 150 points")
    ]
    // Track the currently activated (selected) card.
    @State private var selectedCardId: UUID? = nil
    // Controls when to show the activation alert.
    @State private var showAlert: Bool = false
    // Persist default card id as a string.
    @AppStorage("defaultCardId") private var defaultCardId: String?
    
    // State variables for presenting sheets.
    @State private var showAddCardSheet: Bool = false
    @State private var cardToEdit: DigitalCard? = nil

    // Computed property for activated card title.
    private var activatedCardTitle: String {
        if let id = selectedCardId,
           let card = digitalCards.first(where: { $0.id == id }) {
            return card.title
        }
        return "card"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Physical card (unchanged) wrapped in a NavigationLink.
                NavigationLink(destination: TrackingView()) {
                    PhysicalCardView()
                }
                .buttonStyle(PlainButtonStyle())

                // Vertical list of digital cards.
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(digitalCards) { card in
                            DigitalCardView(card: card, isSelected: selectedCardId == card.id)
                                .onTapGesture {
                                    withAnimation {
                                        selectedCardId = card.id
                                        showAlert = true
                                    }
                                }
                                .contextMenu {
                                    Button("Set as Default") {
                                        defaultCardId = card.id.uuidString
                                        selectedCardId = card.id
                                    }
                                    Button("Edit Card Info") {
                                        cardToEdit = card
                                    }
                                }
                        }
                    }
                    .padding(.top)
                }

                Spacer()
            }
            .navigationTitle("One Link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddCardSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // Alert that confirms activation.
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Card Activated"),
                    message: Text("You have successfully activated \(activatedCardTitle)."),
                    dismissButton: .default(Text("OK"))
                )
            }
            // Sheet for adding a new card.
            .sheet(isPresented: $showAddCardSheet) {
                CardAddView { newCard in
                    digitalCards.append(newCard)
                }
            }
            // Sheet for editing card info.
            .sheet(item: $cardToEdit) { card in
                if let binding = bindingForCard(with: card.id) {
                    CardEditView(card: binding)
                } else {
                    Text("Error loading card info.")
                }
            }
            .onAppear {
                // Activate default card on launch.
                if selectedCardId == nil,
                   let storedDefault = defaultCardId,
                   let defaultCard = digitalCards.first(where: { $0.id.uuidString == storedDefault }) {
                    selectedCardId = defaultCard.id
                }
            }
        }
    }
    
    // Helper to get a binding for a card with a given id.
    private func bindingForCard(with id: UUID) -> Binding<DigitalCard>? {
        guard let index = digitalCards.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        return $digitalCards[index]
    }
}

// MARK: - Card Edit View

struct CardEditView: View {
    @Binding var card: DigitalCard
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Card Info")) {
                    Picker("Card Type", selection: $card.type) {
                        ForEach(CardType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    TextField("Card Name", text: $card.title)
                    TextField("Details", text: $card.details)
                }
            }
            .navigationTitle("Edit Card")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Card Add View

struct CardAddView: View {
    @State private var type: CardType = .bank
    @State private var title: String = ""
    @State private var details: String = ""
    var onAdd: (DigitalCard) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Card Info")) {
                    Picker("Card Type", selection: $type) {
                        ForEach(CardType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    TextField("Card Name", text: $title)
                    TextField("Details", text: $details)
                }
            }
            .navigationTitle("Add Card")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let newCard = DigitalCard(id: UUID(), type: type, title: title, details: details)
                        onAdd(newCard)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

