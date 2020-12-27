//
//  ChatDataProvider.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/12/20.
//

import Foundation
import CoreData

class ChatDataProvider {
    private let persistentContainer: NSPersistentContainer
    private let repository: ChatAPIRepository

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    init(persistentContainer: NSPersistentContainer, repository: ChatAPIRepository) {
        self.persistentContainer = persistentContainer
        self.repository = repository
    }

    func fetchChats(with channelID: String, callBack: @escaping(Error?) -> Void) {
        repository.getChats(with: channelID) { jsonDictionary, error in
            if let error = error { callBack(error); return }

            guard let jsonDictionary = jsonDictionary else { callBack(error); return }

            let taskContext = self.persistentContainer.newBackgroundContext()
            taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            taskContext.undoManager = nil

            self.syncChats(jsonDictionary: jsonDictionary, taskContext: taskContext) ? callBack(nil) : callBack(error)
        }
    }

    private func syncChats(jsonDictionary: [[String: Any]], taskContext: NSManagedObjectContext) -> Bool {
        var successfull = false
        taskContext.performAndWait {
            let matchingChatRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatAPIModel")
            let msgIDs = jsonDictionary.map { $0["mId"] as? String }.compactMap { $0 }
            matchingChatRequest.predicate = NSPredicate(format: "mId in %@", argumentArray: [msgIDs])

            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingChatRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs

            // Execute the request to de batch delete and merge the changes to viewContext, which triggers the UI update
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult

                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                        into: [self.persistentContainer.viewContext])
                }
            } catch {
                print("Error: \(error)\nCould not batch delete existing records.")
                return
            }

            // Create new records.
            for chatDictionary in jsonDictionary {

                guard let chat = NSEntityDescription.insertNewObject(forEntityName: "ChatAPIModel", into: taskContext) as? ChatAPIModel else {
                    print("Error: Failed to create a new Film object!")
                    return
                }

                do {
                    try chat.update(with: chatDictionary)
                } catch {
                    print("Error: \(error)\nThe film object will be deleted.")
                    taskContext.delete(chat)
                }
            }

            // Save all the changes just made and reset the taskContext to free the cache.
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            successfull = true
        }
        return successfull
    }

    func clearCodeData() {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatAPIModel")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch {
            debugPrint("There is an error in deleting records")
        }
    }
}
