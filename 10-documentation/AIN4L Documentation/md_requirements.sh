#!/bin/bash

sudo apt install -y build-essential cmake ninja-build
pip install --upgrade pip setuptools wheel
pip install llama-cpp-python
pip install -U huggingface_hub

hf download Qwen/Qwen2.5-3B-Instruct-GGUF --include "qwen2.5-3b-instruct-q4_k_m.gguf" --local-dir ./models
