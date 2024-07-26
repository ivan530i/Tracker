import UIKit

final class CustomCollection: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var identifier: String
    var collection: Collections
    var didSelectItem: ((String) -> Void)?
    private let collectionHeight = CGFloat(222)
    
    private let collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 32)
        return layout
    }()
    
    
    init(frame: CGRect = .zero, identifier: String, collection: Collections) {
        self.identifier = identifier
        self.collection = collection
        super.init(frame: frame, collectionViewLayout: collectionLayout)
        setupEmojiCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupEmojiCollectionView() {
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        register(SupplementaryView.self,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: "header")
        backgroundColor = .clear
        isScrollEnabled = false
        dataSource = self
        delegate = self
        heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collection {
        case .emoji: return MainHelper.arrayOfEmoji.count
        case .colors: return MainHelper.arrayOfColors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collection {
        case .emoji:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath)
            let view = UILabel(frame: cell.contentView.bounds)
            view.text = MainHelper.arrayOfEmoji[indexPath.row]
            view.font = .systemFont(ofSize: 32)
            view.textAlignment = .center
            cell.addSubview(view)
            return cell
        case .colors:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorsCell", for: indexPath)
            let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            view.layer.cornerRadius = 8
            let colors = colorFromHexToRGB(hexColors: MainHelper.arrayOfColors)
            view.backgroundColor = colors[indexPath.row]
            cell.contentView.addSubview(view)
            view.center = CGPoint(x: cell.contentView.bounds.midX,
                                  y: cell.contentView.bounds.midY)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collection {
        case .emoji:
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.cornerRadius = 8
            cell?.backgroundColor = .ypBackground
            let selectedEmoji = MainHelper.arrayOfEmoji[indexPath.row]
            didSelectItem?(selectedEmoji)
        case .colors:
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 3
            let colors = colorFromHexToRGB(hexColors: MainHelper.arrayOfColors)
            let cellColor = colors[indexPath.row].withAlphaComponent(0.3)
            cell?.layer.borderColor = cellColor.cgColor
            cell?.layer.cornerRadius = 8
            let selectedColor = MainHelper.arrayOfColors[indexPath.row]
            didSelectItem?(selectedColor)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch collection {
        case .emoji:
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.backgroundColor = .clear
        case .colors:
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 0
        }
    }
    
    private func colorFromHexToRGB(hexColors: [String]) -> [UIColor] {
        return hexColors.map { UIColor(hex: $0) }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        var id = ""
        switch kind {
        case UICollectionView.elementKindSectionHeader: id = "header"
        case UICollectionView.elementKindSectionFooter: id = "footer"
        default: id = ""
        }
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: id, for: indexPath)
                as? SupplementaryView else { return UICollectionReusableView() }
        switch collection {
        case .emoji: view.label.text = "Emoji"
        case .colors: view.label.text = "Color"
        }
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
}

