//
//  File.swift
//  iTalk
//
//  Created by Vivek kumar on 06/02/25.
//

import SwiftUI

// Define the structure for a Question
struct Question: Identifiable {
    var id: Int
    var text: String
    var options: [String]
    var correctAnswer: String
}

// Define the structure for a Lesson
struct Lesson: Identifiable {
    var id: Int
    var title: String
    var questions: [Question]
}

// Sample Data (can be moved to a separate file later)
let sampleQuestions: [Question] = [
    Question(id: 1, text: "What color is the apple?", options: ["Red", "Blue", "Green", "Yellow"], correctAnswer: "Red"),
    Question(id: 2, text: "Which animal says 'Meow'?", options: ["Dog", "Cat", "Cow", "Sheep"], correctAnswer: "Cat"),
    Question(id: 3, text: "What shape is the ball?", options: ["Circle", "Square", "Triangle", "Rectangle"], correctAnswer: "Circle"),
    Question(id: 4, text: "Which fruit is yellow?", options: ["Apple", "Banana", "Orange", "Grape"], correctAnswer: "Banana"),
    Question(id: 5, text: "Which animal lives in water?", options: ["Lion", "Elephant", "Fish", "Monkey"], correctAnswer: "Fish")
]

let sampleLesson = Lesson(id: 1, title: "Basic Toddler Learning", questions: sampleQuestions)
