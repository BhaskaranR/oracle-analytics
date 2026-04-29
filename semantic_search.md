You Only Need This
Your DBA does 3 things:
1. Download the file (on the DB server)
bashwget https://adwc4pm.objectstorage.us-ashburn-1.oci.customer-oci.com/p/eLddQappgBJ7jNi6Guz9m9LOtYe2u8LWY19GfgU8flFK4N9YgP4kTlrE9Px3pE12/n/adwc4pm/b/OML-Resources/o/all_MiniLM_L12_v2.onnx
2. Create a directory pointing to where the file lives
sqlCREATE OR REPLACE DIRECTORY ONNX_DIR AS '/path/where/file/was/downloaded/';
GRANT READ ON DIRECTORY ONNX_DIR TO your_schema;
3. Load it into Oracle
sqlBEGIN
  DBMS_VECTOR.LOAD_ONNX_MODEL(
    directory  => 'ONNX_DIR',
    file_name  => 'all_MiniLM_L12_v2.onnx',
    model_name => 'ALL_MINILM_L12_V2'
  );
END;
/
That's it. Done. The Python code you saw is for a completely separate use case — building your own custom model from scratch. Ignore it.You said: give me the query that includes both bm25 and semantic searchgive me the query that includes both bm25 and semantic search10:04 AMClaude responded: ---Recalled previously shared hybrid search query implementationRecalled previously shared hybrid search query implementationsqlWITH

-- Embed the search query using MiniLM
search_vector AS (
  SELECT VECTOR_EMBEDDING(
    ALL_MINILM_L12_V2 
    USING 'employee burnout exhausted overworked' AS data
  ) AS qvec
  FROM dual
),

-- BM25 leg
bm25_results AS (
  SELECT
    f.feedback_id,
    f.feedback_text,
    SCORE(1)                             AS bm25_score,
    RANK() OVER (ORDER BY SCORE(1) DESC) AS bm25_rank
  FROM hres_feedback f
  WHERE CONTAINS(f.feedback_text, 
    '(burnout OR exhausted OR NEAR((overworked, manager), 5)) NOT positive', 1
  ) > 0
  FETCH FIRST 50 ROWS ONLY
),

-- Semantic leg
semantic_results AS (
  SELECT
    f.feedback_id,
    f.feedback_text,
    VECTOR_DISTANCE(
      f.feedback_vector,
      (SELECT qvec FROM search_vector),
      COSINE
    )                                        AS vec_distance,
    RANK() OVER (
      ORDER BY VECTOR_DISTANCE(
        f.feedback_vector,
        (SELECT qvec FROM search_vector),
        COSINE
      ) ASC
    )                                        AS semantic_rank
  FROM hres_feedback f
  FETCH FIRST 50 ROWS ONLY
),

-- RRF merge
rrf_merged AS (
  SELECT
    COALESCE(b.feedback_id,   s.feedback_id)   AS feedback_id,
    COALESCE(b.feedback_text, s.feedback_text)  AS feedback_text,
    ROUND(
      (1.0 / (60 + COALESCE(b.bm25_rank,     9999))) +
      (1.0 / (60 + COALESCE(s.semantic_rank, 9999))),
    6)                                           AS rrf_score
  FROM bm25_results b
  FULL OUTER JOIN semantic_results s
    ON b.feedback_id = s.feedback_id
)

-- Final results
SELECT feedback_id, feedback_text, rrf_score
FROM rrf_merged
ORDER BY rrf_score DESC
FETCH FIRST 20 ROWS ONLY;

Two Things to Change for Your Setup
PlaceholderReplace Withhres_feedbackYour actual table namefeedback_vectorYour vector column name (needs to exist and be populated)

Before This Works
Your feedback table needs a vector column populated. If that's not done yet:
sql-- Add the column
ALTER TABLE hres_feedback 
ADD feedback_vector VECTOR(384, FLOAT32);

-- Populate it (run once)
UPDATE hres_feedback
SET feedback_vector = VECTOR_EMBEDDING(
  ALL_MINILM_L12_V2 USING feedback_text AS data
);
COMMIT;
