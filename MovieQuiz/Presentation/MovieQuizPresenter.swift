//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Maksim Kargin on 11.04.2025.
//

import UIKit

final class MovieQuizPresenter {
    
    // MARK: - Public Properties
    let questionsAmount: Int = 10
    var correctAnswers = 0 //---
    var currentQuestion: QuizQuestion?
    var statisticService: StatisticServiceProtocol? //---
    var questionFactory: QuestionFactoryProtocol? //---
    weak var viewController: MovieQuizViewController?
    
    // MARK: - Private Properties
    private let storage: UserDefaults = .standard //---
    private var currentQuestionIndex = 0
    
    // MARK: - Public Methods
    func isLastQuestion() -> Bool { currentQuestionIndex == questionsAmount - 1 }
    
    func resetQuestionIndex() { currentQuestionIndex = 0 }
    
    func switchToNextQuestion() { currentQuestionIndex += 1 }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            guard let statisticService else { return }
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            let countQuiz = storage.integer(forKey: Keys.gamesCount.rawValue)
            
            let text = """
                    Ваш результат: \(correctAnswers)/\(self.questionsAmount)
                    Количество сыгранных квизов: \(countQuiz)
                    Рекорд: \(statisticService.bestGame.correct)/\(self.questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                    """
            
            viewController?.show(quiz: QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"))
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Private Methods
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
