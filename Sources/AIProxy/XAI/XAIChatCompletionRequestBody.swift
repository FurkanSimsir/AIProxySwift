//
//  XAIChatCompletionRequestBody.swift
//
//
//  Created by Furkan Simsir on 2/19/25.
//

import Foundation

/// Request body for xAI's Chat Completions API (/v1/chat/completions).
/// See: https://docs.x.ai/api/endpoints#chat-completions
nonisolated public struct XAIChatCompletionRequestBody: Encodable, Sendable {

    // Required

    /// A list of messages comprising the conversation so far.
    public let messages: [Message]

    /// ID of the model to use (e.g. "grok-3-mini-fast", "grok-4-1-fast-non-reasoning").
    public let model: String

    // Optional

    /// Positive values penalize new tokens based on their existing frequency in the text so far.
    /// Number between -2.0 and 2.0. Defaults to 0.
    public let frequencyPenalty: Double?

    /// The maximum number of tokens that can be generated in the chat completion.
    public let maxTokens: Int?

    /// How many chat completion choices to generate for each input message.
    /// Defaults to 1.
    public let n: Int?

    /// Positive values penalize new tokens based on whether they appear in the text so far.
    /// Number between -2.0 and 2.0. Defaults to 0.
    public let presencePenalty: Double?

    /// An object specifying the format that the model must output.
    public let responseFormat: ResponseFormat?

    /// If specified, the system will make a best effort to sample deterministically.
    public let seed: Int?

    /// Up to 4 sequences where the API will stop generating further tokens.
    public let stop: [String]?

    /// If set, partial message deltas will be sent as server-sent events.
    public var stream: Bool?

    /// Options for streaming response.
    public var streamOptions: StreamOptions?

    /// What sampling temperature to use, between 0 and 2. Defaults to 1.
    public let temperature: Double?

    /// A list of tools the model may call. Currently, only functions are supported.
    public let tools: [Tool]?

    /// Controls which (if any) tool is called by the model.
    public let toolChoice: ToolChoice?

    /// An alternative to sampling with temperature, called nucleus sampling.
    /// Defaults to 1.
    public let topP: Double?

    private enum CodingKeys: String, CodingKey {
        case frequencyPenalty = "frequency_penalty"
        case maxTokens = "max_tokens"
        case messages
        case model
        case n
        case presencePenalty = "presence_penalty"
        case responseFormat = "response_format"
        case seed
        case stop
        case stream
        case streamOptions = "stream_options"
        case temperature
        case tools
        case toolChoice = "tool_choice"
        case topP = "top_p"
    }

    public init(
        messages: [XAIChatCompletionRequestBody.Message],
        model: String,
        frequencyPenalty: Double? = nil,
        maxTokens: Int? = nil,
        n: Int? = nil,
        presencePenalty: Double? = nil,
        responseFormat: XAIChatCompletionRequestBody.ResponseFormat? = nil,
        seed: Int? = nil,
        stop: [String]? = nil,
        stream: Bool? = nil,
        streamOptions: XAIChatCompletionRequestBody.StreamOptions? = nil,
        temperature: Double? = nil,
        tools: [XAIChatCompletionRequestBody.Tool]? = nil,
        toolChoice: XAIChatCompletionRequestBody.ToolChoice? = nil,
        topP: Double? = nil
    ) {
        self.messages = messages
        self.model = model
        self.frequencyPenalty = frequencyPenalty
        self.maxTokens = maxTokens
        self.n = n
        self.presencePenalty = presencePenalty
        self.responseFormat = responseFormat
        self.seed = seed
        self.stop = stop
        self.stream = stream
        self.streamOptions = streamOptions
        self.temperature = temperature
        self.tools = tools
        self.toolChoice = toolChoice
        self.topP = topP
    }
}

// MARK: - StreamOptions
extension XAIChatCompletionRequestBody {
    nonisolated public struct StreamOptions: Encodable, Sendable {
        let includeUsage: Bool

        private enum CodingKeys: String, CodingKey {
            case includeUsage = "include_usage"
        }
    }
}

// MARK: - Message
extension XAIChatCompletionRequestBody {
    nonisolated public enum Message: Encodable, Sendable {
        /// A system message
        case system(content: String)

        /// A user message with text or multimodal content
        case user(content: UserContent)

        /// An assistant message
        case assistant(content: String)

        /// A tool response message
        case tool(content: String, toolCallID: String)

        private enum CodingKeys: String, CodingKey {
            case content
            case role
            case toolCallId = "tool_call_id"
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .system(let content):
                try container.encode("system", forKey: .role)
                try container.encode(content, forKey: .content)
            case .user(let content):
                try container.encode("user", forKey: .role)
                try container.encode(content, forKey: .content)
            case .assistant(let content):
                try container.encode("assistant", forKey: .role)
                try container.encode(content, forKey: .content)
            case .tool(let content, let toolCallID):
                try container.encode("tool", forKey: .role)
                try container.encode(content, forKey: .content)
                try container.encode(toolCallID, forKey: .toolCallId)
            }
        }
    }
}

// MARK: - Message.UserContent
extension XAIChatCompletionRequestBody.Message {
    nonisolated public enum UserContent: Encodable, Sendable {
        /// A simple text message
        case text(String)

        /// An array of content parts (text and/or images)
        case parts([ContentPart])

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .text(let text):
                try container.encode(text)
            case .parts(let parts):
                try container.encode(parts)
            }
        }
    }
}

// MARK: - Message.UserContent.ContentPart
extension XAIChatCompletionRequestBody.Message.UserContent {
    nonisolated public enum ContentPart: Encodable, Sendable {
        /// Text content
        case text(String)

        /// An image URL (typically a base64 data URI)
        case imageURL(URL, detail: ImageDetail? = nil)

        private enum RootKey: String, CodingKey {
            case type
            case text
            case imageURL = "image_url"
        }

        private enum ImageKey: CodingKey {
            case url
            case detail
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: RootKey.self)
            switch self {
            case .text(let text):
                try container.encode("text", forKey: .type)
                try container.encode(text, forKey: .text)
            case .imageURL(let url, let detail):
                try container.encode("image_url", forKey: .type)
                var nestedContainer = container.nestedContainer(keyedBy: ImageKey.self, forKey: .imageURL)
                try nestedContainer.encode(url, forKey: .url)
                if let detail = detail {
                    try nestedContainer.encode(detail, forKey: .detail)
                }
            }
        }
    }
}

// MARK: - ImageDetail
extension XAIChatCompletionRequestBody.Message.UserContent.ContentPart {
    nonisolated public enum ImageDetail: String, Encodable, Sendable {
        case auto
        case low
        case high
    }
}

// MARK: - ResponseFormat
extension XAIChatCompletionRequestBody {
    nonisolated public enum ResponseFormat: Encodable, Sendable {
        /// Enables JSON mode.
        case jsonObject

        /// Enables Structured Outputs with a JSON schema.
        case jsonSchema(
            name: String,
            description: String? = nil,
            schema: [String: AIProxyJSONValue]? = nil,
            strict: Bool? = nil
        )

        /// Instructs the model to produce text only.
        case text

        private enum RootKey: String, CodingKey {
            case type
            case jsonSchema = "json_schema"
        }

        private enum SchemaKey: String, CodingKey {
            case description
            case name
            case schema
            case strict
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: RootKey.self)
            switch self {
            case .jsonObject:
                try container.encode("json_object", forKey: .type)
            case .jsonSchema(let name, let description, let schema, let strict):
                try container.encode("json_schema", forKey: .type)
                var nestedContainer = container.nestedContainer(
                    keyedBy: SchemaKey.self,
                    forKey: .jsonSchema
                )
                try nestedContainer.encode(name, forKey: .name)
                try nestedContainer.encodeIfPresent(description, forKey: .description)
                try nestedContainer.encodeIfPresent(schema, forKey: .schema)
                try nestedContainer.encodeIfPresent(strict, forKey: .strict)
            case .text:
                try container.encode("text", forKey: .type)
            }
        }
    }
}

// MARK: - Tool
extension XAIChatCompletionRequestBody {
    nonisolated public enum Tool: Encodable, Sendable {
        /// A function that the model can call.
        case function(
            name: String,
            description: String?,
            parameters: [String: AIProxyJSONValue]?,
            strict: Bool?
        )

        private enum RootKey: CodingKey {
            case type
            case function
        }

        private enum FunctionKey: CodingKey {
            case description
            case name
            case parameters
            case strict
        }

        public func encode(to encoder: any Encoder) throws {
            switch self {
            case .function(let name, let description, let parameters, let strict):
                var container = encoder.container(keyedBy: RootKey.self)
                try container.encode("function", forKey: .type)
                var functionContainer = container.nestedContainer(
                    keyedBy: FunctionKey.self,
                    forKey: .function
                )
                try functionContainer.encode(name, forKey: .name)
                try functionContainer.encodeIfPresent(description, forKey: .description)
                try functionContainer.encodeIfPresent(parameters, forKey: .parameters)
                try functionContainer.encodeIfPresent(strict, forKey: .strict)
            }
        }
    }
}

// MARK: - ToolChoice
extension XAIChatCompletionRequestBody {
    nonisolated public enum ToolChoice: Encodable, Sendable {
        /// The model will not call any tool.
        case none

        /// The model can pick between generating a message or calling one or more tools.
        case auto

        /// The model must call one or more tools.
        case required

        /// Forces the model to call a specific function.
        case specific(functionName: String)

        private enum RootKey: CodingKey {
            case type
            case function
        }

        private enum FunctionKey: CodingKey {
            case name
        }

        public func encode(to encoder: any Encoder) throws {
            switch self {
            case .none:
                var container = encoder.singleValueContainer()
                try container.encode("none")
            case .auto:
                var container = encoder.singleValueContainer()
                try container.encode("auto")
            case .required:
                var container = encoder.singleValueContainer()
                try container.encode("required")
            case .specific(let functionName):
                var container = encoder.container(keyedBy: RootKey.self)
                try container.encode("function", forKey: .type)
                var functionContainer = container.nestedContainer(
                    keyedBy: FunctionKey.self,
                    forKey: .function
                )
                try functionContainer.encode(functionName, forKey: .name)
            }
        }
    }
}
