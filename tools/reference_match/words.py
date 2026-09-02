from __future__ import annotations

BANNED_SUBSTRINGS = (
    "ghost",
    "spirit",
    "demon",
    "dead",
    "death",
    "die",
    "kill",
    "help me",
    "get out",
    "leave now",
    "heaven",
    "hell",
    "satan",
    "angel",
    "haunt",
    "murder",
)

WORD_POOL = (
    "table", "window", "yellow", "rain", "walk", "kitchen", "cold", "open",
    "street", "seven", "paper", "blue", "wait", "garden", "bread", "quiet",
    "monday", "water", "chair", "north", "green", "door", "jacket", "river",
    "cloud", "pencil", "orange", "floor", "button", "market", "silver", "road",
    "apple", "later", "number", "brown", "shelf", "clock", "cotton", "bridge",
    "coffee", "twelve", "pocket", "metal", "circle", "winter", "bottle", "key",
    "yellowed", "corner", "plain", "after", "before", "under", "over", "left",
    "right", "middle", "empty", "full", "small", "large", "near", "far",
    "today", "always", "maybe", "never", "often", "slowly", "quickly", "hold",
    "carry", "bring", "leave", "stay", "turn", "move", "stand", "sit",
    "listen", "look", "ask", "tell", "read", "write", "count", "measure",
    "house", "room", "yard", "porch", "basement", "hallway", "cabinet", "drawer",
    "blanket", "pillow", "mirror", "lamp", "switch", "outlet", "hammer", "nail",
    "copper", "plastic", "wooden", "glass", "stone", "gravel", "muddy", "dry",
    "warm", "cooler", "windy", "foggy", "sunny", "cloudy", "evening", "morning",
)


def is_allowed_word(word: str) -> bool:
    token = word.strip().lower()
    if not token or " " in token:
        return False
    return not any(banned in token for banned in BANNED_SUBSTRINGS)
