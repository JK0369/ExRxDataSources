//
//  SomeType.swift
//  ExRxDataSource
//
//  Created by Jake.K on 2022/06/23.
//

import RxDataSources

struct SomeType {
  typealias Model = SectionModel<Section, Item>
  
  enum Section: Equatable {
    case date(date: Date)
  }
  enum Item: Equatable {
    case record(title: String?)
  }
}
