import SwiftUI

struct QuestionListView: View {
    var lesson: Lesson
    @State private var currentQuestionIndex = 0
    @State private var feedbackMessage: String = ""
    @State private var showFeedback = false
    @State private var showOptionsForWrongAnswer = false

    var body: some View {
        VStack {
            if currentQuestionIndex < lesson.questions.count {
                let currentQuestion = lesson.questions[currentQuestionIndex]
                
                Text(currentQuestion.text)
                    .font(.headline)
                    .padding(.bottom, 5)
                
                ForEach(currentQuestion.options, id: \.self) { option in
                    Button(action: {
                        checkAnswer(selectedAnswer: option, correctAnswer: currentQuestion.correctAnswer)
                    }) {
                        Text(option)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.bottom, 5)
                    }
                    .disabled(showFeedback) // Disable buttons after an answer is selected
                }

                if showFeedback {
                    Text(feedbackMessage)
                        .font(.title)
                        .foregroundColor(feedbackMessage == "Correct Answer!" ? .green : .red)
                        .padding()
                        .transition(.opacity)

                    if showOptionsForWrongAnswer {
                        HStack {
                            Button("Try Again") {
                                // Reset the feedback and let the user retry
                                showFeedback = false
                                showOptionsForWrongAnswer = false
                            }
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                            Button("Next") {
                                moveToNextQuestion()
                            }
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.top)
                    }
                }
            } else {
                // All questions answered
                Text("Congratulations! You've completed the lesson.")
                    .font(.headline)
                    .padding()
            }
        }
        .padding()
        .onChange(of: currentQuestionIndex) { _ in
            // Hide feedback when moving to the next question
            showFeedback = false
            showOptionsForWrongAnswer = false
        }
    }

    func checkAnswer(selectedAnswer: String, correctAnswer: String) {
        if selectedAnswer == correctAnswer {
            feedbackMessage = "Correct Answer!"
            showFeedback = true
            
            // Automatically move to the next question after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                moveToNextQuestion()
            }
        } else {
            feedbackMessage = "Incorrect Answer. Try Again or Skip to Next."
            showFeedback = true
            showOptionsForWrongAnswer = true
        }
    }

    func moveToNextQuestion() {
        if currentQuestionIndex < lesson.questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            // Reset feedback if it's the last question
            showFeedback = false
        }
    }
}
