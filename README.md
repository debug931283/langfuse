# Tracing Claude Code with a Local Langfuse

This guide covers starting a local Langfuse server and tracing Claude Code sessions into it with the open-source [Langfuse Claude Code plugin](https://github.com/langfuse/Claude-Observability-Plugin). The plugin runs as a Stop hook, reads Claude Code's conversation transcript, and sends full prompts, model responses, tool calls (inputs and outputs) and timing to Langfuse. No OpenTelemetry setup is needed.

## Prerequisites

- Docker and Docker Compose installed
- Claude Code CLI installed
- [`uv`](https://docs.astral.sh/uv/) on your `PATH` (the hook uses it to install its Python dependencies)

## Step 0: Find Your Langfuse Login in `.env`

The Langfuse web UI login is seeded from the `.env` file at the repository root. Refer to it for the email and password to sign in at `http://localhost:3000`:

```
LANGFUSE_INIT_USER_EMAIL=...
LANGFUSE_INIT_USER_PASSWORD=...
```

These are only applied when Langfuse initializes a fresh database, so changing them later has no effect unless you reset the volumes (`docker-compose down -v`).

The same file also holds the project API keys (`LANGFUSE_INIT_PROJECT_PUBLIC_KEY` / `LANGFUSE_INIT_PROJECT_SECRET_KEY`), which you need in Step 2.

## Step 1: Start the Langfuse Server

```bash
docker-compose up -d
```

Wait for services to be ready (typically 10-30 seconds). Check status:

```bash
docker-compose ps
```

The Langfuse web UI will be available at `http://localhost:3000`.

## Step 2: Install and Configure the Plugin (one time)

Install the plugin (user scope, so it applies to every Claude Code session on this machine):

```bash
claude plugin marketplace add langfuse/Claude-Observability-Plugin
claude plugin install langfuse-observability@langfuse-observability
```

Then save your credentials, either by running `/plugin configure langfuse-observability@langfuse-observability` inside Claude Code, or from a shell:

```bash
set -a; . ./.env; set +a
python3 -c "
import json, os
print(json.dumps({
    'LANGFUSE_PUBLIC_KEY': os.environ['LANGFUSE_INIT_PROJECT_PUBLIC_KEY'],
    'LANGFUSE_SECRET_KEY': os.environ['LANGFUSE_INIT_PROJECT_SECRET_KEY'],
    'LANGFUSE_BASE_URL': 'http://localhost:3000',
}))" | claude plugin configure langfuse-observability@langfuse-observability --values-stdin
```

Restart Claude Code afterwards. Set `CC_LANGFUSE_DEBUG` to `true` in the plugin config to log to `~/.claude/state/langfuse_hook.log`.

**Privacy:** every Claude Code session on this machine now sends full prompts, tool output and file contents to your Langfuse.

## Step 3: Set Custom Trace Tags (optional)

Three scripts are provided. Choose one based on your shell:

- `run_b4_starting_claudecode_cli.sh` — Bash/Zsh (Linux, macOS)
- `run_b4_starting_claudecode_cli.ps1` — PowerShell (Windows, macOS, Linux)
- `run_b4_starting_claudecode_cli.bat` — Command Prompt (Windows)

Each one sets `CC_LANGFUSE_TRACE_TAGS` (edit `SOME_TAG` to your own tag) and clears any leftover OpenTelemetry variables, so sessions are not traced twice.

```bash
source run_b4_starting_claudecode_cli.sh      # Bash / Zsh
```

```powershell
. .\run_b4_starting_claudecode_cli.ps1        # PowerShell (dot-source)
```

```cmd
run_b4_starting_claudecode_cli.bat            REM Command Prompt
```

If PowerShell blocks the script, run `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process` in the same session first.

Verify:

```bash
echo $CC_LANGFUSE_TRACE_TAGS
```

`CC_LANGFUSE_TRACE_TAGS` takes a comma-separated list or a JSON array (up to 20 tags, 200 characters each). The plugin also adds `claude-code` and `skill:<name>` tags itself (disable the latter with `CC_LANGFUSE_SKILL_TAGS=false`).

## Step 4: Start Claude Code

In the same shell:

```bash
claude
```

Each turn appears in Langfuse after the response finishes: a `Conversational Turn` span containing `LLM Call` generations and `Tool: <name>` spans, grouped into a session by the Claude session ID.

## Troubleshooting

### Traces not appearing in Langfuse
- Restart Claude Code after installing or configuring the plugin.
- Check `claude plugin list` shows `langfuse-observability` as enabled.
- Enable `CC_LANGFUSE_DEBUG` and read `~/.claude/state/langfuse_hook.log`.
- Confirm `uv` is on your `PATH` and Langfuse is reachable at `http://localhost:3000`.

### The last turn shows up late
The Stop hook holds the trailing open turn until the next prompt or session end.

### Duplicate traces
Make sure no OpenTelemetry exporter is active (`env | grep -E 'CLAUDE_CODE|OTEL_'` should print nothing relevant).

### Services failed to start
```bash
docker-compose logs
```

## Cleanup

To stop all services:

```bash
docker-compose down
```

To remove volumes (databases) as well:

```bash
docker-compose down -v
```
