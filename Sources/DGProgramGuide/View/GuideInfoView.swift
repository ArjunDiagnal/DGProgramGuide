//
//  File.swift
//  
//
//  Created by Arjun Santhosh on 10/02/25.
//

import UIKit
import DGProgramGuide

enum ProgramStatus {
    case upcoming
    case current
}

class GuideInfoView: UIView {
    
    private var collectionView: UICollectionView!
    private var categoryCollectionView: UICollectionView!
    
    public var channel: GuideEntries? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    public var status: ProgramStatus = .upcoming
    
    private let items = ["Upcoming", "Catch Up"]
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let categoryLayout = UICollectionViewFlowLayout()
        categoryLayout.scrollDirection = .horizontal
        categoryLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        categoryLayout.minimumInteritemSpacing = 5

        categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: categoryLayout)
        categoryCollectionView.register(CategoryCollectionViewCell .self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.backgroundColor = UIConfig.shared.backgroundColor
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(categoryCollectionView)

        NSLayoutConstraint.activate([
            categoryCollectionView.topAnchor.constraint(equalTo: topAnchor),
            categoryCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            categoryCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: 50)
        ])

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
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
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

extension GuideInfoView: UICollectionViewDelegate {
    
}

extension GuideInfoView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            let width = collectionView.frame.width
            let item = self.status == .upcoming ? channel?.upCominglistings?[indexPath.row] : channel?.catchUplistings?[indexPath.row]
            let titleHeight: CGFloat = 70
            let padding: CGFloat = 60
            var descriptionHeight: CGFloat = 0
            if item?.isExpanded ?? false {
                descriptionHeight = heightForText(item?.description ?? "", font: UIFont.systemFont(ofSize: 16, weight: .regular), width: width - 20)
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

extension GuideInfoView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return self.status == .upcoming ? channel?.upCominglistings?.count ?? 0 : channel?.catchUplistings?.count ?? 0
        } else {
            return items.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GuideCollectionViewCell.identifier, for: indexPath) as? GuideCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            cell.index = indexPath
            let item = self.status == .upcoming ? channel?.upCominglistings?[indexPath.row] : channel?.catchUplistings?[indexPath.row]
            cell.configureProgram(item: item)
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

extension GuideInfoView: GuideCollectionViewCellDelegate {
    func didTapButtonInCell(_ cell: GuideCollectionViewCell, index: IndexPath) {
        self.status == .upcoming ? channel?.upCominglistings?[index.row].isExpanded.toggle() : channel?.catchUplistings?[index.row].isExpanded.toggle()
        self.collectionView.reloadItems(at: [index])
    }
}
