//
//  XAIDirectService.swift
//
//
//  Created by Furkan Simsir on 2/19/25.
//

import Foundation

@AIProxyActor final class XAIDirectService: XAIService, DirectService, Sendable {
    private let unprotectedAPIKey: String
    private let baseURL: String

    /// This initializer is not public on purpose.
    /// Customers are expected to use the factory `AIProxy.xAIDirectService` defined in AIProxy.swift
    nonisolated init(
        unprotectedAPIKey: String,
        baseURL: String? = nil
    ) {
        self.unprotectedAPIKey = unprotectedAPIKey
        self.baseURL = baseURL ?? "https://api.x.ai"
    }

    func chatCompletionRequest(
        body: OpenAIChatCompletionRequestBody,
        secondsToWait: UInt
    ) async throws -> OpenAIChatCompletionResponseBody {
        var body = body
        body.stream = false
        body.streamOptions = nil
        let request = try AIProxyURLRequest.createDirect(
            baseURL: self.baseURL,
            path: "/v1/chat/completions",
            body: try body.serialize(),
            verb: .post,
            secondsToWait: secondsToWait,
            contentType: "application/json",
            additionalHeaders: [
                "Authorization": "Bearer \(self.unprotectedAPIKey)"
            ]
        )
        return try await self.makeRequestAndDeserializeResponse(request)
    }

    func streamingChatCompletionRequest(
        body: OpenAIChatCompletionRequestBody,
        secondsToWait: UInt
    ) async throws -> AsyncThrowingStream<OpenAIChatCompletionChunk, Error> {
        var body = body
        body.stream = true
        body.streamOptions = .init(includeUsage: true)
        let request = try AIProxyURLRequest.createDirect(
            baseURL: self.baseURL,
            path: "/v1/chat/completions",
            body: try body.serialize(),
            verb: .post,
            secondsToWait: secondsToWait,
            contentType: "application/json",
            additionalHeaders: [
                "Authorization": "Bearer \(self.unprotectedAPIKey)"
            ]
        )
        return try await self.makeRequestAndDeserializeStreamingChunks(request)
    }

    func createImageRequest(
        body: XAICreateImageRequestBody,
        secondsToWait: UInt
    ) async throws -> OpenAICreateImageResponseBody {
        let request = try AIProxyURLRequest.createDirect(
            baseURL: self.baseURL,
            path: "/v1/images/generations",
            body: try body.serialize(),
            verb: .post,
            secondsToWait: secondsToWait,
            contentType: "application/json",
            additionalHeaders: [
                "Authorization": "Bearer \(self.unprotectedAPIKey)"
            ]
        )
        return try await self.makeRequestAndDeserializeResponse(request)
    }

    func createImageEditRequest(
        body: XAICreateImageEditRequestBody,
        secondsToWait: UInt
    ) async throws -> OpenAICreateImageResponseBody {
        let request = try AIProxyURLRequest.createDirect(
            baseURL: self.baseURL,
            path: "/v1/images/edits",
            body: try body.serialize(),
            verb: .post,
            secondsToWait: secondsToWait,
            contentType: "application/json",
            additionalHeaders: [
                "Authorization": "Bearer \(self.unprotectedAPIKey)"
            ]
        )
        return try await self.makeRequestAndDeserializeResponse(request)
    }
}
