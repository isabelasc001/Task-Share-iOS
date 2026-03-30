//
//  HomeView.swift
//  Task Share
//
//  Created by Isabela S Cardoso on 05/03/26.
//

import UIKit

class HomeView: UIView {

    // MARK: - Logo
    
//    let logoLabel: UILabel = {
//        let label = UILabel()
//        label.text = "TaskShare"
//        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//        label.textColor = .label
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let archivedButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        button.setImage(UIImage(systemName: "archivebox", withConfiguration: config), for: .normal)
        button.tintColor = .systemBlue
        button.accessibilityIdentifier = "archivedButton"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    // MARK: - Search
    
    let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search lists"
        search.searchBarStyle = .minimal
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    
    // MARK: - Segmented
    
    let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["All Lists", "Favorites"])
        control.selectedSegmentIndex = 0
        
        // Liquid glass style
        control.backgroundColor = .systemGray6
        control.selectedSegmentTintColor = .systemBlue
        
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    
    // MARK: - Collection View
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 80, right: 20)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.isHidden = true
        return collection
    }()
    
    // MARK: - Empty Icon
    
    let iconImage: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
        let image = UIImage(systemName: "list.bullet.rectangle", withConfiguration: config)
        
        let imageView = UIImageView(image: image)
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    
    // MARK: - Title
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No tasks yet"
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    
    // MARK: - Subtitle
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Start organizing your day"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    
    // MARK: - Button
    
    let newListButton: UIButton = {
        let button = UIButton(type: .system)
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        button.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 6
        
        button.accessibilityIdentifier = "newListButton"
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    
    // MARK: - Empty State Stack
    
    lazy var emptyStateStack: UIStackView = {
        
        let stack = UIStackView(arrangedSubviews: [
            iconImage,
            titleLabel,
            subtitleLabel
        ])
        
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    // MARK: - Setup
    
    private func setupView() {
        
        addSubview(logoImageView)
        addSubview(archivedButton)
        addSubview(searchBar)
        addSubview(segmentedControl)
        addSubview(collectionView)
        addSubview(emptyStateStack)
        addSubview(newListButton)
        
    }
    
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            
            // Logo
            
            logoImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            logoImageView.widthAnchor.constraint(equalToConstant: 44),
            logoImageView.heightAnchor.constraint(equalToConstant: 44),
            
            archivedButton.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
            archivedButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
          
            // Search
            
            searchBar.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            
            // Segmented
            
            segmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 8),
            segmentedControl.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -8),
            
            // Collection View
            
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Empty State
            
            emptyStateStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyStateStack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            
            
            // Button (FAB)
            
            newListButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            newListButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24),
            newListButton.widthAnchor.constraint(equalToConstant: 56),
            newListButton.heightAnchor.constraint(equalToConstant: 56)
            
        ])
        
    }
    
    func updateState(hasData: Bool) {
        collectionView.isHidden = !hasData
        emptyStateStack.isHidden = hasData
    }
}
