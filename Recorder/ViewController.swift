//
//  ViewController.swift
//  Recorder
//
//  Created by LC on 2018/5/6.
//  Copyright © 2018年 LC. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var recordBut: UIButton!
    @IBOutlet weak var recordsTable: UITableView!
    
    //录音开始/停止标志
    var isRecording = false
    //播放开始/停止标志
    var isPlaying = false
    //上一个播放的录音
    var lastPlay = IndexPath(item: 0, section: 2)
    
    //录音器设置
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    var filePath = ""
    
    //录音音频数组
    var recordsResults: Array<Recorder> = []
    
    //执行数据库操作实例
    let executeData = Record()
    //id
    var randomId = 0
    //路径
    var recordPath = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupTable()
        setupRecorder()
        setRandomPath()
        
    }
    
    //随机生成一个Document下的path，随机数同时作为id
    func setRandomPath(){
        let temp = Int(arc4random()%100000)+1
        randomId = temp
        recordPath = "/record\(String(temp)).wav"
        filePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending(recordPath))!
    }
    
    func setupRecorder() {
        let session = AVAudioSession.sharedInstance()
        //设置session类型
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let err{
            print("设置类型失败:\(err.localizedDescription)")
        }
        //设置session动作
        do {
            try session.setActive(true)
        } catch let err {
            print("初始化动作失败:\(err.localizedDescription)")
        }
    }
    
    //点击按钮，开始录音与停止录音
    @IBAction func startRecording(_ sender: UIButton) {
        if !isRecording {
            recordBut.setBackgroundImage(UIImage(named: "no_microphone"), for: .normal)
            
            //录音设置，需要转换成NSNumber，否则无法录制音频文件
            let recordSetting: [String: Any] = [AVSampleRateKey: NSNumber(value: 16000),//采样率
                AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),//音频格式
                AVLinearPCMBitDepthKey: NSNumber(value: 16),//采样位数
                AVNumberOfChannelsKey: NSNumber(value: 1),//通道数
                AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.min.rawValue)//录音质量
            ];
            
            //开始录音
            do {
                let url = URL(fileURLWithPath: filePath)
                recorder = try AVAudioRecorder(url: url, settings: recordSetting)
                recorder!.prepareToRecord()
                recorder!.record()
                isRecording = true
                print("开始录音")
            } catch let err {
                print("录音失败:\(err.localizedDescription)")
            }
        }
        else {
            //停止录音
            if let recorder = self.recorder {
                if recorder.isRecording {
                    print("正在录音，马上结束它，文件保存到了：\(filePath)")
                }else {
                    print("没有录音，但是依然结束它")
                }
                recorder.stop()
                self.recorder = nil
            }else {
                print("没有初始化")
            }
            //选择是否保存录音
            let alertController = UIAlertController(title: "是否保存录音",
                                                    message: "", preferredStyle: .alert)
            alertController.addTextField {
                (textField: UITextField!) -> Void in
                textField.placeholder = "录音名称"
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "保存", style: .default, handler: {
                action in
                let name = alertController.textFields!.first!.text!
                self.executeData.insertData(id: self.randomId, name: name, path: self.recordPath)
                
                //成功保存后重载数据
                self.recordsResults = self.executeData.queryData()
                self.recordsTable.reloadData()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            isRecording = false
            recordBut.setBackgroundImage(UIImage(named: "microphone"), for: .normal)
            
        }
        
    }
    
}















