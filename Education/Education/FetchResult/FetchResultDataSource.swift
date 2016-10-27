//
//  FetchResultDataSource.swift
//  KidTaxiLib
//
//  Created by Nguyen Van Dung on 9/30/16.
//  Copyright © 2016 Dht. All rights reserved.
//

import Foundation
import CoreData

public typealias TableViewCellConfigureBlock = (AnyObject?, AnyObject?) -> ()
public typealias MonitoringNumberRowChangeBlock = (Int)->()
public class FetchResultDataSource: NSObject, NSFetchedResultsControllerDelegate, UITableViewDataSource {
    var fetchedResultController: NSFetchedResultsController?
    weak var tableView: UITableView?
    var cellIdentifier: String = "__empty"
    var configureCellBlock: TableViewCellConfigureBlock?
    public var rowChangeMonitoring: MonitoringNumberRowChangeBlock?
    public override init() {
        super.init()
    }
    
    deinit {
        self.fetchedResultController?.delegate = nil
    }
    
    public convenience init(aTableview: UITableView, aCelIdentifier: String, aConfigureCellBlock: TableViewCellConfigureBlock) {
        self.init()
        self.tableView = aTableview
        self.cellIdentifier = aCelIdentifier
        self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "__empty")
    }
    
    public func setupFetchResultController(context: NSManagedObjectContext, entityName: String, predict: NSPredicate?, fetchBatchSize: Int = 20, sortDescriptions: [NSSortDescriptor]) {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = fetchBatchSize
        fetchRequest.predicate = predict
        fetchRequest.sortDescriptors = sortDescriptions
        let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedController.delegate = self
        fetchedResultController = fetchedController
    }
    
    public func fetch() {
        do {
            try self.fetchedResultController?.performFetch()
        } catch {
        }
        self.tableView?.reloadData()
    }
    
    public func itemAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        return self.fetchedResultController?.objectAtIndexPath(indexPath)
    }
    
    //MARK FetchResult Delegate
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
            if let idxPath = newIndexPath {
                if idxPath != indexPath {
                    self.tableView?.insertRowsAtIndexPaths([idxPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }
            break;
        case NSFetchedResultsChangeType.Delete:
            if let idxPath = indexPath {
                self.tableView?.deleteRowsAtIndexPaths([idxPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            break;
        case NSFetchedResultsChangeType.Move:
            if let idxPath = indexPath {
                self.tableView?.deleteRowsAtIndexPaths([idxPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            if let idxPath = newIndexPath {
                self.tableView?.insertRowsAtIndexPaths([idxPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            break;
        case NSFetchedResultsChangeType.Update:
            //update cell
            if let idxPath = indexPath {
                configureCellBlock?(self.tableView?.cellForRowAtIndexPath(idxPath), idxPath)
            }
            break
        }
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
            self.tableView?.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case NSFetchedResultsChangeType.Delete:
            self.tableView?.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        default:
            break
        }
    }
    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView?.beginUpdates()
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView?.endUpdates()
    }
    
    
    ///MARK: UITableView DataSource
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let sectionCount =  self.fetchedResultController?.sections?.count ?? 0
        return sectionCount
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = (self.fetchedResultController?.sections?[section].numberOfObjects ?? 0)
        rowChangeMonitoring?(numberOfRows)
        return numberOfRows
    }
    
    public func tableView(atableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = atableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if let aCell = cell {
            if let info = self.fetchedResultController?.objectAtIndexPath(indexPath) {
                configureCellBlock?(aCell, info)
            }
            return aCell
        }
        return atableView.dequeueReusableCellWithIdentifier("__empty")!
    }
}
