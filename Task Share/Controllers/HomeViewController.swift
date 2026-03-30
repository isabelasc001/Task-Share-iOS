//
//  HomeViewController.swift
//  Task Share
//
//  Created by Isabela S Cardoso on 05/03/26.
//

import UIKit

class HomeViewController: UIViewController {
    
    let homeView = HomeView()
    var allLists: [List] = [] {
        didSet {
            updateUI()
        }
    }
    
    var filteredLists: [List] {
        var lists = allLists
        
        // Filter by segment (All vs Favorites)
        if homeView.segmentedControl.selectedSegmentIndex == 1 {
            lists = lists.filter { $0.isFavorite }
        }
        
        // Filter by archive status (Home only shows non-archived)
        lists = lists.filter { !$0.shouldBeArchived }
        
        // Filter by search text
        if let searchText = homeView.searchBar.text, !searchText.isEmpty {
            let searchLower = searchText.lowercased()
            lists = lists.filter { list in
                let titleMatch = list.title.lowercased().contains(searchLower)
                let categoryMatch = list.category.rawValue.lowercased().contains(searchLower)
                let tasksMatch = list.tasks.contains { $0.title.lowercased().contains(searchLower) }
                
                // Simple date matching (e.g., "Mar 11")
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                let dateString = dateFormatter.string(from: list.date)
                let dateMatch = dateString.lowercased().contains(searchLower)
                
                return titleMatch || categoryMatch || dateMatch || tasksMatch
            }
        }
        
        return lists
    }

    override func loadView() {
        view = homeView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadLists()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeView.collectionView.dataSource = self
        homeView.collectionView.delegate = self
        homeView.searchBar.delegate = self
        
        homeView.newListButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        homeView.segmentedControl.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        homeView.archivedButton.addTarget(self, action: #selector(didTapArchived), for: .touchUpInside)
    }
    
    // MARK: - Core Data Fetch
    
    private func loadLists() {
        allLists = CoreDataManager.shared.fetchAllLists()
    }
    
    @objc func didChangeSegment() {
        homeView.collectionView.reloadData()
        updateUI()
    }
    
    @objc func didTapButton() {
        let vc = NewListViewController()
        vc.onListCreated = { [weak self] newList in
            CoreDataManager.shared.createList(from: newList)
            self?.loadLists()
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapArchived() {
        let vc = ArchivedViewController()
        vc.onListRestored = { [weak self] _ in
            self?.loadLists()
        }
        vc.onListDeleted = { [weak self] _ in
            self?.loadLists()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateUI() {
        homeView.collectionView.reloadData()
        homeView.updateState(hasData: !filteredLists.isEmpty)
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.identifier, for: indexPath) as? ListCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: filteredLists[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 40
        return CGSize(width: width, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let list = filteredLists[indexPath.item]
        let vc = NewListViewController(list: list)
        vc.onListUpdated = { [weak self] updatedList in
            CoreDataManager.shared.updateList(with: updatedList)
            self?.loadLists()
            self?.navigationController?.popViewController(animated: true)
        }
        vc.onListDeleted = { [weak self] deletedList in
            CoreDataManager.shared.deleteList(by: deletedList.id)
            self?.loadLists()
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        homeView.collectionView.reloadData()
        updateUI()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
