# SQL Performance Improvement Analysis

## Problem Statement
The current SQL query takes approximately 8 seconds to execute. This query searches for jobs related to "キャビンアテンダント" (Cabin Attendant) across multiple tables with many LEFT JOINs.

## Performance Issues Identified

### 1. **Excessive LEFT JOINs (9 joins)**
- Multiple LEFT JOINs to junction tables and related entities
- Each LEFT JOIN potentially creates a Cartesian product
- GROUP BY at the end has to consolidate all duplicated rows

### 2. **Multiple LIKE Searches with Leading Wildcards (%keyword%)**
- 20 different LIKE conditions with leading wildcards
- Leading wildcards prevent index usage
- Full table scans on text columns

### 3. **Missing or Inefficient Indexes**
Likely missing indexes on:
- Foreign key columns (job_id, affiliate_id, personality_id, etc.)
- deleted columns (used in WHERE clauses)
- type columns in affiliates table
- Text columns being searched with LIKE

### 4. **N+1 Query Pattern via JOINs**
- The query tries to fetch everything in one query
- GROUP BY consolidates duplicates but requires sorting all rows first
- Better to use separate queries for related data

### 5. **Selecting Too Many Columns**
- Selecting all columns from Jobs, JobCategories, JobTypes
- More data to transfer and process
- Should select only needed columns

## Recommended Improvements

### Immediate Improvements (Easy Wins)

#### 1. Add Proper Indexes
```sql
-- Foreign key indexes
CREATE INDEX idx_jobs_job_category_id ON jobs(job_category_id);
CREATE INDEX idx_jobs_job_type_id ON jobs(job_type_id);
CREATE INDEX idx_jobs_media_id ON jobs(media_id);
CREATE INDEX idx_jobs_deleted ON jobs(deleted);
CREATE INDEX idx_jobs_publish_status ON jobs(publish_status);

-- Junction table indexes
CREATE INDEX idx_jobs_personalities_job_id ON jobs_personalities(job_id);
CREATE INDEX idx_jobs_personalities_personality_id ON jobs_personalities(personality_id);
CREATE INDEX idx_jobs_practical_skills_job_id ON jobs_practical_skills(job_id);
CREATE INDEX idx_jobs_practical_skills_skill_id ON jobs_practical_skills(practical_skill_id);
CREATE INDEX idx_jobs_basic_abilities_job_id ON jobs_basic_abilities(job_id);
CREATE INDEX idx_jobs_basic_abilities_ability_id ON jobs_basic_abilities(basic_ability_id);
CREATE INDEX idx_jobs_tools_job_id ON jobs_tools(job_id);
CREATE INDEX idx_jobs_tools_affiliate_id ON jobs_tools(affiliate_id);
CREATE INDEX idx_jobs_career_paths_job_id ON jobs_career_paths(job_id);
CREATE INDEX idx_jobs_career_paths_affiliate_id ON jobs_career_paths(affiliate_id);
CREATE INDEX idx_jobs_rec_qualifications_job_id ON jobs_rec_qualifications(job_id);
CREATE INDEX idx_jobs_rec_qualifications_affiliate_id ON jobs_rec_qualifications(affiliate_id);
CREATE INDEX idx_jobs_req_qualifications_job_id ON jobs_req_qualifications(job_id);
CREATE INDEX idx_jobs_req_qualifications_affiliate_id ON jobs_req_qualifications(affiliate_id);

-- Deleted column indexes
CREATE INDEX idx_job_categories_deleted ON job_categories(deleted);
CREATE INDEX idx_job_types_deleted ON job_types(deleted);
CREATE INDEX idx_personalities_deleted ON personalities(deleted);
CREATE INDEX idx_practical_skills_deleted ON practical_skills(deleted);
CREATE INDEX idx_basic_abilities_deleted ON basic_abilities(deleted);
CREATE INDEX idx_affiliates_deleted ON affiliates(deleted);

-- Composite indexes for affiliates table (type + id + deleted)
CREATE INDEX idx_affiliates_type_deleted ON affiliates(type, deleted);

-- Full-text search indexes for better LIKE performance
CREATE FULLTEXT INDEX idx_jobs_name_fulltext ON jobs(name);
CREATE FULLTEXT INDEX idx_jobs_description_fulltext ON jobs(description);
CREATE FULLTEXT INDEX idx_job_categories_name_fulltext ON job_categories(name);
CREATE FULLTEXT INDEX idx_job_types_name_fulltext ON job_types(name);

-- Composite index for sorting
CREATE INDEX idx_jobs_sort_order_id ON jobs(sort_order DESC, id DESC);
```

#### 2. Use FULLTEXT Search Instead of LIKE
```sql
-- Convert LIKE searches to MATCH AGAINST for Japanese text
-- This requires FULLTEXT indexes (created above)

WHERE (
    MATCH(Jobs.name, Jobs.description) AGAINST('キャビンアテンダント' IN NATURAL LANGUAGE MODE)
    OR MATCH(JobCategories.name) AGAINST('キャビンアテンダント' IN NATURAL LANGUAGE MODE)
    OR MATCH(JobTypes.name) AGAINST('キャビンアテンダント' IN NATURAL LANGUAGE MODE)
)
```

### Medium-term Improvements (Query Restructuring)

#### 3. Split Query into Two Phases

**Phase 1: Get matching Job IDs only**
```sql
-- First, get the IDs of matching jobs (much faster)
SELECT DISTINCT Jobs.id
FROM jobs Jobs
INNER JOIN job_categories JobCategories
    ON JobCategories.id = Jobs.job_category_id
    AND JobCategories.deleted IS NULL
INNER JOIN job_types JobTypes
    ON JobTypes.id = Jobs.job_type_id
    AND JobTypes.deleted IS NULL
WHERE (
    JobCategories.name LIKE '%キャビンアテンダント%'
    OR JobTypes.name LIKE '%キャビンアテンダント%'
    OR Jobs.name LIKE '%キャビンアテンダント%'
    OR Jobs.description LIKE '%キャビンアテンダント%'
    OR Jobs.detail LIKE '%キャビンアテンダント%'
    OR Jobs.business_skill LIKE '%キャビンアテンダント%'
    OR Jobs.knowledge LIKE '%キャビンアテンダント%'
    OR Jobs.location LIKE '%キャビンアテンダント%'
    OR Jobs.activity LIKE '%キャビンアテンダント%'
)
AND Jobs.publish_status = 1
AND Jobs.deleted IS NULL
ORDER BY Jobs.sort_order DESC, Jobs.id DESC
LIMIT 50 OFFSET 0;
```

**Phase 2: Get full details for those IDs**
```sql
-- Then get full details only for the matched job IDs
SELECT Jobs.*, JobCategories.*, JobTypes.*
FROM jobs Jobs
INNER JOIN job_categories JobCategories
    ON JobCategories.id = Jobs.job_category_id
INNER JOIN job_types JobTypes
    ON JobTypes.id = Jobs.job_type_id
WHERE Jobs.id IN (/* IDs from Phase 1 */)
ORDER BY Jobs.sort_order DESC, Jobs.id DESC;
```

#### 4. Remove Unnecessary LEFT JOINs
The original query joins many tables but only searches in some of them. Remove joins that aren't needed for the WHERE clause or SELECT clause:

```sql
-- Only join tables that are actually used in WHERE or SELECT
-- Move related data fetching to separate queries
```

### Long-term Improvements (Architecture)

#### 5. Add Search-Optimized Tables
```sql
-- Create a denormalized search table
CREATE TABLE jobs_search_index (
    job_id INT PRIMARY KEY,
    searchable_text TEXT,
    publish_status TINYINT,
    deleted DATETIME,
    sort_order INT,
    FULLTEXT INDEX idx_searchable_text (searchable_text),
    INDEX idx_publish_status (publish_status),
    INDEX idx_sort_order (sort_order)
);

-- Populate with combined searchable text
INSERT INTO jobs_search_index (job_id, searchable_text, publish_status, deleted, sort_order)
SELECT
    j.id,
    CONCAT_WS(' ',
        j.name, j.description, j.detail, j.business_skill, j.knowledge,
        j.location, j.activity, jc.name, jt.name
    ),
    j.publish_status,
    j.deleted,
    j.sort_order
FROM jobs j
INNER JOIN job_categories jc ON j.job_category_id = jc.id
INNER JOIN job_types jt ON j.job_type_id = jt.id;
```

#### 6. Implement Elasticsearch or Similar
- For complex text searches in production
- Much faster full-text search capabilities
- Better handling of Japanese text
- Can handle complex queries with filters

#### 7. Add Caching Layer
- Cache frequent searches (e.g., Redis)
- Cache for 5-15 minutes depending on update frequency
- Invalidate cache when jobs are modified

## Optimized Query (Immediate Implementation)

```sql
SELECT
    Jobs.id AS `Jobs__id`,
    Jobs.name AS `Jobs__name`,
    Jobs.description AS `Jobs__description`,
    Jobs.location AS `Jobs__location`,
    Jobs.sort_order AS `Jobs__sort_order`,
    Jobs.publish_status AS `Jobs__publish_status`,
    JobCategories.id AS `JobCategories__id`,
    JobCategories.name AS `JobCategories__name`,
    JobTypes.id AS `JobTypes__id`,
    JobTypes.name AS `JobTypes__name`
FROM jobs Jobs
INNER JOIN job_categories JobCategories
    ON (JobCategories.id = Jobs.job_category_id AND JobCategories.deleted IS NULL)
INNER JOIN job_types JobTypes
    ON (JobTypes.id = Jobs.job_type_id AND JobTypes.deleted IS NULL)
WHERE (
    JobCategories.name LIKE '%キャビンアテンダント%'
    OR JobTypes.name LIKE '%キャビンアテンダント%'
    OR Jobs.name LIKE '%キャビンアテンダント%'
    OR Jobs.description LIKE '%キャビンアテンダント%'
    OR Jobs.detail LIKE '%キャビンアテンダント%'
    OR Jobs.business_skill LIKE '%キャビンアテンダント%'
    OR Jobs.knowledge LIKE '%キャビンアテンダント%'
    OR Jobs.location LIKE '%キャビンアテンダント%'
    OR Jobs.activity LIKE '%キャビンアテンダント%'
)
AND Jobs.publish_status = 1
AND Jobs.deleted IS NULL
ORDER BY Jobs.sort_order DESC, Jobs.id DESC
LIMIT 50 OFFSET 0;
```

**Key Changes:**
1. Removed all LEFT JOINs that were only used for searching
2. Only select columns that are needed
3. Removed GROUP BY (no longer needed without multiple joins)
4. Kept only INNER JOINs for JobCategories and JobTypes
5. Rely on proper indexes (must be created first)

**Note:** Related data (personalities, skills, etc.) should be fetched in separate queries using the job IDs returned from this query.

## Expected Performance Improvement

- **With indexes only:** 50-70% reduction (8s → 2-3s)
- **With optimized query + indexes:** 80-90% reduction (8s → 0.5-1s)
- **With FULLTEXT search:** 90-95% reduction (8s → 0.2-0.5s)
- **With search index table:** 95%+ reduction (8s → <0.2s)

## Implementation Priority

1. **Critical (Do First):** Add indexes on foreign keys and deleted columns
2. **High:** Optimize the query to remove unnecessary JOINs
3. **Medium:** Implement FULLTEXT indexes and modify search logic
4. **Low:** Consider architectural changes (search index table, Elasticsearch, caching)

## Monitoring Recommendations

After implementing improvements, use:
```sql
EXPLAIN SELECT ...  -- Check query execution plan
SHOW PROFILE;       -- Analyze query performance
```

Monitor slow query log to identify remaining bottlenecks.
