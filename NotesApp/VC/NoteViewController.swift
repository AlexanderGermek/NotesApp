//
//  NoteViewController.swift
//  NotesApp
//
//  Created by iMac on 18.03.2021.
//

import UIKit

class NoteViewController: UIViewController {
    
    @IBOutlet weak var noteTitleLabel: UITextField!
    @IBOutlet weak var noteBodyTextView: UITextView!
    
    weak var notesViewController: ViewController!
    var note: Note!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNote))

        if note != nil {
            title = note.title
            noteTitleLabel.text   = note.title
            noteBodyTextView.text = note.body
        }
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

    }
    
    //MARK: Functions ------------------------------------------------------------------------------------------------------------
    //чтобы клавиатура была ниже вводимого текста:
    @objc func adjustForKeyboard(notification: Notification) {
        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame   = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            noteBodyTextView.contentInset = .zero
        } else {
            noteBodyTextView.contentInset = UIEdgeInsets(top: 0,
                                                         left: 0,
                                                       bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom,
                                                       right: 0)
        }
        
        noteBodyTextView.scrollIndicatorInsets = noteBodyTextView.contentInset
        
        let selectedRange = noteBodyTextView.selectedRange
        noteBodyTextView.scrollRangeToVisible(selectedRange)
    }
    
    @objc func saveNote() {
        
        let title = noteTitleLabel.text ?? ""
        let body  = noteBodyTextView.text ?? ""
        
        if note == nil {
            note = Note(context: managedContext)
            notesViewController.notes.insert(note, at: 0)
            notesViewController.searchNotes.insert(note, at: 0)
        }
        
        note.title = title
        note.body  = body
        note.date  = Date()
        
        saveNotes(notes: notesViewController.notes)
        
        notesViewController.collectionView.reloadData()
        navigationController?.popViewController(animated: true)
        
        
    }
}
