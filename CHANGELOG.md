*unreleased*

* Ensure Ruby 3.5 compability
* Ensure Ruby 3.4 compability
* Stop testing against Ruby 3.0

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
