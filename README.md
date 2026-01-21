# Tyrell Test Program - Playing Card Distribution System

Complete solution for Tyrell programming test:
- **Part A:** Playing card distribution (PHP + JavaScript)
- **Part B:** SQL query optimization

---

## 🚀 Quick Start

```bash
cd /Users/mandy.lam/Downloads/tyrell
docker-compose up -d
open http://localhost:8080
```

---

## 📁 Project Structure

```
tyrell/
├── README.md                    # This file
├── index.html                   # Interactive frontend
├── api/
│   ├── README.md               # API documentation
│   └── distribute_cards.php    # Backend API
├── sql/
│   ├── README.md               # SQL documentation
│   ├── SQL_IMPROVEMENT_ANALYSIS.md
│   ├── indexes.sql
│   └── optimized_query.sql
├── Dockerfile
└── docker-compose.yml
```

---

## Part A: Card Distribution

### Features
- Interactive UI with real-time statistics
- Visual cards with suit symbols (♠ ♥ ♦ ♣)
- RESTful API
- Full input validation

### Usage

**Web Interface:**
```
http://localhost:8080
```

**API:**
```bash
curl "http://localhost:8080/api/distribute_cards.php?people=3"
```

**Documentation:** See [api/README.md](api/README.md)

---

## Part B: SQL Optimization

### Problem
Original query: ~8 seconds

### Solution
- 42 performance indexes
- Reduced JOINs (9 → 2)
- Removed GROUP BY
- Expected: <1 second (87% faster)

**Documentation:** See [sql/README.md](sql/README.md)

---

## 🛠️ Docker Commands

```bash
docker-compose up -d      # Start
docker-compose down       # Stop
docker-compose logs -f    # View logs
docker-compose restart    # Restart
```

**Services:**
- Web: http://localhost:8080 (PHP 7.4)
- MySQL: localhost:3306 (root/root_password)

---

## 🧪 Testing

### PHP Application
```bash
# Valid
curl "http://localhost:8080/api/distribute_cards.php?people=3"

# Invalid (should error)
curl "http://localhost:8080/api/distribute_cards.php?people=0"
```

---

## 🎯 Technologies

1. PHP 7.4 - Backend
2. JavaScript - Frontend
3. HTML/CSS - UI
4. MySQL 8.0 - Database
5. Docker - Containerization

---

## ✅ Requirements Met

- ✅ PHP + JavaScript (multiple languages)
- ✅ UTF-8 encoding, LF line endings
- ✅ Input validation
- ✅ Docker environment
- ✅ Code comments
- ✅ Error handling
- ✅ SQL optimization
- ✅ GitHub ready

---

## 📋 Time Investment

**Total:** 4.7 hours

| Task | Time |
|------|------|
| Requirements | 15 min |
| PHP backend | 45 min |
| Frontend | 60 min |
| Docker | 20 min |
| SQL optimization | 90 min |
| Documentation | 40 min |
| Testing | 20 min |


## 📄 License

Submitted for Tyrell programming test.
**Reproduction/Reprint prohibited.**

---

## Quick Reference

```bash
# Start application
docker-compose up -d

# Test API
curl "http://localhost:8080/api/distribute_cards.php?people=3"

# Stop
docker-compose down
```

**Visit:** http://localhost:8080 🎴
