//
//  XAICreateImageRequestBody.swift
//
//
//  Created by Furkan Simsir on 2/19/25.
//

import Foundation

/// Request body for xAI's image generation endpoint.
/// xAI uses an OpenAI-compatible `/v1/images/generations` endpoint but with
/// xAI-specific model names (e.g. `grok-imagine-image`) that are not part of
/// OpenAI's model enum.
///
/// See: https://docs.x.ai/api/endpoints#images
nonisolated public struct XAICreateImageRequestBody: Encodable, Sendable {

    /// The model to use for image generation, e.g. `grok-imagine-image`.
    public let model: String

    /// A text description of the desired image(s).
    public let prompt: String

    /// The number of images to generate.
    public let n: Int?

    /// The format in which generated images are returned.
    /// Must be one of `b64_json` or `url`.
    public let responseFormat: String?

    enum CodingKeys: String, CodingKey {
        case model
        case prompt
        case n
        case responseFormat = "response_format"
    }

    public init(
        model: String,
        prompt: String,
        n: Int? = nil,
        responseFormat: String? = nil
    ) {
        self.model = model
        self.prompt = prompt
        self.n = n
        self.responseFormat = responseFormat
    }
}
