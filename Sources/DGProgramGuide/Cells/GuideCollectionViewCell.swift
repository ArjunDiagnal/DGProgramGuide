//
//  GuideCollectionViewCell.swift
//  
//
//  Created by Arjun Santhosh on 04/02/25.
//

import UIKit

class GuideCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "GuideCollectionViewCell"
    
    weak var delegate: GuideCollectionViewCellDelegate?
    var index = IndexPath(row: 0, section: 0)

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.text = "Old Trafford becomes the battlefield"
        return label
    }()
    
    private let upNextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .white
        label.text = "Up Next | Peaky blinders"
        return label
    }()
    
    private let upNextTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .gray
        label.text = "11:55"
        return label
    }()
    
    private let descriptionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIConfig.shared.backgroundColor.withAlphaComponent(0.5)
        view.isHidden = false
        return view
    }()
    
    private let titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        return stackView
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .leading
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private let programImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.image = UIImage(named: "dummy1")
        return imageView
    }()
    
    private let imageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "arrow_right"), for: .normal)
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let progressBarView: UIProgressView = {
        var progressBar = UIProgressView()
        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.setProgress(0.5, animated: false)
        progressBar.tintColor = .lightGray
        return progressBar
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIConfig.shared.backgroundColor
        
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subtitleLabel)
        
        contentView.addSubview(mainStackView)
        contentView.addSubview(titleView)
        
        contentView.addSubview(descriptionView)
        titleView.addSubview(programImageView)
        titleView.addSubview(textStackView)
        titleView.addSubview(progressBarView)
        descriptionView.addSubview(descriptionLabel)
        descriptionView.addSubview(upNextLabel)
        descriptionView.addSubview(upNextTimeLabel)
        contentView.addSubview(imageButton)
        setupConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        descriptionLabel.text = nil
        upNextLabel.text = nil
        upNextTimeLabel.text = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configureProgram(item: Listings?) {
        programImageView.loadImage(from: item?.program?.image?.first?.url ?? "", placeholder: UIImage(named: "placeholder"))
        titleLabel.text = item?.program?.title
        descriptionLabel.text = item?.program?.description
        descriptionView.isHidden = !(item?.isExpanded ?? false)
        
        if let expanded = item?.isExpanded, expanded {
            imageButton.setImage(UIImage.fromPackage(named: "arrow_up"), for: .normal)
            progressBarView.isHidden = false
        } else {
            imageButton.setImage(UIImage.fromPackage(named: "arrow_right"), for: .normal)
            progressBarView.isHidden = true
        }
        if let program = item {
            if let startTime = program.startTime, let endTime = program.endTime {
                let timeFormatted = formatTimeRange(startTime: startTime, endTime: endTime)
                self.subtitleLabel.text = timeFormatted
            }
        }
    }
    
    func configure(with item: GuideEntries?) {
        titleLabel.text = item?.listings?.first?.program?.title
        descriptionLabel.text = item?.listings?.first?.program?.description
        descriptionView.isHidden = !(item?.isExpanded ?? false)
        if let expanded = item?.isExpanded, expanded {
            imageButton.setImage(UIImage.fromPackage(named: "arrow_up"), for: .normal)
            programImageView.loadImage(from: item?.listings?.first?.program?.image?.first?.url ?? "", placeholder: UIImage(named: "placeholder"))
            progressBarView.isHidden = false
//            titleView.backgroundColor = .darkGray
//            descriptionView.backgroundColor = .darkGray
        } else {
            imageButton.setImage(UIImage.fromPackage(named: "arrow_right"), for: .normal)
            programImageView.loadImage(from: item?.thumbnail?.url ?? "", placeholder: UIImage(named: "placeholder"))
            progressBarView.isHidden = true
            titleView.backgroundColor = UIConfig.shared.backgroundColor
            descriptionView.backgroundColor = UIConfig.shared.backgroundColor
        }
        
        if let program = item?.listings?.first {
            if let startTime = program.startTime, let endTime = program.endTime {
                let timeFormatted = formatTimeRange(startTime: startTime, endTime: endTime)
                self.subtitleLabel.text = timeFormatted
            }
        }
        
        if let upcomingProgram = item?.upCominglistings?.first?.program?.title {
            self.upNextLabel.text = "Up Next | \(upcomingProgram)"
        }
        
        if let program = item?.upCominglistings?.first {
            if let startTime = program.startTime, let endTime = program.endTime {
                let timeFormatted = formatTimeRange(startTime: startTime, endTime: endTime)
                self.upNextTimeLabel.text = timeFormatted
            }
        }
    }
    
    func formatTimeRange(startTime: Int, endTime: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current

        let startDate = Date(timeIntervalSince1970: TimeInterval(startTime) / 1000)
        let endDate = Date(timeIntervalSince1970: TimeInterval(endTime) / 1000)

        let startFormatted = dateFormatter.string(from: startDate)
        let endFormatted = dateFormatter.string(from: endDate)

        return "\(startFormatted) - \(endFormatted)"
    }
    private func setupConstraints() {
        
        imageButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        programImageView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        progressBarView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        upNextLabel.translatesAutoresizingMaskIntoConstraints = false
        upNextTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        mainStackView.addArrangedSubview(titleView)
        mainStackView.addArrangedSubview(descriptionView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            
            /// ImageView Constraints
            titleView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 1),
            titleView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -10),
            titleView.heightAnchor.constraint(equalToConstant: 70),
            titleView.widthAnchor.constraint(equalToConstant: contentView.frame.width),
            
            descriptionView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor,constant: 10),
            descriptionView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor,constant: -10),
            
            /// ImageView Constraints
            programImageView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 10),
            programImageView.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 10),
            programImageView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -10),
            programImageView.widthAnchor.constraint(equalTo: programImageView.heightAnchor, multiplier: 2),
            
            
            // Button Constraints (Centered & Equal Size)
            imageButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            imageButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            imageButton.widthAnchor.constraint(equalToConstant: 32),
            imageButton.heightAnchor.constraint(equalToConstant: 48),
            /// StackView Constraints
            textStackView.leadingAnchor.constraint(equalTo: programImageView.trailingAnchor, constant: 10),
            textStackView.topAnchor.constraint(equalTo: programImageView.topAnchor),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            /// StackView Constraints
            progressBarView.leadingAnchor.constraint(equalTo: programImageView.trailingAnchor, constant: 10),
            progressBarView.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: 5),
            progressBarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
        ])
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(UILabel())
        stackView.addArrangedSubview(upNextLabel)
        stackView.addArrangedSubview(upNextTimeLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: 5),
            stackView.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor)
        ])
    }
    
    // Button tap action
    @objc private func buttonTapped() {
        delegate?.didTapButtonInCell(self, index: index)
    }
    
}
