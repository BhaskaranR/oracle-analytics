-- Oracle 19c-compatible rule expansions (NEARn → NEAR + OR logic)
UPDATE rb_comment_rules SET rule_expr_raw = '"career" NEAR "growth" OR "promotion" NEAR "growth" OR "learning" NEAR "growth"' WHERE id = 1;
UPDATE rb_comment_rules SET rule_expr_raw = '"internal transfer" NEAR "opportunity" OR "from_within" NEAR "opportunity" OR "lateral move" NEAR "opportunity" OR "IJP" NEAR "opportunity"' WHERE id = 2;
UPDATE rb_comment_rules SET rule_expr_raw = '"client" NEAR "support" OR "customer" NEAR "support" OR "end user" NEAR "support"' WHERE id = 3;
UPDATE rb_comment_rules SET rule_expr_raw = '"support" NEAR "helpful" OR "assistance" NEAR "helpful" OR "HR help" NEAR "helpful" OR "guidance" NEAR "helpful"' WHERE id = 4;
UPDATE rb_comment_rules SET rule_expr_raw = '"team" NEAR "issues" OR "collaboration" NEAR "issues" OR "peers" NEAR "issues" OR "coworkers" NEAR "issues"' WHERE id = 5;
UPDATE rb_comment_rules SET rule_expr_raw = '"onboarding" NEAR "orientation" OR "orientation" NEAR "orientation" OR "welcome process" NEAR "orientation"' WHERE id = 6;
