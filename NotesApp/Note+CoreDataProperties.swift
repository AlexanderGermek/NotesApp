//
//  Note+CoreDataProperties.swift
//  NotesApp
//
//  Created by iMac on 06.04.2021.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var body: String?
    @NSManaged public var date: Date?
    @NSManaged public var title: String?
    @NSManaged public var reminderDate: Date?

}

extension Note : Identifiable {

}
