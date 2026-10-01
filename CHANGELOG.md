*3.0.0 (September 30, 2026)*

Maintenance status:

* Enter maintenance mode: the feature set is considered complete and no new features
  are planned. Security fixes may be released when needed. Compatibility with future
  Ruby versions is not guaranteed.

Breaking behavior changes:

* Execute String operation names; previously accepted String names did nothing.
* Reject operation-name objects other than Strings or Symbols with ArgumentError.
* Lowercase Unicode initial capitals in camel_case (über_name becomes überName).
* Transform String-subclass keys instead of skipping them.
* Raise ArgumentError for cycles through collection values instead of SystemStackError.

Fixes and maintenance:

* Recognize valid UTF-16/UTF-32 whitespace during compact_blank cleanup.
* Normalize and partition operations once per call, skip cleanup dispatch on scalars,
  and build hashes directly to reduce traversal time and allocations. See benchmark
  methodology and measured limits in docs/performance.md in the source repository.
* Preserve last-value-wins collisions, combined traversal, and existing leaf sharing.
* Restore coverage instrumentation before library loading and add behavioral regression tests.
* Correct operation descriptions, the ActiveSupport comparison, and the contribution link.
* Package README.md and CHANGELOG.md; omit specs from the runtime package.
* Retain Ruby 3.0 support and test Ruby 3.0–3.4 and 4.0 using their latest patch releases.
* Add isolated package verification and a reproducible runtime/allocation benchmark.

See README migration notes before upgrading.

*2.2.1 (December 25, 2023)*

* Ensure Ruby 3.3 compability
* Stop testing against Ruby < 3.0
* Switch from Rubocop to Standard

*2.2.0 (May 17, 2023)*

* Two new transformations added:
  - compact
  - compact_blank
* Ensure Ruby 3.2 compability
* Ensure Ruby 3.3.0-preview compability
* Rename default branch to `main`

*2.1.0 (March 06, 2022)*

* Three new transformations added:
  - snake_case (thanks, @Finnegan5),
  - camel_case,
  - pascal_case
* Improved error message when called with an unknown transformation name
* Improved documentation
* Ensure Ruby 3.1 compability
* Switch from Travis CI to GitHub Actions

*2.0.0 (December 28, 2020)*

* Ensure Ruby 2.6 compability
* Ensure Ruby 2.7 compability
* Ensure Ruby 3.0 compability
* Drops support for Ruby <= 2.2
* Drops support for Ruby 2.3
* Drops support for Ruby 2.4

*1.0.0 (December 26, 2017)*

* Runs specs against Ruby up to version 2.5
* Drops support for Ruby <= 2.1

*0.1.0 (April 27, 2017)*

* Initial version

*0.1.1 (April 27, 2017)*

* Fix `undefined method 'Array#to_h'` on Ruby '< 2.1'
