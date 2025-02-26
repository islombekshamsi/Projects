import SwiftUI

struct dscrptn: View {
    @Binding var startupName: String
    @Binding var startupField: String
    @Binding var startupFounder: String
    @Binding var brainstormText: String
    @Binding var sketchData: Data
    @Binding var lockedColors: [Bool]
    var onSave: () -> Void

    @State private var isMainLocked: Bool = false
    @State private var isLocked: Bool = false
    @State private var value: Double = 50
    @State private var drawing = Drawing()
    @State private var currentLine = Line(points: [])
    @State private var undoStack: [Line] = []
    @State private var isDrawing = false
    @State private var isErasing = true
    @State private var generateFlag: Bool = true
    @State private var dummyFlag: Bool = false
    @State private var fontSize: CGFloat = 17
    @State private var colors: [Color] = (0..<5).map { _ in Color.random() } // Initialize with random colors
    @Environment(\.presentationMode) var presentationMode

    
    
    var sliderColor: Color {
       switch value {
       case 0..<35:
           return .green
       case 76..<101:
           return .red
       default:
           return .orange
       }
   }
   
   var checkColor: Color {
       switch value {
       case 0..<35:
           return .green
       case 36..<101:
           return Color(UIColor.systemGray)
       default:
           return .white
       }
   }

   var urgentColor: Color {
       switch value {
       case 0..<74:
           return Color(UIColor.systemGray)
       case 75..<101:
           return .red
       default:
           return .blue
       }
   }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                //.frame(, height: 50)
                Text("Startup Name")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .padding()
                                HStack {
                                    TextField("Type here", text: $startupName)
                                        .font(.title3)
                                        .frame(width: 280, height: 50)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .padding(.horizontal, 30)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.black, lineWidth: 2)
                                                .frame(height: 50)
                                        )
                                }
                                .frame(maxWidth: .infinity)

                                Text("Industry")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .padding()
                                HStack {
                                    TextField("Type here", text: $startupField)
                                        .font(.title3)
                                        .frame(width: 280, height: 50)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .padding(.horizontal, 30)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.black, lineWidth: 2)
                                                .frame(height: 50)
                                        )
                                }
                                .frame(maxWidth: .infinity)

                                Text("Quick Description")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .padding()
                                HStack {
                                    TextField("Type here", text: $startupFounder)
                                        .font(.title3)
                                        .frame(width: 280, height: 50)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .padding(.horizontal, 30)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.black, lineWidth: 2)
                                                .frame(height: 50)
                                        )
                                }
                                .frame(maxWidth: .infinity)

                                HStack {
                                    Text("Difficulty")
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .padding()
                                    Spacer()
                                    Text(value.formatted())
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .padding(.trailing, 20)
                                }

                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.systemGray6))
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .resizable()
                                            .foregroundStyle(checkColor)
                                            .frame(width: 25, height: 25)
                                            .padding()
                                        
                                        Slider(value: $value, in: 0...100, step: 1)
                                            .accentColor(sliderColor)
                                        
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .resizable()
                                            .foregroundStyle(urgentColor)
                                            .frame(width: 25, height: 25)
                                            .padding()
                                    }
                                }
                // Brainstorm Section
                HStack {
                    Text("Brainstorm")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding()
                    Spacer().frame(width: 100)
                    Button {
                        fontSize += 1
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemGray6))
                                .frame(width: 40, height: 40)
                                .shadow(radius: 5)
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                        }
                    }
                    Button {
                        fontSize -= 1
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemGray6))
                                .frame(width: 40, height: 40)
                                .shadow(radius: 5)
                            Image(systemName: "minus")
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                        }
                    }
                }

                HStack {
                    TextEditor(text: $brainstormText)
                        .font(.system(size: fontSize))
                        .bold()
                        .frame(width: 345, height: 200)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .frame(width: 330)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)

                HStack(alignment: .center, spacing: 150) {
                    Group {
                        Text("Font Size: \(Int(fontSize))")
                        Text("Word Count: \(brainstormText.split(separator: " ").count)")
                    }
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                }
                .frame(maxWidth: .infinity)

                // Sketch Section
                HStack {
                    Text("Sketch")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding()
                }

                ZStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            .foregroundColor(.gray)
                            .frame(width: 365, height: 400)
                            .overlay {
                                if drawing.lines.isEmpty {
                                    Text("Sketch here")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)

                    // Canvas with Smooth Drawing
                    Canvas { context, size in
                        for line in drawing.lines {
                            var path = Path()
                            if let firstPoint = line.points.first {
                                path.move(to: firstPoint)
                                for point in line.points {
                                    path.addLine(to: point)
                                }
                            }
                            context.stroke(path, with: .color(.blue), lineWidth: 3)
                        }

                        // Show current stroke while drawing
                        var tempPath = Path()
                        if let firstPoint = currentLine.points.first {
                            tempPath.move(to: firstPoint)
                            for point in currentLine.points {
                                tempPath.addLine(to: point)
                            }
                        }
                        context.stroke(tempPath, with: .color(.blue), lineWidth: 3)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isDrawing = true
                                currentLine.points.append(value.location)
                            }
                            .onEnded { _ in
                                drawing.lines.append(currentLine)
                                currentLine = Line(points: [])
                                undoStack.removeAll()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isDrawing = false
                                }
                            }
                    )
                }

                // Undo, Save, Clear, and Redo Buttons
                HStack(alignment: .center, spacing: 10) {
                    // Undo Button
                    Button(action: removeLastStroke) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.secondarySystemFill))
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(systemName: "arrow.uturn.backward")
                                    .foregroundColor(.black)
                            }
                    }

                    // Save Button
                    Button(action: {
                        saveDrawingAsImage()
                        onSave() // Call the onSave callback to save data
                    }) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.systemBlue))
                            .frame(width: 100, height: 50)
                            .overlay {
                                Text("Save")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                    }

                    // Clear Button
                    Button(action: clearDrawing) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.systemRed))
                            .frame(width: 100, height: 50)
                            .overlay {
                                Text("Clear")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                    }

                    // Redo Button
                    Button(action: redoLastStroke) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.secondarySystemFill))
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(systemName: "arrow.uturn.forward")
                                    .foregroundColor(.black)
                            }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()

                // Color Palette Section
                HStack {
                    Text("Color Palette")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding()
                    Spacer().frame(width: 65)
                    Button(action: generateFlag ? generateColors : dummyFunction) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.secondarySystemFill))
                            .frame(width: 50, height: 50)
                            .shadow(radius: 5)
                            .overlay {
                                Image(systemName: "wand.and.rays")
                                    .font(.system(size: 26))
                                    .foregroundColor(.blue)
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        generateFlag.toggle()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            isLocked.toggle()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(UIColor.secondarySystemFill))
                                .frame(width: 50, height: 50)
                                .shadow(radius: 5)
                                .overlay {
                                    Image(systemName: "lock.open.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(isLocked ? .gray : .green)
                                        .offset(x: isLocked ? -25 : 0)
                                        .opacity(isLocked ? 0 : 1)
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(isLocked ? .red : .gray)
                                        .offset(x: isLocked ? 0 : 25)
                                        .opacity(isLocked ? 1 : 0)
                                }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                HStack {
                    ForEach(colors.indices, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(colors[index])
                                .frame(width: 68, height: 68)
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 2))
                                .opacity(lockedColors[index] ? 0.9 : 1.0)

                            if lockedColors[index] {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color(UIColor.systemGray6))
                                    .font(.system(size: 30))
                            }
                        }
                        .onTapGesture {
                            toggleColorLock(at: index)
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                HStack {
                    Button(action: {
                        // Save the sketch data before calling onSave
                        saveDrawingAsImage()
                        onSave()
                        presentationMode.wrappedValue.dismiss()
                        //ContentView()
                    }) {
                        Text("Save")
                            .foregroundColor(Color.white)
                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 150, height: 55)
                            .background(Color.blue)
                            .cornerRadius(25)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }){
                Image(systemName: "arrow.backward")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.black)
                    .padding()
            })
            
            .padding()
        }
        .scrollDisabled(isDrawing)
        .onAppear {
            // Load the sketch data when the view appears
            if let loadedDrawing = try? JSONDecoder().decode(Drawing.self, from: sketchData) {
                drawing = loadedDrawing
            }
        }
    }

    private func toggleColorLock(at index: Int) {
        if !isMainLocked {
            withAnimation {
                lockedColors[index].toggle()
            }
        }
    }

    private func generateColors() {
        for index in colors.indices {
            if !lockedColors[index] {
                colors[index] = Color.random()
            }
        }
    }

    private func toggleIsErasing() {
        isErasing.toggle()
    }

    private func removeLastStroke() {
        guard !drawing.lines.isEmpty else { return }
        undoStack.append(drawing.lines.removeLast())
    }

    private func redoLastStroke() {
        guard !undoStack.isEmpty else { return }
        drawing.lines.append(undoStack.removeLast())
    }

    private func clearDrawing() {
        drawing = Drawing()
        undoStack.removeAll()
    }

    private func saveDrawingAsImage() {
        // Convert the drawing to Data and save it to sketchData
        if let encodedData = try? JSONEncoder().encode(drawing) {
            sketchData = encodedData
        }
    }
    private func dummyFunction(){
        dummyFlag.toggle()
    }
}

extension Color {
    static func random() -> Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

struct Drawing: Codable {
    var lines: [Line] = []
}

struct Line: Codable {
    var points: [CGPoint]
}

#Preview {
    dscrptn(startupName: .constant(""), startupField: .constant(""), startupFounder: .constant(""), brainstormText: .constant(""), sketchData: .constant(Data()), lockedColors: .constant([false, false, false, false, false]), onSave: {})
}
