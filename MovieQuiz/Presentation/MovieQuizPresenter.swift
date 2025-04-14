//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Maksim Kargin on 11.04.2025.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
        
    // MARK: - Private Properties
    private let storage: UserDefaults = .standard
    private let questionsAmount: Int = 10
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol!
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    // MARK: - Initializers
    init(viewController: MovieQuizViewControllerProtocol) {
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
        viewController?.showNetworkError(message: message)
    }
    
    // MARK: - Public Methods
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func makeResultsMessage() -> String {
        guard let statisticService else { return "" }
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let countQuiz = storage.integer(forKey: Keys.gamesCount.rawValue)
        let text = """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(countQuiz)
                Рекорд: \(statisticService.bestGame.correct)/\(questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """
        return text
    }
    
    func repeatLoadData() {
        questionFactory?.loadData()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // MARK: - Private Methods
    private func isLastQuestion() -> Bool { currentQuestionIndex == questionsAmount - 1 }
    
    private func switchToNextQuestion() { currentQuestionIndex += 1 }
    
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            viewController?.show(quiz: QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "",
                buttonText: "Сыграть ещё раз"))
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func didAnswer(idCorrectAnswer: Bool) {
        if idCorrectAnswer { correctAnswers += 1 }
    }
    
    private func proceedAnswerResult(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.isEnabledButton(isTrue: false)
        
        didAnswer(idCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            viewController?.isEnabledButton(isTrue: true)
            viewController?.zeroBorderWidth()
            proceedToNextQuestionOrResults()
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        let givenAnswer = isYes
        proceedAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
