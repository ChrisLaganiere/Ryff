//
//  RYRiffCreateNodeCollectionViewCell.swift
//  Ryff
//
//  Created by Christopher Laganiere on 8/15/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit

protocol RYRiffMixerNodeCellDelegate: class {
    func clearHitOnNodeCell(nodeCell: RYRiffMixerNodeCollectionViewCell)
}

class RYRiffMixerNodeCollectionViewCell: UICollectionViewCell {
    
    // Active playing elements
    private let deleteImageView = UIImageView(frame: CGRectZero)
    private let resetImageView = UIImageView(frame: CGRectZero)
    private let playImageView = UIImageView(frame: CGRectZero)
    private let highlightView = UIView(frame: CGRectZero)
    
    // Social remixing elements
    private let starredView = RYStarredView(frame: CGRectZero)
    private let postImageView = UIImageView(frame: CGRectZero)
    
    weak var delegate: RYRiffMixerNodeCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        postImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(postImageView)
        
        highlightView.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(highlightView)
        
        deleteImageView.image = UIImage(named: "x")
        deleteImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(deleteImageView)
        
        resetImageView.image = UIImage(named: "reset")
        resetImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(resetImageView)
        
        playImageView.image = UIImage(named: "play")
        playImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(playImageView)
        
        starredView.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(starredView)
        
        NSLayoutConstraint.activateConstraints(subviewConstraints())
    }
    
    @availability(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func styleWithRiffNode(riffNode: RYRiffAudioNode) {
        self.backgroundColor = statusColor(riffNode.status)
        hideElements(riffNode.status)
    }
    
    // MARK: Actions
    
    func didTapClear(tapGesture: UITapGestureRecognizer) {
        delegate?.clearHitOnNodeCell(self)
    }
    
    // MARK: Status-Dependent
    
    /**
    Provides an appropriate background color for this cell based on the provided riff node status.
    
    :param: status RYRIffAudioNodeStatus to style for.
    
    :returns: UIColor appropriate for this status.
    */
    func statusColor(status: RYRiffAudioNodeStatus) -> UIColor {
        switch (status) {
        case .Recording:
            return RYStyleSheet.recordingColor()
        default:
            return RYStyleSheet.audioPadColor()
        }
    }
    
    /**
    Shows or hides subview elements as appropriate for the provided riff node status.
    
    :param: status RYRiffAudioNodeStatus to style for.
    */
    func hideElements(status: RYRiffAudioNodeStatus) {
        let inUse = (status != .Empty)
        starredView.hidden = inUse
        
        let actionsHidden = (status == .Empty)
        deleteImageView.hidden = actionsHidden
        resetImageView.hidden = actionsHidden
        playImageView.hidden = actionsHidden
        
        let notReadyToPlay = (status != .ReadyToPlay && status != .Active)
        highlightView.hidden = notReadyToPlay
    }
    
    // MARK: Layout
    
    func subviewConstraints() -> [NSLayoutConstraint] {
        let viewsDict = ["delete": deleteImageView, "reset": resetImageView, "play": playImageView, "highlight": highlightView, "starred": starredView, "image": postImageView]
        let metrics = ["padding": Constants.Global.ElementPadding, "small": Constants.Mixer.SmallActionDimension, "large": Constants.Mixer.LargeActionDimension]
        
        var constraints: [AnyObject] = []
        
        // Highlight
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[highlight]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[highlight]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        
        // Post Image
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[image]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[image]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        
        // Starred
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[starred]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[starred]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        
        // Actions
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(padding)-[delete(small)]-(>=padding)-[reset(large)]-(>=padding)-[play(small)]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += [NSLayoutConstraint(item: resetImageView, attribute: .CenterX, relatedBy: .Equal, toItem: resetImageView.superview, attribute: .CenterX, multiplier: 1.0, constant: 0.0)]
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[delete(small)]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[reset(large)]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[play(small)]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        
        return constraints as? [NSLayoutConstraint] ?? []
    }
    
}
