//
//  ViewController.swift
//  ExRxDataSource
//
//  Created by Jake.K on 2022/06/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController {
  private let tableView: UITableView = {
    let view = UITableView()
    view.allowsSelection = true
    view.backgroundColor = .clear
    view.separatorStyle = .none
    view.bounces = true
    view.showsVerticalScrollIndicator = true
    view.contentInset = .zero
    view.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  var items = BehaviorSubject<[SomeType.Model]>(
    value: [
      SomeType.Model(
        model: .date(date: Date()),
        items: (0...100)
          .map(String.init)
          .map { SomeType.Model.Item.record(title: $0) }
      )
    ]
  )
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Layout
    self.view.addSubview(self.tableView)
    NSLayoutConstraint.activate([
      self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
    ])

    // Binding
    let dataSource = RxTableViewSectionedReloadDataSource<SomeType.Model> { dataSource, tableView, indexPath, item in
      switch item {
      case let .record(title):
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = title
        return cell
      }
    }
    dataSource.canEditRowAtIndexPath = { _, _ in true }
    
    self.items
      .distinctUntilChanged()
      .bind(to: self.tableView.rx.items(dataSource: dataSource))
      .disposed(by: self.disposeBag)
    
    self.tableView.rx.itemDeleted
      .observe(on: MainScheduler.asyncInstance)
      .withUnretained(self)
      .bind { ss, indexPath in
        guard var section = try? ss.items.value() else { return }
        var updateSection = section[indexPath.section]
        
        // Update item
        updateSection.items.remove(at: indexPath.item)
        
        // Update section
        section[indexPath.section] = updateSection
        
        // Emit
        ss.items.onNext(section)
      }
      .disposed(by: self.disposeBag)
  }
}
