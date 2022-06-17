//
//  RemoteLoader.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 16.06.22.
//

import Foundation

public class RemoteLoader<Resource> {
    private var client: HTTPClient
    private var url: URL
    private var mapper: Mapper
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<Resource, Error>
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    
    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
        self.client = client
        self.url = url
        self.mapper = mapper
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success((data, response)):
                completion(self.map(data: data, response: response))
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private func map(data: Data, response: HTTPURLResponse) -> Result {
        do {
            let resource = try self.mapper(data, response)
            return .success(resource)
        } catch {
            return .failure(Error.invalidData)
        }
    }
}
