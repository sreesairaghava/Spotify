//
//  CategoryCollectionViewCell.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 04/05/21.
//

import UIKit
import SDWebImage

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "CategoryCollectionViewCell"
    //SubView: ImageView and Label
    //ImageView
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(
            systemName: "music.quarternote.3",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 50,
                weight: .regular)
        )
        return imageView
    }()
    //Label
    private let label: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    //Creating an Array of random system colors
    private let colors: [UIColor] = [
        .systemPink,
        .systemBlue,
        .systemTeal,
        .systemGreen,
        .systemOrange,
        .systemIndigo,
        .systemYellow,
        .darkGray,
        .systemRed
    ]
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        //Add Subviews to init
        contentView.addSubview(label)
        contentView.addSubview(imageView)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text=nil
        imageView.image = UIImage(
            systemName: "music.quarternote.3",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 50,
                weight: .regular)
        )
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(
            x: 10,
            y: contentView.height/2,
            width: contentView.width-20,
            height: contentView.height/2
        )
        imageView.frame = CGRect(
            x: contentView.width/2,
            y: 10,
            width: contentView.width/2,
            height: contentView.height/2)
        
    }
    func configure(with viewModel: CategoryCollectionViewCellViewModel){
        label.text = viewModel.title
        imageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        contentView.backgroundColor = colors.randomElement()
    }
}
