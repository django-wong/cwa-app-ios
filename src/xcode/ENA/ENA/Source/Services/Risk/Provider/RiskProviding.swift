//
// 🦠 Corona-Warn-App
//

import Foundation

typealias RiskProviderResult = Result<Risk, RiskProviderError>

enum RiskProviderError: Error {
	case inactive
	case timeout
	case riskProviderIsRunning
	case missingAppConfig
	case failedKeyPackageDownload(KeyPackageDownloadError)
	case failedRiskCalculation
	case failedRiskDetection(ExposureDetection.DidEndPrematurelyReason)

	var isAlreadyRunningError: Bool {
		switch self {
		case .riskProviderIsRunning:
			return true
		case .failedKeyPackageDownload(let keyPackageDownloadError):
			return keyPackageDownloadError == .downloadIsRunning
		case .failedRiskDetection(let didEndPrematuralyReason):
			if case let .noExposureWindows(exposureWindowsError) = didEndPrematuralyReason {
				if let exposureDetectionError = exposureWindowsError as? ExposureDetectionError {
					return exposureDetectionError == .isAlreadyRunning
				}
			}
		default:
			break
		}

		return false
	}
}

enum RiskProviderActivityState {
	case idle
	case riskRequested
	case downloading
	case detecting

	var isActive: Bool {
		self == .downloading || self == .detecting
	}
}

protocol RiskProviding: AnyObject {

	var riskProvidingConfiguration: RiskProvidingConfiguration { get set }
	var exposureManagerState: ExposureManagerState { get set }
	var activityState: RiskProviderActivityState { get }
	var manualExposureDetectionState: ManualExposureDetectionState? { get }
	var nextExposureDetectionDate: Date { get }

	func observeRisk(_ consumer: RiskConsumer)
	func removeRisk(_ consumer: RiskConsumer)

	func requestRisk(userInitiated: Bool, timeoutInterval: TimeInterval)
}

extension RiskProviding {

	func requestRisk(userInitiated: Bool) {
		requestRisk(userInitiated: userInitiated, timeoutInterval: TimeInterval(60 * 8))
	}

}
