import SwiftUI

struct ContentView: View {
    @StateObject private var calendarViewModel = CalendarViewModel() // Shared ViewModel
    @State var addTextInputs: [String] = ["", "", ""]
    @State var addTitles: [String] = ["Startup Name", "Industry", "Quick Description"]
    @State var items: [String] = ["CollegeMart", "CompCalc"]
    @State var industry: [String] = ["Software", "Hardware"]
    @State var founders: [String] = ["Exclusive college marketplace", "CS Calculator"]
    @State var showRectangle: Bool = false
    @State var searchtext: String = ""
    @State private var offset: CGSize = CGSize(width: 135, height: 350)
    @State private var dragOffset: CGSize = .zero
    @State var brainstormTexts: [String] = Array(repeating: "", count: 4)
    @State var sketches: [Data] = Array(repeating: Data(), count: 4)
    @State var lockedColors: [[Bool]] = Array(repeating: Array(repeating: false, count: 5), count: 4)
    @State private var selectedTab: String = "Notes"
    @State private var showList: Bool = true
    let positions = [
            CGSize(width: -135, height: 350),
            CGSize(width: 135, height: 350),
            CGSize(width: 135, height: -350),
            CGSize(width: -135, height: -350)
        ]

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Text("Ideate")
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .padding()
                    HStack {
                        Button(action: {
                            selectedTab = "Notes"
                            showList = true
                        }) {
                            Capsule()
                                .frame(width: 80, height: 40)
                                .foregroundStyle(selectedTab == "Notes" ? Color.blue : Color(UIColor.systemGray6))
                                .overlay(
                                    Text("Notes")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(selectedTab == "Notes" ? Color.white : Color.black)
                                )
                        }
                        
                        Button(action: {
                            selectedTab = "Tasks"
                            showList = false
                        }) {
                            Capsule()
                                .frame(width: 100, height: 40)
                                .foregroundStyle(selectedTab == "Tasks" ? Color.blue : Color(UIColor.systemGray6))
                                .overlay(
                                    Text("Tasks")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(selectedTab == "Tasks" ? .white : .black)
                                )
                        }
                    }
                    .padding(.bottom, 10)

                    // Display the appropriate view based on the selected tab
                    if selectedTab == "Tasks" {
                        CalendarView(viewModel: calendarViewModel, startupNames: items) // Pass the shared ViewModel
                    } else {
                        List {
                            ForEach(items.indices, id: \.self) { index in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(width: 370, height: 130)
                                        .foregroundStyle(Color.white)
                                        .padding(2)
                                        .shadow(radius: 5)
                                        .overlay(
                                            HStack {
                                                VStack(alignment: .leading, spacing: 15) {
                                                    Text(industry[index])
                                                        .font(.system(size: 17, weight: .semibold))
                                                        .foregroundColor(.gray)
                                                    HStack {
                                                        Text(items[index])
                                                            .font(.system(size: 25, weight: .bold))
                                                        Spacer()
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                    Text(Date().formatted(.dateTime.day().month(.wide).year()) + " | \(founders[index])")
                                                        .font(.system(size: 15))
                                                        .foregroundStyle(Color.secondary)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 25)
                                                Spacer().frame(width: 15)
                                            }
                                        )
                                    
                                    NavigationLink("", destination: dscrptn(
                                        startupName: $items[index],
                                        startupField: $industry[index],
                                        startupFounder: $founders[index],
                                        brainstormText: $brainstormTexts[index],
                                        sketchData: $sketches[index],
                                        lockedColors: $lockedColors[index],
                                        onSave: {
                                            saveData()
                                        }
                                    ))
                                    .opacity(0)
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.vertical, 5)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        deleteItem(indexSet: IndexSet(integer: index))
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        duplicateItem(index: index)
                                    } label: {
                                        Label("Duplicate", systemImage: "plus.square.on.square")
                                    }
                                    .tint(.blue)
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                        .transition(.opacity)
                    }
                }
                if showList{
                                   RoundedRectangle(cornerRadius: 35)
                                       .fill(.black)
                                       .frame(width: 70, height: 70)
                                       .overlay(
                                           Image(systemName: "plus")
                                               .resizable()
                                               .scaledToFit()
                                               .frame(width: 25, height: 25)
                                               .foregroundColor(.white)
                                       )
                                       .offset(CGSize(width: offset.width + dragOffset.width, height: offset.height + dragOffset.height))
                                       .gesture(
                                           DragGesture()
                                               .onChanged { value in
                                                   withAnimation(.easeIn) {
                                                       dragOffset = value.translation
                                                   }
                                               }
                                               .onEnded { _ in
                                                   withAnimation(.spring()) {
                                                       let newOffset = CGSize(width: offset.width + dragOffset.width, height: offset.height + dragOffset.height)
                                                       offset = positions.min(by: {
                                                           hypot($0.width - newOffset.width, $0.height - newOffset.height) <
                                                               hypot($1.width - newOffset.width, $1.height - newOffset.height)
                                                       }) ?? offset
                                                       dragOffset = .zero
                                                   }
                                               }
                                       )
                                   
                                       .onTapGesture {
                                           withAnimation {
                                               showRectangle.toggle()
                                               
                                           }
                                       }
                               }

                               // AddNoteView overlay
                               if showRectangle {
                                   AddNoteView(
                                       showRectangle: $showRectangle,
                                       addTextInputs: $addTextInputs,
                                       addTitles: addTitles,
                                       onSave: saveNewItem
                                   )
                                   .transition(.opacity)
                                   .zIndex(1)
                                   .scaleEffect(showRectangle ? 1 : 0.9)
                               }
                           }
                       }
                   }

                   func deleteItem(indexSet: IndexSet) {
                       withAnimation {
                           for index in indexSet {
                               items.remove(at: index)
                               industry.remove(at: index)
                               founders.remove(at: index)
                               brainstormTexts.remove(at: index)
                               sketches.remove(at: index)
                               lockedColors.remove(at: index)
                           }
                           saveData()
                       }
                   }
                   
                   func moveItem(from: Int, to: Int) {
                       withAnimation {
                           items.swapAt(from, to)
                           industry.swapAt(from, to)
                           founders.swapAt(from, to)
                           brainstormTexts.swapAt(from, to)
                           sketches.swapAt(from, to)
                           lockedColors.swapAt(from, to)
                           saveData()
                       }
                   }

                   func duplicateItem(index: Int) {
                       withAnimation {
                           items.insert(items[index] + " (Duplicate)", at: index + 1)
                           industry.insert(industry[index], at: index + 1)
                           founders.insert(founders[index], at: index + 1)
                           brainstormTexts.insert(brainstormTexts[index], at: index + 1)
                           sketches.insert(sketches[index], at: index + 1)
                           lockedColors.insert(lockedColors[index], at: index + 1)
                           saveData()
                       }
                   }

                   func saveData() {
                       UserDefaults.standard.set(items, forKey: "items")
                       UserDefaults.standard.set(industry, forKey: "field")
                       UserDefaults.standard.set(founders, forKey: "founders")
                       UserDefaults.standard.set(brainstormTexts, forKey: "brainstormTexts")
                       UserDefaults.standard.set(sketches, forKey: "sketches")
                       UserDefaults.standard.set(lockedColors, forKey: "lockedColors")
                   }

                   func saveNewItem() {
                       withAnimation {
                           items.append(addTextInputs[0])
                           industry.append(addTextInputs[1])
                           founders.append(addTextInputs[2])
                           brainstormTexts.append("")
                           sketches.append(Data())
                           lockedColors.append(Array(repeating: false, count: 5))
                           addTextInputs = ["", "", ""]
                           showRectangle = false
                           saveData()
                       }
                   }
               }

               struct AddNoteView: View {
                   @Binding var showRectangle: Bool
                   @Binding var addTextInputs: [String]
                   var addTitles: [String]
                   var onSave: () -> Void

                   @State private var isEmpty: Bool = false
                   @State private var shakeOffset: CGFloat = 0

                   var body: some View {
                       ZStack {
                           Color.gray.opacity(0.8)
                               .edgesIgnoringSafeArea(.all)

                           VStack {
                               Button {
                                   withAnimation(.easeInOut(duration: 0.2)) {
                                       addTextInputs = ["", "", ""]
                                       showRectangle.toggle()
                                   }
                               } label: {
                                   HStack(alignment: .lastTextBaseline) {
                                       Image(systemName: "x.circle")
                                           .resizable()
                                           .frame(width: 40, height: 40)
                                           .fontWeight(.light)
                                           .foregroundStyle(Color.black)
                                           .padding()
                                   }
                                   .frame(maxWidth: .infinity, alignment: .topLeading)
                                   .padding(.top, -45)
                                   .padding(.horizontal, 5)//
                               }
                               .padding(.top)
                               RoundedRectangle(cornerRadius: 20)
                                   .stroke(Color.white, lineWidth: 3)
                                   .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                                   .frame(width: 360, height: 480)
                                   .shadow(radius: 10)
                                   .overlay(
                                       VStack(alignment: .leading, spacing: -10) {
                                           Spacer().frame(height: 30)

                                           ForEach(0..<3) { index in
                                               Text(addTitles[index])
                                                   .font(.system(size: 25, weight: .semibold))
                                                   .padding(.horizontal, 12)

                                               TextField("Type here", text: $addTextInputs[index])
                                                   .font(.system(size: 20, weight: .medium))
                                                   .frame(width: 280, height: 75)
                                                   .textFieldStyle(PlainTextFieldStyle())
                                                   .padding(.horizontal, 20)
                                                   .overlay(
                                                       RoundedRectangle(cornerRadius: 15)
                                                           .stroke(Color.black, lineWidth: 2)
                                                           .frame(height: 50)
                                                           .shadow(radius: 1)
                                                   )
                                                   .padding(10)
                                           }

                                           Spacer().frame(height: 95)

                                           HStack(spacing: 85) {
                                               Text(Date().formatted(.dateTime.day().month(.wide).year()))
                                                   .font(.system(size: 15, weight: .medium))
                                                   .foregroundStyle(Color.secondary)
                                               
                                               Text("At Least One Field Must be Filled")
                                                   .font(.system(size: 15, weight: .medium))
                                                   .foregroundStyle(Color.secondary)
                                           }
                                       }
                                   )
                           
                               .padding()

                               Button(action: {
                                   if addTextInputs.allSatisfy({ $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                                       isEmpty = true
                                       withAnimation(.default) { shakeOffset = 10 }
                                       withAnimation(Animation.easeInOut(duration: 0.1).repeatCount(5, autoreverses: true)) {
                                           shakeOffset = -10
                                       }
                                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                           withAnimation {
                                               shakeOffset = 0
                                               isEmpty = false
                                           }
                                       }
                                       let generator = UINotificationFeedbackGenerator()
                                       generator.notificationOccurred(.error)
                                   } else {
                                       isEmpty = false
                                       onSave()
                                   }
                               }) {
                                   Text("Save")
                                       .foregroundColor(Color.white)
                                       .font(.system(size: 20, weight: .semibold))
                                       .frame(width: 130, height: 55)
                                       .background(isEmpty ? Color.red : Color.blue)
                                       .cornerRadius(25)
                                       .padding()
                                       .offset(x: shakeOffset)
                               }
                           }
                       }
                   }
               }

               #Preview {
                   ContentView()
               }
