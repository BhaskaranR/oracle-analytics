# Reindex Comments with Topic and Count

## Step 1: Match and Reindex Comment with Topic

```bash
POST /comment_rules/_search
{
  "query": {
    "percolate": {
      "field": "rule_query",
      "document": {
        "comment_text": "I received excellent support from the customer service team."
      }
    }
}
```

Assume response returns:
```json
{
  "hits": {
    "hits": [
      {
        "_id": "1",
        "_source": {
          "topic": "Client Support"
        }
      }
    ]
  }
}
```

### Reindex Matched Comment
```bash
POST /matched_comments/_doc
{
  "comment_text": "I received excellent support from the customer service team.",
  "matched_topic": "Client Support"
}
```

## Step 2: Count of Comments per Topic
```bash
GET /matched_comments/_search
{
  "size": 0,
  "aggs": {
    "topic_counts": {
      "terms": {
        "field": "matched_topic.keyword",
        "size": 100
      }
    }
  }
}
```

## Step 3: Rematch All Comments When a New Rule or Synonym is Added

### Trigger Rematch (manually or via a job)
```bash
POST /_reindex
{
  "source": {
    "index": "comments"
  },
  "dest": {
    "index": "rematch_temp"
  },
  "script": {
    "source": "ctx._source.reprocess = true"
  }
}
```

Then for each reprocessed comment:
- Run `percolate` search
- Update/add entry in `matched_comments` with topic

---

## Example Percolate Queries

```bash
POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "I received excellent support from the customer service team." }
} } }

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "The training session helped me understand the new tools better." }
} } }

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "Team collaboration and communication have been excellent lately." }
} } }

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "Onboarding process was smooth and orientation was helpful." }
} } }

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "Career growth seems stagnant without promotion opportunities." }
} } }

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "Internal transfers offer great opportunities for career development." }
} } }

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "The new learning program supports employee growth and skill-building." }
} } }

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "Our client was satisfied with the prompt assistance provided." }
} } }

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "Orientation experience could be improved to reduce confusion." }
} } }

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "IJP offers a good internal opportunity for advancement." }
} } }
