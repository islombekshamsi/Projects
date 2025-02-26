import SwiftUI

// Define Task model
struct Task: Identifiable {
    let id = UUID()
    var title: String
    let date: Date
    var isDone: Bool
    let tint: Color // Custom tint for the background
    var projectName: String?
}

// ViewModel for calendar
class CalendarViewModel: ObservableObject {
    @Published var tasks: [Task] = [
        Task(title: "Meeting at 5 PM", date: Date(), isDone: false, tint: Color.blue, projectName: "CompCalc"),
        Task(title: "Finish Backend", date: Date().addingTimeInterval(86400), isDone: false, tint: Color.purple, projectName: "CompCalc"),
        Task(title: "Finish UI design", date: Date().addingTimeInterval(172800), isDone: false, tint: Color.orange, projectName: "CollegeMart")
    ]
    
    @Published var newTaskTitle = ""
    @Published var newTaskProject = ""
    @Published var newTaskTint: Color = .blue
    @Published var showingAddTaskView = false
    
    func addNewTask() {
        let newTask = Task(
            title: newTaskTitle.isEmpty ? "New Task" : newTaskTitle,
            date: Date(),
            isDone: false,
            tint: newTaskTint,
            projectName: newTaskProject.isEmpty ? "General" : newTaskProject
        )
        
        tasks.append(newTask)
    }
    
    func removeCompletedTask(task: Task) {
        tasks.removeAll { $0.id == task.id && $0.isDone }
    }
}

// Calendar View
struct calendar: View {
    @ObservedObject var viewModel: CalendarViewModel
    var startupNames: [String]
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach($viewModel.tasks) { $task in
                        HStack(alignment: .center, spacing: 15) {
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    task.isDone.toggle()
                                    if task.isDone {
                                        viewModel.removeCompletedTask(task: task)
                                    }
                                }
                            }) {
                                Circle()
                                    .fill(task.isDone ? Color.green : Color.red)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())

                            VStack(alignment: .leading, spacing: 6) {
                                Text(task.title)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .strikethrough(task.isDone, color: .white)
                                    .opacity(task.isDone ? 0.6 : 1.0)

                                HStack {
                                    Text(task.date.formatted(date: .abbreviated, time: .omitted) + " |")
                                        .foregroundColor(.white)
                                        .font(.subheadline)

                                    if let projectName = task.projectName {
                                        Text(projectName)
                                            .foregroundColor(.white)
                                            .font(.subheadline)
                                    }
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(task.tint.opacity(task.isDone ? 0.5 : 1.0))
                                    .shadow(radius: 4)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    .shadow(radius: 4)
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                }
                .padding(.vertical, 16)
            }
            
            Button(action: {
                viewModel.showingAddTaskView.toggle()
            }) {
                Image(systemName: "square.and.pencil.circle.fill")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.white.opacity(0.1))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        
        .sheet(isPresented: $viewModel.showingAddTaskView) {
            AddTaskView(
                newTaskTitle: $viewModel.newTaskTitle,
                newTaskProject: $viewModel.newTaskProject,
                newTaskTint: $viewModel.newTaskTint,
                showingAddTaskView: $viewModel.showingAddTaskView,
                startupNames: startupNames,
                onSave: viewModel.addNewTask
            )
        }
    }
}

// AddTaskView to handle task creation
struct AddTaskView: View {
    @Binding var newTaskTitle: String
    @Binding var newTaskProject: String
    @Binding var newTaskTint: Color
    @Binding var showingAddTaskView: Bool
    var startupNames: [String]
    var onSave: () -> Void
    
    var body: some View {
        VStack {
            Text("Create New Task")
                .font(.headline)
                .padding(.top)
            
            TextField("Task Title", text: $newTaskTitle)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.bottom, 10)
            
            // Add a Picker or Menu for selecting the project
            Picker("Project", selection: $newTaskProject) {
                Text("Select a Project").tag("") // Default option
                ForEach(startupNames, id: \.self) { name in
                    Text(name).tag(name)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.bottom, 10)
            
            ColorPicker("Task Color", selection: $newTaskTint)
                .font(.title3)
                .bold()
                .frame(height: 60)
                .background(Color.gray.opacity(0.1))
                .padding(.bottom, 20)
            
            Button(action: {
                onSave()
                showingAddTaskView = false
            }) {
                Text("Save Task")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    calendar(viewModel: CalendarViewModel(), startupNames: ["CollegeMart", "CompCalc"])
}
