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
        get { return label.text }
        set { label.text = newValue }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        label.text = nil
    }
}
