# API - Card Distribution Backend

## File

- **distribute_cards.php** - RESTful API endpoint for distributing cards

## Usage

### Via Browser
```
http://localhost:8080/api/distribute_cards.php?people=3
```

### Via Command Line
```bash
curl "http://localhost:8080/api/distribute_cards.php?people=3"
```

## API Endpoint

**URL:** `/api/distribute_cards.php`

**Method:** GET or POST

**Parameters:**
- `people` (required) - Number of people (must be > 0)

## Response Format

**Success:**
```json
{
  "success": true,
  "numberOfPeople": 3,
  "distribution": [
    "S-A,H-2,D-3,...",
    "S-K,H-Q,D-J,...",
    "S-2,H-3,D-4,..."
  ]
}
```

**Error:**
```json
{
  "success": false,
  "error": "Input value does not exist or value is invalid"
}
```

## Input Validation

- ✅ Must be greater than 0
- ✅ Null/empty values rejected
- ✅ Non-numeric values rejected
- ✅ Values > 53 accepted (distributes to more people)

## Card Format

- **Suits:** S=Spade, H=Heart, D=Diamond, C=Club
- **Values:** A, 2-9, X(10), J, Q, K
- **Format:** `SUIT-VALUE` (e.g., `S-A`, `H-X`)

## Technical Details

- **Language:** PHP 7.4+
- **Encoding:** UTF-8
- **Line Endings:** LF
- **Error Handling:** Try-catch with proper error messages
- **Algorithm:** Shuffle deck and distribute round-robin
