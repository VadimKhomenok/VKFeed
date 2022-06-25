//
//  ErrorView.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 23.05.22.
//

import UIKit

public final class ErrorView: UIButton {
    
    public var message: String? {
        get { return isVisible ? title(for: .normal) : .none }
        set { setMessageAnimated(newValue) }
    }
    
    private var isVisible: Bool {
        return self.alpha == 1
    }
    
    public var onHide: (() -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        hideMessage()
    }
    
    private func configure() {
        backgroundColor = .errorBackgroundColor
        
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
        configureTitleLabel()
        hideMessage()
    }
    
    private func configureTitleLabel() {
        titleLabel?.textColor = .white
        titleLabel?.font = .systemFont(ofSize: 17)
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 0
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        setTitle(message, for: .normal)
        contentEdgeInsets = .init(top: 4, left: 8, bottom: 4, right: 8)
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    @objc private func hideMessageAnimated() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        } completion: { isFinished in
            if isFinished { self.hideMessage() }
        }
    }
    
    private func hideMessage() {
        setTitle(nil, for: .normal)
        alpha = 0
        contentEdgeInsets = .init(top: -6.5, left: 0, bottom: -6.5, right: 0)
        onHide?()
    }
}

extension UIColor {
    static var errorBackgroundColor: UIColor {
        UIColor(red: 0.99951404330000004, green: 0.41759261489999999, blue: 0.4154433012, alpha: 1)
    }
}
