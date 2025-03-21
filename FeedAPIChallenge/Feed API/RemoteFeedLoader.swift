//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case .success((let data, let response)):
				if response.statusCode != 200 {
					completion(.failure(Error.invalidData))
					return
				}
				let decodedJsonData = try? JSONSerialization.jsonObject(with: data)
				if decodedJsonData == nil {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}
