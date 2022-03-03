# hello-world

## Dependencies

Maven does [not support](https://stackoverflow.com/a/54580971) a concept of a
lock file, which is unfortunate considering transitive dependencies can change
from underneath us. This makes builds non-reproducible, a dire situation in the
land of nix. To at least move partially in that direction, we use the
[dependency-lock](https://github.com/vandmo/dependency-lock-maven-plugin)
plugin.

This allows us to generate a lock file by running:

```bash
mvn se.vandmo:dependency-lock-maven-plugin:create-lock-file
```

and, upon hitting the `validate` phase during the maven build, automatically
verify no dependencies had changed. To perform this check without performing a
full build, either run up to the `validate` phase or invoke the plugin task
directly:

```bash
mvn validate
mvn dependency-lock:check
```

When encountering a change in a transitive dependency, it is recommended that
you add a new [dependencyManagement](https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html#Dependency_Management)
to keep the transitive dependency pinned, as opposed to simply rebuilding and
updating SHAs. Once pinned, we can update the SHA safely and know the resulting
JAR should be identical to before.

## Updating

Check for any newer plugins by running

```bash
mvn versions:display-plugin-updates
```

## Formatting

A `pre-commit` file is included in `.githooks` to ensure consistent formatting.
Run the following to configure `git` to using it:

```bash
git config --local core.hooksPath .githooks/
```
