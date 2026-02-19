//
//  XAIService.swift
//
//
//  Created by Furkan Simsir on 2/19/25.
//

import Foundation

@AIProxyActor public protocol XAIService: Sendable {

    /// Initiates a non-streaming chat completion request to xAI.
    /// xAI's chat completions API is OpenAI-compatible, so this uses OpenAI request/response types.
    ///
    /// - Parameters:
    ///   - body: The chat completion request body. See this reference:
    ///           https://docs.x.ai/api/endpoints#chat-completions
    ///   - secondsToWait: Seconds to wait before raising `URLError.timedOut`
    /// - Returns: A ChatCompletionResponse
    func chatCompletionRequest(
        body: OpenAIChatCompletionRequestBody,
        secondsToWait: UInt
    ) async throws -> OpenAIChatCompletionResponseBody

    /// Initiates a streaming chat completion request to xAI.
    /// xAI's chat completions API is OpenAI-compatible, so this uses OpenAI request/response types.
    ///
    /// - Parameters:
    ///   - body: The chat completion request body. See this reference:
    ///           https://docs.x.ai/api/endpoints#chat-completions
    ///   - secondsToWait: Seconds to wait before raising `URLError.timedOut`
    /// - Returns: An async sequence of completion chunks
    func streamingChatCompletionRequest(
        body: OpenAIChatCompletionRequestBody,
        secondsToWait: UInt
    ) async throws -> AsyncThrowingStream<OpenAIChatCompletionChunk, Error>

    /// Initiates an image generation request to xAI's /v1/images/generations endpoint.
    ///
    /// - Parameters:
    ///   - body: The image generation request body
    ///   - secondsToWait: Seconds to wait before raising `URLError.timedOut`
    /// - Returns: A response body containing the generated image(s)
    func createImageRequest(
        body: XAICreateImageRequestBody,
        secondsToWait: UInt
    ) async throws -> OpenAICreateImageResponseBody

    /// Initiates an image edit request to xAI's /v1/images/edits endpoint.
    /// xAI requires a JSON body (not multipart/form-data) for image editing,
    /// with source images passed as base64 data URIs.
    ///
    /// - Parameters:
    ///   - body: The image edit request body
    ///   - secondsToWait: Seconds to wait before raising `URLError.timedOut`
    /// - Returns: A response body containing the edited image(s)
    func createImageEditRequest(
        body: XAICreateImageEditRequestBody,
        secondsToWait: UInt
    ) async throws -> OpenAICreateImageResponseBody
}
