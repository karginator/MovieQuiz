//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Maksim Kargin on 14.04.2025.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func zeroBorderWidth()
    
    func isEnabledButton(isTrue: Bool)
}
