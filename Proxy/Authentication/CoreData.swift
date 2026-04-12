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
        let request = NSFetchRequest<NSManagedObject>(entityName: "Distance")
        do {
            let results = try viewContext.fetch(request)
            let settings = results.first ?? NSEntityDescription.insertNewObject(
                forEntityName: "Distance",
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
        let request = NSFetchRequest<NSManagedObject>(entityName: "Distance")
        do {
            let results = try viewContext.fetch(request)
            return results.first?.value(forKey: "mapFilter") as? String
        } catch {
            print("CoreData fetch error: \(error)")
            return nil
        }
    }
    // MARK: - Save Landmark Filter to Core Data
    func saveLandmarkFilter(_ filterRawValue: String) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Distance")
        do {
            let results = try viewContext.fetch(request)
            let settings = results.first ?? NSEntityDescription.insertNewObject(
                forEntityName: "Distance",
                into: viewContext
            )
            settings.setValue(filterRawValue, forKey: "landmarkFilter")
            try viewContext.save()
        } catch {
            print("CoreData save error: \(error)")
        }
    }
    // MARK: - Load Landmark Filter from Core Data
    func loadLandmarkFilter() -> String? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Distance")
        do {
            let results = try viewContext.fetch(request)
            return results.first?.value(forKey: "landmarkFilter") as? String
        } catch {
            print("CoreData fetch error: \(error)")
            return nil
        }
    }
}
