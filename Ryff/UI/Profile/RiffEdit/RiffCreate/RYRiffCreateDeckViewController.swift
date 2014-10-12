//
//  RYRiffCreateDeckViewController.swift
//  Ryff
//
//  Created by Christopher Laganiere on 10/5/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

import UIKit

class RYRiffCreateDeckViewController: UIViewController, FDWaveFormProgressDelegate, RiffEngineDeckDelegate {

    @IBOutlet weak var activeTrackWaveformView: FDWaveformView!
    weak var riffEngine: RYRiffEngine?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activeTrackWaveformView.backgroundColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let post = RYAudioDeckManager.sharedInstance()?.currentlyPlayingPost() {
            let postURL = RYDataManager.urlForTempRiff(post.riffURL)
            if (NSFileManager.defaultManager().fileExistsAtPath(postURL.path!)) {
                activeTrackWaveformView.audioURL = postURL
                activeTrackWaveformView.doesAllowScrubbing = true
            }
        }
    }
    
    // MARK: FDWaveFormProgressDelegate
    
    func skipToPosition(position: CGFloat) {
        riffEngine?.activeTrack?.skipToPosition(position)
    }
    
    // MARK: RiffEngineDeckDelegate
    
    func activeTrackProgressChanged() {
        if let progress = riffEngine?.activeTrack?.position() {
            let progressSamples:NSNumber = progress*(Int(activeTrackWaveformView.totalSamples) as NSNumber)
            activeTrackWaveformView.progressSamples = progressSamples
        }
    }
    
    func activeTrackChanged() {
        
    }
    
    func controlsChanged() {
        
    }
}
