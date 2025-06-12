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
    "total": {
      "value": 2,
      "relation": "eq"
    },
    "hits": [
      {
        "_id": "1",
        "_score": 0.8,
        "_source": {
          "topic": "Client Support",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "bacghr_client", "analyzer": "search_analyzer", "max_gaps": 5}},
                    {"match": {"query": "bacghr_support", "analyzer": "search_analyzer", "max_gaps": 5}}
                  ]
                }
              }
            }
          }
        }
      },
      {
        "_id": "7",
        "_score": 0.6,
        "_source": {
          "topic": "Client Help",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "client", "max_gaps": 4}},
                    {"match": {"query": "support", "max_gaps": 4}}
                  ]
                }
              }
            }
          }
        }
      }
    ]
  }
}
```

# Store matched comments with their rules and topics
POST /matched_comments/_doc
{
  "comment_text": "I received excellent support from the customer service team.",
  "matched_rules": [
    {
      "rule_id": "1",
      "topic": "Client Support",
      "score": 0.8,
      "matched_terms": ["bacghr_client", "bacghr_support"],
      "max_gaps": 5,
      "ordered": false
    },
    {
      "rule_id": "7",
      "topic": "Client Help",
      "score": 0.6,
      "matched_terms": ["client", "support"],
      "max_gaps": 4,
      "ordered": false
    }
  ],
  "timestamp": "2024-03-20T10:00:00Z",
  "total_matches": 2
}

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

- Then for each reprocessed comment:
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

Response:
{
  "hits": {
    "total": { "value": 2, "relation": "eq" },
    "hits": [
      {
        "_id": "1",
        "_score": 0.8,
        "_source": {
          "topic": "Client Support",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "bacghr_client", "analyzer": "search_analyzer", "max_gaps": 5}},
                    {"match": {"query": "bacghr_support", "analyzer": "search_analyzer", "max_gaps": 5}}
                  ]
                }
              }
            }
          }
        }
      },
      {
        "_id": "7",
        "_score": 0.6,
        "_source": {
          "topic": "Client Help",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "client", "max_gaps": 4}},
                    {"match": {"query": "support", "max_gaps": 4}}
                  ]
                }
              }
            }
          }
        }
      }
    ]
  }
}

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "The training session helped me understand the new tools better." }
} } }

Response:
{
  "hits": {
    "total": { "value": 1, "relation": "eq" },
    "hits": [
      {
        "_id": "11",
        "_score": 0.9,
        "_source": {
          "topic": "Employee Training",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "training", "analyzer": "search_analyzer", "max_gaps": 3}},
                    {"match": {"query": "session", "analyzer": "search_analyzer", "max_gaps": 3}}
                  ]
                }
              }
            }
          }
        }
      }
    ]
  }
}

# Store matched comment
POST /matched_comments/_doc
{
  "comment_text": "The training session helped me understand the new tools better.",
  "matched_rules": [
    {
      "rule_id": "11",
      "topic": "Employee Training",
      "score": 0.9,
      "matched_terms": ["training", "session"],
      "max_gaps": 3,
      "ordered": false
    }
  ],
  "timestamp": "2024-03-20T10:01:00Z",
  "total_matches": 1
}

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "Team collaboration and communication have been excellent lately." }
} } }

Response:
{
  "hits": {
    "total": { "value": 2, "relation": "eq" },
    "hits": [
      {
        "_id": "5",
        "_score": 0.85,
        "_source": {
          "topic": "Team Collaboration",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "team", "analyzer": "search_analyzer", "max_gaps": 4}},
                    {"match": {"query": "collaboration", "analyzer": "search_analyzer", "max_gaps": 4}}
                  ]
                }
              }
            }
          }
        }
      },
      {
        "_id": "9",
        "_score": 0.7,
        "_source": {
          "topic": "Team Support",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "team", "analyzer": "search_analyzer", "max_gaps": 3}},
                    {"match": {"query": "help", "analyzer": "search_analyzer", "max_gaps": 3}}
                  ]
                }
              }
            }
          }
        }
      }
    ]
  }
}

# Store matched comment
POST /matched_comments/_doc
{
  "comment_text": "Team collaboration and communication have been excellent lately.",
  "matched_rules": [
    {
      "rule_id": "5",
      "topic": "Team Collaboration",
      "score": 0.85,
      "matched_terms": ["team", "collaboration"],
      "max_gaps": 4,
      "ordered": false
    },
    {
      "rule_id": "9",
      "topic": "Team Support",
      "score": 0.7,
      "matched_terms": ["team", "help"],
      "max_gaps": 3,
      "ordered": false
    }
  ],
  "timestamp": "2024-03-20T10:02:00Z",
  "total_matches": 2
}

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "Onboarding process was smooth and orientation was helpful." }
} } }

Response:
{
  "hits": {
    "total": { "value": 2, "relation": "eq" },
    "hits": [
      {
        "_id": "12",
        "_score": 0.9,
        "_source": {
          "topic": "Onboarding Process",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "onboarding", "analyzer": "search_analyzer", "max_gaps": 2}},
                    {"match": {"query": "process", "analyzer": "search_analyzer", "max_gaps": 2}}
                  ]
                }
              }
            }
          }
        }
      },
      {
        "_id": "8",
        "_score": 0.75,
        "_source": {
          "topic": "Onboarding Feedback",
          "query": {
            "intervals": {
              "comment_text": {
                "match": {
                  "query": "orientation experience",
                  "analyzer": "search_analyzer",
                  "ordered": true,
                  "max_gaps": 2
                }
              }
            }
          }
        }
      }
    ]
  }
}

# Store matched comment
POST /matched_comments/_doc
{
  "comment_text": "Onboarding process was smooth and orientation was helpful.",
  "matched_rules": [
    {
      "rule_id": "12",
      "topic": "Onboarding Process",
      "score": 0.9,
      "matched_terms": ["onboarding", "process"],
      "max_gaps": 2,
      "ordered": false
    },
    {
      "rule_id": "8",
      "topic": "Onboarding Feedback",
      "score": 0.75,
      "matched_terms": ["orientation experience"],
      "max_gaps": 2,
      "ordered": true
    }
  ],
  "timestamp": "2024-03-20T10:03:00Z",
  "total_matches": 2
}

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "Career growth seems stagnant without promotion opportunities." }
} } }

Response:
{
  "hits": {
    "total": { "value": 2, "relation": "eq" },
    "hits": [
      {
        "_id": "2",
        "_score": 0.95,
        "_source": {
          "topic": "Career Concerns",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "lack", "analyzer": "search_analyzer", "max_gaps": 2}},
                    {"match": {"query": "bacghr_career", "analyzer": "search_analyzer", "max_gaps": 2}}
                  ]
                }
              }
            }
          }
        }
      },
      {
        "_id": "6",
        "_score": 0.8,
        "_source": {
          "topic": "Career Progression",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "promotion", "analyzer": "search_analyzer", "max_gaps": 4}},
                    {"match": {"query": "career", "analyzer": "search_analyzer", "max_gaps": 4}}
                  ]
                }
              }
            }
          }
        }
      }
    ]
  }
}

# Store matched comment
POST /matched_comments/_doc
{
  "comment_text": "Career growth seems stagnant without promotion opportunities.",
  "matched_rules": [
    {
      "rule_id": "2",
      "topic": "Career Concerns",
      "score": 0.95,
      "matched_terms": ["lack", "bacghr_career"],
      "max_gaps": 2,
      "ordered": false
    },
    {
      "rule_id": "6",
      "topic": "Career Progression",
      "score": 0.8,
      "matched_terms": ["promotion", "career"],
      "max_gaps": 4,
      "ordered": false
    }
  ],
  "timestamp": "2024-03-20T10:04:00Z",
  "total_matches": 2
}

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "Internal transfers offer great opportunities for career development." }
} } }

Response:
{
  "hits": {
    "total": { "value": 2, "relation": "eq" },
    "hits": [
      {
        "_id": "10",
        "_score": 0.85,
        "_source": {
          "topic": "Internal Movement",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "internal", "analyzer": "search_analyzer", "max_gaps": 3}},
                    {"match": {"query": "opportunity", "analyzer": "search_analyzer", "max_gaps": 3}}
                  ]
                }
              }
            }
          }
        }
      },
      {
        "_id": "3",
        "_score": 0.7,
        "_source": {
          "topic": "Career Concerns",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "lack", "analyzer": "search_analyzer", "max_gaps": 2}},
                    {"match": {"query": "bacghr_career", "analyzer": "search_analyzer", "max_gaps": 2}}
                  ]
                }
              }
            }
          }
        }
      }
    ]
  }
}

# Store matched comment
POST /matched_comments/_doc
{
  "comment_text": "Internal transfers offer great opportunities for career development.",
  "matched_rules": [
    {
      "rule_id": "10",
      "topic": "Internal Movement",
      "score": 0.85,
      "matched_terms": ["internal", "opportunity"],
      "max_gaps": 3,
      "ordered": false
    },
    {
      "rule_id": "3",
      "topic": "Career Concerns",
      "score": 0.7,
      "matched_terms": ["lack", "bacghr_career"],
      "max_gaps": 2,
      "ordered": false
    }
  ],
  "timestamp": "2024-03-20T10:05:00Z",
  "total_matches": 2
}

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "The new learning program supports employee growth and skill-building." }
} } }

Response:
{
  "hits": {
    "total": { "value": 2, "relation": "eq" },
    "hits": [
      {
        "_id": "13",
        "_score": 0.9,
        "_source": {
          "topic": "Learning Growth Opportunities",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "learning", "analyzer": "search_analyzer", "max_gaps": 5}},
                    {"match": {"query": "growth", "analyzer": "search_analyzer", "max_gaps": 5}}
                  ]
                }
              }
            }
          }
        }
      },
      {
        "_id": "14",
        "_score": 0.75,
        "_source": {
          "topic": "Simple Learning Growth",
          "query": {
            "intervals": {
              "comment_text": {
                "match": {
                  "query": "learning growth",
                  "analyzer": "search_analyzer",
                  "ordered": true,
                  "max_gaps": 3
                }
              }
            }
          }
        }
      }
    ]
  }
}

# Store matched comment
POST /matched_comments/_doc
{
  "comment_text": "The new learning program supports employee growth and skill-building.",
  "matched_rules": [
    {
      "rule_id": "13",
      "topic": "Learning Growth Opportunities",
      "score": 0.9,
      "matched_terms": ["learning", "growth"],
      "max_gaps": 5,
      "ordered": false
    },
    {
      "rule_id": "14",
      "topic": "Simple Learning Growth",
      "score": 0.75,
      "matched_terms": ["learning growth"],
      "max_gaps": 3,
      "ordered": true
    }
  ],
  "timestamp": "2024-03-20T10:06:00Z",
  "total_matches": 2
}

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "Our client was satisfied with the prompt assistance provided." }
} } }

Response:
{
  "hits": {
    "total": { "value": 2, "relation": "eq" },
    "hits": [
      {
        "_id": "3",
        "_score": 0.85,
        "_source": {
          "topic": "Client Satisfaction",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "client", "max_gaps": 5}},
                    {"match": {"query": "support", "max_gaps": 5}}
                  ]
                }
              }
            }
          }
        }
      },
      {
        "_id": "7",
        "_score": 0.7,
        "_source": {
          "topic": "Client Help",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "client", "max_gaps": 4}},
                    {"match": {"query": "support", "max_gaps": 4}}
                  ]
                }
              }
            }
          }
        }
      }
    ]
  }
}

# Store matched comment
POST /matched_comments/_doc
{
  "comment_text": "Our client was satisfied with the prompt assistance provided.",
  "matched_rules": [
    {
      "rule_id": "3",
      "topic": "Client Satisfaction",
      "score": 0.85,
      "matched_terms": ["client", "support"],
      "max_gaps": 5,
      "ordered": false
    },
    {
      "rule_id": "7",
      "topic": "Client Help",
      "score": 0.7,
      "matched_terms": ["client", "support"],
      "max_gaps": 4,
      "ordered": false
    }
  ],
  "timestamp": "2024-03-20T10:07:00Z",
  "total_matches": 2
}

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "Orientation experience could be improved to reduce confusion." }
} } }

Response:
{
  "hits": {
    "total": { "value": 1, "relation": "eq" },
    "hits": [
      {
        "_id": "8",
        "_score": 0.95,
        "_source": {
          "topic": "Onboarding Feedback",
          "query": {
            "intervals": {
              "comment_text": {
                "match": {
                  "query": "orientation experience",
                  "analyzer": "search_analyzer",
                  "ordered": true,
                  "max_gaps": 2
                }
              }
            }
          }
        }
      }
    ]
  }
}

# Store matched comment
POST /matched_comments/_doc
{
  "comment_text": "Orientation experience could be improved to reduce confusion.",
  "matched_rules": [
    {
      "rule_id": "8",
      "topic": "Onboarding Feedback",
      "score": 0.95,
      "matched_terms": ["orientation experience"],
      "max_gaps": 2,
      "ordered": true
    }
  ],
  "timestamp": "2024-03-20T10:08:00Z",
  "total_matches": 1
}

POST /comment_rules/_search
{ "query": { "percolate": {
    "field": "rule_query",
    "document": { "comment_text": "IJP offers a good internal opportunity for advancement." }
} } }

Response:
{
  "hits": {
    "total": { "value": 2, "relation": "eq" },
    "hits": [
      {
        "_id": "10",
        "_score": 0.9,
        "_source": {
          "topic": "Internal Movement",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "internal", "analyzer": "search_analyzer", "max_gaps": 3}},
                    {"match": {"query": "opportunity", "analyzer": "search_analyzer", "max_gaps": 3}}
                  ]
                }
              }
            }
          }
        }
      },
      {
        "_id": "15",
        "_score": 0.8,
        "_source": {
          "topic": "Internal Department Movement",
          "query": {
            "intervals": {
              "comment_text": {
                "all_of": {
                  "ordered": false,
                  "intervals": [
                    {"match": {"query": "bacghr_internalmove", "analyzer": "search_analyzer", "max_gaps": 4}},
                    {"match": {"query": "departments", "analyzer": "search_analyzer", "max_gaps": 4}}
                  ]
                }
              }
            }
          }
        }
      }
    ]
  }
}

# Store matched comment
POST /matched_comments/_doc
{
  "comment_text": "IJP offers a good internal opportunity for advancement.",
  "matched_rules": [
    {
      "rule_id": "10",
      "topic": "Internal Movement",
      "score": 0.9,
      "matched_terms": ["internal", "opportunity"],
      "max_gaps": 3,
      "ordered": false
    },
    {
      "rule_id": "15",
      "topic": "Internal Department Movement",
      "score": 0.8,
      "matched_terms": ["bacghr_internalmove", "departments"],
      "max_gaps": 4,
      "ordered": false
    }
  ],
  "timestamp": "2024-03-20T10:09:00Z",
  "total_matches": 2
}
