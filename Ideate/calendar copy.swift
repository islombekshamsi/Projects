import SwiftUI

// MARK: - Data Models
struct Task: Identifiable, Codable {
    let id = UUID()
    var title: String
    let date: Date
    var isDone: Bool
    let tint: CodableColor
    var projectName: String?
    
    // Convert Color to Codable type
    struct CodableColor: Codable {
        var red: Double
        var green: Double
        var blue: Double
        var opacity: Double
        
        init(_ color: Color) {
            let uiColor = UIColor(color)
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            self.red = Double(r)
            self.green = Double(g)
            self.blue = Double(b)
            self.opacity = Double(a)
        }
        
        var color: Color {
            Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
        }
    }
}

// MARK: - ViewModel
class CalendarViewModel: ObservableObject {
    @Published var tasks: [Task] = [] {
        didSet { saveTasks() }
    }
    
    @Published var selectedDate = Date()
    @Published var showingAddTaskView = false
    
    init() {
        loadTasks()
    }
    
    // Add sample tasks if none exist (for demo)
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        } else {
            tasks = [
                Task(title: "Meeting at 5 PM", date: Date(), isDone: false, tint: .init(.blue), projectName: "CompCalc"),
                Task(title: "Finish Backend", date: Date().addingTimeInterval(86400), isDone: false, tint: .init(.purple), projectName: "CompCalc"),
                Task(title: "UI Design Review", date: Date().addingTimeInterval(172800), isDone: false, tint: .init(.orange), projectName: "CollegeMart")
            ]
        }
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }
    
    func addTask(title: String, project: String, tint: Color, date: Date) {
        let newTask = Task(
            title: title,
            date: date,
            isDone: false,
            tint: .init(tint),
            projectName: project.isEmpty ? "General" : project
        )
        tasks.append(newTask)
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isDone.toggle()
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    func tasksForDate(_ date: Date) -> [Task] {
        tasks.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
}

// MARK: - Main Calendar View
struct CalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let startupNames: [String]
    
    @State private var isDraggingTask = false
    @State private var draggedTask: Task?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                // Calendar Header
                Text(viewModel.selectedDate.formatted(date: .complete, time: .omitted))
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .padding(.top, 20)
                
                // Date Picker Strip
                CalendarDateStrip(selectedDate: $viewModel.selectedDate, tasks: viewModel.tasks)
                    .padding(.vertical, 12)
                
                // Tasks List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.tasksForDate(viewModel.selectedDate)) { task in
                            TaskCard(
                                task: task,
                                onToggle: { viewModel.toggleTaskCompletion(task) },
                                onDelete: { viewModel.tasks.removeAll { $0.id == task.id } }
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 80)
                }
            }
            
            // Floating Add Button
            AddTaskButton {
                viewModel.showingAddTaskView.toggle()
            }
        }
        .sheet(isPresented: $viewModel.showingAddTaskView) {
            AddTaskView(viewModel: viewModel, startupNames: startupNames)
        }
    }
}

// MARK: - Components

// Date Strip
struct CalendarDateStrip: View {
    @Binding var selectedDate: Date
    let tasks: [Task]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(-7..<7, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
                    let dayTasks = tasks.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
                    
                    Button {
                        withAnimation(.spring()) {
                            selectedDate = date
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                            
                            ZStack {
                                Circle()
                                    .fill(selectedDate == date ? Color.blue : Color.clear)
                                    .frame(width: 32, height: 32)
                                
                                Text(date.formatted(.dateTime.day()))
                                    .font(.system(size: 16, weight: selectedDate == date ? .bold : .medium, design: .rounded))
                                    .foregroundColor(selectedDate == date ? .white : .primary)
                            }
                            
                            if !dayTasks.isEmpty {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .frame(width: 44)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// Task Card
struct TaskCard: View {
    let task: Task
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    onToggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(task.isDone ? task.tint.color : Color(.systemGray5))
                        .frame(width: 24, height: 24)
                    
                    if task.isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Task Content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .strikethrough(task.isDone)
                    .foregroundColor(task.isDone ? .secondary : .primary)
                
                if let project = task.projectName {
                    Text(project.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(task.tint.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(task.tint.color.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            // Time
            Text(task.date.formatted(date: .omitted, time: .shortened))
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .contextMenu {
            Button(role: .destructive) {
                withAnimation {
                    onDelete()
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// Add Task Button
struct AddTaskButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(20)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                .padding(24)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Add Task View
struct AddTaskView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let startupNames: [String]
    
    @State private var title = ""
    @State private var selectedProject = ""
    @State private var selectedColor: Color = .blue
    @State private var selectedDate = Date()
    
    let colorOptions: [Color] = [.blue, .purple, .pink, .orange, .green, .mint]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task title", text: $title)
                        .font(.system(size: 17, design: .rounded))
                }
                
                Section("Details") {
                    Picker("Project", selection: $selectedProject) {
                        Text("None").tag("")
                        ForEach(startupNames, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    
                    DatePicker("Due Date", selection: $selectedDate, displayedComponents: .date)
                }
                
                Section("Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colorOptions, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showingAddTaskView = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addTask(
                            title: title,
                            project: selectedProject,
                            tint: selectedColor,
                            date: selectedDate
                        )
                        viewModel.showingAddTaskView = false
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

// Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    CalendarView(
        viewModel: CalendarViewModel(),
        startupNames: ["CollegeMart", "CompCalc", "New Project"]
    )
}
