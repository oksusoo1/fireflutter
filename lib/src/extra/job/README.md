# Job

Job functionality using FireFlutter


# Overview

- We put the `job` as an extra feature because it is not a general functionality that most apps requires.
- And we put `job` data on different firestore collection since it needs a lot more indexes than post.
  - `Forum` functioanlity of fireflutter is a good function to extends many extra feature. But we simply separate the job function from forum function to make it simple.

# Conditions and rules

- A user can create only one job opening. So if the user needs more than one job opening, he can create another account.
- Creating job opening deducts user's point. To update the amount of pint, refer `Job.pointDeductionForCreation` in job class.



# Administration

- Admin must create `jobOpenings` and `jobSeekers` categories and group them as `job`.


# Job Notification

- User can set notification based on the combination of search option.
  - For instance, User A wants to subscribe notification if there is a new job opening on IT in Gyungi-do, dong-hae city.
    - And A can subscribe as much notification as he wants.

- Job notification should not appear on user's notification settings since it will be available on job search screen with search combinations.





