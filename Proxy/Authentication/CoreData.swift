//
//  CoreData.swift
//  Proxy
//
//  Created by Kevin Alinazar on 2026-02-08.
//

import CoreData

extension AppViewModel {

    // MARK: - Save Map Filter to Core Data

    func saveMapFilter(_ filterRawValue: String) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "UserSettings")

        do {
            let results = try viewContext.fetch(request)
            let settings = results.first ?? NSEntityDescription.insertNewObject(
                forEntityName: "UserSettings",
                into: viewContext
            )
            settings.setValue(filterRawValue, forKey: "mapFilter")
            try viewContext.save()
        } catch {
            print("CoreData save error: \(error)")
        }
    }

    // MARK: - Load Map Filter from Core Data

    func loadMapFilter() -> String? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "UserSettings")

        do {
            let results = try viewContext.fetch(request)
            return results.first?.value(forKey: "mapFilter") as? String
        } catch {
            print("CoreData fetch error: \(error)")
            return nil
        }
    }
}
