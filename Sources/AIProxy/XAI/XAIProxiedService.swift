//
//  XAIProxiedService.swift
//
//
//  Created by Furkan Simsir on 2/19/25.
//

import Foundation

@AIProxyActor final class XAIProxiedService: XAIService, ProxiedService, Sendable {
    private let partialKey: String
    private let serviceURL: String
    private let clientID: String?

    /// This initializer is not public on purpose.
    /// Customers are expected to use the factory `AIProxy.xAIService` defined in AIProxy.swift
    nonisolated init(
        partialKey: String,
        serviceURL: String,
        clientID: String?
    ) {
        self.partialKey = partialKey
        self.serviceURL = serviceURL
        self.clientID = clientID
    }

    func chatCompletionRequest(
        body: OpenAIChatCompletionRequestBody,
        secondsToWait: UInt
    ) async throws -> OpenAIChatCompletionResponseBody {
        var body = body
        body.stream = false
        body.streamOptions = nil
        let request = try await AIProxyURLRequest.create(
            partialKey: self.partialKey,
            serviceURL: self.serviceURL,
            clientID: self.clientID,
            proxyPath: "/v1/chat/completions",
            body: try body.serialize(),
            verb: .post,
            secondsToWait: secondsToWait,
            contentType: "application/json"
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
        let request = try await AIProxyURLRequest.create(
            partialKey: self.partialKey,
            serviceURL: self.serviceURL,
            clientID: self.clientID,
            proxyPath: "/v1/chat/completions",
            body: try body.serialize(),
            verb: .post,
            secondsToWait: secondsToWait,
            contentType: "application/json"
        )
        return try await self.makeRequestAndDeserializeStreamingChunks(request)
    }

    func createImageRequest(
        body: XAICreateImageRequestBody,
        secondsToWait: UInt
    ) async throws -> OpenAICreateImageResponseBody {
        let request = try await AIProxyURLRequest.create(
            partialKey: self.partialKey,
            serviceURL: self.serviceURL,
            clientID: self.clientID,
            proxyPath: "/v1/images/generations",
            body: try body.serialize(),
            verb: .post,
            secondsToWait: secondsToWait,
            contentType: "application/json"
        )
        return try await self.makeRequestAndDeserializeResponse(request)
    }

    func createImageEditRequest(
        body: XAICreateImageEditRequestBody,
        secondsToWait: UInt
    ) async throws -> OpenAICreateImageResponseBody {
        let request = try await AIProxyURLRequest.create(
            partialKey: self.partialKey,
            serviceURL: self.serviceURL,
            clientID: self.clientID,
            proxyPath: "/v1/images/edits",
            body: try body.serialize(),
            verb: .post,
            secondsToWait: secondsToWait,
            contentType: "application/json"
        )
        return try await self.makeRequestAndDeserializeResponse(request)
    }
}
