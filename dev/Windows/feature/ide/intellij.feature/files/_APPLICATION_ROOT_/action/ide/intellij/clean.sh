find . -type d -name '.idea' -depth 1 -exec rm -rf {} +
find . -type f -name '*.iml' -exec rm -f {} +
