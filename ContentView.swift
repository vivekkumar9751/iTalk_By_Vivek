import SwiftUI

class AppSettings: ObservableObject {
    @Published var isOnboarded: Bool = false
}

struct ContentView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        NavigationView {
            if appSettings.isOnboarded {
                // Main App Interface
                TabView {
                    AITutorView()
                        .tabItem {
                            Label("AI Tutor", systemImage: "brain.head.profile")
                        }
                    
                    StoryModeView()
                        .tabItem {
                            Label("Story", systemImage: "book.fill")
                        }
                    
                    GestureLearningView()
                        .tabItem {
                            Label("Gesture", systemImage: "hand.raised.fill")
                        }
                    
//                    QuizModeView()
//                        .tabItem {
//                            Label("Quiz", systemImage: "questionmark.circle.fill")
//                        }
                }
                .navigationTitle("iTalk")
                .navigationBarItems(trailing:
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                )
            } else {
                OnboardingView()
            }
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var fadeIn = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Welcome to iTAlK!")
                    .font(.largeTitle)
                    .bold()
                    .opacity(fadeIn ? 1 : 0)
                    .animation(.easeIn(duration: 2), value: fadeIn)
                
                Image(systemName: "sparkles")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(fadeIn ? 360 : 0))
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: false), value: fadeIn)
                
                Button("Get Started") {
                    appSettings.isOnboarded = true
                }
                .padding()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear { fadeIn = true }
        }
    }
}


struct ProfileView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("User Details")) {
                    HStack {
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        VStack(alignment: .leading) {
                            Text("Vivek Chaudhary")
                                .font(.headline)
                            Text("vk092731@gmail.com")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Progress & Records")) {
                    NavigationLink("AI Tutor Progress", destination: AITutorProgressView())
                    NavigationLink("Story Mode Records", destination: StoryRecordsView())
                    NavigationLink("Gesture Learning Stats", destination: GestureStatsView())
                }
                
                Section(header: Text("Settings")) {
                    NavigationLink("App Settings", destination: SettingsView())
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Profile")
        }
    }
}


//class AITutorProgress: ObservableObject {
//    @Published var tutorHistory: [String] = []  // Track answered questions
//}
//
//struct AITutorView: View {
//    @State private var selectedAnswer: String? = nil
//    @State private var feedbackMessage: String = ""
//    @State private var showFeedback: Bool = false
//    @State private var currentQuestionIndex: Int = 0
//    @State private var currentQuestion: Question
//    @EnvironmentObject var tutorProgress: AITutorProgress  // Track progress
//
//    let questions = sampleLesson.questions
//
//    init() {
//        _currentQuestion = State(initialValue: sampleLesson.questions.first!)
//    }
//
//    var body: some View {
//        VStack {
//            Text(currentQuestion.text)
//                .font(.largeTitle)
//                .bold()
//                .padding()
//
//            HStack {
//                ForEach(currentQuestion.options, id: \.self) { option in
//                    Button(action: {
//                        checkAnswer(selectedAnswer: option)
//                    }) {
//                        Text(option)
//                            .padding()
//                            .background(selectedAnswer == option ? Color.green : Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                }
//            }
//            .padding()
//
//            if showFeedback {
//                Text(feedbackMessage)
//                    .font(.title)
//                    .foregroundColor(.green)
//                    .padding()
//            }
//
//            if showFeedback {
//                Button(action: {
//                    moveToNextQuestion()
//                }) {
//                    Text("Next Question")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding()
//            }
//        }
//        .navigationTitle("AI Tutor")
//        .padding()
//    }
//
//    private func checkAnswer(selectedAnswer: String) {
//        self.selectedAnswer = selectedAnswer
//        if selectedAnswer == currentQuestion.correctAnswer {
//            feedbackMessage = "Correct!"
//            showFeedback = true
//            tutorProgress.tutorHistory.append(currentQuestion.text)  // Record progress
//        } else {
//            feedbackMessage = "Wrong, try again!"
//            showFeedback = true
//        }
//    }
//
//    private func moveToNextQuestion() {
//        if currentQuestionIndex + 1 < questions.count {
//            currentQuestionIndex += 1
//            currentQuestion = questions[currentQuestionIndex]
//            selectedAnswer = nil
//            feedbackMessage = ""
//            showFeedback = false
//        } else {
//            feedbackMessage = "You've completed the quiz!"
//            showFeedback = true
//        }
//    }
//}
//
//
//struct AITutorProgressView: View {
//    @EnvironmentObject var tutorProgress: AITutorProgress
//
//    var body: some View {
//        List {
//            Section(header: Text("Completed AI Tutor Questions")) {
//                ForEach(tutorProgress.tutorHistory, id: \.self) { question in
//                    Text(question)
//                }
//            }
//        }
//        .navigationTitle("AI Tutor Progress")
//    }
//}

struct StoryRecordsView: View {
    @EnvironmentObject var storyManager: StoryManager
    
    var body: some View {
        List {
            Section(header: Text("Story Mode Choices")) {
                ForEach(storyManager.storyHistory, id: \.self) { choice in
                    Text(choice)
                }
            }
        }
        .navigationTitle("Story Mode Records")
    }
}


struct SettingsView: View { var body: some View { Text("App Settings") } }

@main
struct iTalkApp: App {
    @StateObject private var storyManager = StoryManager()
    @StateObject private var appSettings = AppSettings()
    @StateObject private var gestureHistory = GestureHistory()
    @StateObject private var tutorProgress = AITutorProgress()  // Add this

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
                .environmentObject(gestureHistory)
                .environmentObject(storyManager)
                .environmentObject(tutorProgress)  // Ensure AI Tutor tracking is injected
        }
    }
}

