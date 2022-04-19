#  Story: Customer requests to feed

'''
As a user I want my feed to load automatically at application startup
'''

#### Scenarios:

 Customer has connectivity
 When customer requests feed items
 Load feed items from remote and display on screen
 And replace cache with new feed (or save to cache if no cache yet available)
 
 Customer doesn't have connectivity
 And cache is available
 When customer requests feed items
 Show cached feed
 
 Customer doesn't have connectivity
 And cache is empty
 When customer requests feed items
 Show an error message


## Use Cases:

### Load Feed from remote use case:

#### Data:
- URL

#### Primary course (happy path):
1. Execute 'Load Feed Items' with above data (URL)
2. System downloads data with URL.
3. System validates downloaded data.
4. System decodes received data to FeedItem objects.
5. System delivers objects to screen.

#### Invalid data - error course (sad path):
1. System delivers error.

#### No connectivity - error course (sad path):
1. System delivers error.

#### Request failed - error course (sad path):
1. System delivers error.


### Load Feed Fallback (Cache) use case:

#### Data:
- Max. cache age - 7 days old.

#### Primary couse (happy path):
1. Execute 'Load Feed Items' with provided data.
2. System validates for cache age.
3. System fetches data from cache.
4. System creates Feed Items from cache.
5. System delivers objects to screen.

#### No cache - error course (sad path):
1. System delivers error.

#### Max. age expired - error course (sad path):
1. System deletes cache.
2. System delivers error.

#### Load cache failed - error course (sad path):
1. System delivers error.


### Save Feed items (Cache) use case:

#### Data:
- Feed items

#### Primary course (happy path):
1. Execute 'Save Feed Items' with provided data.
2. System encodes feed items.
3. System timestampts the new cache.
4. System renames old cache to name_tmp.
5. System saves new cache.
6. System deletes old cache.
7. System delivers success message.

#### Encoding failed - error course (sad path):
1. System delivers error.

#### Rename failed - error course (sad path):
1. System delivers error.

#### Save failed - error course (sad path):
1. System delivers error.

#### Delete failed - error course (sad path):
1. System delivers error.
