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
    @State private var colors: [Color] = (0..<5).map { _ in Color.random() }
    @State private var sketchSize: CGSize = CGSize(width: 365, height: 400) // New state for resizable canvas
    @Environment(\.presentationMode) var presentationMode
    
    // AI Documentation Generator States
    @State private var customPrompt: String = ""
    @State private var generatedDoc: String = ""
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showCopyConfirmation: Bool = false

    // Color calculations
    var sliderColor: Color {
        let normalizedValue = value / 100.0
        return Color(
            hue: (1.0 - normalizedValue) * 0.3,
            saturation: 1.0,
            brightness: 1.0
        )
    }
   
    var checkColor: Color {
        switch value {
        case 0..<35: return .green
        case 36..<101: return Color(UIColor.systemGray)
        default: return .white
        }
    }

    var urgentColor: Color {
        switch value {
        case 0..<74: return Color(UIColor.systemGray)
        case 75..<101: return .red
        default: return .blue
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Startup Info Section
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

                // Difficulty Slider
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
                        .keyboardType(.default)
                        .autocorrectionDisabled(false)
                        .onChange(of: brainstormText) { newValue in
                                if brainstormText != newValue {
                                    DispatchQueue.main.async {
                                        brainstormText = newValue
                                    }
                                }
                            }
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
                
                // Custom Prompt Section
                VStack(alignment: .leading) {
                    Text("Custom Instructions (Optional)")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextField("Ex: 'Focus on technical details'", text: $customPrompt)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                }
                
                // Generate Documentation Button
                Button(action: generateWithOpenRouter) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isLoading ? "Generating..." : "Generate Documentation")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .disabled(isLoading || brainstormText.isEmpty)
                
                // Generated Documentation Section
                if !generatedDoc.isEmpty {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Generated Documentation")
                                .font(.title2.bold())
                            Spacer()
                            
                            // Copy button with confirmation
                            Button(action: {
                                UIPasteboard.general.string = generatedDoc
                                showCopyConfirmation = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showCopyConfirmation = false
                                }
                            }) {
                                ZStack {
                                    Image(systemName: "doc.on.doc")
                                    if showCopyConfirmation {
                                        Image(systemName: "document.on.document.fill")
                                    }
                                }
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(Circle().fill(Color.blue.opacity(0.1)))
                            }
                        }
                        .padding(.horizontal)

                        // Editable TextEditor
                        TextEditor(text: $generatedDoc)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .frame(minHeight: 365, maxHeight: 400)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal)
                    }
                }

                // Updated Sketch Section with Resizable Canvas
                HStack {
                    Text("Sketch")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding()
                }

                ZStack(alignment: .bottomTrailing) {
                    // Canvas Background
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.gray)
                        .frame(width: sketchSize.width, height: sketchSize.height)
                        .overlay {
                            if drawing.lines.isEmpty {
                                Text("Sketch here")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    
                    // Drawing Canvas
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
                        
                        // Current stroke
                        var tempPath = Path()
                        if let firstPoint = currentLine.points.first {
                            tempPath.move(to: firstPoint)
                            for point in currentLine.points {
                                tempPath.addLine(to: point)
                            }
                        }
                        context.stroke(tempPath, with: .color(.blue), lineWidth: 3)
                    }
                    .frame(width: sketchSize.width, height: sketchSize.height)
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
                    
                    // Resize Handle (Bottom-Right Corner)
                    Image(systemName: "arrow.up.left.and.arrow.down.right.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white))
                        .offset(x: 10, y: 10)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newWidth = max(200, sketchSize.width + value.translation.width)
                                    let newHeight = max(200, sketchSize.height + value.translation.height)
                                    sketchSize = CGSize(width: newWidth, height: newHeight)
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
                        onSave()
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

                // Save Button
                HStack {
                    Button(action: {
                        saveDrawingAsImage()
                        onSave()
                        presentationMode.wrappedValue.dismiss()
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
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .padding()
        }
        .scrollDisabled(isDrawing)
        .onAppear {
            if let loadedDrawing = try? JSONDecoder().decode(Drawing.self, from: sketchData) {
                drawing = loadedDrawing
            }
        }
    }

    // AI Documentation Generation Functions
    private func generateWithOpenRouter() {
        guard !brainstormText.isEmpty else { return }

        isLoading = true
        generatedDoc = ""
        errorMessage = ""

        let url = URL(string: "https://openrouter.ai/api/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer <YOUR_OPENROUTER_API", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let model = "openai/gpt-3.5-turbo"

        let messages: [[String: String]] = [
            ["role": "system", "content": "You are an AI assistant that generates structured startup detailed documentation. Start with startup name that is \(startupName), description and everything needed in documentation. Then,  Include competitors, market research of the industry, and a suggested tech stack. Generate it with clean formatting!: Use all caps for section headers. no markdown symbols (*, #, **), bullet points for lists. NO BOLD just regular text! At conclusion dont state that you are an AI, this is official documentation, and dont add concluding paragraph describing it. I only need documentation!"],
            ["role": "user", "content": brainstormText + (customPrompt.isEmpty ? "" : "\nAdditional Instructions: \(customPrompt)")]
        ]

        let requestBody: [String: Any] = [
            "model": model,
            "messages": messages,
            "max_tokens": 1000
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    isLoading = false

                    if let error = error {
                        showError(message: "Network error: \(error.localizedDescription)")
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                        showError(message: "Invalid server response")
                        return
                    }

                    if httpResponse.statusCode != 200 {
                        showError(message: "HTTP error \(httpResponse.statusCode)")
                        return
                    }

                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let choices = json["choices"] as? [[String: Any]],
                           let message = choices.first?["message"] as? [String: Any],
                           let text = message["content"] as? String {
                            generatedDoc = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        } else {
                            showError(message: "Invalid response format")
                        }
                    } catch {
                        showError(message: "JSON decoding error: \(error.localizedDescription)")
                    }
                }
            }.resume()

        } catch {
            showError(message: "Failed to create request: \(error.localizedDescription)")
        }
    }

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }

    // Drawing Functions
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
        let renderer = ImageRenderer(
            content: Canvas { context, size in
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
            }
            .frame(width: sketchSize.width, height: sketchSize.height)
        )
        
        if let uiImage = renderer.uiImage,
           let data = uiImage.pngData() {
            sketchData = data
        }
    }
    
    private func dummyFunction() {
        dummyFlag.toggle()
    }
}

// Helper extensions
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
    dscrptn(
        startupName: .constant(""),
        startupField: .constant(""),
        startupFounder: .constant(""),
        brainstormText: .constant(""),
        sketchData: .constant(Data()),
        lockedColors: .constant([false, false, false, false, false]),
        onSave: {}
    )
}
