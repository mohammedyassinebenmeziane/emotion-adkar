"""
Utility functions for parsing and formatting Islamic content
"""
import re

def parse_ayah(ayah_full: str) -> dict:
    """
    Parse a full ayah string into text and reference.
    
    Example input: "﴿إِنَّ اللَّهَ مَعَ الصَّابِرِينَ﴾ [البقرة: 153]"
    Returns: {
        "text": "إِنَّ اللَّهَ مَعَ الصَّابِرِينَ",
        "reference": "البقرة: 153"
    }
    """
    if not ayah_full:
        return {"text": None, "reference": None}
    
    # Pattern to match: ﴿...﴾ [reference]
    # The ayah text is between ﴿ and ﴾
    # The reference is between [ and ]
    
    # Extract text between ﴿ and ﴾
    text_match = re.search(r'﴿(.+?)﴾', ayah_full)
    ayah_text = text_match.group(1).strip() if text_match else None
    
    # Extract reference between [ and ]
    ref_match = re.search(r'\[(.+?)\]', ayah_full)
    ayah_reference = ref_match.group(1).strip() if ref_match else None
    
    return {
        "text": ayah_text,
        "reference": ayah_reference
    }
