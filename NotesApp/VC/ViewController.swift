//
//  ViewController.swift
//  NotesApp
//
//  Created by iMac on 18.03.2021.
//

import UIKit
import CoreData

class ViewController: UICollectionViewController {
    
    var detailViewController: NoteViewController!
    var notes: [Note]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewNote))
        
        notes = loadNotes()
        
        let def = UserDefaults.standard
        let first = def.bool(forKey: "firstLaunch")
        
        if !first { createFirstNote() }
        
    }
    
    //MARK: Actions -------------------------------------------------------------------------------------------------------------------
    @IBAction func deleteNote(_ sender: UIButton) {
        
        guard let noteCell = getNoteCellFrom(deleteButton: sender) as? NoteCell else { return }
        
        if let indexPath = collectionView.indexPath(for: noteCell) {
        
            managedContext.delete(notes[indexPath.item])
            notes.remove(at: indexPath.item)
            collectionView.reloadData()
            saveNotes(notes: notes)
        }
        
    }
    
    func getNoteCellFrom(deleteButton: UIView) -> UICollectionViewCell? {
        
        if  deleteButton.superview == nil{
            return nil
        }
        
        let flag = deleteButton.superview?.isKind(of: NoteCell.self)
        
        if flag == false {
            return getNoteCellFrom(deleteButton: deleteButton.superview!)
        } else {
            return deleteButton.superview as? NoteCell
        }
        
    }
    
    
    //MARK: Functions -----------------------------------------------------------------------------------------------------------------
    func getDateStringFrom(date: Date)  -> String {
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "dd.MM.YY HH:mm"
        dayTimePeriodFormatter.locale = Locale(identifier: "ru_RU")
        
        return dayTimePeriodFormatter.string(from: date)
    }
    
    func createFirstNote() {
        
        let note = Note(context: managedContext)
        note.title = "First Note"
        note.body  = "Test note body"
        note.date = Date()
        
        notes.append(note)
        
        UserDefaults.standard.setValue(true, forKey: "firstLaunch")
        collectionView.reloadData()
    }
    
    @objc func createNewNote() {
        
        if let vc = storyboard?.instantiateViewController(identifier: "NoteVC") as? NoteViewController {
            
            vc.notesViewController = self
            self.detailViewController = vc
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? NoteViewController {
            
            if let cell = sender as? NoteCell {
                
                if let indexPath = collectionView.indexPath(for: cell) {
                    
                    vc.notesViewController = self
                    self.detailViewController = vc
                    vc.note = notes[indexPath.item]
                }
            }
        }
    }
    
    
    //MARK: UICollectionViewController ------------------------------------------------------------------------------------------------
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCell", for: indexPath) as? NoteCell else {
            fatalError("Unable to dequeue NoteCell!")
        }
        
        let note = notes[indexPath.item]
        
        cell.titleLabel.text = note.title
        cell.bodyLabel.text  = note.body
        cell.dateLabel.text  = getDateStringFrom(date: note.date!)
        
        cell.layer.cornerRadius = 7
        
        return cell
    }

}

