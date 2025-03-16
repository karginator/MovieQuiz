//
//  File.swift
//  MovieQuiz
//
//  Created by Maksim Kargin on 11.03.2025.
//

import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
    
    // MARK: - Delegate
    weak var delegate: QuestionFactoryDelegate?
    
    // MARK: - Private Properties
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "The Dark Knight",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "Kill Bill",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "The Avengers",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "Deadpool",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "The Green Knight",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: true),
        QuizQuestion(image: "Old",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: false),
        QuizQuestion(image: "Tesla",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: false),
        QuizQuestion(image: "Vivarium",
                     text: "Рейтинг этого фильма больше чем 6?",
                     correctAnswer: false),
        
    ]
    
    // MARK: - Public Methods
    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            return
        }
        
        let question =  questions[safe: index]
        delegate?.didReceiveNextQuestion(question: question)
    }
    
//    func setDelegate(delegate: QuestionFactoryDelegate) {
//        self.delegate = delegate
//    }
}
