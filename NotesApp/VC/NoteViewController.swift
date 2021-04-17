//
//  NoteViewController.swift
//  NotesApp
//
//  Created by iMac on 18.03.2021.
//

import UIKit

class NoteViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var noteTitleLabel: UITextField!
    @IBOutlet weak var noteBodyTextView: UITextView!
    @IBOutlet weak var remindBarButton: UIBarButtonItem!
    
    
    weak var notesViewController: ViewController!
    var note: Note!
    
    var datePickerContainer = UIView()
    let datePicker = UIDatePicker()
    var reminderDateForNote: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.rightBarButtonItems?.insert(UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNote)), at: 0)

        if note != nil {
            title = note.title
            noteTitleLabel.text   = note.title
            noteBodyTextView.text = note.body
            
            if note.reminderDate != nil {
                remindBarButton.image = UIImage(systemName: "bell.fill")
                datePicker.date = note.reminderDate!
                reminderDateForNote = note.reminderDate!
            }
        }
        
        //Для подстройки клавиатуры textView:
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        //Гесчур для отображения/cкрытия клавиатуры:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showKeyboard))
        noteBodyTextView.addGestureRecognizer(tapGesture)
        
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
        note.reminderDate = reminderDateForNote
        
        saveNotes(notes: notesViewController.notes)
        
        notesViewController.searchNotesWithText(text: notesViewController.searchBar.text!)
        navigationController?.popViewController(animated: true)
    }
    
    //отобразить или скрыть клавиатуру:
    @objc func showKeyboard(tap: UITapGestureRecognizer) {
        datePickerContainer.removeFromSuperview()
        
        if noteBodyTextView.isFirstResponder {
            noteBodyTextView.resignFirstResponder()
        } else {
            noteBodyTextView.becomeFirstResponder()
        }
    }
    
    //MARK: - Actions --------------------------------------------------------------
    @IBAction func addReminderForNote(_ sender: Any) {
        noteBodyTextView.resignFirstResponder()
        createdatePicker()
    }
    
    func createdatePicker() {
        
        datePickerContainer.frame = CGRect(x: 0, y: view.frame.height - 250, width: self.view.frame.width, height: 250)
        datePickerContainer.backgroundColor = UIColor.white
        
        let btnWidth = CGFloat(150)
        let doneButton = UIButton()
        doneButton.setTitle("Установить", for: .normal)
        doneButton.setTitleColor(UIColor.systemBlue, for: .normal)
        doneButton.addTarget(self, action: #selector(setReminderDate), for: .touchUpInside)
        doneButton.frame = CGRect(x: datePickerContainer.frame.width - btnWidth, y: 5, width: btnWidth, height: 40)
        datePickerContainer.addSubview(doneButton)
        
        let cancelButton = UIButton()
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(UIColor.systemBlue, for: .normal)
        cancelButton.addTarget(self, action: #selector(setReminderDate), for: .touchUpInside)
        cancelButton.frame = CGRect(x: 0, y: 5, width: btnWidth, height: 40)
        datePickerContainer.addSubview(cancelButton)
        
        
        datePicker.frame = CGRect(x: 0, y: 40.0, width: self.view.frame.width, height: 200)
        datePicker.datePickerMode = .dateAndTime
        //datePicker.backgroundColor = UIColor.yellow
        datePicker.preferredDatePickerStyle = .wheels

        datePickerContainer.addSubview(datePicker)
        
        self.view.addSubview(datePickerContainer)
        
    }
    
    @objc func setReminderDate(sender: UIButton) {
        
        
        let title = sender.title(for: .normal)!
        
        if title == "Установить" {
            
            reminderDateForNote = datePicker.date
            remindBarButton.image = UIImage(systemName: "bell.fill")
            
        } else if title == "Отменить" {
            
            reminderDateForNote = nil
            remindBarButton.image = UIImage(systemName: "bell")
        }
        
        datePickerContainer.removeFromSuperview()
        
        registerNotification()
        
        
    }
    
    func registerNotification() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) {(granted, error) in
            if granted {
                DispatchQueue.main.async {
                    self.scheduleLocal()
                }
            } else {
                return
            }
        }
    }

    @objc func scheduleLocal() {
        
        let center = UNUserNotificationCenter.current()

        //center.removeAllPendingNotificationRequests() // убрать блок по времени
        
        let content = UNMutableNotificationContent()
        content.title = "NoteApp send you message!"
        content.body  = "Your Local Notification activated!"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["reminderDate" : self.datePicker.date as Any]


        content.sound = UNNotificationSound.default
        
        //Календарный триггер:
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: datePicker.date )
  
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
//        // ИНтервальный триггер:
//        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
//
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
//
        registerCategories()
    }

    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        //let button1 = UNNotificationAction(identifier: "button1", title: "Открыть приложение", options: .foreground) // button
        let button2 = UNNotificationAction(identifier: "button2", title: "Открыть Заметку", options: .foreground) // button
        let category = UNNotificationCategory(identifier: "alarm", actions: [button2], intentIdentifiers: [])// group of buttons
        
        center.setNotificationCategories([category])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["reminderDate"] as? Date {
            
            switch response.actionIdentifier {
            
            case UNNotificationDefaultActionIdentifier:
                print("Default identifier")
                
            case "button1":
                print("Открыть приложение")
            case "button2":

                openNote(date: customData)

            default:
                break
            }
        }
        
        completionHandler()
    }
    
    func openNote(date: Date) {
        
        guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
            return
        }
        
        let notesVC = storyboard?.instantiateViewController(withIdentifier: "NotesVC") as! ViewController
        if  let navController = rootViewController as? UINavigationController {
            
            navController.viewControllers.insert(notesVC, at: 0)
            
            let noteVC = storyboard?.instantiateViewController(withIdentifier: "NoteVC") as! NoteViewController
            let notes = loadNotes()
            let openNote = notes.filter{ $0.reminderDate == date}.first
            openNote?.reminderDate = nil
            noteVC.note = openNote
            notesVC.notes = notes
            saveNotes(notes: notes)
            navController.viewControllers.insert(noteVC, at: 1)
            
            navController.popViewController(animated: true)
            
        }
        
    }

}


