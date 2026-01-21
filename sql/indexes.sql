-- =====================================================================
-- PRIMARY TABLE INDEXES (jobs, job_categories, job_types)
-- =====================================================================

-- Jobs table indexes
CREATE INDEX idx_jobs_job_category_id ON jobs(job_category_id) USING BTREE;
CREATE INDEX idx_jobs_job_type_id ON jobs(job_type_id) USING BTREE;
CREATE INDEX idx_jobs_media_id ON jobs(media_id) USING BTREE;
CREATE INDEX idx_jobs_deleted ON jobs(deleted) USING BTREE;
CREATE INDEX idx_jobs_publish_status ON jobs(publish_status) USING BTREE;

-- Composite index for common WHERE clause combinations
CREATE INDEX idx_jobs_status_deleted ON jobs(publish_status, deleted) USING BTREE;

-- Composite index for sorting (important for ORDER BY performance)
CREATE INDEX idx_jobs_sort_order_id ON jobs(sort_order DESC, id DESC) USING BTREE;

-- Job Categories indexes
CREATE INDEX idx_job_categories_deleted ON job_categories(deleted) USING BTREE;

-- Job Types indexes
CREATE INDEX idx_job_types_deleted ON job_types(deleted) USING BTREE;
CREATE INDEX idx_job_types_category_id ON job_types(job_category_id) USING BTREE;

-- =====================================================================
-- JUNCTION TABLE INDEXES (many-to-many relationships)
-- =====================================================================

-- jobs_personalities
CREATE INDEX idx_jobs_personalities_job_id ON jobs_personalities(job_id) USING BTREE;
CREATE INDEX idx_jobs_personalities_personality_id ON jobs_personalities(personality_id) USING BTREE;

-- jobs_practical_skills
CREATE INDEX idx_jobs_practical_skills_job_id ON jobs_practical_skills(job_id) USING BTREE;
CREATE INDEX idx_jobs_practical_skills_skill_id ON jobs_practical_skills(practical_skill_id) USING BTREE;

-- jobs_basic_abilities
CREATE INDEX idx_jobs_basic_abilities_job_id ON jobs_basic_abilities(job_id) USING BTREE;
CREATE INDEX idx_jobs_basic_abilities_ability_id ON jobs_basic_abilities(basic_ability_id) USING BTREE;

-- jobs_tools
CREATE INDEX idx_jobs_tools_job_id ON jobs_tools(job_id) USING BTREE;
CREATE INDEX idx_jobs_tools_affiliate_id ON jobs_tools(affiliate_id) USING BTREE;

-- jobs_career_paths
CREATE INDEX idx_jobs_career_paths_job_id ON jobs_career_paths(job_id) USING BTREE;
CREATE INDEX idx_jobs_career_paths_affiliate_id ON jobs_career_paths(affiliate_id) USING BTREE;

-- jobs_rec_qualifications
CREATE INDEX idx_jobs_rec_qualifications_job_id ON jobs_rec_qualifications(job_id) USING BTREE;
CREATE INDEX idx_jobs_rec_qualifications_affiliate_id ON jobs_rec_qualifications(affiliate_id) USING BTREE;

-- jobs_req_qualifications
CREATE INDEX idx_jobs_req_qualifications_job_id ON jobs_req_qualifications(job_id) USING BTREE;
CREATE INDEX idx_jobs_req_qualifications_affiliate_id ON jobs_req_qualifications(affiliate_id) USING BTREE;

-- =====================================================================
-- RELATED TABLES INDEXES
-- =====================================================================

-- personalities
CREATE INDEX idx_personalities_deleted ON personalities(deleted) USING BTREE;

-- practical_skills
CREATE INDEX idx_practical_skills_deleted ON practical_skills(deleted) USING BTREE;

-- basic_abilities
CREATE INDEX idx_basic_abilities_deleted ON basic_abilities(deleted) USING BTREE;

-- affiliates (used by tools, career paths, qualifications)
CREATE INDEX idx_affiliates_deleted ON affiliates(deleted) USING BTREE;
CREATE INDEX idx_affiliates_type ON affiliates(type) USING BTREE;

-- Composite index for affiliates (frequently filtered by type and deleted)
CREATE INDEX idx_affiliates_type_deleted ON affiliates(type, deleted) USING BTREE;

-- =====================================================================
-- FULL-TEXT SEARCH INDEXES (for LIKE optimization)
-- =====================================================================

-- Jobs table full-text indexes
CREATE FULLTEXT INDEX idx_jobs_name_ft ON jobs(name);
CREATE FULLTEXT INDEX idx_jobs_description_ft ON jobs(description);
CREATE FULLTEXT INDEX idx_jobs_detail_ft ON jobs(detail);
CREATE FULLTEXT INDEX idx_jobs_business_skill_ft ON jobs(business_skill);
CREATE FULLTEXT INDEX idx_jobs_knowledge_ft ON jobs(knowledge);

-- Combined full-text index for multiple columns (more efficient for multi-column search)
CREATE FULLTEXT INDEX idx_jobs_search_ft ON jobs(
    name,
    description,
    detail,
    business_skill,
    knowledge,
    location,
    activity
);

-- Job Categories and Types full-text indexes
CREATE FULLTEXT INDEX idx_job_categories_name_ft ON job_categories(name);
CREATE FULLTEXT INDEX idx_job_types_name_ft ON job_types(name);

-- Related tables full-text indexes
CREATE FULLTEXT INDEX idx_personalities_name_ft ON personalities(name);
CREATE FULLTEXT INDEX idx_practical_skills_name_ft ON practical_skills(name);
CREATE FULLTEXT INDEX idx_basic_abilities_name_ft ON basic_abilities(name);
CREATE FULLTEXT INDEX idx_affiliates_name_ft ON affiliates(name);

-- =====================================================================
-- VERIFY INDEXES CREATED
-- =====================================================================
-- Run these queries to verify indexes are created:

-- SHOW INDEX FROM jobs;
-- SHOW INDEX FROM job_categories;
-- SHOW INDEX FROM job_types;
-- SHOW INDEX FROM jobs_personalities;
-- SHOW INDEX FROM personalities;
-- SHOW INDEX FROM affiliates;

-- =====================================================================
-- ANALYZE TABLES (Update statistics for query optimizer)
-- =====================================================================
-- Run after creating indexes to update table statistics

ANALYZE TABLE jobs;
ANALYZE TABLE job_categories;
ANALYZE TABLE job_types;
ANALYZE TABLE jobs_personalities;
ANALYZE TABLE personalities;
ANALYZE TABLE jobs_practical_skills;
ANALYZE TABLE practical_skills;
ANALYZE TABLE jobs_basic_abilities;
ANALYZE TABLE basic_abilities;
ANALYZE TABLE jobs_tools;
ANALYZE TABLE jobs_career_paths;
ANALYZE TABLE jobs_rec_qualifications;
ANALYZE TABLE jobs_req_qualifications;
ANALYZE TABLE affiliates;
