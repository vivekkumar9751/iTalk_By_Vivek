import SwiftUI
import AVFoundation

class GestureHistory: ObservableObject {
    @Published var records: [String] = []
}

struct GestureLearningView: View {
    @State private var drawingPath = Path()
    @State private var drawnPoints: [CGPoint] = []
    @State private var currentPoint: CGPoint? = nil
    @State private var isCompleted = false
    @State private var feedbackText = "Let's draw a triangle!"
    @State private var showAnimation = false
    @State private var animalBounce = false
    @State private var showParticles = false
    private let speechSynthesizer = AVSpeechSynthesizer()
    @EnvironmentObject var gestureHistory: GestureHistory
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Animated animal character
                Image(systemName: "hare.fill") // Replace with an actual animal image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.yellow)
                    .offset(y: animalBounce ? -10 : 0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animalBounce)
                    .onAppear {
                        animalBounce = true
                        speak(feedbackText)
                    }
                
                Text(feedbackText)
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .scaleEffect(showAnimation ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.5), value: showAnimation)
                
                ZStack {
                    // Faint guide shape (triangle)
                    TriangleShape()
                        .stroke(Color.gray, lineWidth: 3)
                        .frame(width: 200, height: 200)
                        .opacity(0.3)
                    
                    // User's drawing path
                    Canvas { context, size in
                        context.stroke(drawingPath, with: .color(.blue), lineWidth: 5)
                    }
                    .frame(width: 200, height: 200)
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if let lastPoint = currentPoint {
                                drawingPath.addLine(to: value.location)
                                drawnPoints.append(value.location)
                            } else {
                                drawingPath.move(to: value.location)
                                drawnPoints = [value.location]
                                speak(randomEncouragement())
                            }
                            currentPoint = value.location
                        }
                        .onEnded { _ in
                            checkDrawing()
                            currentPoint = nil
                        }
                )
                
                if isCompleted {
                    Button("Draw Again") {
                        drawingPath = Path()
                        drawnPoints = []
                        isCompleted = false
                        feedbackText = "Let's draw something new!"
                        speak(feedbackText)
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                }
                
                if showParticles {
                    Image(systemName: "sparkles")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.yellow)
                        .transition(.scale)
                        .animation(.easeOut(duration: 0.5), value: showParticles)
                }
                
                Spacer()
            }
        }
    }
    
    private func checkDrawing() {
        let similarity = compareDrawingToShape()
        if similarity > 0.7 {
            feedbackText = "Wow! That looks like a triangle! 🎉"
            showParticles = true
            speak(feedbackText)
        } else if similarity > 0.4 {
            feedbackText = "That’s close! Keep practicing!"
            speak(feedbackText)
        } else {
            feedbackText = "Hmm, that looks different. Want to try again?"
            speak(feedbackText)
        }
        showAnimation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showAnimation = false
            showParticles = false
        }
        isCompleted = true
        gestureHistory.records.append("Toddler completed a drawing!")
    }
    
    private func compareDrawingToShape() -> Double {
        let trianglePoints: [CGPoint] = [
            CGPoint(x: 100, y: 0), CGPoint(x: 0, y: 200), CGPoint(x: 200, y: 200)
        ]
        
        let matchingPoints = drawnPoints.filter { point in
            trianglePoints.contains { refPoint in
                abs(point.x - refPoint.x) < 30 && abs(point.y - refPoint.y) < 30
            }
        }
        
        return Double(matchingPoints.count) / Double(trianglePoints.count)
    }
    
    private func speak(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
    
    private func randomEncouragement() -> String {
        let messages = [
            "Great job! Keep going!",
            "You're doing amazing!",
            "Almost there! Try again!",
            "Wow, that’s looking great!"
        ]
        return messages.randomElement() ?? "Keep going!"
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct GestureStatsView: View {
    @EnvironmentObject var gestureHistory: GestureHistory
    
    var body: some View {
        List {
            Section(header: Text("Gesture Records")) {
                ForEach(gestureHistory.records, id: \.self) { record in
                    Text(record)
                }
            }
        }
        .navigationTitle("Gesture Learning Stats")
    }
}
