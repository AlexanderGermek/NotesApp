//
//  ViewController.swift
//  NotesApp
//
//  Created by iMac on 18.03.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDataSource & UICollectionViewDelegate, UISearchBarDelegate {
    
    var detailViewController: NoteViewController!
    var notes: [Note]!
    var searchNotes: [Note]!
    
    private var dimmedView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.alpha = 0.4
        view.backgroundColor = .black
        return view
    }()

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - Override -----------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load notes and create first note
        notes = loadNotes()
        
        let def = UserDefaults.standard
        let first = def.bool(forKey: "firstLaunch")
        
        if !first { createFirstNote() }
        
        searchNotes = notes
                
        //search bar:
        searchBar.autocapitalizationType = .none
        searchBar.setImage(UIImage(), for: .clear, state: .normal)
        
        // button to add new notes:
        let button = plusButton(frame: CGRect(x: view.frame.width - 70, y: view.frame.height - 70, width: 50, height: 50))
        button.addTarget(self, action: #selector(plusButton_AddNewNote), for: .touchUpInside)
        view.addSubview(button)
        
        // dimmed view:
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapDimmedView))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        dimmedView.addGestureRecognizer(gesture)
        view.addSubview(dimmedView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dimmedView.frame = collectionView.frame
    }
    
    
    //MARK: - Actions ------------------------------------------------------------------
    //Add new note:
    @objc func plusButton_AddNewNote() {
        
        if let vc = storyboard?.instantiateViewController(identifier: "NoteVC") as? NoteViewController {
            vc.notesViewController = self
            self.detailViewController = vc
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //Delete note:
    @IBAction func deleteNote(_ sender: UIButton) {
        
        guard let noteCell = getNoteCellFrom(deleteButton: sender) as? NoteCell else { return }
        
        if let indexPath = collectionView.indexPath(for: noteCell) {
        
            let note = searchNotes[indexPath.item]
            
            managedContext.delete(note)
            searchNotes.remove(at: indexPath.item)
            
            if let index = notes.firstIndex(of: note) {
                notes.remove(at: index)
            }
            
            collectionView.reloadData()
            saveNotes(notes: notes)
        }
    }
    //Get cell when delete note button tapped:
    func getNoteCellFrom(deleteButton: UIView) -> UICollectionViewCell? {
        
        if  deleteButton.superview == nil {
            return nil
        }
        
        let flag = deleteButton.superview?.isKind(of: NoteCell.self)
        
        if flag == false {
            return getNoteCellFrom(deleteButton: deleteButton.superview!)
        } else {
            return deleteButton.superview as? NoteCell
        }
        
    }
    
    //Hide dimmed view when tapped
    @objc func didTapDimmedView() {
        searchBarCancelButtonClicked(searchBar)
    }
    
    
    //MARK: - Functions ------------------------------------------------------------------
    //Get String from Date:
    func getDateStringFrom(date: Date)  -> String {
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "dd.MM.YY HH:mm"
        dayTimePeriodFormatter.locale = Locale(identifier: "ru_RU")
        
        return dayTimePeriodFormatter.string(from: date)
    }
    
    //Create first Test note if app launch first time:
    func createFirstNote() {
        
        let note = Note(context: managedContext)
        note.title = "First Note"
        note.body  = "Test note body"
        note.date = Date()
        
        notes.append(note)
        
        UserDefaults.standard.setValue(true, forKey: "firstLaunch")
        collectionView.reloadData()
    }
    
    //Open NoteViewController for creation new note:
    @objc func createNewNote() {
        
        if let vc = storyboard?.instantiateViewController(identifier: "NoteVC") as? NoteViewController {
            
            vc.notesViewController = self
            self.detailViewController = vc
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //Open note for edit:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? NoteViewController {
            
            if let cell = sender as? NoteCell {
                
                if let indexPath = collectionView.indexPath(for: cell) {
                    
                    vc.notesViewController = self
                    self.detailViewController = vc
                    vc.note = searchNotes[indexPath.item]
                }
            }
        }
    }
    
    
    //MARK: - UICollectionViewDataSource ----------------------------------------------------
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchNotes.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCell", for: indexPath) as! NoteCell
        
        let note = searchNotes[indexPath.item]
        
        cell.setupNoteCell()
    
        
        cell.titleLabel.text = note.title
        cell.bodyLabel.text  = note.body
        cell.dateLabel.text  = getDateStringFrom(date: note.date!)
        
        if note.reminderDate != nil {
            let currentDate = Date()
            
            if currentDate > note.reminderDate! {
                note.reminderDate = nil
            } else {
                cell.reminderButton.isHidden = false
            }
        }
        
        return cell
    }
    
    
    //MARK: - UISearchBarDelegate ------------------------------------------------------------
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        dimmedView.isHidden = false
        
        UIView.animate(withDuration: 0.2) {
            searchBar.setShowsCancelButton(true, animated: true)
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.dimmedView.alpha = 0.4
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        UIView.animate(withDuration: 0.2) {
            self.dimmedView.alpha = 0
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.resignFirstResponder()

            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.hidesBarsOnTap = false
            
        } completion: { isDone in
            
            if isDone {
                self.dimmedView.isHidden = true
                searchBar.text = ""
                self.searchNotesWithText(text: searchBar.text!)
            }
        }
        


    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchNotesWithText(text: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        
        
        UIView.animate(withDuration: 0.2) {
            self.dimmedView.alpha = 0
        } completion: { (isDone) in
            
            if isDone { self.dimmedView.isHidden = true}
        }
    }
    
    //Search:
    func searchNotesWithText(text: String) {
        
        if text == "" {
            searchNotes = notes
        } else {
            searchNotes = notes.filter{ $0.title!.contains(text) || $0.body!.contains(text) || getDateStringFrom(date: $0.date!).contains(text) }
        }
        
        collectionView.reloadData()
    }
}

