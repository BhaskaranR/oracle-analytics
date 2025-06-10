POST /rules/_bulk
{"index":{"_id":"1"}}
{"topic":"Client Support","group_refs":["#bacghr_client","#bacghr_support"],"query":{"intervals":{"text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"#bacghr_client","analyzer":"custom_synonym_analyzer","max_gaps":5}},{"match":{"query":"#bacghr_support","analyzer":"custom_synonym_analyzer","max_gaps":5}}]}}}}}
{"index":{"_id":"2"}}
{"topic":"Career Concerns","group_refs":["#bacghr_career"],"query":{"intervals":{"text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"lack","analyzer":"custom_synonym_analyzer","max_gaps":2}},{"match":{"query":"#bacghr_career","analyzer":"custom_synonym_analyzer","max_gaps":2}}]}}}}}
{"index":{"_id":"3"}}
{"id":3,"topic":"Client Satisfaction","rule_query":{"intervals":{"comment_text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"client","max_gaps":5}},{"match":{"query":"support","max_gaps":5}}]}}}}}
{"index":{"_id":"4"}}
{"id":4,"topic":"Learning and Growth","rule_query":{"intervals":{"comment_text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"learning","max_gaps":3}},{"match":{"query":"growth","max_gaps":3}}]}}}}}
{"index":{"_id":"5"}}
{"id":5,"topic":"Team Collaboration","rule_query":{"intervals":{"comment_text":{"all_of":{"ordered":false,"intervals":[{"match":{"query":"team","max_gaps":4}},{"match":{"query":"collaboration","max_gaps":4}}]}}}}}
{"index":{"_id":"6"}}
{"id":6,"topic":"Career Progression","rule_query":{"intervals":{"comment_text":{"all_of":{"intervals":[{"match":{"query":"promotion","max_gaps":4}},{"match":{"query":"career","max_gaps":4}}]}}}}}
{"index":{"_id":"7"}}
{"id":7,"topic":"Client Help","rule_query":{"intervals":{"comment_text":{"all_of":{"intervals":[{"match":{"query":"#bacghr_client","max_gaps":4,"analyzer":"custom_synonym_analyzer"}},{"match":{"query":"#bacghr_support","max_gaps":4,"analyzer":"custom_synonym_analyzer"}}]}}}}}
{"index":{"_id":"8"}}
{"id":8,"topic":"Onboarding Feedback","rule_query":{"intervals":{"comment_text":{"match":{"query":"orientation experience","ordered":true,"max_gaps":2}}}}}
{"index":{"_id":"9"}}
{"id":9,"topic":"Team Support","rule_query":{"intervals":{"comment_text":{"all_of":{"intervals":[{"match":{"query":"team","max_gaps":3}},{"match":{"query":"help","max_gaps":3}}]}}}}}
{"index":{"_id":"10"}}
{"id":10,"topic":"Internal Movement","rule_query":{"intervals":{"comment_text":{"all_of":{"intervals":[{"match":{"query":"internal","max_gaps":3}},{"match":{"query":"opportunity","max_gaps":3}}]}}}}}
{"index":{"_id":"11"}}
{"id":11,"topic":"Employee Training","rule_query":{"intervals":{"comment_text":{"all_of":{"intervals":[{"match":{"query":"training","max_gaps":3}},{"match":{"query":"session","max_gaps":3}}]}}}}}
{"index":{"_id":"12"}}
{"id":12,"topic":"Onboarding Process","rule_query":{"intervals":{"comment_text":{"all_of":{"intervals":[{"match":{"query":"onboarding","max_gaps":2}},{"match":{"query":"process","max_gaps":2}}]}}}}}
