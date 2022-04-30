# Custom Unit Test

- It's not easy to do `widget test` or `integration test` especially the app has full of backend access through restful api or socket connection.
  - The standard of flutter test requires `mock data` to test the logic but, still it is not an easy task to do.
  - So, we developped a custom test for `unit test`, `widget test` and `integration test`. But it's not part of fireflutter.

- `UnitTest` helper class does some basic scaffolding to test screen and access the input and submit.
  - You can test the fireflutter widgets like post creation form or comment creation form.

- For error test, the test must catch the exception with try/catch, so it will not to break the code flow by the exception.
- For success test, the test must success, so you don't need to do try/catch since there won't be any exception thrown.

