# TLDR demo

[TLDR](https://github.com/tendersearls/tldr) is a testing framework by me ([@searls](https://github.com/searls)) and Aaron Patterson ([@tenderlove](https://github.com/tenderlove)).

This is a dead simple, git-clonable example repo designed to show different ways you can execute tests with TLDR.

Here's a rundown of all the files in this repo:

```sh
$ tree -v
.
├── Gemfile # installs tldr, standard, and rake
├── Gemfile.lock # bundler lockfile
├── README.md # you're reading it
├── Rakefile # sets up the default task to run tests, then standard
├── lib # load path automatically looked up by `tldr`
│   ├── calculator.rb # public-facing API
│   └── calculator
│       ├── adder.rb # internal dependency
│       └── subtractor.rb # internal dependency
└── test
    ├── calculator_test.rb # test of public API
    ├── calculator
    │   ├── adder_test.rb # test of internal dependency
    │   └── subtractor_test.rb # test of internal dependency
    └── helper.rb # auto-loaded by tldr, requires lib/calculator.rb
```

## Basic usage

If you want to run the tests, just clone the repo, `cd` into its directory, then run these commands to install the dependencies (`bundle`) and run the tests (`tldr`):

```sh
bundle
bin/tldr
```

And you should see some output like this:

```sh
Command: bin/tldr --prepend "test/calculator/subtractor_test.rb"
--seed 2369

Running:

......

Finished in 3ms.

3 test classes, 6 test methods, 0 failures, 0 errors, 0 skips
```

## Running with Rake

You can also take a look at the [Rakefile](/Rakefile) and see how that's configured before running it yourself:

```sh
bundle exec rake
```

Which should produce approximately the same output.

Listing all the defined tasks with `rake -T`, you'll see that TLDR just exposes a single `tldr` task:

```sh
rake standard               # Lint with the Standard Ruby style guide
rake standard:fix           # Lint and automatically make safe fixes with the Standard Ruby style guide
rake standard:fix_unsafely  # Lint and automatically make fixes (even unsafe ones) with the Standard Ruby style guide
rake tldr                   # Run tldr tests (use TLDR_OPTS or .tldr.yml to configure)
```

If you run `bundle exec rake tldr`, it will be largely equivalent to `bin/tldr`, with the added complication that any command line args you want to set should be

## Running tests continuously

If you have [fswatch](https://github.com/emcrisostomo/fswatch) installed, you can try out running tests continuously with the `--watch` flag:

```
bin/tldr --watch
```

And then try changing some code and tests.

## Running specific tests

TLDR offers several ways to run specific tests.

### Selecting tests by path

Run only the `calculator_test.rb` by constraining TLDR's search path from everything under `test/` to just one file:

```
bin/tldr test/calculator_test.rb
```

### Selecting tests by name

You can also select tests by name. Some examples:

```
# run both test methods named 'test_add'
bin/tldr --name test_add

# Same, but using the '-n' shorthand
bin/tldr -n test_add

# Use a regex pattern to select any test method whose name contains 'add' or 'subtract'
bin/tldr -n /add/ -n /subtract/

# Run only the 'CalculatorTest' class's 'test_add' method
bin/tldr -n CalculatorTest#test_add

# Run any tests under 'CalculatorTest' with a regex pattern
bin/tldr -n /CalculatorTest#/

# Run multiple name searches separated by commas
bin/tldr -n test_add,/subtract/
```

### Selecting by line number

Similar to the RSpec and Rails test runners, you can select which test(s) to run by appending line numbers to paths, like this:

```
bin/tldr test/calculator/adder_test.rb:11
```

Even though line 11 is in the middle of a method, so long as a test method covers line 11, that test will run.

You can also specify multiple lines. This should run two tests:

```
bin/tldr test/calculator_test.rb:9:16
```

## Failing fast

If your test suite is going to fail, you want to fail as fast as possible so you can get back to work ASAP.

Run this failing test to see what failure output normally looks like:

```
bin/tldr test/oops_all_failures.rb
```

You can tell TLDR to abort the run as soon as it encounters the `--fail-fast` flag. It's hard to demo here, though, because TLDR runs tests in parallel by default, and all 3 failing tests will likely finish before we're able to abort, so let's add `--no-parallel`, as well:

```
bin/tldr test/oops_all_failures.rb --fail-fast --no-parallel
```

Whenever a test fails, its failure output will include a command to re-run it, like this:

```
1) OopsAllFailures#test_assert_false_fail [test/oops_all_failures.rb:11] failed:
Expected false to be truthy

  Re-run this test:
    bundle exec tldr "test/oops_all_failures.rb:10"
```

But when `--fail-fast` is enabled, the reporter will also generate a command you can copy-paste to run any tests that didn't finish due to the aborted run (as well as a couple extra lines you can optionally copy to select any that failed as well):

```
Run the 2 tests that didn't finish:
  bundle exec tldr --fail-fast --no-parallel "test/oops_all_failures.rb:2:6" \
    --comment "Also include 1 test that failed:" \
    "test/oops_all_failures.rb:10"
```

## Aborting slow suites with a timeout

This repo's tests are plenty fast for TLDR's default 1.8 second timeout, so if we set the flag we won't notice a difference in output:

```
bin/tldr --timeout
```

You could set the timeout to 10ms and still probably not fail:

```
bin/tldr --timeout .01
```

To force an error, we can disable parallelization and run some intentionally slow tests in sequence:

```
bin/tldr --timeout --no-parallel test/*_slow.rb
```

That should fail (set the timeout to something shorter if it doesn't) and produce a long message like this:

```
Running:

..!

==================== ABORTED RUN ====================

too long; didn't run!

Completed 2 of 3 tests (67%) before running out of time.

1 test was cancelled in progress:
  397ms - KindaSlow#test_kinda_slow [test/kinda_slow.rb:2]

Your 2 slowest completed tests:
  802ms - QuiteSlow#test_pretty_slow [test/quite_slow.rb:2]
  605ms - PrettySlow#test_pretty_slow [test/pretty_slow.rb:2]

Run the 1 test that didn't finish:
  bundle exec tldr --timeout --no-parallel --prepend "test/quite_slow.rb" "test/kinda_slow.rb:2"


Suppress this summary with --yes-i-know

==================== ABORTED RUN ====================

Finished in 1807ms.

2 test classes, 2 test methods, 0 failures, 0 errors, 0 skips
```

Of the tests that finished, you'll see the slowest ones listed so you target those ones for optimization. It'll also give you a command to run the tests that failed to complete.

This message can be handy, but if you're working with a suite that you _know_ will always blow past the timeout, you can squelch all those messages by tacking on `--yes-i-know`, like this:

```
bin/tldr --timeout --no-parallel --yes-i-know test/*_slow.rb
```
