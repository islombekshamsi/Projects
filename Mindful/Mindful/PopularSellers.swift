import SwiftUI

struct CategoryCard: View {
    let category: ProductCategory
    let gradient: [Color]
    @State private var isPressed = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background Gradient Card
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: gradient),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 180, height: 120)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)

            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Icon
                    Image(systemName: category.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Trending Badge
                    if category.isTrending {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 14))
                    }
                }
                
                // Category Name
                Text(category.name)
                    .foregroundColor(.white)
                    .font(.headline)
                
                // Item Count
                Text("\(category.itemCount) items")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.subheadline)
            }
            .padding(.leading, 16)
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
        .onTapGesture {
            isPressed = true
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            // Reset after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }
}

struct PopularSellers: View {
    let categories: [ProductCategory] = [
        ProductCategory(name: "Electronics", icon: "headphones", itemCount: 156, isTrending: true, gradient: [
            Color(red: 0.18, green: 0.29, blue: 0.72),
            Color(red: 0.29, green: 0.52, blue: 0.99),
            Color(red: 0.64, green: 0.82, blue: 1.0)
        ]),
        ProductCategory(name: "Bikes & Scooters", icon: "bicycle", itemCount: 89, isTrending: false, gradient: [
            Color(red: 0.2, green: 0.7, blue: 0.3),
            Color(red: 0.3, green: 0.8, blue: 0.4),
            Color(red: 0.4, green: 0.9, blue: 0.5)
        ]),
        ProductCategory(name: "Furniture", icon: "chair", itemCount: 203, isTrending: true, gradient: [
            Color(red: 0.8, green: 0.4, blue: 0.2),
            Color(red: 0.9, green: 0.5, blue: 0.3),
            Color(red: 1.0, green: 0.6, blue: 0.4)
        ]),
        ProductCategory(name: "Textbooks", icon: "book", itemCount: 312, isTrending: true, gradient: [
            Color(red: 0.5, green: 0.2, blue: 0.7),
            Color(red: 0.6, green: 0.3, blue: 0.8),
            Color(red: 0.7, green: 0.4, blue: 0.9)
        ]),
        ProductCategory(name: "Leasing", icon: "doc.text", itemCount: 178, isTrending: true, gradient: [
            Color(red: 0.1, green: 0.6, blue: 0.8),
            Color(red: 0.2, green: 0.7, blue: 0.9),
            Color(red: 0.3, green: 0.8, blue: 1.0)
        ]),
        ProductCategory(name: "Lost & Found", icon: "magnifyingglass", itemCount: 45, isTrending: false, gradient: [
            Color(red: 0.9, green: 0.5, blue: 0.2),
            Color(red: 1.0, green: 0.6, blue: 0.3),
            Color(red: 1.0, green: 0.7, blue: 0.4)
        ]),
        ProductCategory(name: "Clothing & Shoes", icon: "tshirt", itemCount: 267, isTrending: true, gradient: [
            Color(red: 0.7, green: 0.2, blue: 0.5),
            Color(red: 0.8, green: 0.3, blue: 0.6),
            Color(red: 0.9, green: 0.4, blue: 0.7)
        ])
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular Categories")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(categories) { category in
                        CategoryCard(category: category, gradient: category.gradient)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct ProductCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let itemCount: Int
    let isTrending: Bool
    let gradient: [Color]
}

#Preview {
    PopularSellers()
}
