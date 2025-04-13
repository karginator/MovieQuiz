import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private let storage: UserDefaults = .standard
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    private var presenter: MovieQuizPresenter!
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        presenter = MovieQuizPresenter(viewController: self)
        statisticService = StatisticService()
        showLoadingIndicator()
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - AlertPresenterDelegate
    func alertPresenter(present alert: UIAlertController?) {
        guard let alert else { return }
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Prublic Methods
    func showAnswerResult(isCorrect: Bool) {
        self.noButton.isUserInteractionEnabled = false
        self.yesButton.isUserInteractionEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        presenter.didAnswer(idCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.noButton.isUserInteractionEnabled = true
            self.yesButton.isUserInteractionEnabled = true
            self.presenter.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
        }
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        
        guard let statisticService else { return }
        statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        let countQuiz = storage.integer(forKey: Keys.gamesCount.rawValue)
        
        let text = """
                Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)
                Количество сыгранных квизов: \(countQuiz)
                Рекорд: \(statisticService.bestGame.correct)/\(presenter.questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """
        
        let complition = { [weak self] in
            guard let self else { return }
            presenter.restartGame()
        }
        
        let alert = AlertModel(
            title: result.title,
            message: text,
            buttonText: result.buttonText,
            complition: complition)
        
        let alertPresenter = ResultAlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        alertPresenter.createAlert(create: alert)
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }

    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func showNetworkError(massage: String) {
        hideLoadingIndicator()
        
        let complition = { [weak self] in
            guard let self else { return }
            presenter.restartGame()
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
