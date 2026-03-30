//
//  NewListView.swift
//  Task Share
//
//  Created by Isabela S Cardoso on 09/03/26.
//


import UIKit

class NewListView: UIView {

    // MARK: - Scroll View (for keyboard avoidance)
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .interactive
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Header
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.setTitle(" Back", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.setImage(UIImage(systemName: "star.fill"), for: .selected)
        button.tintColor = .systemYellow
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let favoriteLabel: UILabel = {
        let label = UILabel()
        label.text = "Add to favorites"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // MARK: - Title Field
    
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "List title"
        textField.font = .systemFont(ofSize: 24, weight: .bold)
        textField.borderStyle = .none
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    // MARK: - Categories
    
    let categoryControl: UISegmentedControl = {
        let items = Category.allCases.map { $0.rawValue }
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    
    // MARK: - Collection Items
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(TaskCollectionViewCell.self, forCellWithReuseIdentifier: TaskCollectionViewCell.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.isScrollEnabled = false
        return collection
    }()
    
    /// Dynamic height constraint for the collection view (updated when tasks change)
    var collectionViewHeightConstraint: NSLayoutConstraint!
    
    
    // MARK: - Add Item Button
    
    let addItemButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ Add Item", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Footer Buttons
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete List", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let archiveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Archive List", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    // Bottom constraint for keyboard avoidance
    private var saveButtonBottomConstraint: NSLayoutConstraint!
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupView()
        setupConstraints()
        setupKeyboardObservers()
        setupTapToDismiss()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Setup
    
    func setupView() {
        addSubview(cancelButton)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(favoriteButton)
        contentView.addSubview(favoriteLabel)
        contentView.addSubview(titleTextField)
        contentView.addSubview(categoryControl)
        contentView.addSubview(collectionView)
        contentView.addSubview(addItemButton)
        contentView.addSubview(deleteButton)
        contentView.addSubview(archiveButton)
        contentView.addSubview(saveButton)
    }
    
    
    // MARK: - Constraints
    
    func setupConstraints() {
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
        
        saveButtonBottomConstraint = saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            // Cancel / Back button (fixed at top, outside scroll)
            cancelButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView inside scroll
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Favorite
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            favoriteLabel.centerYAnchor.constraint(equalTo: favoriteButton.centerYAnchor),
            favoriteLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8),
            
            // Title field
            titleTextField.topAnchor.constraint(equalTo: favoriteButton.bottomAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Category
            categoryControl.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            categoryControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Collection
            collectionView.topAnchor.constraint(equalTo: categoryControl.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionViewHeightConstraint,
            
            // Add Item
            addItemButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
            addItemButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addItemButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Delete
            deleteButton.topAnchor.constraint(equalTo: addItemButton.bottomAnchor, constant: 16),
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Archive
            archiveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            archiveButton.centerYAnchor.constraint(equalTo: deleteButton.centerYAnchor),
            archiveButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Save
            saveButton.topAnchor.constraint(equalTo: deleteButton.bottomAnchor, constant: 16),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 56),
            saveButtonBottomConstraint
        ])
    }
    
    // MARK: - Update Collection Height
    
    func updateCollectionViewHeight(taskCount: Int) {
        let rowHeight: CGFloat = 44
        let spacing: CGFloat = 8
        let totalHeight = CGFloat(taskCount) * rowHeight + max(0, CGFloat(taskCount - 1)) * spacing
        collectionViewHeightConstraint.constant = totalHeight
        layoutIfNeeded()
    }
    
    // MARK: - Keyboard Handling
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        let keyboardHeight = keyboardFrame.height - safeAreaInsets.bottom
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
        
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }
    
    private func setupTapToDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        endEditing(true)
    }
}