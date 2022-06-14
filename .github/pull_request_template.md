### What 🕵️ 🔍

- What does the pull request solve?
- What exactly was added or modified?

----------

### How to test (please adjust template) 🥼 🔬
- Feature flag enabled:
  Test main feature, and verify that all aspects of the story are working as described in the PR and the Jira story
  - [ ] step №1
  - [ ] step №2

- Feature flag disabled:
  - [ ] Check affected area that still behave as expected without the feature


- Feature affects new Engine/ Card manager / Settings / DB changes / Architecture update
  - Go to Setting, change language :
    - [ ] Verify that the Feed shows articles in the new language
    - [ ] Verify that like/ dislike / bookmark, visually works
    - [ ] Verify that articles show up in bookmarks
    - [ ] Verify search works and articles show up in the new language

- Feature has DB change
  - [ ] Upgrade test from previous version, verify that the app starts and that the affected area works as expected

- Feature affects platform dependent code
  - [ ] Verify feature on iOS
  - [ ] Verify feature on Android

- Feature affects UI changes
  - [ ] Verify on iPhone SE / [Small Android]
  - [ ] (default) Verify on Pro 13 Max / (Big Android)

----------

### Screenshots 📸 📱

| Before | After  |
| ------ | ------ |
| <img width="280" src=""> | <img width="280" src=""> |

----------

### References 📝 🔗

- [JIRA](https://xainag.atlassian.net/browse/TB-XXXX)

----------