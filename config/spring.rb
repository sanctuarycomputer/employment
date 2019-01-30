%w[
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
  app/use_cases/**/*
].each { |path| Spring.watch(path) }
