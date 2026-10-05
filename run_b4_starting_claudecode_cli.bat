@echo off
rem Tracing is done by the langfuse-observability plugin (Stop hook), not OpenTelemetry.
rem Clear any OTel exporter variables left over from an earlier setup to avoid duplicate traces.
set CLAUDE_CODE_ENABLE_TELEMETRY=
set CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=
set OTEL_EXPORTER_OTLP_ENDPOINT=
set OTEL_EXPORTER_OTLP_PROTOCOL=
set OTEL_TRACES_EXPORTER=
set OTEL_METRICS_EXPORTER=
set OTEL_LOGS_EXPORTER=
set OTEL_RESOURCE_ATTRIBUTES=

rem Comma-separated custom tags added to every trace.
set CC_LANGFUSE_TRACE_TAGS=SOME_TAG
