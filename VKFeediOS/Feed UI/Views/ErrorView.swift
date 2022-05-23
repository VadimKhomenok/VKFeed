//
//  ErrorView.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 23.05.22.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet var label: UILabel!
    
    public var message: String? {
        get { return isVisible ? label.text : .none }
        set { setMessageAnimated(newValue) }
    }
    
    private var isVisible: Bool {
        return self.alpha == 1
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        label.text = nil
        alpha = 0
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        label.text = message
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    private func hideMessageAnimated() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        } completion: { isFinished in
            if isFinished { self.label.text = nil }
        }
    }
}
