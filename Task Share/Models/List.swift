//
//  Task.swift
//  Task Share
//
//  Created by Isabela S Cardoso on 09/03/26.
//
import UIKit
enum Category: String, CaseIterable, Codable {
    case personal = "Personal"
    case work = "Work"
    case health = "Health"
    case study = "Study"
    case other = "Other"
}

struct List: Codable {
    var id: UUID = UUID()
    var title: String
    var date: Date = Date()
    var category: Category
    var tasks: [Task] = []
    var isFavorite: Bool = false
    var isArchived: Bool = false
    
    var isFullyCompleted: Bool {
        return !tasks.isEmpty && tasks.allSatisfy { $0.isCompleted }
    }
    
    var shouldBeArchived: Bool {
        return isArchived || isFullyCompleted
    }
}
