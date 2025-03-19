//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Maksim Kargin on 18.03.2025.
//

import UIKit

final class StatisticService: StatisticServiceProtocol {
    
    // MARK: - storage
    private let storage: UserDefaults = .standard
    
    // MARK: - Public Properties
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            GameResult(correct: storage.integer(forKey: Keys.correctBestGame.rawValue),
                       total: storage.integer(forKey: Keys.totalBestGame.rawValue),
                       date: storage.object(forKey: Keys.dateBestGame.rawValue) as? Date ?? Date())
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correctBestGame.rawValue)
            storage.set(newValue.total, forKey: Keys.totalBestGame.rawValue)
            storage.set(newValue.date, forKey: Keys.dateBestGame.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let totalQuestion = storage.integer(forKey: Keys.totalQuestion.rawValue)
        return Double(totalCorrectAnswers) / (totalQuestion == 0 ? 1 : Double(totalQuestion)) * 100.0
    }
    
    // MARK: - Public Methods
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue) + count
        storage.set(totalCorrectAnswers, forKey: Keys.totalCorrectAnswers.rawValue)
        let totalQuestion = storage.integer(forKey: Keys.totalQuestion.rawValue) + amount
        storage.set(totalQuestion, forKey: Keys.totalQuestion.rawValue)
        
        let game = GameResult(correct: count, total: amount, date: Date())
        if game.isBetterThan(bestGame) {
            bestGame = game
        }
    }
}
