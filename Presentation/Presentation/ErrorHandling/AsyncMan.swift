//
// Created by Shaban on 09/06/2022.
// Copyright (c) 2022 sha. All rights reserved.
//

import Foundation

public typealias AsyncRequest = () async throws -> Void
public typealias AsyncCompletion<T> = (T) -> Void

public struct AsyncMan {
    /// Set NSError handlers
    public static var nsErrorHandlers: Array<NSErrorHandler> = []

    /// Set Error handlers
    public static var errorHandlers: Array<ErrorHandler> = []

    /// Set Resumable handlers
    public static var resumableHandlers: Array<ResumableHandler> = []

    public init() {
    }

    public func request(
            _ operation: @escaping AsyncRequest,
            options: RequestOptions = RequestOptions.defaultOptions(),
            presentable: Presentable? = nil
    ) {
        if options.showLoading {
            presentable?.showLoading()
        }

        guard NetworkState.isConnected else {
            handle(error: AppError.connection, presentable: presentable)
            if options.hideLoading {
                presentable?.hideLoading()
            }
            return
        }

        Task {
            do {
                try await operation()
            } catch {
                options.doOnError?(error)

                if options.inlineHandling?(error) == true {
                    return
                }
                handle(error: error, presentable: presentable)
            }
            if options.hideLoading {
                presentable?.hideLoading()
            }
        }
    }

    private func handle(error: Error, presentable: Presentable?) {
        ErrorProcessor.shared.process(error: error, presentable: presentable)
    }
}
