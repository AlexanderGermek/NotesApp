//
//  CoreDataFunctions.swift
//  NotesApp
//
//  Created by iMac on 18.03.2021.
//

import CoreData


//MARK: CoreDataFunctions ---------------------------------------------------------------------------------
//1. Save
func saveNotes(notes: [Note]) {
    
    do{
        try managedContext.save()
    } catch let error as NSError{
        fatalError("Couldn't save! \(error), \(error.userInfo)")
    }
}

//2. Load
func loadNotes() -> [Note] {

    var notesArray: [Note] = []

    let fetchRequest = NSFetchRequest<Note>(entityName: "Note")

    do{
        let managedNotes = try managedContext.fetch(fetchRequest)
        
        notesArray.append(contentsOf: managedNotes)
        
        notesArray.sort{$0.date! > $1.date!}

    } catch let error as NSError {
        fatalError("Couldn't fetch. \(error), \(error.userInfo)")
    }

    return notesArray
}

