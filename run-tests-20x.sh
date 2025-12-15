#!/bin/bash

echo "🧪 Running 20 iterations of repository tests..."
echo "=============================================="
echo ""

FAILED_ITERATIONS=0
PASSED_ITERATIONS=0

for i in {1..20}; do
    echo "Running iteration $i/20..."
    if ./test-repository.sh $i > /dev/null 2>&1; then
        echo "✅ Iteration $i: PASSED"
        PASSED_ITERATIONS=$((PASSED_ITERATIONS + 1))
    else
        echo "❌ Iteration $i: FAILED"
        FAILED_ITERATIONS=$((FAILED_ITERATIONS + 1))
    fi
done

echo ""
echo "=============================================="
echo "📊 Final Results:"
echo "=============================================="
echo "Total iterations: 20"
echo "Passed: $PASSED_ITERATIONS"
echo "Failed: $FAILED_ITERATIONS"
echo ""
echo "Detailed logs: /home/ubuntu/test-results/"
echo "=============================================="

if [ $FAILED_ITERATIONS -eq 0 ]; then
    echo "✅ All 20 iterations passed!"
    exit 0
else
    echo "❌ $FAILED_ITERATIONS iteration(s) failed"
    exit 1
fi
