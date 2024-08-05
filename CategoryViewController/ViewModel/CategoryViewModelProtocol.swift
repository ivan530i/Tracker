import Foundation

protocol CategoryViewModelProtocol {
    var dataUpdated: ( () -> Void )? { get set }
    var updateCategory: ( (String) -> Void)? { get set }
    
    func createButtonTapped()
    func getCategoryCount() -> Int
    func getCategoryName(_ indexPath: IndexPath) -> String
    func sendLastChosenCategoryToStore(categoryNameToPass: String)
    func showOrHidePlaceholder()
}
