#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test_helpers.sh"

source_path="$1"
output_path="$2"
cxx="$3"

require_pattern "${source_path}" 'std::unique_ptr[[:space:]]*<' 'std::unique_ptr usage'
require_pattern "${source_path}" 'std::make_unique[[:space:]]*<' 'std::make_unique usage'
compile_source "${source_path}" "${output_path}" "${cxx}"
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test_helpers.sh"

source_path="$1"
output_path="$2"
cxx="$3"

require_pattern "${source_path}" 'std::shared_ptr[[:space:]]*<' 'std::shared_ptr usage'
require_pattern "${source_path}" 'std::make_shared[[:space:]]*<' 'std::make_shared usage'
compile_source "${source_path}" "${output_path}" "${cxx}"
