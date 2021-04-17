//
//  PlusButton.swift
//  NotesApp
//
//  Created by iMac on 03.04.2021.
//

import UIKit

class plusButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    func setupButton() {
        
        setShadow()
        
        backgroundColor = .orange
        
        titleLabel?.font = UIFont.systemFont(ofSize: 30)
        setTitle("+", for: .normal)
        setTitleColor(.white, for: .normal)
        
        layer.cornerRadius = frame.width / 2.0
        //layer.borderWidth    = 3.0
        //layer.borderColor    = UIColor.darkGray.cgColor
        
        setTitleColor(.systemOrange, for: .highlighted)
    }
    
    private func setShadow() {
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOffset  = CGSize(width: 0.0, height: 6.0)
        layer.shadowRadius  = 8
        layer.shadowOpacity = 0.5
        clipsToBounds       = true
        layer.masksToBounds = false
    }
}
