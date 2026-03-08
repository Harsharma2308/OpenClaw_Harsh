#!/usr/bin/env bash
# Patches to claude-max-api-proxy (applied after every npm install/update):
#
# Patch 1 — [object Object] bug:
#   Proxy assumes message.content is always a string. OpenClaw sends content
#   as an array of blocks ([{type:text,text:...}]), which serializes as
#   "[object Object]". Fix: extract text from array content blocks.
#
# Patch 2 — sandbox/permissions:
#   Proxy doesn't pass --dangerously-skip-permissions to claude CLI, so
#   tool use (file writes, etc.) is blocked. Fix: add the flag + set cwd to $HOME.
#
# Run after: npm install -g claude-max-api-proxy

set -euo pipefail

ADAPTER="/home/openclaw/.npm-global/lib/node_modules/claude-max-api-proxy/dist/adapter/openai-to-cli.js"
MANAGER="/home/openclaw/.npm-global/lib/node_modules/claude-max-api-proxy/dist/subprocess/manager.js"

if [ ! -f "$ADAPTER" ] || [ ! -f "$MANAGER" ]; then
    echo "ERROR: claude-max-api-proxy not installed at expected path"
    echo "Install with: NODE_OPTIONS='--max-old-space-size=256' npm install -g claude-max-api-proxy --no-fund --no-audit"
    exit 1
fi

node << 'EOF'
const fs = require("fs");

// --- Patch 1: openai-to-cli.js — fix array content ([object Object] bug) ---
const adapterPath = "/home/openclaw/.npm-global/lib/node_modules/claude-max-api-proxy/dist/adapter/openai-to-cli.js";
let adapter = fs.readFileSync(adapterPath, "utf8");

if (!adapter.includes("extractContent")) {
    adapter = adapter.replace(
        `export function messagesToPrompt(messages) {
    const parts = [];
    for (const msg of messages) {
        switch (msg.role) {
            case "system":
                // System messages become context instructions
                parts.push(\`<system>\\n\${msg.content}\\n</system>\\n\`);
                break;
            case "user":
                // User messages are the main prompt
                parts.push(msg.content);
                break;
            case "assistant":
                // Previous assistant responses for context
                parts.push(\`<previous_response>\\n\${msg.content}\\n</previous_response>\\n\`);
                break;
        }
    }
    return parts.join("\\n").trim();
}`,
        `function extractContent(content) {
    if (typeof content === "string") return content;
    if (Array.isArray(content)) {
        return content.map(block => {
            if (typeof block === "string") return block;
            if (block.type === "text") return block.text || "";
            if (block.type === "image_url") return "[image]";
            return "";
        }).join("");
    }
    return String(content);
}
export function messagesToPrompt(messages) {
    const parts = [];
    for (const msg of messages) {
        switch (msg.role) {
            case "system":
                parts.push(\`<system>\\n\${extractContent(msg.content)}\\n</system>\\n\`);
                break;
            case "user":
                parts.push(extractContent(msg.content));
                break;
            case "assistant":
                parts.push(\`<previous_response>\\n\${extractContent(msg.content)}\\n</previous_response>\\n\`);
                break;
        }
    }
    return parts.join("\\n").trim();
}`
    );
    fs.writeFileSync(adapterPath, adapter);
    console.log("Patch 1 applied: array content fix");
} else {
    console.log("Patch 1 already applied");
}

// --- Patch 2: manager.js — add --dangerously-skip-permissions + set cwd to $HOME ---
const managerPath = "/home/openclaw/.npm-global/lib/node_modules/claude-max-api-proxy/dist/subprocess/manager.js";
let manager = fs.readFileSync(managerPath, "utf8");

if (!manager.includes("dangerously-skip-permissions")) {
    manager = manager.replace(
        `"--no-session-persistence", // Don't save sessions`,
        `"--dangerously-skip-permissions", // Allow tool use without prompts\n            "--no-session-persistence", // Don't save sessions`
    );
    console.log("Patch 2a applied: --dangerously-skip-permissions");
} else {
    console.log("Patch 2a already applied");
}

if (!manager.includes("process.env.HOME")) {
    manager = manager.replace(
        `cwd: options.cwd || process.cwd(),`,
        `cwd: options.cwd || process.env.HOME || process.cwd(),`
    );
    console.log("Patch 2b applied: cwd set to $HOME");
} else {
    console.log("Patch 2b already applied");
}

fs.writeFileSync(managerPath, manager);
EOF

systemctl --user restart claude-max-proxy
echo "Done. claude-max-proxy restarted."
