//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Maksim Kargin on 13.03.2025.
//

import UIKit

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
