# Elasticsearch Percolator Rule Setup

This document outlines the complete setup for using percolator queries in Elasticsearch to match user comments to predefined rules, with or without using word groups.

---

## 1. Index Setup

### Create `word_groups` Index

```json
PUT /word_groups
{
  "mappings": {
    "properties": {
      "group_name": { "type": "keyword" },
      "words": { "type": "keyword" }
    }
  }
}

### Create comment_rules Index with Percolator

PUT /comment_rules
{
  "mappings": {
    "properties": {
      "topic": { "type": "keyword" },
      "query": { "type": "percolator" },
      "exclude": { "type": "text" }
    }
  }
}

PUT /comments
{
  "mappings": {
    "properties": {
      "text": {
        "type": "text"
      },
      "created_at": {
        "type": "date"
      },
      "user_id": {
        "type": "keyword"
      }
    }
  }
}



POST /word_groups/_bulk
{ "index": { "_id": "#bacghr_client" } }
{ "group_name": "#bacghr_client", "words": ["client", "customer", "user", "end user"] }

{ "index": { "_id": "#bacghr_internalmove" } }
{ "group_name": "#bacghr_internalmove", "words": ["internal", "transfer", "from_within", "lateral", "IJP"] }

{ "index": { "_id": "#bacghr_career" } }
{ "group_name": "#bacghr_career", "words": ["career", "promotion", "growth", "development"] }

{ "index": { "_id": "#bacghr_onboarding" } }
{ "group_name": "#bacghr_onboarding", "words": ["onboarding", "orientation", "induction"] }

{ "index": { "_id": "#bacghr_team" } }
{ "group_name": "#bacghr_team", "words": ["team", "collaboration", "cooperation", "group"] }

{ "index": { "_id": "#bacghr_support" } }
{ "group_name": "#bacghr_support", "words": ["support", "assistance", "help", "aid"] }

##Insert Rules Without Group Macros



POST /comment_rules/_doc
{
  "topic": "Career Growth",
  "query": {
    "bool": {
      "should": [
        { "match_phrase": { "content": { "query": "career growth", "slop": 3 } } },
        { "match_phrase": { "content": { "query": "promotion growth", "slop": 3 } } },
        { "match_phrase": { "content": { "query": "learning growth", "slop": 3 } } }
      ]
    }
  }
}


POST /comment_rules/_doc
// POST _bulk
{ "index": { "_index": "comment_rules", "_id": "1" } }
{ "topic": "Client Satisfaction", "group_refs": ["#bacghr_client", "#bacghr_support"], "query": { "bool": { "should": [ { "span_near": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "client" } } } }, { "span_multi": { "match": { "wildcard": { "text": "support" } } } } ], "slop": 5, "in_order": false } } ] } } }
{ "index": { "_index": "comment_rules", "_id": "2" } }
{ "topic": "Internal Mobility", "query": { "span_near": { "clauses": [ { "span_or": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "internal" } } } }, { "span_multi": { "match": { "wildcard": { "text": "transfer" } } } }, { "span_multi": { "match": { "wildcard": { "text": "from_within" } } } }, { "span_multi": { "match": { "wildcard": { "text": "lateral" } } } }, { "span_multi": { "match": { "wildcard": { "text": "IJP" } } } } ] } }, { "span_multi": { "match": { "wildcard": { "text": "opportunity" } } } } ], "slop": 4, "in_order": false } } }
{ "index": { "_index": "comment_rules", "_id": "3" } }
{ "topic": "Career Growth", "query": { "span_near": { "clauses": [ { "span_or": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "career" } } } }, { "span_multi": { "match": { "wildcard": { "text": "promotion" } } } }, { "span_multi": { "match": { "wildcard": { "text": "growth" } } } }, { "span_multi": { "match": { "wildcard": { "text": "development" } } } } ] } }, { "span_multi": { "match": { "wildcard": { "text": "lacking" } } } } ], "slop": 6, "in_order": false } } }
{ "index": { "_index": "comment_rules", "_id": "4" } }
{ "topic": "Onboarding", "query": { "span_near": { "clauses": [ { "span_or": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "onboarding" } } } }, { "span_multi": { "match": { "wildcard": { "text": "orientation" } } } }, { "span_multi": { "match": { "wildcard": { "text": "induction" } } } } ] } }, { "span_multi": { "match": { "wildcard": { "text": "helpful" } } } } ], "slop": 3, "in_order": false } } }
{ "index": { "_index": "comment_rules", "_id": "5" } }
{ "topic": "Team Culture", "query": { "span_near": { "clauses": [ { "span_or": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "team" } } } }, { "span_multi": { "match": { "wildcard": { "text": "collaboration" } } } }, { "span_multi": { "match": { "wildcard": { "text": "cooperation" } } } }, { "span_multi": { "match": { "wildcard": { "text": "group" } } } } ] } }, { "span_multi": { "match": { "wildcard": { "text": "issues" } } } } ], "slop": 2, "in_order": false } } }
{ "index": { "_index": "comment_rules", "_id": "6" } }
{ "topic": "Leadership Feedback", "query": { "span_near": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "leadership" } } } }, { "span_multi": { "match": { "wildcard": { "text": "feedback" } } } } ], "slop": 5, "in_order": false } } }
{ "index": { "_index": "comment_rules", "_id": "7" } }
{ "topic": "Work Environment", "query": { "span_near": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "environment" } } } }, { "span_multi": { "match": { "wildcard": { "text": "stressful" } } } } ], "slop": 4, "in_order": false } } }
{ "index": { "_index": "comment_rules", "_id": "8" } }
{ "topic": "Support Experience", "query": { "bool": { "should": [ { "span_near": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "support" } } } }, { "span_multi": { "match": { "wildcard": { "text": "experience" } } } } ], "slop": 5, "in_order": false } }, { "span_near": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "assistance" } } } }, { "span_multi": { "match": { "wildcard": { "text": "feedback" } } } } ], "slop": 5, "in_order": false } } ] } } }
{ "index": { "_index": "comment_rules", "_id": "9" } }
{ "topic": "Promotion Issues", "query": { "span_near": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "promotion" } } } }, { "span_multi": { "match": { "wildcard": { "text": "denied" } } } } ], "slop": 6, "in_order": false } } }
{ "index": { "_index": "comment_rules", "_id": "10" } }
{ "topic": "Client Concerns", "query": { "span_near": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "customer" } } } }, { "span_multi": { "match": { "wildcard": { "text": "issue" } } } } ], "slop": 5, "in_order": false } } }
{ "index": { "_index": "comment_rules", "_id": "11" } }
{ "topic": "Internal Transfers", "query": { "span_near": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "transfer" } } } }, { "span_multi": { "match": { "wildcard": { "text": "within" } } } } ], "slop": 4, "in_order": false } } }
{ "index": { "_index": "comment_rules", "_id": "12" } }
{ "topic": "Career Frustration", "query": { "span_near": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "growth" } } } }, { "span_multi": { "match": { "wildcard": { "text": "blocked" } } } } ], "slop": 6, "in_order": false } } }
{ "index": { "_index": "comment_rules", "_id": "13" } }
{ "topic": "Teamwork Challenge", "query": { "span_near": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "team" } } } }, { "span_multi": { "match": { "wildcard": { "text": "dysfunction" } } } } ], "slop": 4, "in_order": false } } }
{ "index": { "_index": "comment_rules", "_id": "14" } }
{ "topic": "Onboarding Problems", "query": { "span_near": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "induction" } } } }, { "span_multi": { "match": { "wildcard": { "text": "confusing" } } } } ], "slop": 3, "in_order": false } } }
{ "index": { "_index": "comment_rules", "_id": "15" } }
{ "topic": "Customer Help", "query": { "span_near": { "clauses": [ { "span_multi": { "match": { "wildcard": { "text": "end user" } } } }, { "span_multi": { "match": { "wildcard": { "text": "aid" } } } } ], "slop": 4, "in_order": false } } }


POST /comments/_bulk
{ "index": {} }
{ "text": "The onboarding process was very helpful and smooth.", "created_at": "2024-10-01T10:00:00Z", "user_id": "u001" }
{ "index": {} }
{ "text": "I feel there is a lack of career growth opportunities.", "created_at": "2024-10-02T12:30:00Z", "user_id": "u002" }
{ "index": {} }
{ "text": "The support team was quick to assist our end users.", "created_at": "2024-10-03T09:15:00Z", "user_id": "u003" }
{ "index": {} }
{ "text": "Internal transfers seem rare unless you apply through IJP.", "created_at": "2024-10-04T11:20:00Z", "user_id": "u004" }
{ "index": {} }
{ "text": "Orientation sessions were not that useful.", "created_at": "2024-10-05T13:50:00Z", "user_id": "u005" }
{ "index": {} }
{ "text": "Team collaboration is great and helps us solve issues quickly.", "created_at": "2024-10-06T15:05:00Z", "user_id": "u006" }
{ "index": {} }
{ "text": "Customer support has been inconsistent lately.", "created_at": "2024-10-07T16:40:00Z", "user_id": "u007" }
{ "index": {} }
{ "text": "There should be more focus on employee development.", "created_at": "2024-10-08T18:10:00Z", "user_id": "u008" }
{ "index": {} }
{ "text": "Transfer opportunities need to be advertised better internally.", "created_at": "2024-10-09T19:55:00Z", "user_id": "u009" }
{ "index": {} }
{ "text": "My team lacks proper cooperation to handle complex tasks.", "created_at": "2024-10-10T21:20:00Z", "user_id": "u010" }
{ "index": {} }
{ "text": "IJP programs are a good initiative, but awareness is low.", "created_at": "2024-10-11T08:35:00Z", "user_id": "u011" }
{ "index": {} }
{ "text": "Growth and development paths should be clearer.", "created_at": "2024-10-12T09:45:00Z", "user_id": "u012" }
{ "index": {} }
{ "text": "Induction was confusing without proper documents.", "created_at": "2024-10-13T11:00:00Z", "user_id": "u013" }
{ "index": {} }
{ "text": "Helpful and responsive client support made my day.", "created_at": "2024-10-14T12:15:00Z", "user_id": "u014" }
{ "index": {} }
{ "text": "User experience was ruined due to poor support.", "created_at": "2024-10-15T14:30:00Z", "user_id": "u015" }
{ "index": {} }
{ "text": "The career development portal has very few real options.", "created_at": "2024-10-16T16:45:00Z", "user_id": "u016" }
{ "index": {} }
{ "text": "Client aid response time is excellent.", "created_at": "2024-10-17T18:00:00Z", "user_id": "u017" }
{ "index": {} }
{ "text": "No induction was given when I joined.", "created_at": "2024-10-18T19:15:00Z", "user_id": "u018" }
{ "index": {} }
{ "text": "My group lacks proper coordination and it's affecting delivery.", "created_at": "2024-10-19T20:30:00Z", "user_id": "u019" }
{ "index": {} }
{ "text": "Customers reported delays in getting help.", "created_at": "2024-10-20T21:45:00Z", "user_id": "u020" }
