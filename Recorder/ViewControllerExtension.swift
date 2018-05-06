//
//  ViewControllerExtension.swift
//  Recorder
//
//  Created by mac on 2018/5/6.
//  Copyright © 2018年 LC. All rights reserved.
//

import UIKit
import AVFoundation

//设置tableView
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTable() {
        recordsResults = Record().queryData()
        recordsTable.delegate = self
        recordsTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordsResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell.init(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = recordsResults[indexPath.row].name
        cell.detailTextLabel?.text = recordsResults[indexPath.row].date
        
        let image = UIImage(named: "play")
        cell.imageView?.image = image
        
        return cell
    }
    
    //选中一行
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)//取消高亮
        
        if !isPlaying {
            do {
                
                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending(recordsResults[indexPath.row].path!)
                player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path!))
                print("歌曲长度：\(player!.duration)")
                //播放录音
                player!.play()
                //调整图片上一个录音的播放图片与当前录音播放图片
                recordsTable.cellForRow(at: indexPath)?.imageView?.image = UIImage(named: "pause")
                if indexPath != IndexPath(item: 0, section: 2) {
                    recordsTable.cellForRow(at: lastPlay)?.imageView?.image = UIImage(named: "play")
                }
                lastPlay = indexPath
                isPlaying = true
                
                //计时以调整图片
                var timeCount = player!.duration
                let codeTimer = DispatchSource.makeTimerSource(queue:DispatchQueue.global())
                // 设定这个时间源是每秒循环一次，立即开始
                codeTimer.schedule(deadline: .now(), repeating: .milliseconds(100))
                // 设定时间源的触发事件
                codeTimer.setEventHandler(handler: {
                    // 每秒计时一次
                    timeCount = timeCount - 0.1
                    
                    // 时间到了取消时间源
                    if timeCount <= 0 || !self.isPlaying {
                        codeTimer.cancel()
                        self.isPlaying = false
                        // 返回主线程处理一些事件，更新UI等等
                        DispatchQueue.main.async {
                            self.recordsTable.cellForRow(at: indexPath)?.imageView?.image = UIImage(named: "play")
                        }
                    }
                })
                // 启动时间源
                codeTimer.resume()
                
            } catch let err {
                print("播放失败:\(err.localizedDescription)")
            }
        }
        else {
            if player!.isPlaying{
                player!.pause()
                player!.stop()
                // 将当前时间设置为0才可以停止
                player!.currentTime = 0
                isPlaying = false
                //调整图片
                recordsTable.cellForRow(at: indexPath)?.imageView?.image = UIImage(named: "play")
                lastPlay = IndexPath(item: 0, section: 2)
            }
        }
    }
    
    
    //允许左滑删除操作
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //设置删除字样
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    //实现左滑删除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            if executeData.deleteData(id: Int(recordsResults[indexPath.row].id)) {
                //刷新tableview
                recordsResults.remove(at: indexPath.row)
                recordsTable.reloadData()
            }
            
        }
    }
    
    
}
