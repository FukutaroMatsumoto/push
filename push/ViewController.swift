//
//  ViewController.swift
//  push
//
//  Created by 松本 福太郎 on 2019/02/27.
//  Copyright © 2019 松本 福太郎. All rights reserved.
//

import UIKit
import MediaPlayer
import UserNotifications

class ViewController: UIViewController {
  
    @IBOutlet weak var MyTextField: UITextField!
    
    
    var count = 0
    var isAcceptable = false
    
    @IBAction func onBottunTap(_ sender: Any) {
//       stopListeningVolumeButton()
        count += 1
        MyTextField.text="\(count)"
        startListeningVolumeButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.viewController = self
//        startListeningVolumeButton()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
  
    var volumeView : MPVolumeView!
    var initialVolume : Float = 0.1
    
    func setVolume(_ volume: Float) {
        (volumeView.subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(initialVolume, animated: false)
    }
    func stopListeningVolumeButton() {
         if(!isAcceptable){return}
        // 出力音量の監視を終了
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
        // ボリュームビューを破棄
        volumeView.removeFromSuperview()
        volumeView = nil
        isAcceptable = false
    }
    
    func startListeningVolumeButton() {
        if(isAcceptable){return}
        
        // MPVolumeViewを画面の外側に追い出して見えないようにする
        let frame = CGRect(x: -100, y: -100, width: 100, height: 100)
        volumeView = MPVolumeView(frame: frame)
        volumeView.sizeToFit()
        view.addSubview(volumeView)
        isAcceptable = true
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            // AVAudioSessionの出力音量を取得して、最大音量と無音に振り切れないように初期音量を設定する
            let vol = audioSession.outputVolume
            initialVolume = Float(vol.description)!
            if initialVolume > 0.9 {
                initialVolume = 0.9
            } else if initialVolume < 0.1 {
                initialVolume = 0.1
            }
            setVolume(initialVolume)
            // 出力音量の監視を開始
            audioSession.addObserver(self, forKeyPath: "outputVolume", options: .new, context: nil)
        } catch {
            print("Could not observer outputVolume ", error)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            let newVolume = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).floatValue
            // 出力音量が上がったか下がったかによって処理を分岐する
            if initialVolume > newVolume {
                
                count -= 1
                MyTextField.text="\(count)"
                // ボリュームが下がった時の処理をここに記述
//                initialVolume = newVolume
                // ボリュームが０になってしまうと以降のボリューム（ー）操作を検知できないので、０より大きい適当に小さい値に設定する
//                if initialVolume < 0.1 {
//                    initialVolume = 0.1
//                }
            } else if initialVolume < newVolume {
                
                count += 1
                MyTextField.text="\(count)"
                // ボリュームが上がった時の処理をここに記述
//                initialVolume = newVolume
                // startListeningVolumeButton()
                // ボリュームが１になってしまうと以降のボリューム（＋）操作を検知できないので、１より小さい適当に大きい値に設定する
//                if initialVolume > 0.9 {
//                    initialVolume = 0.9
//                }
            }
            // 一旦出力音量の監視をやめて出力音量を設定してから出力音量の監視を再開する
            AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
            setVolume(initialVolume)
            AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: .new, context: nil)
        }
    }
    
//    @IBAction func countstart(_ sender: Any) {
//        startListeningVolumeButton()
//    }
//
    

}

