#!/bin/bash

# 1. Client Support related
curl -X POST "localhost:9200/comment_rules/_search" -H 'Content-Type: application/json' -d '{
  "query": {
    "percolate": {
      "field": "query",
      "document": {
        "text": "The client support team was very responsive and helped resolve my issue quickly"
      }
    }
  }
}'

# 2. Career Concerns
curl -X POST "localhost:9200/comment_rules/_search" -H 'Content-Type: application/json' -d '{
  "query": {
    "percolate": {
      "field": "query",
      "document": {
        "text": "I feel there is a lack of career growth opportunities in my current role"
      }
    }
  }
}'

# 3. Learning and Growth
curl -X POST "localhost:9200/comment_rules/_search" -H 'Content-Type: application/json' -d '{
  "query": {
    "percolate": {
      "field": "query",
      "document": {
        "text": "The learning opportunities provided have contributed to my professional growth"
      }
    }
  }
}'

# 4. Team Collaboration
curl -X POST "localhost:9200/comment_rules/_search" -H 'Content-Type: application/json' -d '{
  "query": {
    "percolate": {
      "field": "query",
      "document": {
        "text": "Our team collaboration has improved significantly over the past quarter"
      }
    }
  }
}'

# 5. Career Progression
curl -X POST "localhost:9200/comment_rules/_search" -H 'Content-Type: application/json' -d '{
  "query": {
    "percolate": {
      "field": "query",
      "document": {
        "text": "I am interested in career advancement and promotion opportunities"
      }
    }
  }
}'

# 6. Onboarding Feedback
curl -X POST "localhost:9200/comment_rules/_search" -H 'Content-Type: application/json' -d '{
  "query": {
    "percolate": {
      "field": "query",
      "document": {
        "text": "The orientation experience was well organized and informative"
      }
    }
  }
}'

# 7. Team Support
curl -X POST "localhost:9200/comment_rules/_search" -H 'Content-Type: application/json' -d '{
  "query": {
    "percolate": {
      "field": "query",
      "document": {
        "text": "My team provided excellent help during the project implementation"
      }
    }
  }
}'

# 8. Internal Movement
curl -X POST "localhost:9200/comment_rules/_search" -H 'Content-Type: application/json' -d '{
  "query": {
    "percolate": {
      "field": "query",
      "document": {
        "text": "I would like to explore internal opportunities in other departments"
      }
    }
  }
}'

# 9. Employee Training
curl -X POST "localhost:9200/comment_rules/_search" -H 'Content-Type: application/json' -d '{
  "query": {
    "percolate": {
      "field": "query",
      "document": {
        "text": "The training session on new tools was very helpful"
      }
    }
  }
}'

# 10. Onboarding Process
curl -X POST "localhost:9200/comment_rules/_search" -H 'Content-Type: application/json' -d '{
  "query": {
    "percolate": {
      "field": "query",
      "document": {
        "text": "The onboarding process was smooth and well-structured"
      }
    }
  }
}'

# 11. Client Help (with synonyms)
curl -X POST "localhost:9200/comment_rules/_search" -H 'Content-Type: application/json' -d '{
  "query": {
    "percolate": {
      "field": "query",
      "document": {
        "text": "The customer support team provided excellent assistance"
      }
    }
  }
}'

# 12. Multiple Rule Match
curl -X POST "localhost:9200/comment_rules/_search" -H 'Content-Type: application/json' -d '{
  "query": {
    "percolate": {
      "field": "query",
      "document": {
        "text": "The client support team helped me with my career growth and learning opportunities"
      }
    }
  }
}' 