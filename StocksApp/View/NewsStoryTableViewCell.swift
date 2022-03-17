//
//  NewsStoryTableViewCell.swift
//  StocksApp
//
//  Created by Nii Yemoh on 17/03/2022.
//

import UIKit
import Kingfisher

class NewsStoryTableViewCell: UITableViewCell {
    
    static let identifier = "NewsStoryTableViewCell"
    static let preferredHeight: CGFloat = 140
    
    struct ViewModel {
        
        let source: String
        let headline: String
        let dateString: String
        let imageUrl: URL?
        
        
        init(model: NewsStory) {
            source = model.source
            headline = model.headline
            dateString = .string(from: model.datetime)
            imageUrl = URL(string: model.image)
        }
    }
    
    //source
    private let  sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    //headline
    private let  headlineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    //date
    private let  dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    //image
    private let storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        backgroundColor = .secondarySystemBackground
        addSubViews(sourceLabel, headlineLabel, dateLabel, storyImageView)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height - 12
        storyImageView.frame = CGRect(x: contentView.width - imageSize - 10,
                                      y: 3.0,
                                      width: imageSize,
                                      height: imageSize)
        
        let availableWidth: CGFloat = contentView.width - separatorInset.left - imageSize - 15
        
        dateLabel.frame = CGRect(x: separatorInset.left,
                                 y: contentView.height - 40,
                                 width: availableWidth,
                                 height: 40)
        
        
        sourceLabel.sizeToFit()
        sourceLabel.frame = CGRect(x: separatorInset.left,
                                   y: 4,
                                   width: availableWidth,
                                   height: sourceLabel.height)
        
        
        headlineLabel.frame = CGRect(x: separatorInset.left,
                                     y: sourceLabel.bottom + 5 ,
                                     width: availableWidth,
                                     height: contentView.height - sourceLabel.bottom - dateLabel.height - 10)
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        storyImageView.image = nil
    }
    
    
    public func configure(with viewModel: ViewModel) {
        headlineLabel.text = viewModel.headline
        sourceLabel.text = viewModel.source
        dateLabel.text = viewModel.dateString
        //storyImageView.setImage(withUrl: viewModel.imageUrl)
        storyImageView.kf.indicatorType = .activity
        storyImageView.kf.setImage(with: viewModel.imageUrl, placeholder: nil, options: nil, completionHandler: nil)
    }
    
    
    
}
