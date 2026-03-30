//
//  ArchivedViewController.swift
//  Task Share
//
//  Created by Antigravity on 11/03/26.
//

import UIKit

class ArchivedViewController: UIViewController {
    
    let archivedView = ArchivedView()
    var archivedLists: [List] = []
    var onListRestored: ((List) -> Void)?
    var onListDeleted: ((List) -> Void)?
    
    override func loadView() {
        view = archivedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        archivedView.backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        archivedView.collectionView.dataSource = self
        archivedView.collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadArchivedLists()
    }
    
    private func loadArchivedLists() {
        archivedLists = CoreDataManager.shared.fetchArchivedLists()
        archivedView.collectionView.reloadData()
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension ArchivedViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return archivedLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.identifier, for: indexPath) as? ListCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: archivedLists[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 40
        return CGSize(width: width, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let list = archivedLists[indexPath.item]
        let vc = NewListViewController(list: list)
        vc.onListUpdated = { [weak self] updatedList in
            CoreDataManager.shared.updateList(with: updatedList)
            self?.loadArchivedLists()
            if !updatedList.shouldBeArchived {
                self?.onListRestored?(updatedList)
            }
            self?.navigationController?.popViewController(animated: true)
        }
        vc.onListDeleted = { [weak self] deletedList in
            CoreDataManager.shared.deleteList(by: deletedList.id)
            self?.loadArchivedLists()
            self?.onListDeleted?(deletedList)
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
