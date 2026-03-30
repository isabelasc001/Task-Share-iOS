//
//  NewListViewController.swift
//  Task Share
//
//  Created by Isabela S Cardoso on 09/03/26.
//

import UIKit

class NewListViewController: UIViewController {
    
    let listView = NewListView()
    var tasks: [Task] = [] {
        didSet {
            listView.collectionView.reloadData()
            listView.updateCollectionViewHeight(taskCount: tasks.count)
        }
    }
    var list: List?
    
    var onListCreated: ((List) -> Void)?
    var onListUpdated: ((List) -> Void)?
    var onListDeleted: ((List) -> Void)?
    var onListArchived: ((List) -> Void)?
    
    init(list: List? = nil) {
        self.list = list
        super.init(nibName: nil, bundle: nil)
        if let list = list {
            self.tasks = list.tasks
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = listView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupCollectionView()
        setupInitialData()
        
        // Dismiss keyboard on Return
        listView.titleTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        listView.updateCollectionViewHeight(taskCount: tasks.count)
    }
    
    private func setupInitialData() {
        if let list = list {
            listView.titleTextField.text = list.title
            listView.favoriteButton.isSelected = list.isFavorite
            listView.saveButton.setTitle("Update", for: .normal)
            listView.deleteButton.isHidden = false
            listView.archiveButton.isHidden = false
            
            if list.isArchived {
                listView.archiveButton.setTitle("Unarchive List", for: .normal)
            } else {
                listView.archiveButton.setTitle("Archive List", for: .normal)
            }
            
            if let index = Category.allCases.firstIndex(of: list.category) {
                listView.categoryControl.selectedSegmentIndex = index
            }
        }
    }
    
    private func setupActions() {
        listView.cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        listView.saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        listView.favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        listView.addItemButton.addTarget(self, action: #selector(didTapAddItem), for: .touchUpInside)
        listView.deleteButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        listView.archiveButton.addTarget(self, action: #selector(didTapArchive), for: .touchUpInside)
    }
    
    private func setupCollectionView() {
        listView.collectionView.dataSource = self
        listView.collectionView.delegate = self
    }
    
    @objc private func didTapCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapSave() {
        // Dismiss keyboard first
        view.endEditing(true)
        
        guard let title = listView.titleTextField.text, !title.isEmpty else {
            return
        }
        
        let category = Category.allCases[listView.categoryControl.selectedSegmentIndex]
        
        if var existingList = list {
            existingList.title = title
            existingList.category = category
            existingList.tasks = tasks
            existingList.isFavorite = listView.favoriteButton.isSelected
            onListUpdated?(existingList)
        } else {
            let newList = List(
                title: title,
                category: category,
                tasks: tasks,
                isFavorite: listView.favoriteButton.isSelected
            )
            onListCreated?(newList)
        }
    }
    
    @objc private func didTapDelete() {
        guard let list = list else { return }
        let alert = UIAlertController(title: "Delete List", message: "Are you sure you want to delete this list?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.onListDeleted?(list)
        }))
        present(alert, animated: true)
    }
    
    @objc private func didTapArchive() {
        guard var list = list else { return }
        list.isArchived.toggle()
        onListUpdated?(list)
    }
    
    @objc private func didTapFavorite() {
        listView.favoriteButton.isSelected.toggle()
    }
    
    @objc private func didTapAddItem() {
        // Dismiss keyboard before showing alert
        view.endEditing(true)
        
        let alert = UIAlertController(title: "New Item", message: "Enter item description", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Buy milk..."
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                let newTask = Task(title: text)
                self?.tasks.append(newTask)
            }
        }))
        
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension NewListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Collection View

extension NewListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCollectionViewCell.identifier, for: indexPath) as? TaskCollectionViewCell else {
            return UICollectionViewCell()
        }
        let task = tasks[indexPath.item]
        cell.configure(with: task)
        cell.onCheckboxToggle = { [weak self] isCompleted in
            self?.tasks[indexPath.item].isCompleted = isCompleted
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: 44)
    }
}
