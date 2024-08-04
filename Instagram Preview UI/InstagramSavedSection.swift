import SwiftUI

struct InstagramSavedSection: View {
    var body: some View {
        let names: [String] = ["Funny", "Inspirational", "Facts", "Educational", "Recipes", "Sports", "Movies", "Music", "Games", "Design", "Books", "University"]
        let boxColors: [Color] = [Color.blue, Color.green, Color.yellow, Color.red, Color.gray, Color.mint, Color.orange, Color.indigo, Color.teal, Color.white, Color.secondary, Color.pink]
        let iconSize: CGFloat = 25.0
        ZStack {
            ScrollView(showsIndicators: true){
                VStack {
                    // Add a spacer with the same height as the header
                    Spacer()
                        .frame(height: 60)
                    
                    LazyVStack{
                            ForEach(0..<6){rowIndex in
                                ScrollView{
                                    LazyHStack(spacing: 0){
                                        ForEach(0..<2){ columnIndex in
                                            // Calculate the index for names array
                                            let Index = rowIndex * 2 + columnIndex
                                            
                                            // Ensure the index is within bounds
                                            if Index < names.count {
                                                VStack(alignment: .leading, spacing: -5) {
                                                    RoundedRectangle(cornerRadius: 9.0)
                                                        .fill(boxColors[Index])
                                                        .frame(width: 160, height: 160)
                                                        .shadow(radius: 5.0)
                                                        .padding()
                                                    Text(names[Index])
                                                        .fontWeight(.bold)
                                                        .padding(.horizontal, 20)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                    }
                    .padding(.bottom, 60)
                }
                .ignoresSafeArea()
                .background(Color(UIColor.systemBackground))
            }
            
            // Overlay the header
            VStack {
                ZStack {
                    Text("Saved")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.black)
                    
                    HStack(spacing: 0){
                        Image(systemName: "arrowshape.backward")
                            .resizable()
                            .foregroundColor(Color.black)
                            .frame(width: iconSize, height: iconSize)
                            .bold()
                        Spacer()
                        Image(systemName: "plus")
                            .resizable()
                            .foregroundColor(Color.black)
                            .frame(width: iconSize, height: iconSize)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color.white)
                
                Spacer()
                
                VStack {
                        HStack(spacing: 0){
                            Image(systemName: "house")
                                .resizable()
                                .foregroundColor(Color.black)
                                .frame(width: iconSize, height: iconSize)
                                .bold()
                            Spacer()
                                .frame(width: 50)
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: iconSize, height: iconSize)
                                .bold()
                            Spacer()
                                .frame(width: 50)
                            Image(systemName: "plus.app")
                                .resizable()
                                .frame(width: iconSize, height: iconSize)
                                .bold()
                            Spacer()
                                .frame(width: 50)
                            Image(systemName: "movieclapper")
                                .resizable()
                                .frame(width: iconSize, height: iconSize)
                                .bold()
                            Spacer()
                                .frame(width: 50)

                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .foregroundColor(Color.black)
                                .frame(width: iconSize, height: iconSize)
                                .bold()
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.white)
            }
        }
    }
}
#Preview {
    InstagramSavedSection()
}
