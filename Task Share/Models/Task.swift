//
//  Task.swift
//  Task Share
//
//  Created by Isabela S Cardoso on 09/03/26.
//

import Foundation

struct Task: Codable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
}
