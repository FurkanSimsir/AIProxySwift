//
//  XAICreateResponseRequestBody.swift
//
//
//  Created by Furkan Simsir on 2/19/25.
//

import Foundation

/// Request body for xAI's Responses API (/v1/responses).
/// See: https://docs.x.ai/api/endpoints#create-responses
nonisolated public struct XAICreateResponseRequestBody: Encodable, Sendable {

    /// Text, image, or file inputs to the model, used to generate a response.
    public let input: OpenAIResponse.Input?

    /// Inserts a system (or developer) message as the first item in the model's context.
    public let instructions: String?

    /// Model ID used to generate the response (e.g. "grok-3-mini-fast").
    public let model: String

    /// The unique ID of the previous response to the model. Use this to create multi-turn conversations.
    public let previousResponseId: String?

    /// Configuration options for reasoning models.
    public let reasoning: Reasoning?

    /// Whether to store the generated model response for later retrieval via API.
    public let store: Bool?

    /// If set, partial response deltas will be sent as server-sent events.
    public var stream: Bool?

    /// What sampling temperature to use, between 0 and 2.
    public let temperature: Double?

    /// Configuration options for a text response from the model.
    public let text: OpenAIResponse.TextConfiguration?

    /// How the model should select which tool (or tools) to use when generating a response.
    public let toolChoice: ToolChoice?

    /// An array of tools the model may call while generating a response.
    public let tools: [Tool]?

    /// An alternative to sampling with temperature, called nucleus sampling.
    public let topP: Double?

    /// The truncation strategy to use for the model response.
    public let truncation: Truncation?

    private enum CodingKeys: String, CodingKey {
        case input
        case instructions
        case model
        case previousResponseId = "previous_response_id"
        case reasoning
        case store
        case stream
        case temperature
        case text
        case toolChoice = "tool_choice"
        case tools
        case topP = "top_p"
        case truncation
    }

    public init(
        input: OpenAIResponse.Input? = nil,
        instructions: String? = nil,
        model: String,
        previousResponseId: String? = nil,
        reasoning: XAICreateResponseRequestBody.Reasoning? = nil,
        store: Bool? = nil,
        stream: Bool? = nil,
        temperature: Double? = nil,
        text: OpenAIResponse.TextConfiguration? = nil,
        toolChoice: XAICreateResponseRequestBody.ToolChoice? = nil,
        tools: [XAICreateResponseRequestBody.Tool]? = nil,
        topP: Double? = nil,
        truncation: XAICreateResponseRequestBody.Truncation? = nil
    ) {
        self.input = input
        self.instructions = instructions
        self.model = model
        self.previousResponseId = previousResponseId
        self.reasoning = reasoning
        self.store = store
        self.stream = stream
        self.temperature = temperature
        self.text = text
        self.toolChoice = toolChoice
        self.tools = tools
        self.topP = topP
        self.truncation = truncation
    }
}

// MARK: - Truncation
extension XAICreateResponseRequestBody {
    nonisolated public enum Truncation: String, Encodable, Sendable {
        case auto
        case disabled
    }
}

// MARK: - Tool
extension XAICreateResponseRequestBody {
    nonisolated public enum Tool: Encodable, Sendable {
        /// Enable web search for the model.
        /// xAI's web search tool has no configurable parameters.
        case webSearch

        /// A function that the model can call.
        case function(FunctionTool)

        private enum CodingKeys: String, CodingKey {
            case type
            case name
            case description
            case parameters
            case strict
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .webSearch:
                try container.encode("web_search", forKey: .type)
            case .function(let tool):
                try container.encode("function", forKey: .type)
                try container.encode(tool.name, forKey: .name)
                try container.encodeIfPresent(tool.description, forKey: .description)
                try container.encode(tool.parameters, forKey: .parameters)
                try container.encodeIfPresent(tool.strict, forKey: .strict)
            }
        }
    }

    nonisolated public struct FunctionTool: Sendable {
        public let name: String
        public let parameters: [String: AIProxyJSONValue]
        public let strict: Bool?
        public let description: String?

        public init(
            name: String,
            parameters: [String: AIProxyJSONValue],
            strict: Bool? = true,
            description: String? = nil
        ) {
            self.name = name
            self.parameters = parameters
            self.strict = strict
            self.description = description
        }
    }
}

// MARK: - ToolChoice
extension XAICreateResponseRequestBody {
    nonisolated public enum ToolChoice: Encodable, Sendable {
        /// The model will not call any tool and instead generates a message.
        case none

        /// The model can pick between generating a message or calling one or more tools.
        case auto

        /// The model must call one or more tools.
        case required

        /// Forces the model to call a specific function.
        case function(name: String)

        private enum RootKey: String, CodingKey {
            case type
            case name
        }

        public func encode(to encoder: Encoder) throws {
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
            case .function(let name):
                var container = encoder.container(keyedBy: RootKey.self)
                try container.encode("function", forKey: .type)
                try container.encode(name, forKey: .name)
            }
        }
    }
}

// MARK: - Reasoning
extension XAICreateResponseRequestBody {
    nonisolated public struct Reasoning: Encodable, Sendable {
        public let effort: Effort?

        public init(effort: Effort? = nil) {
            self.effort = effort
        }

        nonisolated public enum Effort: String, Encodable, Sendable {
            case low
            case medium
            case high
        }
    }
}
