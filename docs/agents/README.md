# agents/ — the Python agent scaffold

| Doc | Covers |
|---|---|
| [`scaffold.md`](scaffold.md) | The bootstrap sequence, the agent modules, what a **profile** is, the discovery-vs-capture distinction, and the five rules that keep this a bootstrap rather than a demo |

## The bootstrap direction

Build the agents in **Python with frontier models**, record the traces, and only then re-implement
in C++ with our own models — comparing eval scores between the two. Building in C++ first because
the engine is C++ is the mistake this sequence exists to prevent; the previous attempt did exactly
that and produced four checkpoints with no broad gain.

## Related, in another repo

The **company's** agent workforce — thirteen role agents operating a world model — is
[`orama-business-model`](https://github.com/oramasearch/orama-business-model). Different purpose,
same conventions: private repos, uv, tool surfaces derived from source rather than retyped, every
run traced including failures, versioned prompts, deterministic checks with no LLM judge. Its
[`docs/agents/`](https://github.com/oramasearch/orama-business-model/blob/main/docs/agents/README.md)
records what those conventions cost when broken.
