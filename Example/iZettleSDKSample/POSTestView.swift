import SwiftUI

// MARK: - POS Test View for Live Preview
struct POSTestView: View {
    @State private var selectedTab = 0
    @State private var transactionAmount = "99.99"
    @State private var enableTipping = true
    @State private var transactions: [Transaction] = []
    @State private var showSuccess = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.1, green: 0.15, blue: 0.3), Color(red: 0.05, green: 0.1, blue: 0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack {
                    HStack {
                        Text("TESTPOS SDKAPP")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "square.stack.3d.up.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                    }
                    .padding(16)
                    
                    // Status
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Developer Mode: ENABLED")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.green)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .background(Color(red: 0.08, green: 0.12, blue: 0.25))
                
                // Tab Navigation
                HStack(spacing: 0) {
                    TabButton(title: "Payments", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    TabButton(title: "Settings", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    TabButton(title: "Logs", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .background(Color(red: 0.08, green: 0.12, blue: 0.25))
                .padding(.bottom, 12)
                
                // Content
                TabView(selection: $selectedTab) {
                    // Payment Tab
                    PaymentTabView(
                        amount: $transactionAmount,
                        enableTipping: $enableTipping,
                        showSuccess: $showSuccess,
                        onProcessPayment: {
                            processTestPayment()
                        }
                    )
                    .tag(0)
                    
                    // Settings Tab
                    SettingsTabView(enableTipping: $enableTipping)
                        .tag(1)
                    
                    // Logs Tab
                    LogsTabView(transactions: transactions)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                Spacer()
            }
            
            // Success Overlay
            if showSuccess {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Payment Successful")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Amount: €\(transactionAmount)")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.8))
                .onTapGesture {
                    showSuccess = false
                }
            }
        }
    }
    
    func processTestPayment() {
        let transaction = Transaction(
            id: UUID().uuidString,
            amount: Double(transactionAmount) ?? 0,
            timestamp: Date(),
            status: "SUCCESS",
            type: "CARD_PAYMENT"
        )
        transactions.insert(transaction, at: 0)
        showSuccess = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showSuccess = false
        }
    }
}

// MARK: - Tab Views
struct PaymentTabView: View {
    @Binding var amount: String
    @Binding var enableTipping: Bool
    @Binding var showSuccess: Bool
    var onProcessPayment: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Transaction Amount")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
                
                HStack {
                    Text("€")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                    
                    Spacer()
                }
                .padding(12)
                .background(Color(red: 0.15, green: 0.2, blue: 0.35))
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Payment Methods")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
                
                PaymentMethodButton(icon: "creditcard.fill", title: "Card Payment", description: "Tap to start") {
                    onProcessPayment()
                }
                
                PaymentMethodButton(icon: "qrcode", title: "QR Code Payment", description: "PayPal / Venmo") {
                    onProcessPayment()
                }
                
                PaymentMethodButton(icon: "keyboard", title: "Manual Entry", description: "Card details") {
                    onProcessPayment()
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Enable Tipping", isOn: $enableTipping)
                    .foregroundColor(.white)
                
                if enableTipping {
                    HStack(spacing: 8) {
                        ForEach([5, 10, 15], id: \.self) { tip in
                            Button(action: {}) {
                                Text("\(tip)%")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(8)
                                    .background(Color.orange.opacity(0.7))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            
            Button(action: onProcessPayment) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Process Payment")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.orange)
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(16)
        .foregroundColor(.white)
    }
}

struct SettingsTabView: View {
    @Binding var enableTipping: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("POS Configuration")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                SettingRow(label: "Developer Mode", value: "ENABLED", status: .active)
                SettingRow(label: "Tipping", value: enableTipping ? "ON" : "OFF", status: enableTipping ? .active : .inactive)
                SettingRow(label: "Alternative Payments", value: "PayPal / QRC", status: .active)
                SettingRow(label: "Card Reader", value: "iZettle", status: .active)
                SettingRow(label: "Currency", value: "EUR", status: .active)
            }
            
            Toggle("Enable Tipping", isOn: $enableTipping)
                .padding(.top, 12)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(16)
        .foregroundColor(.white)
    }
}

struct LogsTabView: View {
    var transactions: [Transaction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Transaction Log")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(transactions.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
            }
            
            if transactions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No transactions yet")
                        .foregroundColor(.gray)
                    Text("Process a payment to see logs")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(transactions, id: \.id) { transaction in
                            TransactionLogRow(transaction: transaction)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .foregroundColor(.white)
    }
}

// MARK: - Component Views
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .orange : .gray)
                
                if isSelected {
                    Capsule()
                        .fill(Color.orange)
                        .frame(height: 3)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

struct PaymentMethodButton: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(Color(red: 0.15, green: 0.2, blue: 0.35))
            .cornerRadius(8)
        }
    }
}

struct SettingRow: View {
    let label: String
    let value: String
    let status: SettingStatus
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(value)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Circle()
                .fill(status == .active ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
        }
        .padding(12)
        .background(Color(red: 0.15, green: 0.2, blue: 0.35))
        .cornerRadius(8)
    }
}

struct TransactionLogRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.type)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                    Text(transaction.status)
                        .font(.system(size: 11))
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("€\(String(format: "%.2f", transaction.amount))")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(transaction.timestamp.formatted(date: .omitted, time: .standard))
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(Color(red: 0.15, green: 0.2, blue: 0.35))
        .cornerRadius(8)
    }
}

// MARK: - Models
struct Transaction: Identifiable {
    let id: String
    let amount: Double
    let timestamp: Date
    let status: String
    let type: String
}

enum SettingStatus {
    case active
    case inactive
}

// MARK: - Preview
#Preview {
    POSTestView()
        .preferredColorScheme(.dark)
}
