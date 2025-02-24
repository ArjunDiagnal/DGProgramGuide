//
//  DGGuide.swift
//  
//
//  Created by Arjun Santhosh on 28/01/25.
//

import UIKit

protocol GuideCollectionViewCellDelegate: AnyObject {
    func didTapButtonInCell(_ cell: GuideCollectionViewCell, index: IndexPath)
}

public protocol DGGuideDelegate: AnyObject {
    func scrollViewDidScroll(shouldHideView: Bool)
}

public class DGGuide: UIView, UICollectionViewDelegate {
            
    public weak var delegate: DGGuideDelegate?
    public var parentController: UIViewController?
    public var channelList: [GuideEntries]? {
        didSet {
            if let channels = channelList, channels.count > 0 {
                let filteredPGMS = self.filterLivePrograms()
                self.filteredLiveList = filteredPGMS
                self.setupCurrentChannel(channel: filteredPGMS.first, index: 1)
                self.collectionView.reloadData()
            }
        }
    }
        
    private var lastContentOffset: CGFloat = 0
    private var isViewHidden = false

    var currentPlayingChannel: GuideEntries? {
        didSet {
            moreInfoView.channel = currentPlayingChannel
        }
    }
    public var filteredLiveList: [GuideEntries]?
    private var viewHeader: EPGTitleCollectionReusableView?
    
    private let playerView: PlayerView = {
        let view = PlayerView()
        view.backgroundColor = .black
        if UIDevice.current.userInterfaceIdiom == .pad {
            view.applyBorderAndCornerRadius()
        }
        return view
    }()
    
    private let moreInfoView: GuideInfoView = {
        let view = GuideInfoView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
        view.backgroundColor = UIConfig.shared.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIConfig.shared.backgroundColor
        view.addTopAndBottomBorders(color: .gray.withAlphaComponent(0.5), height: 0.5)
        return view
    }()
    
    private let expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .clear
        button.setImage(UIImage.fromPackage(named: "circle_open")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return button
    }()
    
    private var titleIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "dummy1")
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 3
        return view
    }()
    
    private var titleStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .leading
        view.axis = .vertical
        view.spacing = 5
        return view
    }()
    
    private let seeMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See More", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.lightGray, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 10)
        return button
    }()
    
    private var channelNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var mainTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var collectionView: UICollectionView!
    private var categoryCollectionView: UICollectionView!
    private let items = ["All Channel", "My Channel", "Free to me", "Action", "Drama"]
    
    private var EPGitems: [Item] = [
         Item(title: "Friends: The Reunion", description: "This is the description for item 1."),
         Item(title: "Our Planet: High Seas", description: "Old Trafford becomes the battlefield as Manchester United takes on their fierce rivals, Liverpool, in one of the most anticipated fixtures of the season.Old Trafford becomes the battlefield as Manchester United takes on their fierce rivals, Liverpool, in one of the most anticipated fixtures of the season.Old Trafford becomes the battlefield as Manchester United takes on their fierce rivals, Liverpool, in one of the most anticipated fixtures of the season."),
         Item(title: "Manchester United vs Liverpool", description: "This is the description for item 2."),
         Item(title: "Making a Murderer", description: "This is the description for item 2."),
         Item(title: "The Last Dance", description: "This is the description for item 2."),
         Item(title: "Richard Hammond’s Workshop", description: "This is the description for item 2."),
         Item(title: "Item 3", description: "Old Trafford becomes the battlefield as Manchester United takes on their fierce rivals, Liverpool, in one of the most anticipated fixtures of the season."),
         Item(title: "Arsenal vs Manchester United", description: "This is the description for item 4.")
     ]
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            print("CustomView is now visible in a view controller.")
        } else {
            print("CustomView is no longer visible.")
            self.playerView.cleanUpPlayer()
        }
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        setupUIView()
        self.startGuidePlayback()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
        setupUIView()
        self.startGuidePlayback()
    }
    
    func rotateToLandscape() {
        let orientation = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(orientation, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    /// Function to initiate trailer playback
    func startGuidePlayback() {
//        self.playerModel = PlayerViewModel(withTrailer: trailer, media: media)
//        playerView.dataSource = self
//        playerView.delegate = self
        playerView.isHidden = false
        playerView.backgroundColor = .clear
        playerView.getDataAndStartPlayer()
//        self.isTrailerInitialised = true
    }

    private func setupUIView() {
        self.backgroundColor = UIConfig.shared.backgroundColor
        playerView.translatesAutoresizingMaskIntoConstraints = false
        moreInfoView.translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false

        // Create Main StackView
        let stackView = UIStackView()
        stackView.axis = UIDevice.current.userInterfaceIdiom == .pad ? .horizontal : .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = UIDevice.current.userInterfaceIdiom == .pad ? 10 : 0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Create Secondary StackView
        let secondaryStackView = UIStackView()
        secondaryStackView.axis = .vertical
        secondaryStackView.distribution = .fill
        secondaryStackView.alignment = .fill
        secondaryStackView.spacing = 0
        secondaryStackView.translatesAutoresizingMaskIntoConstraints = false
        if UIDevice.current.userInterfaceIdiom == .pad {
            secondaryStackView.applyBorderAndCornerRadius()
        }

        // Initialize CollectionView (Before Adding)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIConfig.shared.backgroundColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EPGTitleCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: EPGTitleCollectionReusableView.reuseIdentifier)
        collectionView.register(GuideCollectionViewCell.self, forCellWithReuseIdentifier: GuideCollectionViewCell.identifier)

        // Add Views to Secondary StackView
        secondaryStackView.addArrangedSubview(titleView)
        secondaryStackView.addArrangedSubview(collectionView)

        if UIDevice.current.userInterfaceIdiom == .pad {
            // Add Views to Main StackView
            stackView.addArrangedSubview(secondaryStackView)
            stackView.addArrangedSubview(playerView)
        } else {
            // Add Views to Main StackView
            stackView.addArrangedSubview(playerView)
            stackView.addArrangedSubview(secondaryStackView)
        }

        // Add Main StackView to View
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: UIDevice.current.userInterfaceIdiom == .pad ? 15 : 0),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: UIDevice.current.userInterfaceIdiom == .pad ? 10 : 0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: UIDevice.current.userInterfaceIdiom == .pad ? -10 : 0),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            playerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: UIDevice.current.userInterfaceIdiom == .pad ? 0.8 : 0.35),
            playerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: UIDevice.current.userInterfaceIdiom == .pad ? 0.7 : 1),
            titleView.heightAnchor.constraint(equalToConstant: 60)
        ])

        // Expand Button Setup
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(expandButton)
        
        addSubview(moreInfoView)
        moreInfoView.isHidden = true
        
        NSLayoutConstraint.activate([
            expandButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            expandButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -12),
            expandButton.widthAnchor.constraint(equalToConstant: 40),
            expandButton.heightAnchor.constraint(equalToConstant: 40),
            
            moreInfoView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
            moreInfoView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            moreInfoView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            moreInfoView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Icon StackView
        titleIconImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        titleIconImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        channelNumberLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        channelNumberLabel.text = "001"

        let iconStackView = UIStackView(arrangedSubviews: [titleIconImageView, channelNumberLabel])
        iconStackView.axis = .horizontal
        iconStackView.spacing = 5
        iconStackView.alignment = .center
        iconStackView.translatesAutoresizingMaskIntoConstraints = false

        // Title StackView Fixes
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .horizontal
        titleStackView.spacing = 5
        titleStackView.alignment = .center
        titleStackView.distribution = .fill // Ensuring it doesn't expand titleView
        titleStackView.addArrangedSubview(iconStackView)
        titleView.addSubview(titleStackView)

        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 10),
            titleStackView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 15),
            titleStackView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -55),
            titleStackView.heightAnchor.constraint(equalToConstant: 60),  // Ensuring height remains 60
            titleStackView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -10) // Prevent extra height expansion
        ])

        expandButton.addTarget(self, action: #selector(actionExpandButton), for: .touchUpInside)
    }


    
    func setupCurrentChannel(channel: GuideEntries?, index: Int) {
        if let title =  channel?.listings?.first?.program?.title {
            viewHeader?.configure(title: title, subtitle: "More Info")
        }
        if let thumbnail = channel?.thumbnail {
            if let url = thumbnail.url {
                titleIconImageView.loadImage(from: url)
            }
        }
        self.channelNumberLabel.text = "00\(index)"
        self.currentPlayingChannel = channel
    }
    
    // Button tap action
    @objc private func actionExpandButton() {
        setupBottomSheet()
    }
    
    /// Function to filter and create a new GuideEntries list with only live programs
    func filterLivePrograms() -> [GuideEntries] {
        var currentTime = Int64(Date().timeIntervalSince1970 * 1000)
        
//        let stringTimestamp = "1739345400000"
//        if let int64Timestamp = Int64(stringTimestamp) {
//            currentTime = int64Timestamp
//        } else {
//            print("Conversion failed")
//        }
        
        guard let channels = self.channelList else { return [] }
        var filteredChannels = [GuideEntries]()
        for channel in channels {
            
            print("current :: \(channel.title) count ::::\(channel.listings?.count)")
            
            if let listing = channel.listings {
                for list in listing {
                    print("current :: \(list.program?.title)")
                    if let startTime = list.startTime, let endTime = list.endTime {
                        print("current ::: \(currentTime) start ::: \(startTime)::: end \(endTime)")
                    }
                }
            }
            
            let liveProgram = channel.listings?.filter({$0.startTime ?? 0 <= currentTime && $0.endTime ?? 0 > currentTime })
           
            var filteredchannel = GuideEntries()
            filteredchannel.title = channel.title
            filteredchannel.id = channel.id
            filteredchannel.thumbnail = channel.thumbnail
            filteredchannel.listings = liveProgram
            
            
            if let liveProgramItem = liveProgram, liveProgramItem.count > 0 {
                if let liveProgramEndTime = liveProgramItem.first?.endTime {
                    filteredchannel.upCominglistings = channel.listings?.filter({$0.endTime ?? 0 > liveProgramEndTime })
                }
                if let liveProgramStartTime = liveProgramItem.first?.startTime {
                    filteredchannel.catchUplistings = channel.listings?.filter({$0.endTime ?? 0 <= liveProgramStartTime })
                }
            }
            
            print("current :: \(liveProgram?.count)")
            print("current :: \(filteredchannel.upCominglistings?.count) upCominglistings")
            print("current :: \(filteredchannel.catchUplistings?.count) catchUplistings")
            
            if filteredChannels.count == 0 {
                filteredChannels = [filteredchannel]
            } else {
                filteredChannels.append(filteredchannel)
            }
        }
        
        print("current :::: \(filteredChannels.count)")
        print("current :: \(filteredChannels.first?.listings?.count)")
        
        return filteredChannels
    }
    
    private func setupBottomSheet() {
        if moreInfoView.isHidden {
            showViewWithSlideUpAnimation(view: moreInfoView)
        } else {
            hideViewWithSlideDownAnimation(view: moreInfoView)
        }
    }
    
    func hideViewWithSlideDownAnimation(view: UIView, duration: TimeInterval = 0.3) {
        let originalPosition = view.frame.origin.y // Store the original Y position
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            view.frame.origin.y += view.frame.height
        }) { _ in
            view.isHidden = true
            view.frame.origin.y = originalPosition // Reset position
        }
    }
    
    func showViewWithSlideUpAnimation(view: UIView, duration: TimeInterval = 0.3) {
        // Start position (below the screen or parent view)
        let originalFrame = view.frame
        view.frame.origin.y += view.frame.height
        view.isHidden = false

        // Animate sliding up
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            view.frame = originalFrame
        })
    }

    private func setupCollectionView() {
//        let categoryLayout = UICollectionViewFlowLayout()
//        categoryLayout.scrollDirection = .horizontal
//        categoryLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
//        categoryLayout.minimumInteritemSpacing = 5

//        categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: categoryLayout)
//        categoryCollectionView.register(CategoryCollectionViewCell .self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
////        categoryCollectionView.dataSource = self
////        categoryCollectionView.delegate = self
//        categoryCollectionView.backgroundColor = .darkGray
//        categoryCollectionView.showsHorizontalScrollIndicator = false
//        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(categoryCollectionView)
//
//        NSLayoutConstraint.activate([
//            categoryCollectionView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
//            categoryCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            categoryCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            categoryCollectionView.heightAnchor.constraint(equalToConstant: 50)
//        ])


       
    }
    
    func heightForText(_ text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        return ceil(boundingBox.height)
    }

}

extension DGGuide: UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return filteredLiveList?.count ?? 2
        } else {
            return items.count
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GuideCollectionViewCell.identifier, for: indexPath) as? GuideCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            cell.index = indexPath
            cell.configure(with: filteredLiveList?[indexPath.row])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: items[indexPath.item])
            return cell
        }
    }

}

extension DGGuide: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: EPGTitleCollectionReusableView .reuseIdentifier,
                                                                     for: indexPath) as! EPGTitleCollectionReusableView

        self.viewHeader = header
        if let title = self.filteredLiveList?.first?.listings?.first?.program?.title {
            header.configure(title: title, subtitle: "More info")
        }
        return header
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        let epsilon: CGFloat = 5.0 // Small buffer to prevent jitter

        if contentHeight > 0 {
            if offsetY <= 0 + epsilon {
                // Scrolled to the top - Show View
                if isViewHidden {
                    isViewHidden = false
                    self.delegate?.scrollViewDidScroll(shouldHideView: false)
                }
            } else if offsetY + scrollViewHeight >= contentHeight - epsilon {
                // Scrolled to the bottom - Hide View
                if !isViewHidden {
                    isViewHidden = true
                    self.delegate?.scrollViewDidScroll(shouldHideView: true)
                }
            } else {
                // Detect Scroll Direction
                if offsetY > lastContentOffset {
                    // Scrolling Down - Hide View
                    if !isViewHidden {
                        isViewHidden = true
                        self.delegate?.scrollViewDidScroll(shouldHideView: true)
                    }
                } else if offsetY < lastContentOffset {
                    // Scrolling Up - Show View
                    if isViewHidden {
                        isViewHidden = false
                        self.delegate?.scrollViewDidScroll(shouldHideView: false)
                    }
                }
            }
        }

        // Update last offset for next check
        lastContentOffset = offsetY
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let channel = self.filteredLiveList else { return }
        let selectedChannel = channel[indexPath.row]
        self.setupCurrentChannel(channel: selectedChannel, index: indexPath.row + 1)
        filteredLiveList?[indexPath.row].isExpanded.toggle() // Toggle expansion state
        self.collectionView.reloadItems(at: [indexPath])
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            let width = collectionView.frame.width
            let item = filteredLiveList?[indexPath.item]
            let titleHeight: CGFloat = 70
            let padding: CGFloat = 60
            var descriptionHeight: CGFloat = 0
            if let expanded = item?.isExpanded, expanded {
                descriptionHeight = heightForText(item?.listings?.first?.program?.description ?? "", font: UIFont.systemFont(ofSize: 16, weight: .regular), width: width - 20)
                descriptionHeight += padding
            }
            return CGSize(width: width, height: titleHeight + descriptionHeight)
        } else {
            let text = items[indexPath.item]
            let font = UIFont.systemFont(ofSize: 14, weight: .medium)
            let textWidth = text.size(withAttributes: [NSAttributedString.Key.font: font]).width
            return CGSize(width: textWidth + 20, height: 32)
        }
    }
}

extension DGGuide: GuideCollectionViewCellDelegate {
    func didTapButtonInCell(_ cell: GuideCollectionViewCell, index: IndexPath) {
        filteredLiveList?[index.item].isExpanded.toggle() // Toggle expansion state
        self.collectionView.reloadItems(at: [index])
    }
}

struct Item {
    let title: String
    let description: String
    var isExpanded: Bool = false // Track expanded state
}

public extension UIImage {
    static func fromPackage(named name: String) -> UIImage? {
        return UIImage(named: name, in: Bundle.module, compatibleWith: nil)
    }
}

extension UIImageView {
    func loadImage(from urlString: String, placeholder: UIImage? = nil) {
        self.image = placeholder // Set placeholder before loading
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}

extension UIView {
    func addTopAndBottomBorders(color: UIColor = .lightGray, height: CGFloat = 1.0) {
        let topBorder = UIView()
        topBorder.backgroundColor = color
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(topBorder)

        let bottomBorder = UIView()
        bottomBorder.backgroundColor = color
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bottomBorder)

        NSLayoutConstraint.activate([
            topBorder.topAnchor.constraint(equalTo: self.topAnchor),
            topBorder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topBorder.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            topBorder.heightAnchor.constraint(equalToConstant: height),

            bottomBorder.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bottomBorder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomBorder.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomBorder.heightAnchor.constraint(equalToConstant: height)
        ])
    }
}

extension UIView {
    func applyBorderAndCornerRadius(borderWidth: CGFloat = 0.5, borderColor: UIColor = .darkGray, cornerRadius: CGFloat = 10) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
}








