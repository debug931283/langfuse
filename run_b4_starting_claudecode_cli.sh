# Tracing is done by the langfuse-observability plugin (Stop hook), not OpenTelemetry.
# Clear any OTel exporter variables left over from an earlier setup to avoid duplicate traces.
unset CLAUDE_CODE_ENABLE_TELEMETRY CLAUDE_CODE_ENHANCED_TELEMETRY_BETA
unset OTEL_EXPORTER_OTLP_ENDPOINT OTEL_EXPORTER_OTLP_PROTOCOL
unset OTEL_TRACES_EXPORTER OTEL_METRICS_EXPORTER OTEL_LOGS_EXPORTER OTEL_RESOURCE_ATTRIBUTES

# Comma-separated custom tags added to every trace (up to 20), e.g. "tag-one,tag-two,env:local".
export CC_LANGFUSE_TRACE_TAGS="tag-one,tag-two,env:local"
