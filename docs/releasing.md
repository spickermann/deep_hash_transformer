# Release procedure

## Prepare locally

1. Review the intended API changes and migration notes. Verify the version is not
   already published on RubyGems.org. Set the version in `lib/deep_hash_transformer/version.rb`.
2. Run `bundle exec rake` on the supported Ruby series. CI also runs isolated
   package verification for every series. Record any versions not tested locally.
3. Run `ruby script/benchmark.rb > results.json`; use the same Ruby, inputs and
   settings for comparisons. See [performance](performance.md).
4. Finish README and Changelog, including the intended release date for review.
   Run `ruby script/verify_package.rb` against the final source.
5. Review the generated `pkg/deep_hash_transformer-VERSION.gem`, its SHA-256,
   contents, dependencies, compatibility results, and migration notes.
6. Check the GitHub account's write permission and RubyGems credentials without
   exposing secrets. A local key or an index API response alone does not prove
   that the key has the `push_rubygem` scope. MFA may be required at publication.
7. Obtain explicit approval for the version and external actions before tagging,
   pushing, publishing on RubyGems.org, or creating a GitHub Release.

## Publish only after release approval

The existing `bundler/gem_tasks` process is `bundle exec rake release`. It builds
into `pkg/`, requires committed tracked changes, creates `vVERSION`, pushes the
current branch and tag to the remote, and uploads the gem. It does not run tests
or create a GitHub Release. The gemspec restricts publishing to
`https://rubygems.org`.

Review and commit all intended source and documentation changes first, including
new files; the task's clean-tree check does not replace review of untracked files.
Confirm the remote and branch before running the release task. For this project
the intended remote is `origin` at `spickermann/deep_hash_transformer`, normally
on `main`. Never force-push as part of releasing.

A failed task can have already pushed the branch/tag. Inspect remote state before
retrying. Do not delete published versions or rewrite a release tag to repair a
partial release. If the source or package must change after publication, release
a new version.

Create a GitHub Release only if that action was separately included in the release
approval; use the reviewed Changelog and migration notes as its description.

## Verify publication

Check RubyGems.org's version-specific metadata: version, authors, license,
required Ruby, runtime dependencies, links and package checksum. Download and
install that exact registry version into a fresh isolated gem directory and run
the smoke tests against the installed files, outside the checkout. Confirm the
Git tag points to the reviewed release commit and provide the release URL.

If authentication or MFA blocks publication, report the completed actions and the
specific remaining authorization step; never report success from a local build.
