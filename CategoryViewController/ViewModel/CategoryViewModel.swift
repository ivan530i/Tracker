import UIKit

final class CategoryViewModel: CategoryViewModelProtocol {
    
    private let dataManager = CoreDataManager.shared
    weak var view: CategoryViewControllerProtocol?
    
    private var categories = [String]() {
        didSet {
            dataUpdated?()
            viewDidLoad()
        }
    }
    
    var dataUpdated: ( () -> Void )?
    var updateCategory: ( (String) -> Void)?
    
    init() {
        getCategoriesFromCD()
    }
    
    func viewDidLoad() {
        view?.isPlaceholderShown(categories.isEmpty)
    }
    
    func createButtonTapped() {
        let createCategoryVC = CreateCategoryVC()
        let navVC = UINavigationController(rootViewController: createCategoryVC)
        createCallback(createCategoryVC)
        view?.showScreen(navVC)
    }
    
    func categoryCellSelected(cell: CustomCategoryCell) {
        guard let categoryNameToPass = cell.titleLabel.text else {
            print("Oooops"); return }
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
        var newCategories = [String]()
        listOfCategories.forEach { cat in
            guard let catName = cat.header else { return }
            newCategories.append(catName)
        }
        categories = newCategories
    }
}
