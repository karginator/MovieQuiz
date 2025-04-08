//
//  ResultAlertPresenter.swift
//  MovieQuiz
//
//  Created by Maksim Kargin on 14.03.2025.
//

import UIKit

final class ResultAlertPresenter: AlertPresenterProtocol {
    
    // MARK: - Delegate
    weak var delegate: AlertPresenterDelegate?
    
    // MARK: - Public Methods
    func createAlert(create resultAlert: AlertModel?) {
        guard let resultAlert else { return }
        
        let alert = UIAlertController(
            title: resultAlert.title,
            message: resultAlert.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: resultAlert.buttonText, style: .cancel) { _ in
            resultAlert.complition()
        }
        
        alert.addAction(action)
        
        alert.view.accessibilityIdentifier = "Game results"
        
        delegate?.alertPresenter(present: alert)
    }
}
