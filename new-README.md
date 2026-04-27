# HRES Text Analytics
## Oracle Hybrid Search Architecture
*Semantic + BM25 Rule Matching at Scale*

---

## The Simple Explanation 💡

Imagine you're an HR manager searching through thousands of employee feedback comments looking for people who feel **overworked and stressed**.

**The Old Way (Keyword Search)**

You search for the words "overworked" and "stressed". Your system scans every comment and returns only ones that contain those exact words.

But what about the employee who wrote:

> *"I'm completely burnt out and running on empty."*

Or the one who wrote:

> *"The workload is crushing — I haven't taken a day off in months."*

Your search **misses them completely** — because neither comment contains "overworked" or "stressed".

**The Smart Way (Semantic Search)**

Now imagine a really smart colleague who *understands what you mean*, not just what you typed.

They know:
- 😓 "overworked" = burnt out, exhausted, running on empty, crushing workload
- 😰 "stressed" = overwhelmed, anxious, under pressure, can't cope

So they surface **all** the relevant feedback — even comments that never used your exact words — and rank the most relevant ones at the top.

**The Best of Both (Hybrid Search)**

The smartest approach combines both:
- **Keyword search (BM25)** catches comments that use your exact terms — fast and precise
- **Semantic search** catches comments that *mean* the same thing in different words
- **Together**, they find everything a human reviewer would find — nothing slips through

This is exactly what the HRES hybrid search architecture delivers — across 1.5 million feedback comments, matched against 4,000 categorization rules, entirely within Oracle.

---

## 1. Background — Why Hybrid Search

Traditional keyword-based search in text analytics systems matches exact terms — it cannot understand synonyms, paraphrases, or semantic intent. In the HRES context, employee feedback arrives in highly varied language for the same underlying themes. A system relying on keyword matching alone will miss a significant portion of relevant documents.

Two complementary techniques address this:

- **BM25 (Best Match 25)** — a statistical ranking function that scores keyword relevance based on term frequency and document length normalization
- **Semantic / Vector Search** — encodes the meaning of text into dense numerical vectors and finds conceptually similar content regardless of exact word choice

> **Key Insight:** Hybrid search combining BM25 and semantic retrieval consistently outperforms either technique alone. On standard benchmarks (BEIR), hybrid search scores 62–68% relevance versus 45–50% for BM25 alone and 52–57% for semantic alone.

| Dimension | BM25 / Keyword | Semantic (Vector) | Hybrid |
|---|---|---|---|
| Match basis | Exact term overlap | Meaning & intent | Both |
| "car" vs "automobile" | No match | Match | Match |
| Rare technical terms | Strong | May miss | Strong |
| Paraphrasing / synonyms | Misses | Catches | Catches |
| Typos | Misses | Tolerant | Tolerant |
| Context sensitivity | None | High | High |
| Computation speed | Fast | Moderate | Moderate |

---

## 2. How BM25 and TF-IDF Work

### 2.1 TF-IDF

TF-IDF combines two signals:

- **Term Frequency (TF)** — how often a word appears in a document. A document mentioning 'burnout' ten times is more relevant than one mentioning it once.
- **Inverse Document Frequency (IDF)** — penalizes common words. 'The' appears everywhere and carries no signal; 'elasticsearch' is rare and highly informative.

TF-IDF rewards words that appear often in one document but rarely across the corpus.

### 2.2 BM25 — The Upgrade

BM25 addresses two known weaknesses of TF-IDF:

- **Saturation** — repeating a word 100 times should not make a document 100x more relevant. BM25 caps diminishing returns from repetition.
- **Length normalization** — longer documents naturally contain more term occurrences. BM25 penalizes verbosity so long documents do not score unfairly high.

> **Elasticsearch Default:** BM25 is the default ranking algorithm in Elasticsearch and is also available in Oracle via `CTXSYS.CONTEXT` full-text indexes and the `CONTAINS` / `SCORE` functions.

---

## 3. Semantic / Vector Search

Semantic search converts text into dense numerical vectors (embeddings) that encode meaning. Two pieces of text with similar meaning will have vectors that are close together in high-dimensional space, even if they share no common words.

### 3.1 Embedding Models

An embedding model reads a piece of text and outputs a fixed-length array of floating-point numbers. For HRES, Oracle provides the `all-MiniLM-L12-v2` model (384 dimensions) that can be loaded directly into Oracle Database 23ai using `DBMS_VECTOR.LOAD_ONNX_MODEL` — no external API calls required.

### 3.2 Distance Metrics

| Metric | Oracle Syntax | Best For |
|---|---|---|
| Cosine similarity | `COSINE` | Text — most common choice for NLP |
| Dot product | `DOT` | Normalized vectors |
| Euclidean | `EUCLIDEAN` | Geometric distance in embedding space |
| Manhattan | `MANHATTAN` | Less sensitive to outliers |

For HRES text analytics, **Cosine distance** is the recommended default.

---

## 4. Oracle AI Vector Search (Database 23ai)

Oracle Database 23ai introduces native vector capabilities — no separate vector database or external search cluster is required. All semantic search runs inside the same Oracle instance that holds HRES business data.

### 4.1 Key Features

- **VECTOR data type** — first-class column type for storing embeddings alongside relational data
- **VECTOR_EMBEDDING()** — SQL function that generates embeddings using an in-database ONNX model
- **VECTOR_DISTANCE()** — SQL function that computes similarity between two vectors
- **HNSW vector index** — in-memory Hierarchical Navigable Small World graph for approximate nearest-neighbor search in sub-millisecond time
- **IVF index** — storage-based neighbor partition index for massive datasets
- **Oracle Text CONTAINS / SCORE** — existing BM25-style keyword search

### 4.2 Embedding Model — All-MiniLM-L12-v2

| Property | Value |
|---|---|
| Model name | all-MiniLM-L12-v2 |
| Vector dimensions | 384 (FLOAT32) |
| Storage per vector | ~1.5 KB |
| Runs where | Inside Oracle DB on CPU — no external calls |
| License | Open source (Sentence Transformers / HuggingFace) |
| Load command | `DBMS_VECTOR.LOAD_ONNX_MODEL` |

### 4.3 Oracle vs Elasticsearch Comparison

| Feature | Elasticsearch | Oracle 23ai |
|---|---|---|
| Vector storage | `dense_vector` field | `VECTOR` data type |
| Keyword search | BM25 match query | `CONTAINS()` with `SCORE()` |
| Semantic search | kNN query | `VECTOR_DISTANCE()` |
| Hybrid merge | RRF rank fusion | Manual RRF in SQL CTE |
| Embedding model | External or built-in | ONNX model inside DB |
| Data location | Separate search engine | Same DB as HR data |
| RAG support | Via external pipeline | Native inside DB |
| External API calls | Optional | None required |

---

## 5. Hybrid Search Flow — RRF Merge

The power of hybrid search lies not in combining raw scores (which have incompatible scales) but in combining ranked positions using Reciprocal Rank Fusion (RRF).

### 5.1 RRF Formula

For a document appearing at rank position `r` in a given result list:

```
RRF score  =  1 / (60 + rank_in_BM25)  +  1 / (60 + rank_in_semantic)
```

A document ranking #2 in BM25 and #3 in semantic search will almost certainly appear in the top 3 hybrid results. The constant 60 prevents very high scores for top-ranked documents from dominating.

### 5.2 Why Hybrid Beats Both Alone

| Query Type | BM25 Alone | Semantic Alone | Hybrid |
|---|---|---|---|
| Exact technical term (e.g. 'W-2 form') | Strong | May drift | Strong |
| Emotional / intent ('feeling burnt out') | Weak | Strong | Strong |
| Paraphrase / synonym | Misses | Catches | Catches |
| Ambiguous term (java = language or coffee?) | No context | Context-aware | Context-aware |
| Rare domain-specific terms | Strong | Variable | Strong |

---

## 6. Rule Matching Architecture — 4,000 Rules

The HRES text analytics engine maintains approximately 4,000 categorization rules. Naively evaluating all rules against every incoming feedback record is computationally prohibitive. The two-stage hybrid architecture solves this efficiently.

> **Performance Problem:** Naive approach: 4,000 rules × 1.5M records = 6 billion evaluations. This is not viable. The two-stage approach reduces this to approximately 20 precise evaluations per record.

### 6.1 Two-Stage Pipeline

**Stage 1 — Semantic Shortlist (Fast)**

All 4,000 rules are embedded and stored with a HNSW vector index. When a feedback record arrives, its embedding is compared against all rule vectors using approximate nearest-neighbor search. This returns the top 20 candidate rules in sub-millisecond time — without evaluating any rule logic.

**Stage 2 — Precise Rule Evaluation (Exact)**

Only the 20 candidate rules from Stage 1 are evaluated using full BM25 keyword matching (`CONTAINS`). This applies the exact rule logic to only the candidates most likely to match, not to all 4,000 rules.

### 6.2 Oracle Index Requirements

| Index | Type | Purpose |
|---|---|---|
| `rules_text_idx` | CTXSYS.CONTEXT (Oracle Text) | BM25 keyword search on rule text |
| `rules_vector_idx` | HNSW (Oracle 23ai) | Fast approximate semantic search on rule vectors |
| `feedback_vector_idx` | HNSW (Oracle 23ai) | Optional: similarity search on feedback records |

### 6.3 RRF Merge Within Rule Matching

Within Stage 1, BM25 and semantic search both run against the rules table and their results are merged via RRF before the top 20 are passed to Stage 2. This ensures the shortlist is not biased toward either technique.

| Stage | Input | Output | Speed |
|---|---|---|---|
| BM25 on rules | Feedback text | Top 50 rule matches (keyword) | ~2–5ms |
| Semantic on rules | Feedback vector | Top 50 rule matches (semantic) | ~1–2ms |
| RRF merge | Two ranked lists of 50 | Unified top 20 candidates | <1ms |
| Exact evaluation | 20 candidate rules | Final matched categories | ~5ms |
| **Total per record** | — | — | **~60–70ms (incl. embedding)** |

---

## 7. Cost Analysis — 1.5 Million Comments

### 7.1 Storage

| Item | Calculation | Size |
|---|---|---|
| Comment vectors (1.5M) | 1.5M × 384 dims × 4 bytes | ~2.25 GB |
| Rule vectors (4,000) | 4,000 × 384 × 4 bytes | ~6 MB |
| Oracle Text index (BM25) | Estimated 0.5–1× raw text size | ~1–2 GB |
| HNSW vector index (rules) | 1.3 × vector size × dims × rows | ~8 MB |
| **Total additional storage** | — | **~4–5 GB** |

> **On-Premise Cost:** At Bank of America on-premise Oracle, 4–5 GB of additional storage is effectively zero incremental cost — it is standard disk allocation.

### 7.2 Embedding Generation — One-Time Batch

MiniLM-L12-v2 running on CPU inside Oracle processes approximately 10–20 records per second per session.

| Scenario | Sessions | Estimated Time |
|---|---|---|
| Single DB session | 1 | ~20–40 hours |
| Moderate parallelism | 8 | ~3–5 hours |
| High parallelism | 20 | ~1.5 hours |

This is a one-time operation. Subsequent runs only process new or changed records.

### 7.3 Per-Record Ongoing Cost

| Step | Time per Record |
|---|---|
| VECTOR_EMBEDDING (MiniLM in-DB) | ~50ms |
| HNSW semantic search on 4,000 rules | ~1–2ms |
| BM25 CONTAINS search on 4,000 rules | ~2–5ms |
| RRF merge + exact match (top 20) | ~5ms |
| **Total per incoming feedback record** | **~60–65ms** |

### 7.4 API Cost Comparison

| Embedding Option | Cost for 1.5M Records |
|---|---|
| OpenAI text-embedding-3-small | ~$0.30 (but data leaves BoA — not approved) |
| Azure OpenAI (enterprise) | ~$0.30 plus Azure consumption |
| **Oracle built-in MiniLM (this solution)** | **$0.00 — no external API** |

> **Bottom Line:** The total incremental cost for processing 1.5M comments is approximately 3–5 hours of Oracle DB compute time (one-time) and 4–5 GB of additional storage. There are no API fees, no new licenses, and no separate infrastructure. Ongoing cost per new record is approximately 60–65ms of CPU.

---

## 8. Pre-Computed Matches — Materialized Rule Matching

Rather than running hybrid search at query time, matches can be computed **once per feedback record at write time** and stored permanently. This turns a compute problem into a storage problem — and storage at BoA is essentially free.

### 8.1 The Core Idea

```
Without pre-computation                With pre-computation
──────────────────────                 ────────────────────
Query arrives                          Feedback arrives (write)
    │                                      │
    ▼                                      ▼
Run BM25 + Semantic          →         Run BM25 + Semantic  ← once only
against 4,000 rules                    against 4,000 rules
    │                                      │
    ▼                                      ▼
Return results                         Store in matches table
(recomputed every time)                    │
                                           ▼
                                       Query arrives (read)
                                           │
                                           ▼
                                       Simple SELECT join   ← no computation
                                       <1ms response
```

### 8.2 Matches Table Structure

```sql
CREATE TABLE hres_feedback_rule_matches (
  feedback_id     NUMBER,
  rule_id         NUMBER,
  category        VARCHAR2(100),
  bm25_score      NUMBER,
  semantic_score  NUMBER,
  rrf_score       NUMBER,
  rule_version    NUMBER DEFAULT 1,
  matched_at      TIMESTAMP,
  CONSTRAINT pk_matches PRIMARY KEY (feedback_id, rule_id)
);
```

### 8.3 Write-Time vs Read-Time Cost

| Scenario | Without Pre-computation | With Pre-computation |
|---|---|---|
| 1.5M existing records | Compute on every query | **One-time batch** to populate |
| Each new feedback | Compute on every read | Compute **once on write** |
| 10 analysts querying same record | 10 × full hybrid search | 10 × simple `SELECT` |
| Query response time | ~60–65ms per record | **<1ms** (table lookup) |
| DB CPU during reporting | High — sustained | Near zero |

### 8.4 Handling Rule Changes

When rules are updated or added, stored matches for affected records become stale. The `rule_version` column manages this cleanly — increment the version on any rule change and a background job re-processes only the records where that rule was a candidate match. A full reprocessing of all 1.5M records is never needed for a single rule change.

### 8.5 Storage Cost of Pre-Computed Matches

Assuming an average of 5 rule matches per feedback record:

| Item | Calculation | Size |
|---|---|---|
| 1.5M records × 5 matches | 7.5M rows | ~600 MB |
| Indexes on `feedback_id`, `category`, `rrf_score` | — | ~200 MB |
| **Total** | — | **~800 MB** |

Less than 1 GB — negligible at BoA scale.

---

## 9. Implementation Considerations for HRES

### 9.1 Constraints Addressed

- **No external API calls** — all embedding generation uses Oracle's in-database ONNX runtime
- **No new infrastructure** — Oracle 23ai AI Vector Search is included in the existing DB license
- **No model deployment** — the MiniLM model is loaded once by a DBA using `DBMS_VECTOR.LOAD_ONNX_MODEL`
- **Existing data intact** — vector columns are added alongside existing columns; no schema migration required
- **SQL-first** — all search logic is expressed in standard Oracle SQL / PL/SQL

### 9.2 DBA Actions Required (One-Time)

- Load MiniLM ONNX model via `DBMS_VECTOR.LOAD_ONNX_MODEL`
- Create `VECTOR` column on rules and feedback tables
- Create HNSW vector index on rules table
- Create Oracle Text `CONTEXT` index on rules table (if not already present)
- Grant `VECTOR_EMBEDDING` execution privilege to application schema

### 9.3 Relationship to Existing Percolation Architecture

The existing Elasticsearch percolation query approach is conceptually preserved in Oracle: rules are stored, indexed, and matched against incoming documents. The Oracle two-stage hybrid approach replicates this pattern natively in SQL with the addition of semantic understanding, eliminating the need to maintain a separate Elasticsearch cluster for this workload.

| Elasticsearch Concept | Oracle Equivalent |
|---|---|
| Percolation query | Two-stage rule matching procedure |
| `match` query (BM25) | `CONTAINS()` with `SCORE()` |
| kNN search | `VECTOR_DISTANCE()` with HNSW index |
| RRF rank fusion | Manual RRF in SQL CTE |
| Index mapping types | `feedback_type` column + WHERE filter |
| Separate ES cluster | None — Oracle only |

---

## 10. Summary

| Topic | Recommendation |
|---|---|
| Search approach | Hybrid BM25 + Semantic with RRF merge |
| Database | Oracle 23ai AI Vector Search (native) |
| Embedding model | all-MiniLM-L12-v2 (in-DB ONNX, 384 dims) |
| Distance metric | Cosine |
| Rule matching | Two-stage: semantic shortlist (top 20) + exact BM25 evaluation |
| Match storage | Pre-computed — stored at write time, queried instantly |
| External API dependency | None |
| One-time batch cost | 3–5 hours of DB compute (8 sessions) |
| Storage overhead (vectors) | ~4–5 GB |
| Storage overhead (matches) | ~800 MB |
| Per-record write latency | ~60–65ms (one-time) |
| Per-record read latency | <1ms (pre-computed) |
| API fees for 1.5M records | $0 |

---

*Bank of America / TCS — Internal Use Only*
