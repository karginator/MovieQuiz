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
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    // MARK: - Initializers
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    // MARK: - Public Methods
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizesImageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let correctAnswer: Bool
            let arrayMoreOrLessForQuestion = ["больше", "меньше"]
            let arrayRatingForQuestion: [Float] = [8, 9]
            
            let randomMoreOrLessForQuestion = arrayMoreOrLessForQuestion.randomElement() ?? ""
            let randomRatingForQuestion = arrayRatingForQuestion.randomElement() ?? 0
            
            let text = "Рейтинг этого фильма \(randomMoreOrLessForQuestion) чем \(Int(randomRatingForQuestion))?"
            correctAnswer = randomMoreOrLessForQuestion == "больше" ? rating > randomRatingForQuestion : rating < randomRatingForQuestion
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func setDelegate(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
}
