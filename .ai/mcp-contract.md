# App MCP

The agent talks to a running application through `tools/app-mcp/server.mjs`. The server is registered in `.mcp.json` only when the product is a service, UI, or mobile app.

Tools: `health`, `get_state`, `invoke`, `screenshot`.

The non-production profile must expose:

- `GET /__ai/health`
- `GET /__ai/state?scope=`
- `POST /__ai/invoke`
- `GET /__ai/screenshot?name=`

Do not expose these routes in production. A library has no process, so the MCP stays unregistered until one exists.
