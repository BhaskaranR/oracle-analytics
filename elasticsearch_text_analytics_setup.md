# Elasticsearch Setup for Text Analytics Rules and Comments

## 1. Create Index: `comments`

```json
PUT /comments
{
  "mappings": {
    "properties": {
      "id": { "type": "integer" },
      "respondent_id": { "type": "integer" },
      "comment_text": { "type": "text" }
    }
  }
}
```

---

## 2. Create Index: `rules`

```json
PUT /rules
{
  "mappings": {
    "properties": {
      "id": { "type": "integer" },
      "topic": { "type": "keyword" },
      "rule_query": { "type": "object", "enabled": false }
    }
  }
}
```

---

## 3. Insert Sample Comments

```json
POST /comments/_bulk
{ "index": { "_id": 1 } }
{ "id": 1, "respondent_id": 1001, "comment_text": "I think career development is important for growth." }
{ "index": { "_id": 2 } }
{ "id": 2, "respondent_id": 1002, "comment_text": "Internal transfer was a great opportunity." }
{ "index": { "_id": 3 } }
{ "id": 3, "respondent_id": 1003, "comment_text": "Support from the client was lacking." }
```

---

## 4. Insert Sample Rules (flattened span_near queries)

```json
POST /rules/_bulk
{ "index": { "_id": 1 } }
{
  "id": 1,
  "topic": "Career Growth",
  "rule_query": {
    "span_near": {
      "clauses": [
        { "span_term": { "comment_text": "career" } },
        { "span_term": { "comment_text": "growth" } }
      ],
      "slop": 5,
      "in_order": false
    }
  }
}
{ "index": { "_id": 2 } }
{
  "id": 2,
  "topic": "Internal Mobility",
  "rule_query": {
    "span_near": {
      "clauses": [
        { "span_term": { "comment_text": "internal" } },
        { "span_term": { "comment_text": "transfer" } }
      ],
      "slop": 4,
      "in_order": false
    }
  }
}
```

---

## 5. Select Matching Comments for a Rule

```json
POST /comments/_search
{
  "query": {
    "span_near": {
      "clauses": [
        { "span_term": { "comment_text": "career" } },
        { "span_term": { "comment_text": "growth" } }
      ],
      "slop": 5,
      "in_order": false
    }
  },
  "highlight": {
    "fields": {
      "comment_text": {}
    }
  }
}
```

---

## 6. Optional Aggregation: Match Count by Rule

(You’ll need to run queries per rule or use scripted logic externally)

---

Let me know if you want this in Python (Elasticsearch client) or a curl-based shell script.
