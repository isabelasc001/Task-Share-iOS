//
//  ListCollectionViewCell.swift
//  Task Share
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell {
    static let identifier = "ListCollectionViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let itemsPreviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 3
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(itemsPreviewLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            categoryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            dateLabel.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            itemsPreviewLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 12),
            itemsPreviewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            itemsPreviewLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            itemsPreviewLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(with list: List) {
        titleLabel.text = list.title
        categoryLabel.text = list.category.rawValue
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        dateLabel.text = formatter.string(from: list.date)
        
        let itemsText = list.tasks.prefix(3).map { "• \($0.title)" }.joined(separator: "\n")
        itemsPreviewLabel.text = itemsText
        
        let colors: [UIColor] = [
            .systemRed.withAlphaComponent(0.15),
            .systemBlue.withAlphaComponent(0.15),
            .systemGreen.withAlphaComponent(0.15),
            .systemOrange.withAlphaComponent(0.15),
            .systemPurple.withAlphaComponent(0.15),
            .systemTeal.withAlphaComponent(0.15),
            .systemPink.withAlphaComponent(0.15),
            .systemYellow.withAlphaComponent(0.15)
        ]
        let colorIndex = abs(list.id.uuidString.hashValue) % colors.count
        contentView.backgroundColor = colors[colorIndex]
    }
}
