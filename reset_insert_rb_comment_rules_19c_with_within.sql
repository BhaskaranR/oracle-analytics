-- Delete existing rules
DELETE FROM rb_comment_rules;

-- Insert new Oracle 19c-safe rules with NEAR and WITHIN
INSERT INTO rb_comment_rules (id, topic, rule_expr_raw) VALUES (1, 'Client Satisfaction', '"client" NEAR "support" OR "customer" NEAR "support" OR "end user" NEAR "support"');
INSERT INTO rb_comment_rules (id, topic, rule_expr_raw) VALUES (2, 'Internal Mobility', '"internal transfer" NEAR "opportunity" OR "from_within" NEAR "opportunity" OR "lateral move" NEAR "opportunity" OR "IJP" NEAR "opportunity"');
INSERT INTO rb_comment_rules (id, topic, rule_expr_raw) VALUES (3, 'Career Growth', '"career" NEAR "growth" OR "promotion" NEAR "growth" OR "learning" NEAR "growth"');
INSERT INTO rb_comment_rules (id, topic, rule_expr_raw) VALUES (4, 'Onboarding', '"onboarding" NEAR "helpful" OR "orientation" NEAR "helpful" OR "welcome process" NEAR "helpful"');
INSERT INTO rb_comment_rules (id, topic, rule_expr_raw) VALUES (5, 'Team Culture', '"team" NEAR "issues" OR "collaboration" NEAR "issues" OR "peers" NEAR "issues" OR "coworkers" NEAR "issues"');
INSERT INTO rb_comment_rules (id, topic, rule_expr_raw) VALUES (6, 'Onboarding Section Test', '"onboarding" WITHIN COMMENT');
INSERT INTO rb_comment_rules (id, topic, rule_expr_raw) VALUES (7, 'Support Section Match', '"support" WITHIN COMMENT');

COMMIT;
