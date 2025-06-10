#!/bin/bash

# Step 1: Create index with custom analyzer for synonyms
curl -X PUT "localhost:9200/comments_index" -H 'Content-Type: application/json' -d '
{
  "settings": {
    "analysis": {
      "filter": {
        "custom_synonym_filter": {
          "type": "synonym",
          "synonyms": [
            "#bacghr_client => client, customer, user, end user",
            "#bacghr_internalmove => internal, transfer, from_within, lateral, IJP",
            "#bacghr_career => career, promotion, growth, development",
            "#bacghr_onboarding => onboarding, orientation, induction",
            "#bacghr_team => team, collaboration, cooperation, group",
            "#bacghr_support => support, assistance, help, aid"
          ]
        }
      },
      "analyzer": {
        "custom_synonym_analyzer": {
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "custom_synonym_filter"
          ]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "text": {
        "type": "text",
        "analyzer": "custom_synonym_analyzer"
      }
    }
  }
}'

# Step 2: Create percolator index for comment_rules
curl -X PUT "localhost:9200/comment_rules" -H 'Content-Type: application/json' -d '
{
  "mappings": {
    "properties": {
      "query": {
        "type": "percolator"
      },
      "topic": {
        "type": "keyword"
      },
      "group_refs": {
        "type": "keyword"
      },
      "text": {
        "type": "text",
        "analyzer": "custom_synonym_analyzer"
      }
    }
  }
}'

# Step 3: Index percolator rules using intervals
curl -X POST "localhost:9200/comment_rules/_bulk" -H 'Content-Type: application/json' -d '
{ "index": { "_id": "1" } }
{
  "topic": "Client Support",
  "group_refs": ["#bacghr_client", "#bacghr_support"],
  "query": {
    "intervals": {
      "text": {
        "all_of": {
          "ordered": false,
          "intervals": [
            { "match": { "query": "#bacghr_client", "analyzer": "custom_synonym_analyzer", "max_gaps": 5 } },
            { "match": { "query": "#bacghr_support", "analyzer": "custom_synonym_analyzer", "max_gaps": 5 } }
          ]
        }
      }
    }
  }
}
{ "index": { "_id": "2" } }
{
  "topic": "Career Concerns",
  "group_refs": ["#bacghr_career"],
  "query": {
    "intervals": {
      "text": {
        "all_of": {
          "ordered": false,
          "intervals": [
            { "match": { "query": "lack", "analyzer": "custom_synonym_analyzer", "max_gaps": 2 } },
            { "match": { "query": "#bacghr_career", "analyzer": "custom_synonym_analyzer", "max_gaps": 2 } }
          ]
        }
      }
    }
  }
}
{ "index": { "_id": "3" } }
{
  "topic": "Team Collaboration",
  "group_refs": ["#bacghr_team"],
  "query": {
    "intervals": {
      "text": {
        "match": {
          "query": "great team",
          "analyzer": "custom_synonym_analyzer",
          "max_gaps": 3,
          "ordered": true
        }
      }
    }
  }
}
'

# Step 4: Match an incoming comment
curl -X POST "localhost:9200/comment_rules/_search" -H 'Content-Type: application/json' -d '
{
  "query": {
    "percolate": {
      "field": "query",
      "document": {
        "text": "The customer received helpful support from our team"
      }
    }
  }
}'
