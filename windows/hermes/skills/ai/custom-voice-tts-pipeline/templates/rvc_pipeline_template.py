import os
import sys
import argparse
import asyncio
import edge_tts
import torch
import torch.nn as nn
import torch.nn.functional as F
import soundfile as sf
import numpy as np
import faiss
from scipy import signal
import parselmouth

class TextEncoder768(nn.Module):
    def __init__(self, out_channels, hidden_channels, filter_channels, n_heads, n_layers, kernel_size, p_dropout, f0=True):
        super().__init__()
        # Standard RVC v2 768-dim phone embedding
        self.emb_phone = nn.Linear(768, hidden_channels)

def setup_rvc_path(rvc_root):
    sys.path.insert(0, rvc_root)
    os.environ["PATH"] = rvc_root + os.pathsep + os.environ.get("PATH", "")
