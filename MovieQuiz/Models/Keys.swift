//
//  Keys.swift
//  MovieQuiz
//
//  Created by Maksim Kargin on 18.03.2025.
//

import UIKit

private let storage: UserDefaults = .standard

enum Keys: String {
    case gamesCount
    case correctBestGame
    case totalBestGame
    case dateBestGame
    case totalCorrectAnswers
    case totalQuestion
    case recordGame
}

func cleanStore() {
    storage.removeObject(forKey: Keys.gamesCount.rawValue)
    storage.removeObject(forKey: Keys.correctBestGame.rawValue)
    storage.removeObject(forKey: Keys.totalBestGame.rawValue)
    storage.removeObject(forKey: Keys.dateBestGame.rawValue)
    storage.removeObject(forKey: Keys.totalCorrectAnswers.rawValue)
    storage.removeObject(forKey: Keys.totalQuestion.rawValue)
    storage.removeObject(forKey: Keys.recordGame.rawValue)
}
