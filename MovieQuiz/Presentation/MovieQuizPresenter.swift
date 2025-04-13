//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Maksim Kargin on 11.04.2025.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Public Properties
    let questionsAmount: Int = 10
    var correctAnswers = 0
    var currentQuestion: QuizQuestion?
    
    // MARK: - Private Properties
    private let storage: UserDefaults = .standard
    private var currentQuestionIndex = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    private weak var viewController: MovieQuizViewController?
    
    // MARK: - Initializers
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // MARK: - didLoadDataFromServer
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - didFailToLoadData
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(massage: message)
    }
    
    // MARK: - Public Methods
    func isLastQuestion() -> Bool { currentQuestionIndex == questionsAmount - 1 }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
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
    
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            viewController?.show(quiz: QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "",
                buttonText: "Сыграть ещё раз"))
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didAnswer(idCorrectAnswer: Bool) {
        if idCorrectAnswer { correctAnswers += 1 }
    }
    
    func makeResultsMessage() -> String {
        guard let statisticService else { return "" }
        statisticService.store(correct: self.correctAnswers, total: self.questionsAmount)
        let countQuiz = storage.integer(forKey: Keys.gamesCount.rawValue)
        let text = """
                Ваш результат: \(self.correctAnswers)/\(self.questionsAmount)
                Количество сыгранных квизов: \(countQuiz)
                Рекорд: \(statisticService.bestGame.correct)/\(self.questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """
        return text
    }
    
    func showAnswerResult(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.isEnabledButton(isTrue: false)
        
        didAnswer(idCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            viewController?.isEnabledButton(isTrue: true)
            viewController?.zeroBorderWidth()
            self.proceedToNextQuestionOrResults()
        }
    }
    
    // MARK: - Private Methods
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        let givenAnswer = isYes
        viewController?.proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
