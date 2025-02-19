import SwiftUI
import AVFoundation
import Speech
import AudioToolbox
import SpriteKit


class AITutorProgress: ObservableObject {
    @Published var tutorHistory: [String] = []  // Track answered questions
}

struct AITutorProgressView: View {
    @EnvironmentObject var tutorProgress: AITutorProgress

    var body: some View {
        List {
            Section(header: Text("Completed AI Tutor Questions")) {
                ForEach(tutorProgress.tutorHistory, id: \.self) { question in
                    Text(question)
                }
            }
        }
        .navigationTitle("AI Tutor Progress")
    }
}


struct AITutorView: View {
    @State private var selectedAnswer: String? = nil
    @State private var feedbackMessage: String = ""
    @State private var showFeedback: Bool = false
    @State private var currentQuestionIndex: Int = 0
    @State private var currentQuestion: Question
    @EnvironmentObject var tutorProgress: AITutorProgress
    @State private var speechRecognizer: SFSpeechRecognizer?
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine: AVAudioEngine?
    @State private var scene: SKScene?
    
    let synthesizer = AVSpeechSynthesizer()
    let questions = sampleLesson.questions
    
    init() {
        _currentQuestion = State(initialValue: sampleLesson.questions.first!)
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        audioEngine = AVAudioEngine()
    }

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Tutor Animation
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 150, height: 150)
                        .shadow(color: .blue, radius: 10, x: 0, y: 5)
                    
                    Text("🐶") // Replace with an animated SpriteKit character if desired
                        .font(.system(size: 80))
                        .scaleEffect(showFeedback ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0), value: showFeedback)
                }
                .padding(.top, 20)

                // Question Text
                Text(currentQuestion.text)
                    .font(.custom("SF Pro", size: 28))
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)

                // Answer Options
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(currentQuestion.options, id: \.self) { option in
                        Button(action: {
                            checkAnswer(selectedAnswer: option)
                        }) {
                            Text(option)
                                .font(.custom("SF Pro", size: 24))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    selectedAnswer == option ?
                                    (feedbackMessage == "Correct!" ? Color.green : Color.red) :
                                    Color.blue.opacity(0.7)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                                .scaleEffect(selectedAnswer == option ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: selectedAnswer)
                        }
                    }
                }
                .padding(.horizontal, 20)

                // Feedback Message
                if showFeedback {
                    Text(feedbackMessage)
                        .font(.custom("SF Pro", size: 24))
                        .foregroundColor(feedbackMessage == "Correct!" ? .green : .red)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer()
            }
            .padding()
        }
        .onAppear {
            narrateQuestion()
        }
        .navigationTitle("Tutor")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func checkAnswer(selectedAnswer: String) {
        self.selectedAnswer = selectedAnswer
        if selectedAnswer == currentQuestion.correctAnswer {
            feedbackMessage = "Correct!"
            playSystemSound(soundID: 1020) // Success sound
            animateAnimal(action: "jump")
        } else {
            feedbackMessage = "Wrong, try again!"
            playSystemSound(soundID: 1021) // Error sound
            animateAnimal(action: "shake")
        }
        showFeedback = true
        narrateFeedback()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            moveToNextQuestion()
        }
    }

    private func moveToNextQuestion() {
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
            currentQuestion = questions[currentQuestionIndex]
            selectedAnswer = nil
            feedbackMessage = ""
            showFeedback = false
            narrateQuestion()
        } else {
            feedbackMessage = "You've completed the quiz!"
            showFeedback = true
        }
    }

    private func narrateQuestion() {
        let utterance = AVSpeechUtterance(string: currentQuestion.text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }

    private func narrateFeedback() {
        let utterance = AVSpeechUtterance(string: feedbackMessage)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }

    private func animateAnimal(action: String) {
        guard let scene = scene else { return }
        let animal = scene.children.first as! SKSpriteNode
        
        if action == "jump" {
            let jumpUp = SKAction.moveBy(x: 0, y: 50, duration: 0.2)
            let jumpDown = SKAction.moveBy(x: 0, y: -50, duration: 0.2)
            animal.run(SKAction.sequence([jumpUp, jumpDown]))
        } else if action == "shake" {
            let shakeLeft = SKAction.moveBy(x: -10, y: 0, duration: 0.1)
            let shakeRight = SKAction.moveBy(x: 10, y: 0, duration: 0.1)
            animal.run(SKAction.sequence([shakeLeft, shakeRight, shakeLeft, shakeRight]))
        }
    }

    private func playSystemSound(soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
}
