//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Maksim Kargin on 18.03.2025.
//

import UIKit

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        correct >= another.correct
    }
}
