import SwiftUI

struct PhysicalCardView: View {
    var body: some View {
        ZStack {
            // Background with gradient
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#2E69FB"), Color(hex: "#141F9D")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                .frame(height: 220)
            
            // Card content
            VStack(alignment: .leading, spacing: 16) {
                // Card logo or title
                HStack {
                    Text("One-Link")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "#50CEC3"))
                }
                
                // Card number
                Text("**** **** **** 1234")
                    .font(.system(size: 20, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(8)
                
                // Cardholder name and expiration date
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CARDHOLDER NAME")
                            .font(.caption)
                            .foregroundColor(Color.white.opacity(0.7))
                        Text("John Doe")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("EXPIRES")
                            .font(.caption)
                            .foregroundColor(Color.white.opacity(0.7))
                        Text("12/25")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                
                // Logo and contactless icon
                HStack {
                    // Replace the simcard icon with your logo
                    Image("Logo") // Make sure "logo" matches the name in your asset catalog
                        .resizable() // Make the image resizable
                        .scaledToFit() // Maintain aspect ratio
                        .frame(width: 40, height: 40) // Adjust size as needed
                    
                    Spacer()
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "#50CEC3"))
                }
            }
            .padding()
        }
        .padding()
    }
}

// Extension to use hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct PhysicalCardView_Previews: PreviewProvider {
    static var previews: some View {
        PhysicalCardView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
