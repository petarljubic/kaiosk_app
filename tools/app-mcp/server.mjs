import { Buffer } from "node:buffer";

const base = process.env.APP_BASE_URL ?? "http://127.0.0.1:3000";

const tools = [
  {
    name: "health",
    description: "Read the running application's health probe.",
    inputSchema: { type: "object", properties: {}, additionalProperties: false },
  },
  {
    name: "get_state",
    description: "Read application state for a named scope.",
    inputSchema: {
      type: "object",
      properties: { scope: { type: "string" } },
      required: ["scope"],
      additionalProperties: false,
    },
  },
  {
    name: "invoke",
    description: "Invoke a named action on the application probe.",
    inputSchema: {
      type: "object",
      properties: {
        action: { type: "string" },
        payload: { type: "string" },
      },
      required: ["action"],
      additionalProperties: false,
    },
  },
  {
    name: "screenshot",
    description: "Ask the application probe for a screenshot reference.",
    inputSchema: {
      type: "object",
      properties: { name: { type: "string" } },
      required: ["name"],
      additionalProperties: false,
    },
  },
];

function send(message) {
  const payload = Buffer.from(JSON.stringify(message), "utf8");
  process.stdout.write(`Content-Length: ${payload.length}\r\n\r\n`);
  process.stdout.write(payload);
}

function reply(id, result) {
  send({ jsonrpc: "2.0", id, result });
}

function failure(id, message) {
  send({ jsonrpc: "2.0", id, error: { code: -32000, message } });
}

async function probe(path, options = {}) {
  const response = await fetch(new URL(path, base), options);
  const text = await response.text();
  return {
    content: [{ type: "text", text: `${response.status}\n${text}` }],
    isError: !response.ok,
  };
}

async function callTool(name, args) {
  if (name === "health") {
    return probe("/__ai/health");
  }
  if (name === "get_state") {
    return probe(`/__ai/state?scope=${encodeURIComponent(args.scope)}`);
  }
  if (name === "invoke") {
    return probe("/__ai/invoke", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ action: args.action, payload: args.payload ?? null }),
    });
  }
  if (name === "screenshot") {
    return probe(`/__ai/screenshot?name=${encodeURIComponent(args.name)}`);
  }
  throw new Error(`unknown tool: ${name}`);
}

async function handle(message) {
  if (!message || message.jsonrpc !== "2.0") {
    return;
  }
  const { id, method, params } = message;
  if (method === "initialize") {
    reply(id, {
      protocolVersion: "2024-11-05",
      capabilities: { tools: {} },
      serverInfo: { name: "app", version: "0.1.0" },
    });
    return;
  }
  if (method === "notifications/initialized" || method === "initialized") {
    return;
  }
  if (method === "ping") {
    reply(id, {});
    return;
  }
  if (method === "tools/list") {
    reply(id, { tools });
    return;
  }
  if (method === "tools/call") {
    try {
      reply(id, await callTool(params?.name, params?.arguments ?? {}));
    } catch (error) {
      failure(id, error instanceof Error ? error.message : String(error));
    }
    return;
  }
  if (id !== undefined) {
    failure(id, `unsupported method: ${method}`);
  }
}

let buffer = Buffer.alloc(0);
process.stdin.on("data", (chunk) => {
  buffer = Buffer.concat([buffer, chunk]);
  while (true) {
    const headerEnd = buffer.indexOf("\r\n\r\n");
    if (headerEnd === -1) {
      return;
    }
    const header = buffer.slice(0, headerEnd).toString("utf8");
    const match = header.match(/Content-Length:\s*(\d+)/i);
    if (!match) {
      buffer = Buffer.alloc(0);
      return;
    }
    const length = Number(match[1]);
    const start = headerEnd + 4;
    if (buffer.length < start + length) {
      return;
    }
    const body = buffer.slice(start, start + length).toString("utf8");
    buffer = buffer.slice(start + length);
    void handle(JSON.parse(body));
  }
});
