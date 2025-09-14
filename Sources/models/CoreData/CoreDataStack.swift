//
//  CoreDataStack.swift
//  TaskWarriorStickies
//
//  Created by GitHub Copilot on 2025-01-13.
//

import Foundation
import CoreData

@MainActor
class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let model = createManagedObjectModel()
        let container = NSPersistentContainer(name: "TaskWarriorStickies", managedObjectModel: model)
        
        container.persistentStoreDescriptions = [createPersistentStoreDescription()]
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error.localizedDescription)")
            }
        }
        
        return container
    }()
    
    private func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // Create Sticky entity
        let stickyEntity = NSEntityDescription()
        stickyEntity.name = "StickyEntity"
        stickyEntity.managedObjectClassName = NSStringFromClass(StickyEntity.self)
        
        // Attributes
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false
        
        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.attributeType = .stringAttributeType
        titleAttribute.isOptional = false
        
        let positionXAttribute = NSAttributeDescription()
        positionXAttribute.name = "positionX"
        positionXAttribute.attributeType = .doubleAttributeType
        positionXAttribute.isOptional = false
        
        let positionYAttribute = NSAttributeDescription()
        positionYAttribute.name = "positionY"
        positionYAttribute.attributeType = .doubleAttributeType
        positionYAttribute.isOptional = false
        
        let widthAttribute = NSAttributeDescription()
        widthAttribute.name = "width"
        widthAttribute.attributeType = .doubleAttributeType
        widthAttribute.isOptional = false
        
        let heightAttribute = NSAttributeDescription()
        heightAttribute.name = "height"
        heightAttribute.attributeType = .doubleAttributeType
        heightAttribute.isOptional = false
        
        let transparencyAttribute = NSAttributeDescription()
        transparencyAttribute.name = "transparency"
        transparencyAttribute.attributeType = .doubleAttributeType
        transparencyAttribute.isOptional = false
        
        let alwaysOnTopAttribute = NSAttributeDescription()
        alwaysOnTopAttribute.name = "alwaysOnTop"
        alwaysOnTopAttribute.attributeType = .booleanAttributeType
        alwaysOnTopAttribute.isOptional = false
        
        let filterAttribute = NSAttributeDescription()
        filterAttribute.name = "filter"
        filterAttribute.attributeType = .stringAttributeType
        filterAttribute.isOptional = true
        
        let sortByAttribute = NSAttributeDescription()
        sortByAttribute.name = "sortBy"
        sortByAttribute.attributeType = .stringAttributeType
        sortByAttribute.isOptional = true
        
        let sortOrderAttribute = NSAttributeDescription()
        sortOrderAttribute.name = "sortOrder"
        sortOrderAttribute.attributeType = .stringAttributeType
        sortOrderAttribute.isOptional = true
        
        let visibleColumnsAttribute = NSAttributeDescription()
        visibleColumnsAttribute.name = "visibleColumns"
        visibleColumnsAttribute.attributeType = .transformableAttributeType
        visibleColumnsAttribute.isOptional = false
        visibleColumnsAttribute.valueTransformerName = "NSSecureUnarchiveFromDataTransformer"
        
        stickyEntity.properties = [
            idAttribute, titleAttribute, positionXAttribute, positionYAttribute,
            widthAttribute, heightAttribute, transparencyAttribute, alwaysOnTopAttribute,
            filterAttribute, sortByAttribute, sortOrderAttribute, visibleColumnsAttribute
        ]
        
        model.entities = [stickyEntity]
        return model
    }
    
    private func createPersistentStoreDescription() -> NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription()
        description.url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("TaskWarriorStickies.sqlite")
        return description
    }
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
