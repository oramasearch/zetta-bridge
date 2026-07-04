# Blueprint backup

A point-in-time export of the **wtm `ORAMA-ZETTA`** blueprint — the single source of truth that the
GitHub issues on [`oramasearch/zetta`](https://github.com/oramasearch/zetta/issues) and the
[`zetta-docs`](https://github.com/oramasearch/zetta-docs) site are projected from.

This is a **backup / snapshot only**. The authoritative blueprint lives in worktree-manager
(`ORAMA-ZETTA`). To change the design, edit the wtm artifact and re-run the sync — do **not**
hand-edit these files.

## Files

- `artifacts.json` — every artifact: `key`, `title`, `type`, `domain`, `status`, `priority`, `summary`, `body`.
- `relations.json` — every traceability relation: `{ from, relation, to }`.

## Regenerate

Dump fresh from wtm (read-only) and overwrite these files:

```sh
# via the worktree-manager MCP tools (read-only):
#   list_artifacts(project_id=9)  -> artifacts.json
#   list_relations(project_id=9)  -> relations.json
```

The same two files drive the issue generator at
[`modules/zetta-docs/.sync/create_issues.py`](../../modules/zetta-docs/.sync/create_issues.py)
(one keyed, agent-ready GitHub issue per artifact) and the docs renderer `render.py`.

## Snapshot contents

This snapshot includes the **native data-plane + multi-frontend** thrust added during backlog grooming:

- **ADR-30** per-table/db replication strategy + replicated partition catalog + compute-near-data
- **ADR-31** pluggable `Partitioner` seam (record→partition, partition→node)
- **ADR-32** native minimal Parquet reader (no Arrow/foreign dep)
- **ADR-33** multi-frontend core: SQL / simulated-Python / Lua lower to the ExecutionGraph IR
- **ADR-34** pluggable Index engine seam; `oramacore-cpp` native fulltext as the first index backend
- **ENT-35..40** ReplicationStrategy · Partition · Partitioner · LanguageFrontend · Index · IndexBackend
- **ARC-14..16** native data plane · frontend→IR lowering · index subsystem
- **TBL-13** `system.dataset_partitions` · **NFR-3** distributed scale · **QAS-3** elastic-burst rebalance
- **SCR-8 / CMP-6** governed Console/REPL · **TC-9..13** parquet parity / placement / compute-near-data / UC-1-at-scale / fulltext index · **RSK-10** hand-rolled parquet risk

…on top of the existing 300-artifact blueprint (vision → strategy → requirements → architecture →
domain → data → APIs → security → UX → delivery → backlog → testing → risk → governance).
