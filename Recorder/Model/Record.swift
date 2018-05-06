//
//  Record.swift
//  Recorder
//
//  Created by mac on 2018/5/6.
//  Copyright © 2018年 mac. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Record {
    
    func queryData() -> Array<Recorder>{
        //获取总代理和托管对象总管
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        //建立一个获取的请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recorder")
        
        //查询操作
        do {
            
            let fetchedObjects = try context.fetch(fetchRequest) as! [Recorder]
            return fetchedObjects
            
            
        } catch  {
            let nserror = error as NSError
            fatalError("查询错误： \(nserror), \(nserror.userInfo)")
            
        }
        
        return []
    }
    
    func insertData(id: Int, name: String, path: String) {
        //获取总代理和托管对象总管
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObectContext = appDelegate.persistentContainer.viewContext
        
        //建立一个entity
        let entity = NSEntityDescription.entity(forEntityName: "Recorder", in: managedObectContext)
        let record = NSManagedObject(entity: entity!, insertInto: managedObectContext)
        
        //获取当前日期并转换成字符串
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let customDate = dateFormatter.string(from: now)
        
        record.setValue(name, forKey: "name")
        record.setValue(id, forKey: "id")
        record.setValue(path, forKey: "path")
        record.setValue(customDate, forKey: "date")
        
        //保存entity到托管对象中。如果保存失败，进行处理
        do {
            try managedObectContext.save()
        } catch  {
            fatalError("无法保存")
        }
        
    }
    
    //删除数据
    func deleteData(id: Int) -> Bool{
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let entityName = "Recorder"
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        fetchRequest.entity = entity
        
        do {
            
            let fetchedObjects = try context.fetch(fetchRequest) as! [Recorder]
            for one: Recorder in fetchedObjects {
                if one.id == id {
                    //删除Document下对应文件及数据库中存储的路径
                    let fileManager = FileManager.default
                    let filePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending(one.path!))!
                    if fileManager.fileExists(atPath: filePath) {
                        try fileManager.removeItem(atPath: filePath)
                        context.delete(one)
                        app.saveContext()
                        return true
                    }
                    
                }
            }
            
        } catch  {
            let nserror = error as NSError
            fatalError("查询错误： \(nserror), \(nserror.userInfo)")
        }
        
        return false
        
    }
}
