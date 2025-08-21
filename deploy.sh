#!/bin/bash
# deploy.sh - Push ke Hugging Face Spaces

echo "🔍 Menyiapkan deploy ke Hugging Face..."

git add .
echo "📝 Masukkan pesan commit:"
read commit_msg
git commit -m "$commit_msg"

echo "🚀 Push ke Hugging Face..."
git push https://huggingface.co/spaces/yudarahma/sisfocloud main

echo "✅ Berhasil deploy!"
