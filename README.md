# Firebase Storage / Isolate Issue Sample App

## Set up
1. In `main.dart`, make sure to add your Firebase info on line 119.
2. This repo doesn't have a `GoogleService-info.plist` file, so you'd need to add that as well.

The code is already set up to run an isolate before calling `putFile`. If you want to see `putFile` working without the isolate, commend out line 88 and then kill and reopen the app.