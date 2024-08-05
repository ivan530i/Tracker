import UIKit

final class CategoryViewModel: CategoryViewModelProtocol {
    
    private let dataManager = CoreDataManager.shared
    weak var view: CategoryViewControllerProtocol?
    
    private var categories = [String]() {
        didSet {
            dataUpdated?()
        }
    }
    
    var dataUpdated: ( () -> Void )?
    var updateCategory: ( (String) -> Void)?
    
    init() {
        getCategoriesFromCD()
    }
    
    func createButtonTapped() {
        let createCategoryVC = CreateCategoryVC()
        let navVC = UINavigationController(rootViewController: createCategoryVC)
        createCallback(createCategoryVC)
        view?.showScreen(navVC)
    }
    
    func showOrHidePlaceholder() {
        if categories.isEmpty {
            view?.showPlaceholder()
        } else {
            view?.hidePlaceholder()
        }
    }
    
    func sendLastChosenCategoryToStore(categoryNameToPass: String) {
        dataManager.sendLastChosenCategoryToStore(categoryName: categoryNameToPass)
        updateCategory?(categoryNameToPass)
    }
    
    func getCategoryCount() -> Int {
        categories.count
    }
    
    func getCategoryName(_ indexPath: IndexPath) -> String {
        categories[indexPath.row]
    }
    
    private func createCallback(_ createCategoryVC: CreateCategoryVC) {
        createCategoryVC.updateCategory = { [weak self] in
            self?.getCategoriesFromCD()
        }
    }
    
    private func getCategoriesFromCD() {
        let listOfCategories = dataManager.getCategoriesFromCoreData()
        categories = []
        listOfCategories.forEach { cat in
            guard let catName = cat.header else { return }
            categories.append(catName)
        }
    }
}
