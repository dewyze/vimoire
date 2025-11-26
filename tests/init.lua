-- Test harness setup for vimoire
-- Runs all tests in tests/ directory

-- Set up package path to find vimoire code in app/lua/
package.path = package.path .. ";app/lua/?.lua;app/lua/?/init.lua"

-- Run tests
require("plenary.test_harness").test_directory("tests", {
  minimal_init = "tests/minimal_init.lua",
  timeout = 5000,
})
