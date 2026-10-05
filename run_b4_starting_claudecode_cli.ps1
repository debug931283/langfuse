# Tracing is done by the langfuse-observability plugin (Stop hook), not OpenTelemetry.
# Clear any OTel exporter variables left over from an earlier setup to avoid duplicate traces.
foreach ($name in @(
    "CLAUDE_CODE_ENABLE_TELEMETRY", "CLAUDE_CODE_ENHANCED_TELEMETRY_BETA",
    "OTEL_EXPORTER_OTLP_ENDPOINT", "OTEL_EXPORTER_OTLP_PROTOCOL",
    "OTEL_TRACES_EXPORTER", "OTEL_METRICS_EXPORTER", "OTEL_LOGS_EXPORTER",
    "OTEL_RESOURCE_ATTRIBUTES"
)) {
    Remove-Item "Env:$name" -ErrorAction SilentlyContinue
}

# Comma-separated custom tags added to every trace.
$env:CC_LANGFUSE_TRACE_TAGS = "SOME_TAG"
