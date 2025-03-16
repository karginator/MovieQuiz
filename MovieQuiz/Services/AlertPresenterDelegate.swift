//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Maksim Kargin on 15.03.2025.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func alertPresenter(present alert: UIAlertController?)
}
