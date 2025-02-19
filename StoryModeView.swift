import SwiftUI

struct StoryModeView: View {
    @StateObject private var storyManager = StoryManager()
    @State private var dragOffset = CGSize.zero // For gesture handling

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Story Image (if available)
                if let imageName = storyManager.currentNode.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 250, maxHeight: 250)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }

                // Story Text
                Text(storyManager.currentNode.text)
                    .font(.custom("SF Pro", size: 24))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)

                // Choice Buttons
                VStack(spacing: 15) {
                    ForEach(storyManager.currentNode.choices, id: \.nextNodeID) { choice in
                        Button(action: {
                            storyManager.selectChoice(choice)
                        }) {
                            Text(choice.text)
                                .font(.custom("SF Pro", size: 20))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { _ in
                    if dragOffset.width > 100 {
                        storyManager.advanceToNextNode() // Move forward
                    } else if dragOffset.width < -100 {
                        storyManager.goToPreviousNode() // Move backward
                    }
                    dragOffset = .zero
                }
        )
        .onAppear {
            storyManager.speakText(storyManager.currentNode.text) // Narrate story
        }
    }
}

//class StoryManager: ObservableObject {
//    @Published var currentNode: StoryNode = StoryNode.sample
//
//    // Navigate to the next story node based on the user's choice
//    func selectChoice(_ choice: StoryChoice) {
//        // Logic to navigate to the next node
//        print("Selected choice: \(choice.text)")
//    }
//
//    // Advance to the next story node
//    func advanceToNextNode() {
//        // Logic to move forward in the story
//        print("Advanced to the next node")
//    }
//
//    // Go back to the previous story node
//    func goToPreviousNode() {
//        // Logic to move backward in the story
//        print("Went back to the previous node")
//    }
//
//    // Narrate the story text
//    func speakText(_ text: String) {
//        print("Narrating: \(text)")
//        // Add text-to-speech logic here
//    }
//}

struct StoryNode: Identifiable {
    let id: UUID
    let text: String
    let imageName: String?
    let choices: [StoryChoice]

    // A sample story node
    static let sample = StoryNode(
        id: UUID(),
        text: "Welcome to the Story! Choose your adventure below.",
        imageName: nil,
        choices: [
            StoryChoice(text: "Begin the journey", nextNodeID: UUID()),
            StoryChoice(text: "Explore the forest", nextNodeID: UUID())
        ]
    )
}

struct StoryChoice {
    let text: String
    let nextNodeID: UUID
}
