//
//  RYRiffCreateDeckViewController.swift
//  Ryff
//
//  Created by Christopher Laganiere on 10/5/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

import UIKit

class RYRiffCreateDeckViewController: UIViewController {

    @IBOutlet weak var activeTrackWaveformView: FDWaveformView!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activeTrackWaveformView.backgroundColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let post = RYAudioDeckManager.sharedInstance()?.currentlyPlayingPost() {
            let postURL = RYDataManager.urlForTempRiff(post.riffHQURL)
            if (NSFileManager.defaultManager().fileExistsAtPath(postURL.path!)) {
                activeTrackWaveformView.audioURL = postURL
                activeTrackWaveformView.doesAllowScrubbing = true
                self.styleFromRiffEngine()
            }
        }
    }
    
    func styleFromRiffEngine() {
//        if (riffEngine.recording) {
//            recordButton.tintColor = RYStyleSheet.postActionColor()
//        } else {
//            recordButton.tintColor = RYStyleSheet.availableActionColor()
//        }
    }
    
    // MARK: Actions
    
    
    @IBAction func recordButtonHit(sender: AnyObject) {
//        riffEngine.recordActive()
        self.styleFromRiffEngine()
    }
    // MARK: Media
    
    func skipToPosition(position: CGFloat) {
//        riffEngine.activeTrack?.skipToPosition(position)
    }
    
    // MARK: RiffEngineDeckDelegate
    
    func activeTrackProgressChanged() {
//        if let progress = riffEngine.activeTrack?.position() {
//            let progressSamples = UInt(progress*CGFloat(activeTrackWaveformView.totalSamples))
//            activeTrackWaveformView.progressSamples = progressSamples
//        }
    }
    
    func activeTrackChanged() {
        
    }
    
    func controlsChanged() {
        
    }
}
