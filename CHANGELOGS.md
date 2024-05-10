## Changelogs

### 10/5/24

- Almost fully styled discover page
- Added loading indicator to load new posts in profile page
- Added discover post thumbail template

### 7/5/24

- Fully stylised home page and profile page along with addition of supporting components
- Added 'Common' class to quickly access commonly used attributes
- Changed status bar colour to transparent
- Changed discover page from maps discovery to post discovery

### 4/5/24
- Ignored tap event for the navbar button subtitle
- Added an option to remove the drag indicator; Fixed a bug where the popup will get dismissed when scrolling up fastly

### 3/5/24
- Fixed a bug where the container can't be minimised when the inner List View's scroll position is not at 0

### 30/4/24
- Changed widget structure and drag detector logic to fix the conflict between ListView scrolling gesture and container drag detector gesture. This custom component is now an almost 1:1 recreation of Instagram's comment section popup and its behaviour
- Fully stylised the popup container
- Added the ability to close the popup when clicking outside of it
- Added opened fragments history tracking for popup container animation purposes when switching between home page and profile page
- Added controller classes for certain fragments and custom widgets to allow accessing child methods
- Added very bold font for the Lato family
- Re-added the Maps API key that got accidentally deleted when fixing gradle stuff

### 28/4/24
- Changed settings.gradle and some other gradle configs to fix build errors. No more red annoying kotlin error texts
- Added slide up pop-up screen for many uses in the future (comments showing up, switch from home to profile page, etc.)

### 26/4/24
- Merge remote-tracking branch 'origin/main' into dev/feature/home-screen