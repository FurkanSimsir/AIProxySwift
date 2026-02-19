//
//  XAICreateImageEditRequestBody.swift
//
//
//  Created by Furkan Simsir on 2/19/25.
//

import Foundation

/// Request body for xAI's image edit endpoint.
/// Unlike OpenAI's multipart/form-data approach, xAI requires a JSON body
/// with the source image passed as a base64 data URI.
///
/// See: https://docs.x.ai/api/endpoints#edit-image
nonisolated public struct XAICreateImageEditRequestBody: Encodable, Sendable {

    /// The model to use for image editing, e.g. `grok-imagine-image`.
    public let model: String

    /// A text description of the desired edit.
    public let prompt: String

    /// The source image to edit, referenced as a data URI (e.g. `data:image/jpeg;base64,...`).
    public let image: ImageReference

    /// The number of images to generate.
    public let n: Int?

    /// The format in which generated images are returned.
    /// Must be one of `b64_json` or `url`.
    public let responseFormat: String?

    enum CodingKeys: String, CodingKey {
        case model
        case prompt
        case image
        case n
        case responseFormat = "response_format"
    }

    public init(
        model: String,
        prompt: String,
        image: ImageReference,
        n: Int? = nil,
        responseFormat: String? = nil
    ) {
        self.model = model
        self.prompt = prompt
        self.image = image
        self.n = n
        self.responseFormat = responseFormat
    }
}

extension XAICreateImageEditRequestBody {
    nonisolated public struct ImageReference: Encodable, Sendable {
        /// The image URL, typically a base64 data URI (e.g. `data:image/jpeg;base64,...`).
        public let url: String

        /// The type of the image reference. Use `image_url` for data URIs.
        public let type: String

        public init(url: String, type: String = "image_url") {
            self.url = url
            self.type = type
        }
    }
}
