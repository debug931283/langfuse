# Starting Langfuse with OpenTelemetry Instrumentation

This guide covers starting the Langfuse server and Claude Code with OpenTelemetry tracing configured.

## Prerequisites

- Docker and Docker Compose installed
- Claude Code CLI installed
- Environment variables file (choose one based on your shell)

## Step 0: Find Your Langfuse Login in `.env`

The Langfuse web UI login is seeded from the `.env` file at the repository root. Refer to it for the email and password to sign in at `http://localhost:3000`:

```
LANGFUSE_INIT_USER_EMAIL=...
LANGFUSE_INIT_USER_PASSWORD=...
```

These are only applied when Langfuse initializes a fresh database, so changing them later has no effect unless you reset the volumes (`docker-compose down -v`).

The same file also holds the project API keys (`LANGFUSE_INIT_PROJECT_PUBLIC_KEY` / `LANGFUSE_INIT_PROJECT_SECRET_KEY`), which `docker-compose.yml` passes to the OpenTelemetry Collector.

## Step 1: Start the Langfuse Server

Start the Docker Compose stack which includes:
- Langfuse web service
- PostgreSQL database
- ClickHouse analytics database
- Redis cache
- OpenTelemetry Collector

```bash
docker-compose up -d
```

Wait for services to be ready (typically 10-30 seconds). Check status:

```bash
docker-compose ps
```

The Langfuse web UI will be available at `http://localhost:3000`

## Step 2: Set Environment Variables

Three setup scripts are provided in this directory. Choose the script based on your shell environment:

- `run_b4_starting_claudecode_cli.sh` — Bash/Zsh (Linux, macOS)
- `run_b4_starting_claudecode_cli.ps1` — PowerShell (Windows, macOS, Linux)
- `run_b4_starting_claudecode_cli.bat` — Command Prompt (Windows)

Optional: Copy the appropriate script to a convenient location or add it to your system PATH for easy access.

### Running the Script

### Bash / Zsh / Linux / macOS

Run the bash script to export environment variables:

```bash
source run_b4_starting_claudecode_cli.sh
```

### PowerShell (Windows / Cross-platform)

Run the PowerShell script using dot-sourcing to set variables in the current session:

```powershell
. .\run_b4_starting_claudecode_cli.ps1
```

If you have execution policy restrictions, set it for the current process only, then run the script:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
. .\run_b4_starting_claudecode_cli.ps1
```

**Important:** The execution policy must be bypassed in the SAME session where you run dot-sourcing. Any command that spawns a new PowerShell process (like `powershell -ExecutionPolicy Bypass ...`) will set variables only in that subprocess, not your current session.

### Command Prompt (Windows)

Run the batch script:

```cmd
run_b4_starting_claudecode_cli.bat
```

## Step 2b: Confirm Environment Variables Are Set

Verify that the environment variables were successfully set before proceeding:

### Bash / Zsh / Linux / macOS

```bash
echo $OTEL_EXPORTER_OTLP_ENDPOINT
echo $CLAUDE_CODE_ENABLE_TELEMETRY
```

Expected output:
```
http://localhost:4317
1
```

Or verify all variables at once:

```bash
env | grep -E 'CLAUDE_CODE|OTEL_'
```

### PowerShell (Windows / Cross-platform)

```powershell
$env:OTEL_EXPORTER_OTLP_ENDPOINT
$env:CLAUDE_CODE_ENABLE_TELEMETRY
```

Expected output:
```
http://localhost:4317
1
```

Or verify all variables at once:

```powershell
Get-ChildItem env: | Where-Object {$_.Name -match 'CLAUDE_CODE|OTEL_'}
```

### Command Prompt (Windows)

```cmd
echo %OTEL_EXPORTER_OTLP_ENDPOINT%
echo %CLAUDE_CODE_ENABLE_TELEMETRY%
```

Expected output:
```
http://localhost:4317
1
```

Or verify all variables at once:

```cmd
set | findstr /I "CLAUDE_CODE OTEL_"
```

## Step 3: Start Claude Code

After sourcing the environment variables script, start Claude Code in the same shell:

```bash
claude code
```

Or with a specific working directory:

```bash
claude code /path/to/project
```

## Environment Variables Explained

| Variable | Value | Purpose |
|----------|-------|---------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | `1` | Enable telemetry collection |
| `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA` | `1` | Enable enhanced telemetry (beta) |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | `http://localhost:4317` | OpenTelemetry collector gRPC endpoint |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc` | Use gRPC protocol for OTLP |
| `OTEL_TRACES_EXPORTER` | `otlp` | Export traces to OTLP |
| `OTEL_METRICS_EXPORTER` | `none` | Disable metrics export |
| `OTEL_LOGS_EXPORTER` | `none` | Disable logs export |
| `OTEL_RESOURCE_ATTRIBUTES` | `session.tag=SOME_TAG` | Tag traces with custom session identifier |

## OpenTelemetry Collector Configuration

The OpenTelemetry Collector (`otel-collector-config.yaml`) is configured to:

1. **Receive** traces from Claude Code via gRPC (port 4317) and HTTP (port 4318)
2. **Process** traces:
   - Map token usage attributes to OpenAI semantic conventions
   - Tag traces with session information
3. **Export** traces to Langfuse at `http://langfuse-web:3000/api/public/otel`

## Troubleshooting

### OpenTelemetry Collector not running
Check if Docker services are healthy:
```bash
docker-compose logs otel-collector
```

### Traces not appearing in Langfuse
- Verify environment variables are set: `echo $OTEL_EXPORTER_OTLP_ENDPOINT`
- Check collector logs: `docker-compose logs otel-collector`
- Ensure Claude Code telemetry is enabled

### Services failed to start
Check Docker Compose errors:
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

## Next Steps

1. Claude Code will now send traces to the OpenTelemetry Collector
2. Traces are processed and forwarded to Langfuse
3. View traces in the Langfuse web UI at `http://localhost:3000`
