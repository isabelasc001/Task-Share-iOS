//
//  CoreDataManager.swift
//  Task Share
//
//  Created by Antigravity on 26/03/26.
//

import CoreData
import UIKit

// MARK: - Core Data Manager

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    var viewContext: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to access AppDelegate")
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Save
    
    func save() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Core Data save error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Create List
    
    func createList(from list: List) {
        let context = viewContext
        
        let listEntity = ListEntity(context: context)
        listEntity.id = list.id
        listEntity.title = list.title
        listEntity.date = list.date
        listEntity.categoryRaw = list.category.rawValue
        listEntity.isFavorite = list.isFavorite
        listEntity.isArchived = list.isArchived
        
        for task in list.tasks {
            let taskEntity = TaskEntity(context: context)
            taskEntity.id = task.id
            taskEntity.title = task.title
            taskEntity.isCompleted = task.isCompleted
            taskEntity.list = listEntity
        }
        
        // ChangeRecord — create
        createChangeRecord(changeType: "create", targetID: list.id, targetType: "list", snapshot: nil)
        
        save()
    }
    
    // MARK: - Read Lists
    
    func fetchAllLists(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [List] {
        let request: NSFetchRequest<ListEntity> = ListEntity.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors ?? [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { $0.toList() }
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    func fetchActiveLists() -> [List] {
        let predicate = NSPredicate(format: "isArchived == NO")
        return fetchAllLists(predicate: predicate)
    }
    
    func fetchFavoriteLists() -> [List] {
        let predicate = NSPredicate(format: "isArchived == NO AND isFavorite == YES")
        return fetchAllLists(predicate: predicate)
    }
    
    func fetchArchivedLists() -> [List] {
        let predicate = NSPredicate(format: "isArchived == YES")
        return fetchAllLists(predicate: predicate)
    }
    
    func searchLists(searchText: String) -> [List] {
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR categoryRaw CONTAINS[cd] %@", searchText, searchText)
        return fetchAllLists(predicate: predicate)
    }
    
    // MARK: - Update List
    
    func updateList(with updatedList: List) {
        let context = viewContext
        
        guard let listEntity = fetchListEntity(by: updatedList.id) else {
            print("List not found for update: \(updatedList.id)")
            return
        }
        
        // Snapshot the old state before modifying
        let oldSnapshot = listEntity.toList()
        createChangeRecord(changeType: "update", targetID: updatedList.id, targetType: "list", snapshot: oldSnapshot)
        
        // Apply new values
        listEntity.title = updatedList.title
        listEntity.categoryRaw = updatedList.category.rawValue
        listEntity.isFavorite = updatedList.isFavorite
        listEntity.isArchived = updatedList.isArchived
        
        // Re-sync tasks: delete all existing, re-insert from updated list
        if let existingTasks = listEntity.tasks as? Set<TaskEntity> {
            for task in existingTasks {
                context.delete(task)
            }
        }
        
        for task in updatedList.tasks {
            let taskEntity = TaskEntity(context: context)
            taskEntity.id = task.id
            taskEntity.title = task.title
            taskEntity.isCompleted = task.isCompleted
            taskEntity.list = listEntity
        }
        
        save()
    }
    
    // MARK: - Delete List
    
    func deleteList(by id: UUID) {
        let context = viewContext
        
        guard let listEntity = fetchListEntity(by: id) else {
            print("List not found for deletion: \(id)")
            return
        }
        
        // Snapshot the state before deleting
        let oldSnapshot = listEntity.toList()
        createChangeRecord(changeType: "delete", targetID: id, targetType: "list", snapshot: oldSnapshot)
        
        // Cascade deletes child TaskEntity objects automatically
        context.delete(listEntity)
        
        save()
    }
    
    // MARK: - Archive / Unarchive
    
    func toggleArchive(for id: UUID) {
        guard let listEntity = fetchListEntity(by: id) else {
            print("List not found for archive toggle: \(id)")
            return
        }
        
        // Snapshot old state
        let oldSnapshot = listEntity.toList()
        createChangeRecord(changeType: "update", targetID: id, targetType: "list", snapshot: oldSnapshot)
        
        listEntity.isArchived = !listEntity.isArchived
        
        save()
    }
    
    // MARK: - Private Helpers
    
    private func fetchListEntity(by id: UUID) -> ListEntity? {
        let request: NSFetchRequest<ListEntity> = ListEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Fetch entity error: \(error)")
            return nil
        }
    }
    
    private func createChangeRecord(changeType: String, targetID: UUID, targetType: String, snapshot: List?) {
        let context = viewContext
        let record = ChangeRecordEntity(context: context)
        record.id = UUID()
        record.timestamp = Date()
        record.changeType = changeType
        record.targetID = targetID
        record.targetType = targetType
        
        if let snapshot = snapshot {
            record.snapshot = try? JSONEncoder().encode(snapshot)
        }
    }
}

// MARK: - ListEntity → List Mapping

extension ListEntity {
    func toList() -> List {
        let taskArray: [Task] = (tasks as? Set<TaskEntity>)?.map { taskEntity in
            Task(
                id: taskEntity.id ?? UUID(),
                title: taskEntity.title ?? "",
                isCompleted: taskEntity.isCompleted
            )
        } ?? []
        
        let category = Category(rawValue: categoryRaw ?? "Other") ?? .other
        
        return List(
            id: id ?? UUID(),
            title: title ?? "",
            date: date ?? Date(),
            category: category,
            tasks: taskArray,
            isFavorite: isFavorite,
            isArchived: isArchived
        )
    }
}
