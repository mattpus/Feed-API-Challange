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

	private struct Root: Decodable {
		let items: [Item]
	}

	private struct Item: Decodable {
		let imageID: UUID
		let imageDescription: String?
		let imageLocation: String?
		let imageURL: URL

		enum CodingKeys: String, CodingKey {
			case imageID = "image_id"
			case imageDescription = "image_desc"
			case imageLocation = "image_loc"
			case imageURL = "image_url"
		}
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case let .success((data, response)):
				if response.statusCode == 200,
				   let decodedList = try? JSONDecoder().decode(Root.self, from: data) {
					let feedImages = decodedList.items.map {
						FeedImage(id: $0.imageID,
						          description: $0.imageDescription,
						          location: $0.imageLocation,
						          url: $0.imageURL)
					}
					return completion(.success(feedImages))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}
