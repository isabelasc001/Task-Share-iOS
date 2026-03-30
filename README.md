###  Technologies Used
- **Platform & Language:** iOS native application built with Swift 5+.
- **Architecture:** MVC (Model-View-Controller) separating data, UI, and logic clearly.
- **UI Framework:** UIKit used programmatically (no Storyboards) for better scaling and dynamic layout control.
- **Data Persistence:** Core Data (`CoreDataManager`) for offline-first, local database management of lists and tasks.
- **Testing:** XCTest and XCUITest used for automated UI and functional testing.

### Functionalities
- **Dashboard & Navigation:** A `LandingPageViewController` welcoming users, leading to a `HomeViewController` that displays categorized lists (Personal, Work, Health, Study, Other) in a dynamic `UICollectionView`.
- **List & Task Management:** Users can create custom lists with infinite sub-tasks via the `NewListViewController`.
- **Smart Archiving Logic:** Tasks can be checked off. Once all tasks in a list are completed, the list is automatically flagged as `isFullyCompleted` and moved to the `ArchivedViewController` to keep the main dashboard clean.
- **Favorites & Deletion:** Users can favorite important lists or permanently delete them.

### Results
The result is a highly functional, offline-capable iOS productivity app. By using Core Data, it ensures real-time local saving. The programmatic UIKit approach allows for a seamless, scalable, and responsive user experience across different iOS devices, and the auto-archiving psychology helps users focus purely on active tasks while keeping a history of completed work.
