-- Sample rb_comment_rules INSERTs with expanded expressions (no macros)
INSERT INTO rb_comment_rules (id, topic, rule_expr_raw) VALUES (1, 'Client Satisfaction', '"client" NEAR "support" OR "customer" NEAR "support" OR "end user" NEAR "support"');
INSERT INTO rb_comment_rules (id, topic, rule_expr_raw) VALUES (2, 'Internal Mobility', '"internal transfer" NEAR "opportunity" OR "from_within" NEAR "opportunity" OR "lateral move" NEAR "opportunity" OR "IJP" NEAR "opportunity"');
INSERT INTO rb_comment_rules (id, topic, rule_expr_raw) VALUES (3, 'Career Growth', '"career" NEAR "growth" OR "promotion" NEAR "growth" OR "learning" NEAR "growth"');
INSERT INTO rb_comment_rules (id, topic, rule_expr_raw) VALUES (4, 'Onboarding', '"onboarding" NEAR "helpful" OR "orientation" NEAR "helpful" OR "welcome process" NEAR "helpful"');
INSERT INTO rb_comment_rules (id, topic, rule_expr_raw) VALUES (5, 'Team Culture', '"team" NEAR "issues" OR "collaboration" NEAR "issues" OR "peers" NEAR "issues" OR "coworkers" NEAR "issues"');


-- Example SELECT queries using rule_expr_raw directly
SELECT * FROM rb_survey_comments
WHERE CONTAINS(comment_text, '"client" NEAR "support" OR "customer" NEAR "support" OR "end user" NEAR "support"', 1) > 0;

SELECT * FROM rb_survey_comments
WHERE CONTAINS(comment_text, '"internal transfer" NEAR "opportunity" OR "from_within" NEAR "opportunity" OR "lateral move" NEAR "opportunity" OR "IJP" NEAR "opportunity"', 1) > 0;

SELECT * FROM rb_survey_comments
WHERE CONTAINS(comment_text, '"career" NEAR "growth" OR "promotion" NEAR "growth" OR "learning" NEAR "growth"', 1) > 0;

SELECT * FROM rb_survey_comments
WHERE CONTAINS(comment_text, '"onboarding" NEAR "helpful" OR "orientation" NEAR "helpful" OR "welcome process" NEAR "helpful"', 1) > 0;

SELECT * FROM rb_survey_comments
WHERE CONTAINS(comment_text, '"team" NEAR "issues" OR "collaboration" NEAR "issues" OR "peers" NEAR "issues" OR "coworkers" NEAR "issues"', 1) > 0;

