#!/bin/bash
set -e  # Exit on any command failure

# Step 1: Define synonym set (requires Elasticsearch 8.8+ and xpack.synonyms.enabled=true)
curl -X PUT "localhost:9200/_synonyms/word_groups" -H 'Content-Type: application/json' -d '
{
  "synonyms_set": [
    {
      "id": "bacghr_client",
      "synonyms": "bacghr_client => client, customer, user, end user"
    },
    {
      "id": "bacghr_internalmove",
      "synonyms": "bacghr_internalmove => internal, transfer, from_within, lateral, IJP"
    },
    {
      "id": "bacghr_career",
      "synonyms": "bacghr_career => career, promotion, growth, development"
    },
    {
      "id": "bacghr_onboarding",
      "synonyms": "bacghr_onboarding => onboarding, orientation, induction"
    },
    {
      "id": "bacghr_team",
      "synonyms": "bacghr_team => team, collaboration, cooperation, group"
    },
    {
      "id": "bacghr_support",
      "synonyms": "bacghr_support => support, assistance, help, aid"
    }
  ]
}'

# Step 2: Create percolator index with synonym analyzer
curl -X PUT "localhost:9200/comment_rules" -H 'Content-Type: application/json' -d '
{
  "settings": {
    "analysis": {
      "filter": {
        "synonym_rules": {
          "type": "synonym_graph",
          "synonyms_set": "word_groups",
          "updateable": true
        }
      },
      "analyzer": {
        "synonym_search_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": ["lowercase", "synonym_rules"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "query": {
        "type": "percolator"
      },
      "topic": {
        "type": "keyword"
      },
      "comment_text": {
        "type": "text",
        "analyzer": "synonym_search_analyzer",
        "search_analyzer": "synonym_search_analyzer"
      }
    }
  }
}'

# Step 3: Bulk index percolator rules
curl -X POST "localhost:9200/comment_rules/_bulk" -H 'Content-Type: application/x-ndjson' -d '
{"index":{"_id":"1"}}
{"topic":"Client Support","query":{"intervals":{"comment_text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"bacghr_client","analyzer":"synonym_analyzer","max_gaps":5}},{"match":{"query":"bacghr_support","analyzer":"synonym_analyzer","max_gaps":5}}]}}}}}
{"index":{"_id":"2"}}
{"topic":"Career Concerns","query":{"intervals":{"comment_text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"lack","analyzer":"synonym_analyzer","max_gaps":2}},{"match":{"query":"bacghr_career","analyzer":"synonym_analyzer","max_gaps":2}}]}}}}}
{"index":{"_id":"3"}}
{"topic":"Client Satisfaction","query":{"intervals":{"comment_text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"client","analyzer":"synonym_analyzer","max_gaps":5}},{"match":{"query":"support","analyzer":"synonym_analyzer","max_gaps":5}}]}}}}}
{"index":{"_id":"4"}}
{"topic":"Learning and Growth","query":{"intervals":{"comment_text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"learning","analyzer":"synonym_analyzer","max_gaps":3}},{"match":{"query":"growth","analyzer":"synonym_analyzer","max_gaps":3}}]}}}}}
{"index":{"_id":"5"}}
{"topic":"Team Collaboration","query":{"intervals":{"comment_text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"team","analyzer":"synonym_analyzer","max_gaps":4}},{"match":{"query":"collaboration","analyzer":"synonym_analyzer","max_gaps":4}}]}}}}}
{"index":{"_id":"6"}}
{"topic":"Career Progression","query":{"intervals":{"comment_text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"promotion","analyzer":"synonym_analyzer","max_gaps":4}},{"match":{"query":"career","analyzer":"synonym_analyzer","max_gaps":4}}]}}}}}
{"index":{"_id":"7"}}
{"topic":"Client Help","query":{"intervals":{"comment_text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"bacghr_client","analyzer":"synonym_analyzer","max_gaps":4}},{"match":{"query":"bacghr_support","analyzer":"synonym_analyzer","max_gaps":4}}]}}}}}
{"index":{"_id":"8"}}
{"topic":"Onboarding Feedback","query":{"intervals":{"comment_text":{"match":{"query":"orientation experience","analyzer":"synonym_analyzer","ordered":true,"max_gaps":2}}}}}
{"index":{"_id":"9"}}
{"topic":"Team Support","query":{"intervals":{"comment_text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"team","analyzer":"synonym_analyzer","max_gaps":3}},{"match":{"query":"help","analyzer":"synonym_analyzer","max_gaps":3}}]}}}}}
{"index":{"_id":"10"}}
{"topic":"Internal Movement","query":{"intervals":{"comment_text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"internal","analyzer":"synonym_analyzer","max_gaps":3}},{"match":{"query":"opportunity","analyzer":"synonym_analyzer","max_gaps":3}}]}}}}}
{"index":{"_id":"11"}}
{"topic":"Employee Training","query":{"intervals":{"comment_text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"training","analyzer":"synonym_analyzer","max_gaps":3}},{"match":{"query":"session","analyzer":"synonym_analyzer","max_gaps":3}}]}}}}}
{"index":{"_id":"12"}}
{"topic":"Onboarding Process","query":{"intervals":{"comment_text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"onboarding","analyzer":"synonym_analyzer","max_gaps":2}},{"match":{"query":"process","analyzer":"synonym_analyzer","max_gaps":2}}]}}}}}
'
