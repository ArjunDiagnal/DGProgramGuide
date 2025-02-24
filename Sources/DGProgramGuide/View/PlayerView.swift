//
//  File.swift
//  
//
//  Created by Arjun Santhosh on 14/02/25.
//

import UIKit
import AVFoundation

protocol VideoPlayerViewDataSource: AnyObject {
//    var playerModel: PlayerViewModel? {get}
}

protocol VideoPlayerViewDelegate: AnyObject {
    func currentPlayerStatus(status: AVPlayerItem.Status)
    func currentTimeControlStatus(status: AVPlayer.TimeControlStatus)
    func playerBufferFull()
    func playerLikelyToKeepUp()
    func playerBufferEmpty()
    func playerDidFinishPlaying()
    func playerItemFailedToPlay()
    func seekToSuccess(time: Double)
    func errorFromSmilData()
    func updateProgress(time: CMTime)
    func videoPaused()
//    func expandVideoPlayer(media: MediaEntity, pipMode: Bool, isPlaying: Bool)
    func restorePlayUI()
}

extension VideoPlayerViewDelegate {
    func currentPlayerStatus(status: AVPlayerItem.Status) {}
    func currentTimeControlStatus(status: AVPlayer.TimeControlStatus) {}
    func playerBufferFull() {}
    func playerLikelyToKeepUp() {}
    func playerBufferEmpty() {}
    func playerDidFinishPlaying() {}
    func playerItemFailedToPlay() {}
    func seekToSuccess(time: Double) {}
    func errorFromSmilData() {}
    func updateProgress(time: CMTime) {}
}

class PlayerView: UIView {
    weak var dataSource: VideoPlayerViewDataSource?
    weak var delegate: VideoPlayerViewDelegate?
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    private var playerObservers: [NSKeyValueObservation] = []
    var isVideoPaused = false
    var pipClosed = false
    var isResignActivity = false
    var playButton: UIButton?
    var expandButton: UIButton?
    var videoQualityButton: UIButton?
    var languageButton: UIButton?
    var muteButton: UIButton?
    var pipButton: UIButton?
    var fwdSeekButton: UIButton?
    var bwdSeekButton: UIButton?
    var holderView: UIView?
    var liveUIContainer: UIView?
    var circleUI: UIView?
    var circleLayer: CAShapeLayer?
    var externalPlaybackView: UIView?
    var progressBar: UIProgressView?
    var slider: UISlider?
    var liveLabel: UILabel?
    var timeLabel: UILabel?
    var titleLabel: UILabel?
    var seekDuration: CMTime = .zero
    var hasCastActive = false
    var isDetailsPageHidden: Bool = false
    static let assetKeysRequiredToPlay = ["playable"]

    var isSliderDragged = false
    var isPlaybackLive = true
    var progressTimer: Timer?
    /// Faiirplay delegate


    
    /// MARK:- Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func restorePlaybackView() {
        self.externalPlaybackView?.isHidden = true
    }
    
    /// Using AVAsset now runs the risk of blocking the current thread (the main UI thread) whilst I/O happens to populate the properties. It's prudent to defer our work until the properties we need have been loaded.
    
    func getDataAndStartPlayer() {
        addPlayerControls()
        setupPlayer()
    }
    
    
    /// function to reset player
    public func cleanUpPlayer() {
        self.dataSource = nil
        self.delegate = nil
        self.player?.pause()
        self.player = nil
        self.playerLayer = nil
    }
    
    deinit {
        cleanUpPlayer()
        progressTimer?.invalidate()
    }

    
    /// background notification listener
    @objc func playerItemFailedToPlay(_ notification: Notification) {
//        self.pauseVideo()
        delegate?.playerItemFailedToPlay()
    }
    
    private func setupPlayer() {
         guard let url = URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8") else {
             print("Invalid M3U8 URL")
             return
         }

         player = AVPlayer(url: url)
         playerLayer = AVPlayerLayer(player: player)
         playerLayer?.frame = self.bounds
        playerLayer?.videoGravity = .resizeAspectFill

         if let playerLayer = playerLayer {
             layer.addSublayer(playerLayer)
         }

         player?.play()
        self.bringSubviewToFront(holderView ?? UIView())
     }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds // Ensure it resizes with the view
    }

}



extension PlayerView {
    
    @objc func buttonTapped() {
  
    }
    
    @objc func actionMuteButton() {
        
    }
    
    @objc func handleSeekTapped(_ sender: UIButton) {
 
    }
    
    /**
     Function to seek to the sepcified time
     - Parameter :
     - seekTime: New time to which the playback should continue with
     */
    public func seek(to seekTime: CMTime) {
    
    }
    
    /// Handle the tap action for live container view
    @objc func handleViewTap(_ gesture: UITapGestureRecognizer) {
    
    }
    
    @objc func sliderValueChanged(_ slider: UISlider) {
        if isSliderDragged {
            return
        }

    }
    
    /// Action to expand the video to full screen
    @objc func actionExpandButton() {
        
    }
    
    func showViewWithAnimation(autoHide: Bool) {
    
    }
    
    func hideViewWithAnimation() {
  
    }
    
    func addPlayerControls() {
        
        if self.holderView != nil {
            return
        }
        
        // Create a UIView instance
        let holderView = UIView()
        holderView.backgroundColor = .clear
        
        // Disable autoresizing masks translation into constraints
        holderView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the view to the superview
        self.addSubview(holderView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Define constraints for myView's position and size
            holderView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            holderView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            holderView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            holderView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
        self.holderView = holderView
        self.holderView?.isHidden = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
        self.addGestureRecognizer(tapGesture)
        
        // Create a UIView instance
        let externalView = UIView()
        externalView.backgroundColor = .black
        
        // Disable autoresizing masks translation into constraints
        externalView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the view to the superview
        self.addSubview(externalView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Define constraints for myView's position and size
            externalView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            externalView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            externalView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            externalView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
        self.externalPlaybackView = externalView
        self.externalPlaybackView?.isHidden = true
        
        var externalMessageLabel = UILabel()
//        externalMessageLabel.textColor = pageTheme?.getAccentColor(for: .body, colorLevel: .secondary)
        externalMessageLabel.textAlignment = .center
        externalMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.externalPlaybackView?.addSubview(externalMessageLabel)
        if let viewPIP = externalPlaybackView {
            externalMessageLabel.trailingAnchor.constraint(equalTo: viewPIP.trailingAnchor,
                                                           constant: -10).isActive = true
            externalMessageLabel.leadingAnchor.constraint(equalTo: viewPIP.leadingAnchor,
                                                          constant: 10).isActive = true
            externalMessageLabel.centerYAnchor.constraint(equalTo:viewPIP.centerYAnchor).isActive = true
        }
        
        /// Image view to show top shadow
        let topShadowView = UIImageView()
        topShadowView.translatesAutoresizingMaskIntoConstraints = false
        topShadowView.image = UIImage(named: "shadow_down")
        topShadowView.alpha = 0.6
        holderView.addSubview(topShadowView)
        
        /// Image view to show bottom shadow
        let bottomShadowView = UIImageView()
        bottomShadowView.translatesAutoresizingMaskIntoConstraints = false
        bottomShadowView.image = UIImage(named: "shadow")
        bottomShadowView.alpha = 0.6
        holderView.addSubview(bottomShadowView)
        
        topShadowView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        topShadowView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        topShadowView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        topShadowView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bottomShadowView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        bottomShadowView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        bottomShadowView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        bottomShadowView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        /// Create a stack view
        let stackBottomView = UIStackView()
        stackBottomView.axis = .horizontal
        stackBottomView.alignment = .center
        stackBottomView.distribution = .fillEqually
        stackBottomView.spacing = 10
        
        /// Create three circular views
        let circleView1 = createCircularView()
        
        let expandButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        expandButton.setImage(UIImage.fromPackage(named: "button_settings")?.withRenderingMode(.alwaysOriginal), for: .normal)
        expandButton.tintColor = .white
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        expandButton.addTarget(self, action: #selector(self.actionExpandButton), for: .touchUpInside)
        self.expandButton = expandButton
        circleView1.addSubview(expandButton)
        NSLayoutConstraint.activate([
            expandButton.centerXAnchor.constraint(equalTo: circleView1.centerXAnchor),
            expandButton.centerYAnchor.constraint(equalTo: circleView1.centerYAnchor)
        ])
        
        
        let circleView2 = createCircularView()
        let tapGestureCircle2 = UITapGestureRecognizer(target: self, action: #selector(self.buttonTapped))
        circleView2.addGestureRecognizer(tapGestureCircle2)
        let playButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        playButton.setImage(UIImage(named: "icon_pause"), for: .normal)
        playButton.tintColor = .white
        playButton.contentMode = .center
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.imageView?.contentMode = .scaleAspectFit
        playButton.contentVerticalAlignment = .fill
        playButton.contentHorizontalAlignment = .fill
//        playButton.imageEdgeInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        playButton.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        self.playButton = playButton
        circleView2.addSubview(playButton)
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: circleView2.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: circleView2.centerYAnchor)
        ])
        
        let circleView3 = createCircularView()
        let tapGestureCircle3 = UITapGestureRecognizer(target: self, action: #selector(self.actionMuteButton))
        circleView3.addGestureRecognizer(tapGestureCircle3)
        let muteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        muteButton.setImage(UIImage.fromPackage(named: "button_mute")?.withRenderingMode(.alwaysOriginal), for: .normal)
        muteButton.tintColor = .white
        muteButton.contentVerticalAlignment = .fill
        muteButton.contentHorizontalAlignment = .fill
        muteButton.translatesAutoresizingMaskIntoConstraints = false
        muteButton.addTarget(self, action: #selector(self.actionMuteButton), for: .touchUpInside)
//        muteButton.imageView?.layer.transform = CATransform3DMakeScale(0.6, 0.6, 0.6)
        self.muteButton = muteButton
        circleView3.addSubview(muteButton)
        NSLayoutConstraint.activate([
            muteButton.centerXAnchor.constraint(equalTo: circleView3.centerXAnchor),
            muteButton.centerYAnchor.constraint(equalTo: circleView3.centerYAnchor)
        ])
        
        /// Add circular views to stack view
        stackBottomView.addArrangedSubview(circleView1)
        stackBottomView.addArrangedSubview(circleView3)
        holderView.addSubview(circleView2)
        
        /// Add stack view to the main view
        stackBottomView.translatesAutoresizingMaskIntoConstraints = false
        holderView.addSubview(stackBottomView)
        
        /// Constraints for stack view
        let constraintBottom: CGFloat =  -12
        let constraintRight: CGFloat =  -10
        NSLayoutConstraint.activate([
            stackBottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: constraintRight),
            stackBottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: constraintBottom),
            
        
                // Center horizontally and vertically
            circleView2.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView2.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0.5
        progressView.tintColor = .blue
        progressView.trackTintColor = .darkGray
        progressView.clipsToBounds = true
        self.progressBar = progressView
        holderView.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            progressView.bottomAnchor.constraint(equalTo: circleView1.topAnchor, constant: -10),
            progressView.heightAnchor.constraint(equalToConstant: 3)
        ])
        
        // Create a container UIView
        let liveContainer = UIView()
        liveContainer.translatesAutoresizingMaskIntoConstraints = false

        // Time Label
        let timeLabel = UILabel()
        timeLabel.text = "9:45pm"
        timeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        timeLabel.textColor = .white
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        // Live Icon (UIImageView)
        let liveIcon = UIImageView()
//        liveIcon.setImage(UIImage.fromPackage(named: "icon_live")?.withRenderingMode(.alwaysOriginal), for: .normal)
        liveIcon.image = UIImage.fromPackage(named: "icon_live")
        liveIcon.tintColor = UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 1.0) // Red-orange color
        liveIcon.contentMode = .scaleAspectFit
        liveIcon.translatesAutoresizingMaskIntoConstraints = false

        // Live Label
        let liveLabel = UILabel()
        liveLabel.text = "LIVE"
        liveLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        liveLabel.textColor = .white
        liveLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add views to the container
        liveContainer.addSubview(timeLabel)
        liveContainer.addSubview(liveIcon)
        liveContainer.addSubview(liveLabel)

        // Add container to main view
        holderView.addSubview(liveContainer)

        // Constraints
        NSLayoutConstraint.activate([
            // Position the liveContainer
            liveContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            liveContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -25),

            // Time Label Constraints
            timeLabel.leadingAnchor.constraint(equalTo: liveContainer.leadingAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: liveContainer.centerYAnchor),

            // Live Icon Constraints
            liveIcon.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 10),
            liveIcon.centerYAnchor.constraint(equalTo: liveContainer.centerYAnchor),
            liveIcon.widthAnchor.constraint(equalToConstant: 18), // Adjust size of the icon
            liveIcon.heightAnchor.constraint(equalToConstant: 18),

            // Live Label Constraints
            liveLabel.leadingAnchor.constraint(equalTo: liveIcon.trailingAnchor, constant: 5),
            liveLabel.centerYAnchor.constraint(equalTo: liveContainer.centerYAnchor),
            liveLabel.trailingAnchor.constraint(equalTo: liveContainer.trailingAnchor)
        ])
    }

    }

// Function to create a circular view
func createCircularView() -> UIView {
    let circleRadius: CGFloat = 40
    let circleView = UIView()
    circleView.backgroundColor = .clear
    circleView.layer.cornerRadius = circleRadius / 2
    circleView.widthAnchor.constraint(equalToConstant: circleRadius).isActive = true
    circleView.heightAnchor.constraint(equalToConstant: circleRadius).isActive = true
    return circleView
}

