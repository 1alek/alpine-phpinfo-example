#!/bin/bash

echo -n "Test #1 (Check index)    : "
curl --noproxy "*" -X GET http://localhost:${WEBPORT}/ 2>&1 | grep -q 'PHP Version' && echo "[OK]" || exit 1

exit 0
