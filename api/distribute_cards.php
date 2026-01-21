<?php
header('Content-Type: application/json; charset=UTF-8');
error_reporting(E_ALL);
ini_set('display_errors', 0);

/**
 * Main card distribution function
 *
 * @param int $numberOfPeople Number of people to distribute cards to
 * @return array Result array with success status and data/error message
 */
function distributeCards($numberOfPeople) {
    try {
        // Validate input
        if ($numberOfPeople === null || $numberOfPeople === '') {
            throw new Exception('Input value does not exist or value is invalid');
        }

        // Check if input is numeric
        if (!is_numeric($numberOfPeople)) {
            throw new Exception('Input value does not exist or value is invalid');
        }

        // Convert to integer
        $numberOfPeople = intval($numberOfPeople);

        // Validate: any number less than 0 is invalid (0 is also invalid as per requirement 5d)
        if ($numberOfPeople <= 0) {
            throw new Exception('Input value does not exist or value is invalid');
        }

        // Create deck of 52 cards
        $deck = createDeck();

        // Shuffle the deck randomly
        shuffle($deck);

        // Distribute cards to people
        $distribution = array_fill(0, $numberOfPeople, []);

        // Deal cards one by one to each person (round-robin style)
        foreach ($deck as $index => $card) {
            $personIndex = $index % $numberOfPeople;
            $distribution[$personIndex][] = $card;
        }

        // Format output
        $output = [];
        foreach ($distribution as $personCards) {
            $output[] = implode(',', $personCards);
        }

        return [
            'success' => true,
            'numberOfPeople' => $numberOfPeople,
            'distribution' => $output
        ];

    } catch (Exception $e) {
        return [
            'success' => false,
            'error' => $e->getMessage()
        ];
    }
}

/**
 * Create a standard 52-card deck
 *
 * Suits: S (Spade), H (Heart), D (Diamond), C (Club)
 * Values: A, 2-9, X (10), J, Q, K
 *
 * @return array Array of card strings in format "SUIT-VALUE"
 */
function createDeck() {
    $suits = ['S', 'H', 'D', 'C'];
    $values = ['A', '2', '3', '4', '5', '6', '7', '8', '9', 'X', 'J', 'Q', 'K'];

    $deck = [];

    // Generate all 52 cards (4 suits × 13 values)
    foreach ($suits as $suit) {
        foreach ($values as $value) {
            $deck[] = $suit . '-' . $value;
        }
    }

    return $deck;
}

/**
 * Get input parameter from GET or POST request
 *
 * @param string $key Parameter name
 * @return mixed Parameter value or null if not found
 */
function getInputParameter($key) {
    // Check POST first, then GET
    if (isset($_POST[$key]) && $_POST[$key] !== '') {
        return $_POST[$key];
    } elseif (isset($_GET[$key]) && $_GET[$key] !== '') {
        return $_GET[$key];
    }
    return null;
}

// Main execution
try {
    // Get number of people from request
    $numberOfPeople = getInputParameter('people');

    // Distribute cards
    $result = distributeCards($numberOfPeople);

    // Return JSON response
    echo json_encode($result, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);

} catch (Exception $e) {
    // Handle any unexpected errors
    echo json_encode([
        'success' => false,
        'error' => 'Irregularity occurred'
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit(1);
}
