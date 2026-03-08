#!/usr/bin/env bash
# Patch claude-max-api-proxy to handle OpenAI array content format.
#
# Bug: proxy assumes message.content is always a string, but OpenClaw sends
# content as an array of blocks: [{"type":"text","text":"..."}]
# Result without patch: messages arrive as "[object Object]" in Claude CLI.
#
# Run this after: npm install -g claude-max-api-proxy
# Or after any update to the package.

set -euo pipefail

ADAPTER="/home/openclaw/.npm-global/lib/node_modules/claude-max-api-proxy/dist/adapter/openai-to-cli.js"

if [ ! -f "$ADAPTER" ]; then
    echo "ERROR: claude-max-api-proxy not installed at expected path"
    echo "Install with: NODE_OPTIONS='--max-old-space-size=256' npm install -g claude-max-api-proxy --no-fund --no-audit"
    exit 1
fi

# Check if already patched
if grep -q "extractContent" "$ADAPTER"; then
    echo "Already patched, skipping."
    exit 0
fi

# Apply patch
node << 'EOF'
const fs = require("fs");
const path = "/home/openclaw/.npm-global/lib/node_modules/claude-max-api-proxy/dist/adapter/openai-to-cli.js";
let src = fs.readFileSync(path, "utf8");

const OLD = `export function messagesToPrompt(messages) {
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
}`;

const NEW = `function extractContent(content) {
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
}`;

if (!src.includes("extractContent")) {
    src = src.replace(OLD, NEW);
    fs.writeFileSync(path, src);
    console.log("Patch applied successfully.");
} else {
    console.log("Already patched.");
}
EOF

systemctl --user restart claude-max-proxy
echo "Done. claude-max-proxy restarted."
