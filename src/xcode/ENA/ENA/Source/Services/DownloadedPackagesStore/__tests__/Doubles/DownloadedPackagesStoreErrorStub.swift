//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import XCTest
@testable import ENA

class DownloadedPackagesStoreErrorStub: DownloadedPackagesStoreV1 {

	private let error: SQLiteErrorCode

	init(error: SQLiteErrorCode) {
		self.error = error
	}

	func open() { }

	func close() { }

	func set(country: Country.ID, day: String, package: SAPDownloadedPackage) -> Result<Void, SQLiteErrorCode> {
		return .failure(error)
	}

	func set(country: Country.ID, hour: Int, day: String, package: SAPDownloadedPackage) -> Result<Void, SQLiteErrorCode> {
		return .failure(error)
	}

	func package(for day: String, country: Country.ID) -> SAPDownloadedPackage? {
		return nil
	}

	func hourlyPackages(for day: String, country: Country.ID) -> [SAPDownloadedPackage] {
		return [SAPDownloadedPackage]()
	}

	func allDays(country: Country.ID) -> [String] {
		return [String]()
	}

	func hours(for day: String, country: Country.ID) -> [Int] {
		return [Int]()
	}

	func reset() { }

	func deleteHourPackage(for day: String, hour: Int, country: Country.ID) { }

	func deleteDayPackage(for day: String, country: Country.ID) { }

	var keyValueStore: Store?

}
