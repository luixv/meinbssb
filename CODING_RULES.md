# Mein BSSB
These are the coding rules:


. Choose a ticket.
. Assign it to you and create a branch. Ideally use the ticket number and a short descritption as the name of your branch. Ideally... :-)
. Implement the ticket.
. While implementing, perform DAILY (or more than daily) an "update from main".
. If the ticket is related to the infrastructure then update the README.
. Test locally.
. Test locally.
. Test locally again.
. Add necessary unit-tests.
. Update the mocks, i.e. run: flutter pub run build_runner build --delete-conflicting-outputs
. Ensure that your branch is warnings free.
. Test the web version (flutter build web).
. Test the phone version. Either use the emulator or create an apk.
. Ensure that you have a "good" code coverage regarding unit-tests 
. Run flutter flutter test .\test\unit --coverage and afterwards open coverage/lcov-report/index.html 
. commit and push your changes.
. Open a Pull request.
. DO NOT MERGE.
. Assign it to somebody else.
. Be happy