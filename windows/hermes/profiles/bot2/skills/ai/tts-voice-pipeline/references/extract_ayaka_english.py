"""
Filter simon3000/genshin-voice dataset for Kamisato Ayaka's English lines.
Uses exact feature names: speaker="Kamisato Ayaka", language="English(US)"
"""

import pandas as pd
import os

def count_ayaka_english_in_parquet(filepath):
    """Count Ayaka English lines in a single parquet file."""
    df = pd.read_parquet(filepath)
    ayaka_en = df[
        (df['speaker'].str.strip() == 'Kamisato Ayaka') & 
        (df['language'].str.strip() == 'English(US)')
    ]
    return len(ayaka_en), ayaka_en

def extract_ayaka_english(parquet_dir, output_dir):
    """Extract Ayaka English lines from all parquet files in a directory."""
    os.makedirs(output_dir, exist_ok=True)
    
    parquet_files = [f for f in os.listdir(parquet_dir) if f.endswith('.parquet')]
    total_count = 0
    
    for pf in parquet_files:
        filepath = os.path.join(parquet_dir, pf)
        count, ayaka_df = count_ayaka_english_in_parquet(filepath)
        total_count += count
        
        if count > 0:
            # Save filtered dataframe
            output_path = os.path.join(output_dir, f'ayaka_english_{pf}')
            ayaka_df.to_parquet(output_path)
            print(f"{pf}: {count} lines -> saved to {output_path}")
    
    print(f"\nTotal Ayaka English lines: {total_count}")
    return total_count

# Usage
# extract_ayaka_english('path/to/genshin_voice/data', 'path/to/output')
