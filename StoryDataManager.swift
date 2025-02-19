//
//  File.swift
//  iTalk
//
//  Created by Vivek kumar on 06/02/25.
//

import Foundation
import AVFoundation
import Speech

class StoryManager: ObservableObject {
    @Published var currentNode: StoryNode
    @Published var storyHistory: [String] = []
    private var storyNodes: [UUID: StoryNode]
    private var nodeHistory: [StoryNode] = [] // Stack to track navigation history
    private var synthesizer = AVSpeechSynthesizer()
    private let speechRecognizer = SFSpeechRecognizer()
    
    init() {
        // Unique IDs for nodes
        let startNodeID = UUID()
        let exploreNodeID = UUID()
        let ignoreNodeID = UUID()
        let treasureRoomNodeID = UUID()
        let trapRoomNodeID = UUID()
        let wizardNodeID = UUID()
        let fleeNodeID = UUID()
        let riddleNodeID = UUID()
        let rewardNodeID = UUID()
        
        // Story Nodes
        let rewardNode = StoryNode(
            id: rewardNodeID,
            text: "The rabbit solves the riddle and is rewarded with a magical carrot!",
            imageName: "magic_carrot",
            choices: []
        )

        let riddleNode = StoryNode(
            id: riddleNodeID,
            text: "The wizard presents a riddle: 'What has keys but can't open locks?'",
            imageName: "wizard_riddle",
            choices: [
                StoryChoice(text: "Answer: A piano", nextNodeID: rewardNodeID),
                StoryChoice(text: "Run away", nextNodeID: fleeNodeID)
            ]
        )

        let fleeNode = StoryNode(
            id: fleeNodeID,
            text: "The rabbit gets scared and runs away, ending the adventure early.",
            imageName: "rabbit_run",
            choices: []
        )

        let wizardNode = StoryNode(
            id: wizardNodeID,
            text: "The rabbit meets a kind wizard who offers a magical riddle challenge.",
            imageName: "wizard",
            choices: [
                StoryChoice(text: "Accept the challenge", nextNodeID: riddleNodeID),
                StoryChoice(text: "Politely decline", nextNodeID: fleeNodeID)
            ]
        )

        let trapRoomNode = StoryNode(
            id: trapRoomNodeID,
            text: "The rabbit enters a dark room and narrowly avoids a trap! It escapes back to safety.",
            imageName: "trap",
            choices: []
        )

        let treasureRoomNode = StoryNode(
            id: treasureRoomNodeID,
            text: "The rabbit discovers a treasure chest filled with golden carrots!",
            imageName: "treasure",
            choices: [
                StoryChoice(text: "Take some treasure", nextNodeID: wizardNodeID),
                StoryChoice(text: "Leave it untouched", nextNodeID: ignoreNodeID)
            ]
        )

        let exploreNode = StoryNode(
            id: exploreNodeID,
            text: "The rabbit bravely steps inside and finds two paths: one leading to a bright room and another to a dark hallway.",
            imageName: "path_choices",
            choices: [
                StoryChoice(text: "Enter the bright room", nextNodeID: treasureRoomNodeID),
                StoryChoice(text: "Explore the dark hallway", nextNodeID: trapRoomNodeID)
            ]
        )

        let ignoreNode = StoryNode(
            id: ignoreNodeID,
            text: "The rabbit hops away, missing an adventure.",
            imageName: "rabbit_hop",
            choices: []
        )

        let startNode = StoryNode(
            id: startNodeID,
            text: "Once upon a time, a rabbit found a magical door. What should it do?",
            imageName: "rabbit",
            choices: [
                StoryChoice(text: "Go inside", nextNodeID: exploreNodeID),
                StoryChoice(text: "Ignore it", nextNodeID: ignoreNodeID)
            ]
        )

        // Build story nodes dictionary
        storyNodes = [
            startNodeID: startNode,
            exploreNodeID: exploreNode,
            ignoreNodeID: ignoreNode,
            treasureRoomNodeID: treasureRoomNode,
            trapRoomNodeID: trapRoomNode,
            wizardNodeID: wizardNode,
            fleeNodeID: fleeNode,
            riddleNodeID: riddleNode,
            rewardNodeID: rewardNode
        ]

        currentNode = startNode
        nodeHistory.append(startNode) // Add the initial node to the history
        
        loadProgress()
    }
    
    // Select a choice and move to the next node
    func selectChoice(_ choice: StoryChoice) {
        if let nextNode = storyNodes[choice.nextNodeID] {
            nodeHistory.append(currentNode) // Save the current node to history before navigating
            storyHistory.append("Chose: \(choice.text) → \(nextNode.text)")
            currentNode = nextNode
            speakText(nextNode.text)
            saveProgress()
        }
    }
    
    // Navigate to the next node in the story (if applicable)
    func advanceToNextNode() {
        // Check if the current node has exactly one choice to auto-advance
        if let firstChoice = currentNode.choices.first, currentNode.choices.count == 1 {
            selectChoice(firstChoice)
        } else {
            print("No automatic next node to advance to.")
        }
    }

    // Navigate to the previous node in the story (if possible)
    func goToPreviousNode() {
        guard nodeHistory.count > 1 else {
            print("No previous nodes available.")
            return
        }
        nodeHistory.removeLast() // Remove the current node
        currentNode = nodeHistory.last! // Set the previous node as the current node
        speakText(currentNode.text)
    }
    
    // Narrate the story text
    func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        synthesizer.speak(utterance)
    }

    // Save the user's progress
    func saveProgress() {
        UserDefaults.standard.set(currentNode.id.uuidString, forKey: "currentNodeID")
        UserDefaults.standard.set(storyHistory, forKey: "storyHistory") // Save history
    }
    
    // Load the user's progress
    func loadProgress() {
        if let savedNodeIDString = UserDefaults.standard.string(forKey: "currentNodeID"),
           let savedNodeID = UUID(uuidString: savedNodeIDString),
           let savedNode = storyNodes[savedNodeID] {
            currentNode = savedNode
        }
        
        if let savedHistory = UserDefaults.standard.array(forKey: "storyHistory") as? [String] {
            storyHistory = savedHistory
        }
    }
}
