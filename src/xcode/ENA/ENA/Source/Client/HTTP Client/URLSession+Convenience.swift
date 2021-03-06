//
// 🦠 Corona-Warn-App
//

import Foundation

extension URLSession {
	typealias Completion = Response.Completion

	// This method executes HTTP GET requests.
	func GET(_ url: URL, extraHeaders: [String: String]? = nil, completion: @escaping Completion) {
		response(for: URLRequest(url: url), isFake: false, extraHeaders: extraHeaders, completion: completion)
	}

	// This method executes HTTP POST requests.
	func POST(_ url: URL, extraHeaders: [String: String]? = nil, completion: @escaping Completion) {
		var request = URLRequest(url: url)
		request.httpMethod = "POST"

		response(for: request, isFake: false, extraHeaders: extraHeaders, completion: completion)
	}

	// This method executes HTTP POST with HTTP BODY requests.
	func POST(_ url: URL, _ body: Data, extraHeaders: [String: String]? = nil, completion: @escaping Completion) {
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.httpBody = body
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		response(for: request, isFake: false, extraHeaders: extraHeaders, completion: completion)
	}

	// This method executes HTTP requests.
	// It does some additional checks - purely for convenience:
	// - if there is an error it aborts
	// - if there is either no HTTP body and/or HTTPURLResponse it aborts
	// Note that, if we send out a fake request, we omit
	// the response and give back a fakeResponse failure.
	func response(
		for request: URLRequest,
		isFake: Bool = false,
		extraHeaders: [String: String]? = nil,
		completion: @escaping Completion
	) {
		// modify request - if needed
		var request = request
		extraHeaders?.forEach {
			request.addValue($1, forHTTPHeaderField: $0)
		}

		dataTask(with: request) { data, response, error in
			guard !isFake else {
				completion(.failure(.fakeResponse))
				return
			}

			guard let response = response as? HTTPURLResponse else {
				completion(.failure(.noResponse))
				return
			}

			if let error = error {
				completion(.failure(.httpError(error, response)))
				return
			}

			guard let data = data else {
				completion(.failure(.noResponse))
				return
			}

			completion(
				.success(
					.init(body: data, statusCode: response.statusCode, httpResponse: response)
				)
			)
		}
		.resume()
	}
}

extension URLSession {
	/// Represents a response produced by the convenience extensions on `URLSession`.
	struct Response {
		// MARK: Properties

		let body: Data?
		let statusCode: Int
		let httpResponse: HTTPURLResponse

		// MARK: Working with a Response

		var hasAcceptableStatusCode: Bool {
			type(of: self).acceptableStatusCodes.contains(statusCode)
		}

		private static let acceptableStatusCodes = (200 ... 299)
	}
}

extension URLSession.Response {
	enum Failure: Error {
		/// The session received an `Error`.
		case httpError(Error, HTTPURLResponse)
		/// The session did not receive an error but nor either an `HTTPURLResponse`/HTTP body.
		case noResponse
		case teleTanAlreadyUsed
		case qrAlreadyUsed
		case qrDoesNotExist
		case regTokenNotExist
		case invalidResponse
		case serverError(Int)
		case fakeResponse
	}

	typealias Completion = (Result<URLSession.Response, Failure>) -> Void
}
