//
//  NoteCell.swift
//  NotesApp
//
//  Created by iMac on 18.03.2021.
//

import UIKit

class NoteCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reminderButton: UIButton!
    
    func setupNoteCell() {
        //Apply rounded corners
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        
        // Set masks to bounds to false to avoid the shadow
        // from being clipped to the corner radius
        layer.cornerRadius = 5.0
        layer.masksToBounds = false
        
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOffset  = CGSize(width: 0.0, height: 6.0)
        layer.shadowRadius  = 8
        layer.shadowOpacity = 0.5
        clipsToBounds       = true
        layer.masksToBounds = false
        
        layer.borderWidth    = 2.0
        layer.borderColor    = UIColor.darkGray.cgColor
        
        bodyLabel.lineBreakMode = .byWordWrapping // notice the 'b' instead of 'B'
        bodyLabel.numberOfLines = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.reminderButton.isHidden = true
    }


    
}
