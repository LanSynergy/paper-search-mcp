# Multi-stage build for smaller image
FROM python:3.12-slim AS builder

WORKDIR /app
COPY pyproject.toml README.md LICENSE ./
COPY paper_search_mcp/ paper_search_mcp/

RUN pip install --no-cache-dir build \
    && python -m build --wheel \
    && pip install --no-cache-dir dist/*.whl

FROM python:3.12-slim

WORKDIR /app
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/paper-search-mcp /usr/local/bin/paper-search-mcp

# Transport config — set MCP_TRANSPORT=http for network/Dokploy deployments
ENV MCP_TRANSPORT="http"
ENV MCP_HOST="0.0.0.0"
ENV MCP_PORT="8000"

# Optional API keys — override at runtime via Dokploy environment variables
ENV PAPER_SEARCH_MCP_UNPAYWALL_EMAIL=""
ENV PAPER_SEARCH_MCP_CORE_API_KEY=""
ENV PAPER_SEARCH_MCP_SEMANTIC_SCHOLAR_API_KEY=""
ENV PAPER_SEARCH_MCP_ZENODO_ACCESS_TOKEN=""
ENV PAPER_SEARCH_MCP_DOAJ_API_KEY=""
ENV PAPER_SEARCH_MCP_GOOGLE_SCHOLAR_PROXY_URL=""
ENV PAPER_SEARCH_MCP_IEEE_API_KEY=""
ENV PAPER_SEARCH_MCP_ACM_API_KEY=""

EXPOSE 8000

CMD ["paper-search-mcp"]
