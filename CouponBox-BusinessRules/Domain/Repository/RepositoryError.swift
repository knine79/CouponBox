//
//  RepositoryError.swift
//  CouponBox-BusinessRules
//
//  Created by Samuel Kim on 11/2/23.
//

import Foundation

public enum RepositoryError: LocalizedError {
    case entityNotFoundError
    case alreadyExistItem
    case itemNotFound
    
    public var errorDescription: String? {
        switch self {
        case .entityNotFoundError:
            "데이터 테이블을 찾을 수 없습니다.".locaized
        case .alreadyExistItem:
            "이미 존재하는 데이터입니다.".locaized
        case .itemNotFound:
            "존재하지 않는 데이터입니다.".locaized
        }
    }
}
