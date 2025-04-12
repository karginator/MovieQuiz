import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var correctAnswers = 0
    private let storage: UserDefaults = .standard
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    private var presenter = MovieQuizPresenter()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        showLoadingIndicator()
        questionFactory?.loadData()
        
        presenter.viewController = self
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        show(quiz: viewModel)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - AlertPresenterDelegate
    func alertPresenter(present alert: UIAlertController?) {
        guard let alert else { return }
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - didLoadDataFromServer
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - didFailToLoadData
    func didFailToLoadData(with error: Error) {
        showNetworkError(massage: error.localizedDescription)
    }
    
    // MARK: - Prublic Methods
    func showAnswerResult(isCorrect: Bool) {
        self.noButton.isUserInteractionEnabled = false
        self.yesButton.isUserInteractionEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        if isCorrect {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.noButton.isUserInteractionEnabled = true
            self.yesButton.isUserInteractionEnabled = true
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
        }
    }
    
    // MARK: - Private Methods
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            guard let statisticService else {
                return
            }
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let countQuiz = storage.integer(forKey: Keys.gamesCount.rawValue)
            
            let text = """
                    Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                    Количество сыгранных квизов: \(countQuiz)
                    Рекорд: \(statisticService.bestGame.correct)/\(presenter.questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                    """
            
            show(quiz: QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"))
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        
        let complition = { [weak self] in
            guard let self else { return }
            presenter.resetQuestionIndex()
            correctAnswers = 0
            questionFactory?.requestNextQuestion()
        }
        
        let alert = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            complition: complition)
        
        let alertPresenter = ResultAlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        alertPresenter.createAlert(create: alert)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(massage: String) {
        hideLoadingIndicator()
        
        let complition = { [weak self] in
            guard let self else { return }
            presenter.resetQuestionIndex()
            correctAnswers = 0
            questionFactory?.requestNextQuestion()
            questionFactory?.loadData()
        }
        
        let alert = AlertModel(
            title: "Ошибка",
            message: massage,
            buttonText: "Попробуй еще раз",
            complition: complition)
        
        let alertPresenter = ResultAlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        alertPresenter.createAlert(create: alert)
    }
}
