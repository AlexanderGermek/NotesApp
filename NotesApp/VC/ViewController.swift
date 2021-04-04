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

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.autocapitalizationType = .none
        
        notes = loadNotes()
        
        let def = UserDefaults.standard
        let first = def.bool(forKey: "firstLaunch")
        
        if !first { createFirstNote() }
        
        searchNotes = notes

    
        let button = plusButton(frame: CGRect(x: view.frame.width - 70, y: view.frame.height - 70, width: 50, height: 50))
                
        button.addTarget(self, action: #selector(plusButton_AddNewNote), for: .touchUpInside)
        view.addSubview(button)
                
        searchBar.setImage(UIImage(), for: .clear, state: .normal)
        
    }
    
    //MARK: Actions -------------------------------------------------------------------------------------------------------------------
    //Добавить новую заметку
    @objc func plusButton_AddNewNote() {
        
        if let vc = storyboard?.instantiateViewController(identifier: "NoteVC") as? NoteViewController {
            
            vc.notesViewController = self
            self.detailViewController = vc
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //Удалить заметку
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
    //Получить ячейку для удаления
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
    //Строку с датой из даты
    func getDateStringFrom(date: Date)  -> String {
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "dd.MM.YY HH:mm"
        dayTimePeriodFormatter.locale = Locale(identifier: "ru_RU")
        
        return dayTimePeriodFormatter.string(from: date)
    }
    
    //Создание первой заметки при первом запуске пользователем
    func createFirstNote() {
        
        let note = Note(context: managedContext)
        note.title = "First Note"
        note.body  = "Test note body"
        note.date = Date()
        
        notes.append(note)
        
        UserDefaults.standard.setValue(true, forKey: "firstLaunch")
        collectionView.reloadData()
    }
    
    //Открыть контроллер для создания новой заметки
    @objc func createNewNote() {
        
        if let vc = storyboard?.instantiateViewController(identifier: "NoteVC") as? NoteViewController {
            
            vc.notesViewController = self
            self.detailViewController = vc
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //Открыть заметку для правки
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
    
    //Установка фильтра по ячейкам
    func searchNotesWithText(text: String) {
        
        if text == "" {
            searchNotes = notes
        } else {
            searchNotes = notes.filter{ $0.title!.contains(text) || $0.body!.contains(text) || getDateStringFrom(date: $0.date!).contains(text) }
        }
        
        collectionView.reloadData()
    }
    
    
    //MARK: UICollectionViewDataSource ------------------------------------------------------------------------------------------------
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchNotes.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCell", for: indexPath) as? NoteCell else {
            fatalError("Unable to dequeue NoteCell!")
        }
        
        let note = searchNotes[indexPath.item]
        
        cell.setupNoteCell()
        
        cell.titleLabel.text = note.title
        cell.bodyLabel.text  = note.body
        cell.dateLabel.text  = getDateStringFrom(date: note.date!)
        
        return cell
    }
    
    //MARK: UISearchBarDelegate
    //1. Настройка показа кнопки Cancel:
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(true, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: true)
        //navigationController?.hidesBarsOnTap = true
    }
    //2.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchNotesWithText(text: searchBar.text!)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnTap = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchNotesWithText(text: searchText)
    }
}

