# Delphi LSP MCP Server

A Model Context Protocol (MCP) server that exposes Language Server Protocol (LSP) capabilities to AI assistants and other MCP clients.

Supports both:

- Embarcadero Delphi (`DelphiLSP.exe`)
- Free Pascal (`pasls.exe`)

---

## Target Specifications

- MCP Specification: **2025-11-25**
- LSP Specification: **3.17**

---

## Features

- MCP ↔ LSP bridge using JSON-RPC 2.0
- stdio-based transport
- Dynamic workspace discovery
- Semantic code intelligence for AI agents
- Delphi and Free Pascal support
- Debugger synchronization support (`--wait`)
- Automatic project discovery (`.dpr` / `.lpr`)
- LSP retry logic and auto-document-open
- Compatible with:
  - Claude Desktop
  - Gemini-CLI
  - Antigravity
  - Other MCP-compatible clients

### Supported Operations

- Go to Definition
- Find References
- Hover Information
- Code Completion
- Workspace Symbol Search

---

## Project Information

| Item | Details |
|------|---------|
| Author | Skybuck Flying |
| Contact | skybuck2000@hotmail.com |
| Version | 0.08 |
| Repository | https://github.com/SkybuckFlying/Delphi-LSP-MCP-Server |

### Specifications

- MCP Specification (2025-11-25)  
  https://modelcontextprotocol.io/specification/2025-11-25

- Language Server Protocol Specification 3.17  
  https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/

---

## Requirements

- Windows OS
- Delphi 13 (RAD Studio 13.0+) or Free Pascal
- `DelphiLSP.exe` or `pasls.exe`

---

## Building

### Delphi IDE

1. Open `DelphiLSPMCPServer.dpr`
2. Select **Project → Build**

### Command Line

```bash
dcc64 DelphiLSPMCPServer.dpr
```

---

## Usage

### Command Line Options

```text
DelphiLSPMCPServer [options]

Options:
  --lsp-path <path>      Path to LSP executable
  --workspace <path>     Workspace root or file:// URI
  --log-level <level>    debug, info, warning, error
  --debug                Enable verbose diagnostics
  --wait                 Wait for debugger before startup
  --help                 Show help
```

---

## Dynamic Workspace Discovery

Starting with v0.05, the server can automatically determine the active workspace.

### Detection Strategy

1. MCP `initialize` request
   - Reads `rootUri` or `rootPath`

2. Current Working Directory fallback

3. Automatic `.dpr` / `.lpr` project detection

This allows AI agents to switch projects dynamically without restarting the server configuration.

---

## AI Optimization

The repository includes:

- `DelphiLSP.md`

This file instructs AI agents to prioritize semantic tools such as:

- `hover`
- `goto_definition`

instead of relying on text-based searches.

### Recommended GEMINI.md Setup

```text
# Project Context

Refer to DelphiLSP.md for semantic code analysis instructions.
Use LSP semantic tools instead of grep/text searching whenever possible.
```

---

## Configuration Examples

### Gemini-CLI / Antigravity

```json
{
  "mcpServers": {
    "delphi-lsp": {
      "command": "C:\\Tools\\DelphiLSPMCPServer.exe",
      "args": [
        "--log-level",
        "info",
        "--lsp-path",
        "G:\\Tools\\PascalLanguageServer\\pasls.exe"
      ]
    }
  }
}
```

### Claude Desktop

```json
{
  "mcpServers": {
    "delphi-lsp": {
      "command": "C:\\Tools\\DelphiLSPMCPServer.exe",
      "args": [
        "--workspace",
        "C:\\MyProject",
        "--log-level",
        "info"
      ]
    }
  }
}
```

---

## Available Tools

### `delphi_goto_definition`

Find the definition of a symbol at a specific position.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uri` | string | File URI |
| `line` | integer | Zero-based line number |
| `character` | integer | Zero-based character offset |

Example URI:

```text
file:///C:/Projects/MyProject/MainUnit.pas
```

---

### `delphi_find_references`

Find all references to a symbol.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uri` | string | File URI |
| `line` | integer | Zero-based line number |
| `character` | integer | Zero-based character offset |
| `includeDeclaration` | boolean | Include declaration in results |

---

### `delphi_hover`

Retrieve hover information such as:

- Type information
- Symbol documentation
- Declaration details

#### Parameters

| Parameter | Type |
|-----------|------|
| `uri` | string |
| `line` | integer |
| `character` | integer |

---

### `delphi_completion`

Retrieve code completion suggestions.

#### Parameters

| Parameter | Type |
|-----------|------|
| `uri` | string |
| `line` | integer |
| `character` | integer |

---

### `delphi_workspace_symbols`

Search for symbols across the entire workspace.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `query` | string | Symbol search query |

---

## Debugging Support

Version 0.08 introduced debugger synchronization support.

### Features

- `--wait` startup mode
- Cross-process synchronization using Windows Events
- Automatic debugger attach workflow
- No blocking `ReadLn`
- Heartbeat logging during wait state
- First-line debugging support

### Typical Workflow

1. Start test runner with `--wait`
2. Attach debugger to server process
3. Set breakpoints
4. Continue execution
5. Tests begin automatically

---

## Architecture

```text
┌─────────────────────┐
│  MCP Client         │
│  (AI Assistant)     │
└──────────┬──────────┘
           │ JSON-RPC over stdio
           ▼
┌─────────────────────┐
│  Delphi LSP MCP     │
│  Server             │
│                     │
│  ┌───────────────┐  │
│  │ MCP Server    │  │
│  └───────┬───────┘  │
│          │          │
│  ┌───────▼───────┐  │
│  │ LSP Client    │  │
│  └───────┬───────┘  │
└──────────┼──────────┘
           │ LSP JSON-RPC
           ▼
┌─────────────────────┐
│ DelphiLSP / pasls   │
└─────────────────────┘
```

---

## Core Units

| Unit | Responsibility |
|------|----------------|
| `Common.JsonRpc` | JSON-RPC parsing and message types |
| `Common.Logging` | Thread-safe singleton logger |
| `Common.Utils` | URI/path conversion utilities |
| `MCP.Protocol.Types` | MCP protocol type definitions |
| `MCP.Server` | MCP routing and workspace discovery |
| `MCP.Tools.LSP` | MCP → LSP bridge implementations |
| `MCP.Transport.Stdio` | MCP stdio transport |
| `LSP.Client` | LSP request handling and document sync |
| `LSP.Protocol.Types` | LSP protocol definitions |
| `LSP.Transport.Process` | LSP child process management |

---

## Testing

The repository includes:

- `TestAllTools.dpr`

Coverage includes:

- MCP initialization
- Tool discovery
- Hover requests
- Definition lookup
- Reference lookup
- Completion
- Workspace symbol search
- Error handling
- Shutdown handling

### Running Tests

```bash
TestAllTools.exe
TestAllTools.exe --wait
TestAllTools.exe --help
```

---

## Known Issues

### pasls Limitations

- Initial indexing may require delays after `didOpen`
- Hover requests can timeout on very large projects
- FPC installation paths must be configured correctly
- Server/LSP bitness should match (recommendation, not a requirement)

### Recommendations

- Match server and LSP bitness
- Add delay after `didOpen`
- Verify RTL/FPC configuration
- Use retry logic for transient failures

---

## Version History

## Version History

### v0.08 — Debugging Synchronization  
**Date: 27 May 2026 (Git commits match this work)**

- Added named Windows Event synchronization  
- Added debugger wait support (`--wait`)  
- Added first-line debugging workflow  
- Added heartbeat status logging during wait  
- Removed blocking `ReadLn`  
- Fixed double-free crash in `HandleToolsList`  
- All 20 automated tests passing  

---

### v0.07 — Debugging Infrastructure Preparation  
**Date: 27 May 2026 (filesystem)**

- Added preliminary debugger-wait scaffolding  
- Added early heartbeat logging  
- Added initial named event constants  
- Improved LSP startup race-condition handling  
- Improved error messages for missing LSP executable  
- Added retry logic for pasls hover/definition failures  

---

### v0.06 — LSP Stability & pasls Compatibility  
**Date: 27 May 2026 (filesystem)**

- Improved synchronous and queued LSP request handling  
- Added pasls-specific indexing delay handling  
- Improved workspace sniffing reliability  
- Added fallback for missing or malformed `rootUri`  
- Improved `.dpr` / `.lpr` detection heuristics  
- Fixed environment variable inheritance for DelphiLSP  
- Added internal LSP health-check pings  
- Expanded semantic test suite (generics, interfaces, inheritance)  

---

### v0.05 — Dynamic Workspace & Stability  
**Date: 27 April 2026 (Git)**

- Dynamic workspace discovery from MCP initialize request  
- Centralized URI/path handling in `Common.Utils`  
- Automatic `.dpr` / `.lpr` project discovery  
- Forced `-Mdelphi` parsing mode for Free Pascal  
- Added `DelphiLSP.md` AI guidance  
- Expanded semantic analysis test coverage  

---

### v0.04 — Architecture Improvements  
**Date: 27 April 2026 (Git)**

- Major architecture refactor  
- Added LSP retry logic  
- Added automatic document opening  
- Improved unit separation  
- Added support for both DelphiLSP and pasls  

---

### v0.03 — Test More Functionality  
**Date: 27 April 2026 (filesystem)**  
*(No Git commit exists for this version)*

- Experimental version  
- Used for testing additional functionality  
- this version was bad and was skipped.

---

### v0.02 — Protocol Compliance  
**Date: 02 February 2026 (Git)**

- Improved PasLS integration  
- Fixed encoding issues  
- Improved JSON‑RPC compliance  
- Stabilized LSP features (definition, hover)  

---

### v0.01 — Initial Release  
**Date: 26 January 2026 (Git)**

- Initial MCP ↔ LSP bridge implementation  
- Initial Delphi semantic tooling support  



## Roadmap

### Short Term

- LSP health checks
- Better timeout recovery
- Enhanced diagnostics
- Automatic LSP restart support

### Medium Term

- Incremental document synchronization
- Project configuration support
- Compiler/search path configuration

### Long Term

- Async operations
- Response caching
- Connection pooling
- Additional LSP features:
  - Rename
  - Code Actions
  - Formatting

---

## Documentation

Additional documentation:

- `DelphiLSP.md`
- `/docs/architecture.md`
- `/docs/testing.md`
- `/docs/debugging.md`
- `/docs/version-history.md`

---

## License

This is a demonstration project.

Use at your own risk.
