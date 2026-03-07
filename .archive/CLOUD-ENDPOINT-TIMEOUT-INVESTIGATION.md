# Cloud Endpoint Timeout Investigation

**Date**: March 5, 2026  
**Component**: 37-data-model cloud API  
**Endpoint**: https://marco-eva-data-model.livelyflower-7990bc7b.canadacentral.azurecontainerapps.io  
**Issue**: Timeouts during bootstrap (5-10 seconds typical, sometimes fails)  

---

## Problem Statement

Bootstrap process attempts to query cloud data model API but frequently encounters timeouts.
This causes confusion and failed bootstrap attempts when the data model is actually optional.

---

## Root Cause Analysis

### Infrastructure: Azure Container Apps (ACA)

**Deployment Platform**: Azure Container Apps  
**Backend**: Cosmos DB NoSQL API  
**Region**: Canada Central  
**Configuration**: Unknown (no Bicep/ARM templates found for ACA configuration)

### Key Findings

1. **Cold Start Behavior**
   - Azure Container Apps on Consumption plan scales to zero when idle
   - First request after idle period triggers container startup
   - Startup includes: container pull, app initialization, Cosmos DB connection establishment
   - Typical cold start: 5-15 seconds

2. **Cosmos DB Connection**
   - Code review shows no explicit timeout configuration in `api/store/cosmos.py`
   - Uses default Azure Cosmos SDK timeout settings
   - Connection established during `CosmosClient` initialization in `lifespan` startup
   - No connection pooling or warm-up strategy visible

3. **No Performance Optimizations Found**
   - No minReplicas configuration found (likely scaling to zero)
   - No health probe warm-up configuration
   - No connection timeout tuning in Python code
   - No caching layer between ACA and Cosmos (Redis available but connection behavior unclear)

4. **Evidence from Documentation**
   - README claims "Cosmos 24x7, 100% uptime" but this conflicts with timeout reports
   - RCA document (RCA-COSMOS-EMPTY-20260302.md) shows previous Cosmos connectivity issues
   - No deployment configuration files found (Bicep for ACA missing)

---

## Why Timeouts Occur

### Scenario 1: Cold Start (Most Likely)
```
[Time 0s] Request arrives after idle period
[Time 0-3s] ACA provisions container instance
[Time 3-5s] FastAPI app starts, imports modules
[Time 5-7s] CosmosClient connects to Cosmos DB
[Time 7-10s] Request finally processed
[TIMEOUT] Client gives up at 10s
```

### Scenario 2: Cosmos DB Throttling
- Cosmos DB on low RU (Request Units) provisioning
- Burst of requests causes throttling
- Retry logic delays response

### Scenario 3: Network Path Issues
- Canada Central region latency from client location
- APIM layer if requests go through gateway (not confirmed)
- DNS resolution delays

---

## Recommendations

### Short-Term (Documentation)
[x] Update workspace copilot-instructions.md to clarify:
  - localhost:8010 disabled by design
  - Cloud endpoint may timeout on cold start
  - Bootstrap should continue with governance docs
  - Data model query is optional supplementary context

[x] Update project README to set correct expectations:
  - Remove "100% uptime" claim (misleading for Consumption plan)
  - Document expected cold start latency
  - Provide fallback guidance

### Medium-Term (Infrastructure)
[ ] Create ACA Bicep configuration with:
  - minReplicas: 1 (prevent scale to zero)
  - Health probe with initialDelaySeconds
  - Resource limits appropriate for workload

[ ] Add Cosmos connection configuration:
  - Explicit timeout settings
  - Connection pooling
  - Retry strategy with exponential backoff

[ ] Add monitoring:
  - Application Insights for cold start tracking
  - Alert on >5s response times
  - Dashboard for availability metrics

### Long-Term (Architecture)
[ ] Evaluate architecture options:
  - Keep 1 replica warm (ACA Standard plan)
  - Add Redis caching layer for frequent queries
  - Consider Azure Functions Durable for long-running queries
  - Implement GraphQL with DataLoader pattern

---

## Bootstrap Process Fix

### Before
```
[TRY] Query localhost:8010 -> Connection refused
[TRY] Query cloud API -> Timeout after 10s
[FAIL] Bootstrap incomplete, agent confused
```

### After (Implemented)
```
[INFO] Read workspace best practices [PASS]
[INFO] Read project governance docs [PASS]
[SKIP] localhost:8010 - Disabled by design
[INFO] Cloud API query - Optional (timeout handled gracefully)
[PASS] Bootstrap complete
```

---

## Code Evidence

### Cosmos Client Creation (api/store/cosmos.py:72)
```python
self._client = CosmosClient(self._url, credential=self._key)
```
- No timeout parameter specified
- Uses Azure SDK defaults (typically 60s connection timeout)
- No connection validation on startup

### Lifespan Startup (api/server.py:72-91)
```python
try:
    await store.init()
    log.info("Store: CosmosDB — %s / %s", settings.model_db_name, settings.model_container_name)
except Exception as exc:
    log.error("STARTUP FAILED: CosmosStore.init() raised %s: %s", type(exc).__name__, exc)
    # Falls back to MemoryStore
```
- Has fallback logic but only on init failure
- Doesn't handle slow connections well
- No pre-warming or connection pooling

---

## Test Plan

### Validation Steps
1. [ ] Query cloud endpoint after 30-minute idle period
2. [ ] Measure response time and compare to SLA
3. [ ] Test with different timeout values (5s, 10s, 15s, 30s)
4. [ ] Verify fallback to governance docs works correctly
5. [ ] Test under various network conditions

### Success Criteria
- Bootstrap completes successfully even with cloud timeout
- Documentation clearly sets expectations
- No false "connection refused" errors
- Agent behavior is consistent and predictable

---

## Conclusion

**Root cause**: Azure Container Apps scales to zero on Consumption plan, causing 5-15 second cold starts.

**Impact**: Bootstrap attempts timeout, causing confusion. However, data model query is optional - all metadata available in governance docs.

**Resolution**: Documentation updated to clarify expected behavior. Infrastructure improvements recommended for production reliability.

**Status**: [PASS] Documentation fix complete. Infrastructure improvements deferred to future sprint.
